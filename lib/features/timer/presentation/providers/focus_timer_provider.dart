import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

@pragma('vm:entry-point')
void timerNotificationTapBackground(NotificationResponse details) async {
  final action = details.actionId; // 'pause', 'resume', 'stop'
  if (action == null) return;

  final prefs = await SharedPreferences.getInstance();
  final mode = prefs.getString('timer_mode') ?? 'Focus';

  if (action == 'pause') {
    final targetTimeStr = prefs.getString('timer_target_time');
    if (targetTimeStr != null) {
      final targetTime = DateTime.parse(targetTimeStr);
      final remaining = targetTime.difference(DateTime.now()).inSeconds;
      final secondsLeft = remaining > 0 ? remaining : 0;

      await prefs.setBool('timer_is_running', false);
      await prefs.setInt('timer_seconds_left', secondsLeft);

      await _updateNotificationStatic(
        id: 888,
        title: '$mode Timer Paused',
        body: 'Paused at ${_formatTimeStatic(secondsLeft)}',
        secondsLeft: secondsLeft,
        isRunning: false,
        mode: mode,
      );
    }
  } else if (action == 'resume') {
    final secondsLeft = prefs.getInt('timer_seconds_left') ?? (25 * 60);
    final targetTime = DateTime.now().add(Duration(seconds: secondsLeft));

    await prefs.setBool('timer_is_running', true);
    await prefs.setString('timer_target_time', targetTime.toIso8601String());

    await _updateNotificationStatic(
      id: 888,
      title: '$mode Timer Active',
      body: 'Focusing...',
      secondsLeft: secondsLeft,
      isRunning: true,
      mode: mode,
      targetTime: targetTime,
    );
  } else if (action == 'stop') {
    final totalSeconds = prefs.getInt('timer_total_seconds') ?? (25 * 60);
    await prefs.setBool('timer_is_running', false);
    await prefs.setInt('timer_seconds_left', totalSeconds);

    final notificationsPlugin = FlutterLocalNotificationsPlugin();
    await notificationsPlugin.cancel(id: 888);
  }
}

String _formatTimeStatic(int totalSeconds) {
  final minutes = (totalSeconds ~/ 60).toString().padLeft(2, '0');
  final seconds = (totalSeconds % 60).toString().padLeft(2, '0');
  return '$minutes:$seconds';
}

Future<void> _updateNotificationStatic({
  required int id,
  required String title,
  required String body,
  required int secondsLeft,
  required bool isRunning,
  required String mode,
  DateTime? targetTime,
}) async {
  final notificationsPlugin = FlutterLocalNotificationsPlugin();

  final androidDetails = AndroidNotificationDetails(
    'focus_timer_channel',
    'Focus Timer',
    channelDescription: 'Persistent active focus timer controls',
    importance: Importance.defaultImportance,
    priority: Priority.defaultPriority,
    onlyAlertOnce: true,
    ongoing: isRunning,
    showWhen: isRunning,
    usesChronometer: isRunning,
    chronometerCountDown: isRunning,
    when: targetTime?.millisecondsSinceEpoch,
    icon: 'ic_notification',
    largeIcon: const DrawableResourceAndroidBitmap('launcher_icon'),
    styleInformation: const MediaStyleInformation(),
    actions: [
      AndroidNotificationAction(
        isRunning ? 'pause' : 'resume',
        isRunning ? 'Pause' : 'Resume',
      ),
      const AndroidNotificationAction(
        'stop',
        'Stop',
      ),
    ],
  );

  const iosDetails = DarwinNotificationDetails(
    presentAlert: true,
    presentBadge: false,
    presentSound: false,
    categoryIdentifier: 'focus_timer_category',
  );

  await notificationsPlugin.show(
    id: id,
    title: title,
    body: body,
    notificationDetails: NotificationDetails(android: androidDetails, iOS: iosDetails),
  );
}

class FocusTimerProvider extends ChangeNotifier {
  static FocusTimerProvider? activeInstance;

  Timer? _timer;
  int _totalSeconds = 25 * 60;
  int _secondsLeft = 25 * 60;
  bool _isRunning = false;
  String _mode = 'Focus'; // Focus, Short Break, Long Break
  bool _isSoundEnabled = true;
  late final AudioPlayer _audioPlayer;

  int get totalSeconds => _totalSeconds;
  int get secondsLeft => _secondsLeft;
  bool get isRunning => _isRunning;
  String get mode => _mode;
  bool get isSoundEnabled => _isSoundEnabled;

  double get progress {
    if (_totalSeconds == 0) return 0.0;
    return (_totalSeconds - _secondsLeft) / _totalSeconds;
  }

  FocusTimerProvider() {
    activeInstance = this;
    _audioPlayer = AudioPlayer();
    _audioPlayer.setReleaseMode(ReleaseMode.stop);
    loadStateFromPrefs();
  }

  void toggleSound() {
    _isSoundEnabled = !_isSoundEnabled;
    _saveStateToPrefs();
    notifyListeners();
  }

  Future<void> loadStateFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    _isSoundEnabled = prefs.getBool('timer_sound_enabled') ?? true;
    _mode = prefs.getString('timer_mode') ?? 'Focus';
    _totalSeconds = prefs.getInt('timer_total_seconds') ?? (25 * 60);

    final bool running = prefs.getBool('timer_is_running') ?? false;
    if (running) {
      final targetTimeStr = prefs.getString('timer_target_time');
      if (targetTimeStr != null) {
        final targetTime = DateTime.parse(targetTimeStr);
        final remaining = targetTime.difference(DateTime.now()).inSeconds;
        if (remaining > 0) {
          _secondsLeft = remaining;
          _isRunning = true;
          _startForegroundTimer();
        } else {
          _secondsLeft = 0;
          _isRunning = false;
          _timer?.cancel();
          _onTimerFinished();
        }
      }
    } else {
      _secondsLeft = prefs.getInt('timer_seconds_left') ?? _totalSeconds;
      _isRunning = false;
      _timer?.cancel();
    }
    notifyListeners();
  }

  Future<void> _saveStateToPrefs({DateTime? targetTime}) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('timer_is_running', _isRunning);
    await prefs.setInt('timer_seconds_left', _secondsLeft);
    await prefs.setInt('timer_total_seconds', _totalSeconds);
    await prefs.setString('timer_mode', _mode);
    await prefs.setBool('timer_sound_enabled', _isSoundEnabled);
    if (targetTime != null) {
      await prefs.setString('timer_target_time', targetTime.toIso8601String());
    } else if (!_isRunning) {
      await prefs.remove('timer_target_time');
    }
  }

  void startTimer() {
    if (_isRunning) return;
    HapticFeedback.lightImpact();
    _isRunning = true;
    
    final targetTime = DateTime.now().add(Duration(seconds: _secondsLeft));
    _saveStateToPrefs(targetTime: targetTime);

    _startForegroundTimer();
    _updateSystemNotification(targetTime: targetTime);
    notifyListeners();
  }

  void _startForegroundTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_secondsLeft > 0) {
        _secondsLeft--;
        _playTick();
        _saveStateToPrefs();
        notifyListeners();
      } else {
        _timer?.cancel();
        _isRunning = false;
        _saveStateToPrefs();
        _onTimerFinished();
        notifyListeners();
      }
    });
  }

  void pauseTimer() {
    if (!_isRunning) return;
    HapticFeedback.lightImpact();
    _timer?.cancel();
    _isRunning = false;
    _saveStateToPrefs();
    _updateSystemNotification();
    notifyListeners();
  }

  void resetTimer() {
    HapticFeedback.mediumImpact();
    _timer?.cancel();
    _isRunning = false;
    _secondsLeft = _totalSeconds;
    _saveStateToPrefs();
    FlutterLocalNotificationsPlugin().cancel(id: 888);
    notifyListeners();
  }

  void adjustTime(int deltaSeconds) {
    if (_isRunning) return;
    final newSeconds = _secondsLeft + deltaSeconds;
    if (newSeconds > 0 && newSeconds <= 120 * 60) {
      _secondsLeft = newSeconds;
      _totalSeconds = newSeconds;
      _saveStateToPrefs();
      notifyListeners();
    }
  }

  void setMode(String newMode, int durationMinutes) {
    HapticFeedback.lightImpact();
    _timer?.cancel();
    _isRunning = false;
    _mode = newMode;
    _totalSeconds = durationMinutes * 60;
    _secondsLeft = _totalSeconds;
    _saveStateToPrefs();
    FlutterLocalNotificationsPlugin().cancel(id: 888);
    notifyListeners();
  }

  void _playTick() async {
    if (_isSoundEnabled) {
      try {
        await _audioPlayer.stop();
        await _audioPlayer.play(AssetSource('sounds/tick.mp3'));
      } catch (e) {
        debugPrint('Error playing tick: $e');
      }
    }
    HapticFeedback.lightImpact();
  }

  void _onTimerFinished() async {
    FlutterLocalNotificationsPlugin().cancel(id: 888);

    if (_isSoundEnabled) {
      try {
        await _audioPlayer.stop();
        await _audioPlayer.play(AssetSource('sounds/success.mp3'));
      } catch (e) {
        debugPrint('Error playing success: $e');
      }
    }

    for (int i = 0; i < 3; i++) {
      await Future.delayed(const Duration(milliseconds: 300));
      HapticFeedback.vibrate();
    }
  }

  void _updateSystemNotification({DateTime? targetTime}) {
    _updateNotificationStatic(
      id: 888,
      title: _isRunning ? '$_mode Timer Active' : '$_mode Timer Paused',
      body: _isRunning ? 'Focusing...' : 'Paused at ${_formatTimeStatic(_secondsLeft)}',
      secondsLeft: _secondsLeft,
      isRunning: _isRunning,
      mode: _mode,
      targetTime: targetTime,
    );
  }

  @override
  void dispose() {
    if (activeInstance == this) {
      activeInstance = null;
    }
    _timer?.cancel();
    _audioPlayer.dispose();
    super.dispose();
  }
}
