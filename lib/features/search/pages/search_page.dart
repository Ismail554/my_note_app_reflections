import 'package:Reflections/core/constants/app_constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:Reflections/core/theme/app_colors.dart';
import 'package:Reflections/core/theme/app_font_manager.dart';
import 'package:Reflections/features/search/presentation/controller/search_controller.dart'
    as sc;
import 'package:Reflections/shared/widgets/note_card.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final _textController = TextEditingController();
  late final sc.SearchController _controller;

  @override
  void initState() {
    super.initState();
    _controller = Get.put(sc.SearchController());
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  void _onClear() {
    _textController.clear();
    _controller.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ─── Header ──────────────────────────────────────────────────
            Padding(
              padding: EdgeInsets.fromLTRB(20.w, 20.h, 20.w, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Search', style: AppFontManager.displayMedium),
                  AppSpacing.h4,
                  Text(
                    'Find notes by title or content.',
                    style: AppFontManager.bodySmall,
                  ),
                  AppSpacing.h20,

                  // ─── Search Field ──────────────────────────────────────
                  Obx(
                    () => TextField(
                      controller: _textController,
                      onChanged: _controller.search,
                      style: AppFontManager.bodyMedium.copyWith(
                        color: AppColors.textPrimary,
                      ),
                      decoration: InputDecoration(
                        hintText: 'Search your thoughts...',
                        hintStyle: AppFontManager.bodyMedium.copyWith(
                          color: AppColors.textHint,
                        ),
                        prefixIcon: Icon(
                          Icons.search_rounded,
                          color: AppColors.primaryMedium,
                          size: 20.r,
                        ),
                        suffixIcon: _controller.query.value.isNotEmpty
                            ? GestureDetector(
                                onTap: _onClear,
                                child: Icon(
                                  Icons.close_rounded,
                                  color: AppColors.textHint,
                                  size: 18.r,
                                ),
                              )
                            : null,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            AppSpacing.h20,
            Divider(
              height: 1,
              color: AppColors.divider,
              indent: 20.w,
              endIndent: 20.w,
            ),
            AppSpacing.h8,

            // ─── Results ─────────────────────────────────────────────────
            Expanded(
              child: Obx(() {
                if (!_controller.hasSearched.value) {
                  return _SearchIdleState();
                }
                if (_controller.results.isEmpty) {
                  return _NoResultsState(query: _controller.query.value);
                }
                return ListView.builder(
                  physics: const BouncingScrollPhysics(),
                  padding: EdgeInsets.symmetric(
                    horizontal: 20.w,
                    vertical: 8.h,
                  ),
                  itemCount: _controller.results.length,
                  itemBuilder: (context, index) {
                    return NoteCard(note: _controller.results[index]);
                  },
                );
              }),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Idle State ────────────────────────────────────────────────────────────
class _SearchIdleState extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 72.r,
            height: 72.r,
            decoration: const BoxDecoration(
              color: AppColors.primarySurface,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.search_rounded,
              color: AppColors.primaryXLight,
              size: 32.r,
            ),
          ),
          AppSpacing.h16,
          Text(
            'Start typing to search\nyour reflections.',
            textAlign: TextAlign.center,
            style: AppFontManager.bodyMedium,
          ),
        ],
      ),
    );
  }
}

// ─── No Results State ──────────────────────────────────────────────────────
class _NoResultsState extends StatelessWidget {
  final String query;
  const _NoResultsState({required this.query});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(32.r),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 72.w,
              height: 72.h,
              decoration: const BoxDecoration(
                color: AppColors.primarySurface,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.search_off_rounded,
                color: AppColors.primaryXLight,
                size: 32.r,
              ),
            ),
            AppSpacing.h16,
            Text(
              'No results for "$query"',
              textAlign: TextAlign.center,
              style: AppFontManager.headlineMedium.copyWith(fontSize: 16.sp),
            ),
            AppSpacing.h8,
            Text(
              'Try different keywords or\ncheck the spelling.',
              textAlign: TextAlign.center,
              style: AppFontManager.bodySmall,
            ),
          ],
        ),
      ),
    );
  }
}
