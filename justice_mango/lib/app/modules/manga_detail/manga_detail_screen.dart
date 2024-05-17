import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:go_router/go_router.dart';
import 'package:justice_mango/app/data/model/manga_meta_combine.dart';
import 'package:justice_mango/app/gwidget/chapter_card.dart';
import 'package:justice_mango/app/gwidget/manga_frame.dart';
import 'package:justice_mango/app/gwidget/tag.dart';
import 'package:justice_mango/app/modules/manga_detail/manga_detail_provider.dart';
import 'package:justice_mango/app/modules/reader/reader_screen.dart';
import 'package:justice_mango/app/theme/color_theme.dart';
import 'package:justice_mango/app/util/layout_constants.dart';

import '../reader/reader_screen_args.dart';

class MangaDetailScreen extends ConsumerStatefulWidget {
  static const String routeName = "/manga_detail";
  final MangaMetaCombine metaCombine;

  const MangaDetailScreen({Key? key, required this.metaCombine}) : super(key: key);

  @override
  MangaDetailScreenState createState() => MangaDetailScreenState();
}

class MangaDetailScreenState extends ConsumerState<MangaDetailScreen> {
  late final MangaDetailStateNotifier mangaDetailNotifier;

  @override
  void initState() {
    super.initState();
    mangaDetailNotifier = ref.read(mangaDetailProvider(widget.metaCombine).notifier);
  }

  @override
  void dispose() {
    // Get.delete(tag: widget.metaCombine.mangaMeta.preId);
    super.dispose();
  }

  goToLastReadChapter(state) {
    GoRouter.of(context).go(
      ReaderScreen.routeName,
      extra: ReaderScreenArgs(
        chaptersInfo: state.chaptersInfo,
        index: state.metaCombine.repo.getLastReadIndex(state.metaCombine.mangaMeta.preId) ?? 0,
        metaCombine: state.metaCombine,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final mangaDetailState = ref.watch(mangaDetailProvider(widget.metaCombine));
    return Scaffold(
      floatingActionButton: _fab(mangaDetailState),
      body: CustomScrollView(
        slivers: [
          _buildSliverAppBar(mangaDetailState),
          _buildDescription(mangaDetailState),
          SliverList(
            delegate: SliverChildListDelegate(
              mangaDetailState.chaptersInfo.isEmpty
                  ? [
                      const Padding(
                        padding: EdgeInsets.all(24.0),
                        child: Center(
                          child: CircularProgressIndicator(),
                        ),
                      )
                    ]
                  : List.generate(
                      mangaDetailState.chaptersInfo.length,
                      (index) {
                        return ChapterCard(
                          chaptersInfo: mangaDetailState.chaptersInfo,
                          index: index,
                          metaCombine: mangaDetailState.metaCombine,
                          isRead: mangaDetailState.readArray[index],
                        );
                      },
                    ),
            ),
          ),
          const SliverPadding(padding: EdgeInsets.all(24)),
        ],
      ),
    );
  }

  SliverToBoxAdapter _buildDescription(state) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            state.metaCombine.mangaMeta.alias?.isNotEmpty ?? false
                ? Padding(
                    padding: const EdgeInsets.only(bottom: 8.0),
                    child: Text(
                        "${"alias:".tr()} ${state.metaCombine.mangaMeta.alias.toString().replaceAll("[", "").replaceAll("]", "")}"),
                  )
                : Container(),
            Text(
              state.metaCombine.mangaMeta.description,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(
              height: 10,
            ),
            Text(
              state.metaCombine.mangaMeta.status,
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const SizedBox(
              height: 10,
            ),
            Tags(
              tags: state.metaCombine.mangaMeta.tags,
            ),
          ],
        ),
      ),
    );
  }

  SliverAppBar _buildSliverAppBar(state) {
    return SliverAppBar(
      floating: true,
      title: Text(
        state.metaCombine.mangaMeta.title,
        style: const TextStyle(
          color: Colors.black54,
        ),
      ),
      backgroundColor: Colors.white,
      iconTheme: IconTheme.of(context).copyWith(
        color: Colors.black54,
      ),
      expandedHeight: 40 * 6.5,
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          decoration: BoxDecoration(
            image: DecorationImage(
              image: NetworkImage(state.metaCombine.mangaMeta.imgUrl),
              fit: BoxFit.cover,
            ),
          ),
          child: Container(
            decoration: LayoutConstants.backcardMangaBoxDecoration,
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Row(
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  MangaFrame(
                    imageUrl: state.metaCombine.mangaMeta.imgUrl,
                    height: 40 * 4.5,
                  ),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Text(
                            state.metaCombine.mangaMeta.title,
                            style: Theme.of(context).textTheme.titleLarge,
                            textAlign: TextAlign.center,
                          ),
                          Text(
                            state.metaCombine.mangaMeta.author,
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _fab(state) {
    return SpeedDial(
      animatedIcon: AnimatedIcons.menu_close,
      animatedIconTheme: const IconThemeData(size: 22),
      backgroundColor: mainColorSecondary,
      foregroundColor: Colors.white,
      visible: true,
      curve: Curves.bounceIn,
      children: [
        SpeedDialChild(
          child: const Icon(
            Icons.play_arrow_rounded,
            color: Colors.white,
          ),
          backgroundColor: state.chaptersInfo.isEmpty ? notWhite : mainColorSecondary,
          onTap: state.chaptersInfo.isEmpty
              ? () {}
              : () {
                  mangaDetailNotifier.addToRecentRead();
                  goToLastReadChapter(state);
                },
          label: 'readNow'.tr(),
          labelStyle: const TextStyle(
            fontWeight: FontWeight.w500,
            color: Colors.white,
            fontSize: 16.0,
          ),
          labelBackgroundColor: mainColorSecondary,
        ),
        SpeedDialChild(
          child: state.isFavorite
              ? const Icon(
                  Icons.library_add_check,
                  color: Colors.pink,
                )
              : const Icon(
                  Icons.favorite,
                  color: Colors.white,
                ),
          backgroundColor: mainColorSecondary,
          onTap: () async {
            if (state.isFavorite) {
              await mangaDetailNotifier.removeFromFavoriteBox();
            } else {
              await mangaDetailNotifier.addToFavoriteBox();
            }
          },
          label: state.isFavorite ? 'favorite!'.tr() : 'markFavorite'.tr(),
          labelStyle: const TextStyle(
            fontWeight: FontWeight.w500,
            color: Colors.white,
            fontSize: 16.0,
          ),
          labelBackgroundColor: mainColorSecondary,
        ),
        if (state.isFavorite)
          SpeedDialChild(
            child: state.isExceptional
                ? const Icon(
                    Icons.notifications_active_rounded,
                    color: Colors.white,
                  )
                : const Icon(
                    Icons.notifications_off_rounded,
                    color: Colors.white,
                  ),
            backgroundColor: mainColorSecondary,
            onTap: () async {
              if (state.isExceptional) {
                await state.removeAsExceptionalFavorite();
              } else {
                await state.markAsExceptionalFavorite();
              }
            },
            label: state.isExceptional ? 'turnOnNotification'.tr() : 'turnOffNotification'.tr(),
            labelStyle: const TextStyle(
              fontWeight: FontWeight.w500,
              color: Colors.white,
              fontSize: 16.0,
            ),
            labelBackgroundColor: mainColorSecondary,
          ),
      ],
    );
  }
}
