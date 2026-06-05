import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:Reflections/core/theme/app_colors.dart';
import 'package:Reflections/core/theme/app_font_manager.dart';
import 'package:Reflections/features/habit/data/models/habit_model.dart';
import 'package:Reflections/features/habit/state/habit_provider.dart';

class FocusTimerPage extends StatefulWidget {
  final HabitModel? associatedHabit;

  const FocusTimerPage({super.key, this.associatedHabit});

  @override
  State<FocusTimerPage> createState() => _FocusTimerPageState();
}

class _FocusTimerPageState extends State<FocusTimerPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryTextColor = isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary;

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBackground : AppColors.lightBackground,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new_rounded, color: primaryTextColor, size: 20.sp),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          widget.associatedHabit != null 
              ? 'Focus: ${widget.associatedHabit!.name}' 
              : 'Focus Timer',
          style: AppFontManager.headingLarge.copyWith(
            color: primaryTextColor,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: AppColors.accent,
          indicatorWeight: 3.r,
          labelColor: AppColors.accent,
          unselectedLabelColor: isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted,
          labelStyle: AppFontManager.labelMedium.copyWith(fontWeight: FontWeight.bold),
          tabs: const [
            Tab(text: 'POMODORO'),
            Tab(text: 'STOPWATCH'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _PomodoroTab(associatedHabit: widget.associatedHabit),
          const _StopwatchTab(),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
//  POMODORO TAB
// ═══════════════════════════════════════════════════════════════════════════
class _PomodoroTab extends StatefulWidget {
  final HabitModel? associatedHabit;
  const _PomodoroTab({this.associatedHabit});

  @override
  State<_PomodoroTab> createState() => _PomodoroTabState();
}

class _PomodoroTabState extends State<_PomodoroTab> {
  Timer? _timer;
  int _totalSeconds = 25 * 60;
  int _secondsLeft = 25 * 60;
  bool _isRunning = false;
  String _mode = 'Focus'; // Focus, Short Break, Long Break
  late final AudioPlayer _audioPlayer;

  @override
  void initState() {
    super.initState();
    _audioPlayer = AudioPlayer();
  }

  void _startTimer() {
    if (_isRunning) return;
    HapticFeedback.lightImpact();
    setState(() => _isRunning = true);
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_secondsLeft > 0) {
        setState(() {
          _secondsLeft--;
        });
      } else {
        _timer?.cancel();
        setState(() {
          _isRunning = false;
        });
        _onTimerFinished();
      }
    });
  }

  void _pauseTimer() {
    HapticFeedback.lightImpact();
    _timer?.cancel();
    setState(() => _isRunning = false);
  }

  void _resetTimer() {
    HapticFeedback.mediumImpact();
    _timer?.cancel();
    setState(() {
      _isRunning = false;
      _secondsLeft = _totalSeconds;
    });
  }

  void _setPreset(String mode, int minutes) {
    if (_isRunning) return;
    HapticFeedback.selectionClick();
    setState(() {
      _mode = mode;
      _totalSeconds = minutes * 60;
      _secondsLeft = _totalSeconds;
    });
  }

  void _onTimerFinished() async {
    // Play completion success sound
    try {
      await _audioPlayer.stop();
      await _audioPlayer.play(AssetSource('sounds/success.mp3'));
    } catch (e) {
      debugPrint('Error playing success sound: $e');
    }

    // Alarm/vibration feedback sequence for the end of time
    for (int i = 0; i < 3; i++) {
      HapticFeedback.vibrate();
      await Future.delayed(const Duration(milliseconds: 300));
    }
    
    // Celebration sheet / dialogue
    if (!mounted) return;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) {
        final isDark = Theme.of(context).brightness == Brightness.dark;
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24.r)),
          backgroundColor: isDark ? AppColors.darkSurface : AppColors.lightSurface,
          title: Row(
            children: [
              Text('🎉 ', style: TextStyle(fontSize: 24.sp)),
              Text(
                'Focus Accomplished!',
                style: AppFontManager.headingLarge.copyWith(
                  color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          content: Text(
            widget.associatedHabit != null
                ? 'Amazing focus session completed for "${widget.associatedHabit!.name}"! Mark it completed for today?'
                : 'Congratulations! You completed your ${_mode.toLowerCase()} session. Take a moment to celebrate!',
            style: AppFontManager.bodyMedium.copyWith(
              color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text(
                'Later',
                style: AppFontManager.bodyMedium.copyWith(
                  color: isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted,
                ),
              ),
            ),
            if (widget.associatedHabit != null)
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.accent,
                  foregroundColor: AppColors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
                  padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
                ),
                onPressed: () async {
                  final todayStr = DateTime.now().toIso8601String().substring(0, 10);
                  final provider = context.read<HabitProvider>();
                  final navigator = Navigator.of(context);
                  await provider.toggleHabitDay(widget.associatedHabit!, todayStr);
                  if (ctx.mounted) {
                    Navigator.pop(ctx); // Close dialog
                    navigator.pop(); // Go back to tracker
                  }
                },
                child: Text('Complete Habit', style: AppFontManager.buttonSmall),
              )
            else
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.accent,
                  foregroundColor: AppColors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
                  padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
                ),
                onPressed: () => Navigator.pop(ctx),
                child: Text('Done', style: AppFontManager.buttonSmall),
              ),
          ],
        );
      },
    );
  }

  String _formatTime(int seconds) {
    final m = (seconds ~/ 60).toString().padLeft(2, '0');
    final s = (seconds % 60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  @override
  void dispose() {
    _timer?.cancel();
    _audioPlayer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryTextColor = isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary;
    final secondaryTextColor = isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary;

    final progress = _totalSeconds > 0 ? _secondsLeft / _totalSeconds : 1.0;

    return Padding(
      padding: EdgeInsets.all(24.r),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          // ─── Mode Indicator Pills ──────────────────────────────────
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _modeButton('Focus', 25),
              SizedBox(width: 8.w),
              _modeButton('Short Break', 5),
              SizedBox(width: 8.w),
              _modeButton('Long Break', 15),
            ],
          ),

          // ─── Radial Timer progress indicator ────────────────────────
          Stack(
            alignment: Alignment.center,
            children: [
              SizedBox(
                width: 220.r,
                height: 220.r,
                child: CircularProgressIndicator(
                  value: progress,
                  strokeWidth: 10.r,
                  backgroundColor: isDark 
                      ? Colors.white.withValues(alpha: 0.06) 
                      : Colors.black.withValues(alpha: 0.06),
                  valueColor: const AlwaysStoppedAnimation<Color>(AppColors.accent),
                ),
              ),
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    _formatTime(_secondsLeft),
                    style: AppFontManager.displayLarge.copyWith(
                      fontSize: 48.sp,
                      color: primaryTextColor,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    _mode.toUpperCase(),
                    style: AppFontManager.labelMedium.copyWith(
                      color: AppColors.accent,
                      letterSpacing: 1.5,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ],
          ),

          // ─── Timer Custom adjust buttons ──────────────────────────
          if (!_isRunning)
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  onPressed: () {
                    HapticFeedback.lightImpact();
                    setState(() {
                      if (_totalSeconds > 60) {
                        _totalSeconds -= 60;
                        _secondsLeft = _totalSeconds;
                      }
                    });
                  },
                  icon: Icon(Icons.remove_circle_outline_rounded, color: secondaryTextColor, size: 28.sp),
                ),
                Text(
                  '${_totalSeconds ~/ 60} min',
                  style: AppFontManager.headingMedium.copyWith(
                    color: primaryTextColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                IconButton(
                  onPressed: () {
                    HapticFeedback.lightImpact();
                    setState(() {
                      _totalSeconds += 60;
                      _secondsLeft = _totalSeconds;
                    });
                  },
                  icon: Icon(Icons.add_circle_outline_rounded, color: secondaryTextColor, size: 28.sp),
                ),
              ],
            )
          else
            SizedBox(height: 48.h),

          // ─── Controls ──────────────────────────────────────────────
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Reset
              _controlCircleButton(
                icon: Icons.replay_rounded,
                onTap: _resetTimer,
                color: isDark ? AppColors.darkSurfaceVariant : Colors.black.withValues(alpha: 0.05),
                iconColor: primaryTextColor,
              ),
              SizedBox(width: 24.w),
              // Play/Pause
              _controlCircleButton(
                icon: _isRunning ? Icons.pause_rounded : Icons.play_arrow_rounded,
                onTap: _isRunning ? _pauseTimer : _startTimer,
                color: AppColors.accent,
                iconColor: AppColors.white,
                size: 64.r,
                iconSize: 32.sp,
              ),
              SizedBox(width: 24.w),
              // Skip/Next mode (only when running, or shortcut)
              _controlCircleButton(
                icon: Icons.skip_next_rounded,
                onTap: () {
                  HapticFeedback.mediumImpact();
                  if (_mode == 'Focus') {
                    _setPreset('Short Break', 5);
                  } else {
                    _setPreset('Focus', 25);
                  }
                },
                color: isDark ? AppColors.darkSurfaceVariant : Colors.black.withValues(alpha: 0.05),
                iconColor: primaryTextColor,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _modeButton(String title, int minutes) {
    final isSelected = _mode == title;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GestureDetector(
      onTap: () => _setPreset(title, minutes),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 8.h),
        decoration: BoxDecoration(
          color: isSelected 
              ? AppColors.accent.withValues(alpha: 0.12)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(20.r),
          border: Border.all(
            color: isSelected ? AppColors.accent : (isDark ? AppColors.darkDivider : AppColors.lightDivider),
            width: isSelected ? 1.5 : 0.5,
          ),
        ),
        child: Text(
          title,
          style: AppFontManager.bodySmall.copyWith(
            color: isSelected 
                ? AppColors.accent 
                : (isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary),
            fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
          ),
        ),
      ),
    );
  }

  Widget _controlCircleButton({
    required IconData icon,
    required VoidCallback onTap,
    required Color color,
    required Color iconColor,
    double? size,
    double? iconSize,
  }) {
    final finalSize = size ?? 48.r;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: finalSize,
        height: finalSize,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: color,
        ),
        child: Icon(icon, color: iconColor, size: iconSize ?? 22.sp),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
//  STOPWATCH TAB
// ═══════════════════════════════════════════════════════════════════════════
class _StopwatchTab extends StatefulWidget {
  const _StopwatchTab();

  @override
  State<_StopwatchTab> createState() => _StopwatchTabState();
}

class _StopwatchTabState extends State<_StopwatchTab> {
  Timer? _timer;
  int _milliseconds = 0;
  bool _isRunning = false;
  final List<String> _laps = [];
  late final AudioPlayer _audioPlayer;
  int _lastTickedSecond = 0;

  @override
  void initState() {
    super.initState();
    _audioPlayer = AudioPlayer();
    // Configure low latency sound mode if supported by platform
    _audioPlayer.setReleaseMode(ReleaseMode.stop);
  }

  void _startStopwatch() {
    if (_isRunning) return;
    HapticFeedback.lightImpact();
    setState(() => _isRunning = true);
    _timer = Timer.periodic(const Duration(milliseconds: 10), (timer) {
      setState(() {
        _milliseconds += 10;
        final currentSecond = _milliseconds ~/ 1000;
        if (currentSecond > _lastTickedSecond) {
          _lastTickedSecond = currentSecond;
          _playTick();
        }
      });
    });
  }

  void _playTick() async {
    try {
      await _audioPlayer.stop();
      await _audioPlayer.play(AssetSource('sounds/tick.mp3'));
      HapticFeedback.lightImpact();
    } catch (e) {
      debugPrint('Error playing tick: $e');
    }
  }

  void _pauseStopwatch() {
    HapticFeedback.lightImpact();
    _timer?.cancel();
    setState(() => _isRunning = false);
  }

  void _resetStopwatch() {
    HapticFeedback.mediumImpact();
    _timer?.cancel();
    setState(() {
      _isRunning = false;
      _milliseconds = 0;
      _lastTickedSecond = 0;
      _laps.clear();
    });
  }

  void _recordLap() {
    if (!_isRunning) return;
    HapticFeedback.selectionClick();
    setState(() {
      _laps.insert(0, _formatTime(_milliseconds));
    });
  }

  String _formatTime(int totalMs) {
    final hundreds = ((totalMs % 1000) ~/ 10).toString().padLeft(2, '0');
    final seconds = ((totalMs ~/ 1000) % 60).toString().padLeft(2, '0');
    final minutes = (totalMs ~/ 60000).toString().padLeft(2, '0');
    return '$minutes:$seconds.$hundreds';
  }

  @override
  void dispose() {
    _timer?.cancel();
    _audioPlayer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryTextColor = isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary;

    return Padding(
      padding: EdgeInsets.all(24.r),
      child: Column(
        children: [
          SizedBox(height: 24.h),
          // Time Display
          Text(
            _formatTime(_milliseconds),
            style: TextStyle(
              fontSize: 64.sp,
              fontWeight: FontWeight.w700,
              fontFeatures: const [FontFeature.tabularFigures()],
              color: primaryTextColor,
            ),
          ),
          SizedBox(height: 32.h),

          // Laps Header / Area
          Expanded(
            child: _laps.isEmpty
                ? Center(
                    child: Text(
                      'No laps recorded yet.',
                      style: AppFontManager.bodyMedium.copyWith(
                        color: isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted,
                      ),
                    ),
                  )
                : ListView.separated(
                    physics: const BouncingScrollPhysics(),
                    itemCount: _laps.length,
                    separatorBuilder: (_, _) => Divider(color: isDark ? AppColors.darkDivider : AppColors.lightDivider, height: 1),
                    itemBuilder: (ctx, index) {
                      final lapNum = _laps.length - index;
                      return Padding(
                        padding: EdgeInsets.symmetric(vertical: 12.h, horizontal: 16.w),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Lap $lapNum',
                              style: AppFontManager.bodyMedium.copyWith(
                                color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            Text(
                              _laps[index],
                              style: AppFontManager.bodyMedium.copyWith(
                                color: primaryTextColor,
                                fontWeight: FontWeight.bold,
                                fontFeatures: const [FontFeature.tabularFigures()],
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
          ),

          // Buttons Controls
          Padding(
            padding: EdgeInsets.only(bottom: 16.h),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Lap button
                _controlCircleButton(
                  icon: Icons.outlined_flag_rounded,
                  onTap: _recordLap,
                  color: isDark ? AppColors.darkSurfaceVariant : Colors.black.withValues(alpha: 0.05),
                  iconColor: _isRunning ? primaryTextColor : (isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted),
                ),
                SizedBox(width: 24.w),
                // Play / Pause
                _controlCircleButton(
                  icon: _isRunning ? Icons.pause_rounded : Icons.play_arrow_rounded,
                  onTap: _isRunning ? _pauseStopwatch : _startStopwatch,
                  color: AppColors.accent,
                  iconColor: AppColors.white,
                  size: 64.r,
                  iconSize: 32.sp,
                ),
                SizedBox(width: 24.w),
                // Reset
                _controlCircleButton(
                  icon: Icons.replay_rounded,
                  onTap: _resetStopwatch,
                  color: isDark ? AppColors.darkSurfaceVariant : Colors.black.withValues(alpha: 0.05),
                  iconColor: primaryTextColor,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _controlCircleButton({
    required IconData icon,
    required VoidCallback onTap,
    required Color color,
    required Color iconColor,
    double? size,
    double? iconSize,
  }) {
    final finalSize = size ?? 48.r;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: finalSize,
        height: finalSize,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: color,
        ),
        child: Icon(icon, color: iconColor, size: iconSize ?? 22.sp),
      ),
    );
  }
}
