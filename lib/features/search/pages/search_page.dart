import 'package:Reflections/core/constants/app_constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:Reflections/core/theme/app_colors.dart';
import 'package:Reflections/core/theme/app_font_manager.dart';
import 'package:Reflections/core/providers/note_provider.dart';
import 'package:Reflections/core/providers/search_provider.dart';
import 'package:Reflections/shared/widgets/note_card.dart';
import 'package:Reflections/core/utils/app_navigator.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final _textController = TextEditingController();

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  void _onClear(SearchProvider searchProvider) {
    _textController.clear();
    searchProvider.clear();
  }

  @override
  Widget build(BuildContext context) {
    final searchProvider = context.watch<SearchProvider>();
    final noteProvider = context.watch<NoteProvider>();

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
                  TextField(
                    controller: _textController,
                    onChanged: (val) => searchProvider.search(val, noteProvider.notes),
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
                        size: 20.sp,
                      ),
                      suffixIcon: searchProvider.query.isNotEmpty
                          ? GestureDetector(
                              onTap: () => _onClear(searchProvider),
                              child: Icon(
                                Icons.close_rounded,
                                color: AppColors.textHint,
                                size: 18.sp,
                              ),
                            )
                          : null,
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
              child: Builder(builder: (context) {
                if (!searchProvider.hasSearched) {
                  return _SearchIdleState();
                }
                if (searchProvider.results.isEmpty) {
                  return _NoResultsState(query: searchProvider.query);
                }
                return ListView.builder(
                  physics: const BouncingScrollPhysics(),
                  padding: EdgeInsets.only(
                    left: 20.w,
                    right: 20.w,
                    top: 8.h,
                    bottom: 100.h, // Space for frosted floating bottom nav!
                  ),
                  itemCount: searchProvider.results.length,
                  itemBuilder: (context, index) {
                    final note = searchProvider.results[index];
                    return NoteCard(
                      note: note,
                      onTap: () => AppNavigator.goToAddNote(note: note),
                    );
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
            width: 72.w,
            height: 72.h,
            decoration: const BoxDecoration(
              color: AppColors.primarySurface,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.search_rounded,
              color: AppColors.primaryXLight,
              size: 32.sp,
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
                size: 32.sp,
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
