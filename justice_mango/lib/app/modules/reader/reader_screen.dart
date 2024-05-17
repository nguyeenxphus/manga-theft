import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:justice_mango/app/modules/reader/reader_provider.dart';
import 'package:justice_mango/app/modules/reader/reader_screen_args.dart';
import 'package:justice_mango/app/modules/reader/widget/manga_image.dart';
import 'package:justice_mango/app/util/layout_constants.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

class ReaderScreen extends ConsumerStatefulWidget {
  static const String routeName = "/reader";
  final ReaderScreenArgs readerScreenArgs;

  const ReaderScreen({Key? key, required this.readerScreenArgs}) : super(key: key);

  @override
  ReaderScreenState createState() => ReaderScreenState();
}

class ReaderScreenState extends ConsumerState<ReaderScreen> {
  // String tag = randomAlpha(3);
  late final ReaderStateNotifier readerNotifier;
  final RefreshController refreshController = RefreshController(initialRefresh: false);

  @override
  void initState() {
    super.initState();
    readerNotifier = ref.read(readerProvider(widget.readerScreenArgs.metaCombine).notifier);
    // Get.put(
    //   ReaderController(
    //     chaptersInfo: widget.readerScreenArgs.chaptersInfo,
    //     index: widget.readerScreenArgs.index,
    //     metaCombine: widget.readerScreenArgs.metaCombine,
    //     preloadUrl: widget.readerScreenArgs.preloadUrl ?? [],
    //   ),
    //   tag: tag,
    // );
  }

  @override
  void dispose() {
    super.dispose();
    refreshController.dispose();
  }

  onLoading() {
    if (widget.readerScreenArgs.index - 1 >= 0) {
      GoRouter.of(context).pushReplacement(
        ReaderScreen.routeName,
        extra: ReaderScreenArgs(
          chaptersInfo: widget.readerScreenArgs.chaptersInfo,
          index: widget.readerScreenArgs.index - 1,
          metaCombine: widget.readerScreenArgs.metaCombine,
          preloadUrl: widget.readerScreenArgs.preloadUrl,
        ),
      );
      refreshController.loadComplete();
    } else {
      refreshController.loadFailed();
    }
  }

  onRefresh() {
    if (widget.readerScreenArgs.index + 1 < widget.readerScreenArgs.chaptersInfo.length) {
      readerNotifier.toPrevChapter();
      refreshController.refreshCompleted();
    } else {
      refreshController.refreshFailed();
    }
  }

  @override
  Widget build(BuildContext context) {
    final readerState = ref.watch(readerProvider(widget.readerScreenArgs.metaCombine));
    return Scaffold(
      body: RefreshConfiguration(
        maxUnderScrollExtent: 70,
        footerTriggerDistance: -70,
        child: SmartRefresher(
          controller: refreshController,
          enablePullUp: true,
          enablePullDown: true,
          footer: ClassicFooter(
            idleText: 'idleLoadingNextChapter'.tr(),
            canLoadingText: 'canLoadingNextChapter'.tr(),
            loadingText: 'loadingNextChapter'.tr(),
            failedText: 'failedNextChapter'.tr(),
          ),
          header: ClassicHeader(
            idleText: 'idleLoadingPrevChapter'.tr(),
            failedText: 'failedPrevChapter'.tr(),
            refreshingText: 'loadingPrevChapter'.tr(),
            releaseText: 'releasePrevChapter'.tr(),
            completeText: 'completeText'.tr(),
          ),
          onLoading: onLoading,
          onRefresh: onRefresh,
          child: CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              _buildSliverAppBar(readerState),
              readerState.loading
                  ? const SliverToBoxAdapter(
                      child: Padding(
                        padding: EdgeInsets.all(48.0),
                        child: Center(
                          child: SizedBox(
                            width: 48,
                            height: 48,
                            child: CircularProgressIndicator(),
                          ),
                        ),
                      ),
                    )
                  : SliverList(
                      delegate: SliverChildListDelegate(
                        readerState.hasError
                            ? [
                                Center(
                                  child: Padding(
                                    padding: const EdgeInsets.all(24),
                                    child: ElevatedButton(
                                      onPressed: () {
                                        readerNotifier.getPages();
                                      },
                                      child: Text('reload'.tr()),
                                    ),
                                  ),
                                )
                              ]
                            : [
                                Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: List.generate(
                                    readerState.imgUrls.length,
                                    (index) => MangaImage(
                                      imageUrl: readerState.imgUrls[index],
                                      repo: readerState.metaCombine.repo,
                                    ),
                                  ),
                                ),
                              ],
                        addRepaintBoundaries: false,
                      ),
                    ),
              SliverList(
                delegate: SliverChildListDelegate(
                  List.generate(
                    1,
                    (index) => Container(
                      padding: const EdgeInsets.symmetric(vertical: 24),
                      child: const Text(
                        "🦉 🦉 🦉 🦉 🦉",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 30,
                        ),
                      ),
                    ),
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  _buildSliverAppBar(readerState) {
    return SliverAppBar(
      floating: true,
      title: Text(
        readerState.chaptersInfo[readerState.index].name,
        style: const TextStyle(
          color: Colors.black54,
        ),
      ),
      backgroundColor: Colors.white,
      iconTheme: IconTheme.of(context).copyWith(color: Colors.black54),
      expandedHeight: 150,
      flexibleSpace: FlexibleSpaceBar(
        centerTitle: false,
        background: Container(
          decoration: BoxDecoration(
            image: DecorationImage(
              image: NetworkImage(readerState.metaCombine.mangaMeta.imgUrl),
              fit: BoxFit.cover,
            ),
          ),
          child: Container(
            decoration: LayoutConstants.backcardMangaBoxDecoration,
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.end,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    readerState.metaCombine.mangaMeta.title,
                    style: Theme.of(context).textTheme.bodyLarge,
                    maxLines: 1,
                  ),
                  Text(
                    "#${(readerState.chaptersInfo.length - readerState.index).toString()} / ${readerState.chaptersInfo.length}",
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
