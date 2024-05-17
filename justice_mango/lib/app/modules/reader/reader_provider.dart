import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:justice_mango/app/data/model/chapter_info.dart';
import 'package:justice_mango/app/data/model/manga_meta_combine.dart';
import 'package:justice_mango/app/data/service/cache_service.dart';
import 'package:justice_mango/app/modules/manga_detail/manga_detail_provider.dart';

class ReaderStateData {
  final List<ChapterInfo> chaptersInfo;
  final int index;
  final MangaMetaCombine metaCombine;
  final List<String> preloadUrl;
  final List<String> imgUrls;
  final bool hasError;
  final bool loading;

  const ReaderStateData({
    this.chaptersInfo = const <ChapterInfo>[],
    this.index = 0,
    required this.metaCombine,
    this.preloadUrl = const <String>[],
    this.imgUrls = const <String>[],
    this.hasError = false,
    this.loading = true,
  });

  ReaderStateData copyWith({
    List<ChapterInfo>? chaptersInfo,
    int? index,
    MangaMetaCombine? metaCombine,
    List<String>? imgUrls,
    List<String>? preloadUrl,
    bool? hasError,
    bool? loading,
  }) {
    return ReaderStateData(
      chaptersInfo: chaptersInfo ?? this.chaptersInfo,
      index: index ?? this.index,
      metaCombine: metaCombine ?? this.metaCombine,
      imgUrls: imgUrls ?? this.imgUrls,
      preloadUrl: preloadUrl ?? this.preloadUrl,
      hasError: hasError ?? this.hasError,
      loading: loading ?? this.loading,
    );
  }
}

class ReaderStateNotifier extends StateNotifier<ReaderStateData> {
  Ref ref;

  ReaderStateNotifier(this.ref, MangaMetaCombine metaCombine) : super(ReaderStateData(metaCombine: metaCombine)) {
    init();
  }

  // late RefreshController refreshController;

  void init() {
    // refreshController = RefreshController(initialRefresh: false);
    if (state.preloadUrl.isNotEmpty) {
      state.copyWith(imgUrls: state.preloadUrl);
    } else {
      getPages();
    }
    getPreloadPages();
    // MangaDetailController mangaDetailController =
    //     Get.find(tag: metaCombine.mangaMeta.preId);
    ref.read(mangaDetailProvider(state.metaCombine).notifier).setIsRead(state.index);
  }

  @override
  void dispose() {
    super.dispose();
    // refreshController.dispose();
  }

  void getPages() async {
    //await Future.delayed(Duration(seconds: 2));
    state.copyWith(loading: true);
    try {
      state.copyWith(
        imgUrls: await state.metaCombine.repo.getPages(state.chaptersInfo[state.index].url ?? ''),
        hasError: false,
      );
    } catch (e, stacktrace) {
      if (kDebugMode) {
        print(e);
        print(stacktrace);
      }
      state.copyWith(hasError: true);
    }
    state.copyWith(loading: false);
  }

  void getPreloadPages() async {
    if (state.index - 1 < 0) {
      return;
    }
    await Future.delayed(const Duration(seconds: 5));
    state.metaCombine.repo.getPages(state.chaptersInfo[state.index - 1].url ?? '').then((value) {
      state.copyWith(preloadUrl: value);
      for (var url in state.preloadUrl) {
        CacheService.getImage(url, state.metaCombine.repo);
      }
    });
  }

  // void toNextChapter() async {
  //   if (state.index - 1 >= 0) {
  //     Get.off(
  //       () => ReaderScreen(
  //         readerScreenArgs: ReaderScreenArgs(
  //           chaptersInfo: chaptersInfo,
  //           index: index - 1,
  //           metaCombine: metaCombine,
  //           preloadUrl: preloadUrl,
  //         ),
  //       ),
  //       // Getx prevent duplicate routes by default
  //       preventDuplicates: false,
  //     );
  //     refreshController.loadComplete();
  //   } else {
  //     refreshController.loadFailed();
  //   }
  // }

  void toPrevChapter() async {
    // tối ưu preload url
    state.copyWith(index: state.index + 1);

    if (state.imgUrls.isNotEmpty) {
      state.copyWith(preloadUrl: state.imgUrls, imgUrls: []);
      getPages();
    } else {
      getPages();
      getPreloadPages();
    }
    ref.read(mangaDetailProvider(state.metaCombine).notifier).setIsRead(state.index);
  }
}

final readerProvider = StateNotifierProvider.family<ReaderStateNotifier, ReaderStateData, MangaMetaCombine>(
    (ref, metaCombine) => ReaderStateNotifier(ref, metaCombine));
