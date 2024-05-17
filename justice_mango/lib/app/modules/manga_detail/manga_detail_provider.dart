import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:justice_mango/app/data/model/chapter_info.dart';
import 'package:justice_mango/app/data/model/manga_meta_combine.dart';
import 'package:justice_mango/app/modules/home/tab/favorite/favorite_provider.dart';
import 'package:justice_mango/app/modules/home/tab/recent/recent_provider.dart';

import '../../data/model/recent_read.dart';
import '../../data/service/hive_service.dart';

class MangaDetailStateData {
  final MangaMetaCombine metaCombine;
  final bool isFavorite;
  final bool isExceptional;
  final List<ChapterInfo> chaptersInfo;
  final List<bool> readArray;

  const MangaDetailStateData({
    required this.metaCombine,
    this.isFavorite = false,
    this.isExceptional = false,
    this.chaptersInfo = const <ChapterInfo>[],
    this.readArray = const <bool>[],
  });

  MangaDetailStateData copyWith({
    MangaMetaCombine? metaCombine,
    bool? isFavorite,
    bool? isExceptional,
    List<ChapterInfo>? chaptersInfo,
    List<bool>? readArray,
  }) {
    return MangaDetailStateData(
      metaCombine: metaCombine ?? this.metaCombine,
      isFavorite: isFavorite ?? this.isFavorite,
      isExceptional: isExceptional ?? this.isExceptional,
      chaptersInfo: chaptersInfo ?? this.chaptersInfo,
      readArray: readArray ?? this.readArray,
    );
  }
}

class MangaDetailStateNotifier extends StateNotifier<MangaDetailStateData> {
  Ref ref;

  MangaDetailStateNotifier(this.ref, MangaMetaCombine metaCombine)
      : super(MangaDetailStateData(metaCombine: metaCombine)) {
    init();
  }

  init() {
    List<ChapterInfo> chaptersInfo = [];
    List<bool> readArray = [];
    MangaMetaCombine metaCombine = state.metaCombine;

    metaCombine.repo.updateLastReadInfo(mangaMeta: metaCombine.mangaMeta).then((value) {
      chaptersInfo.addAll(value);
      for (var chapter in chaptersInfo) {
        readArray.add(metaCombine.repo.isRead(chapter.preChapterId));
      }
    });
    state = state.copyWith(
      metaCombine: metaCombine,
      isFavorite: metaCombine.repo.isFavorite(metaCombine.mangaMeta.preId),
      isExceptional: metaCombine.repo.isExceptionalFavorite(metaCombine.mangaMeta.preId),
      chaptersInfo: chaptersInfo,
      readArray: readArray,
    );
  }

  setIsRead(int index) async {
    await state.metaCombine.repo.markAsRead(state.chaptersInfo[index].preChapterId, state.chaptersInfo[index]);
    await state.metaCombine.repo.updateLastReadIndex(
      preId: state.metaCombine.mangaMeta.preId,
      readIndex: index,
    );
    List<bool> readArray = state.readArray;
    readArray[index] = true;
    // mục đích delay: để hiển thị đã đọc không xuất hiện trước khi vào màn đọc [ux]
    await Future.delayed(const Duration(seconds: 1));
    // update();
    if (index == 0) {
      state.metaCombine.repo.updateLastReadInfo(
        mangaMeta: state.metaCombine.mangaMeta,
        updateStatus: true,
      );
    }
  }

  addToFavoriteBox() async {
    await state.metaCombine.repo.putMangaMetaFavorite(state.metaCombine.mangaMeta);
    state = state.copyWith(isFavorite: true);

    ref.read(favoriteProvider.notifier).refreshUpdate();
  }

  markAsExceptionalFavorite() async {
    await state.metaCombine.repo.markAsExceptionalFavorite(state.metaCombine.mangaMeta.preId);
    state = state.copyWith(isExceptional: true);
  }

  removeAsExceptionalFavorite() async {
    await state.metaCombine.repo.removeExceptionalFavorite(state.metaCombine.mangaMeta.preId);
    state = state.copyWith(isExceptional: false);
  }

  removeFromFavoriteBox() async {
    await state.metaCombine.repo.removeFavorite(state.metaCombine.mangaMeta.preId);
    state = state.copyWith(isFavorite: false);

    ref.read(favoriteProvider.notifier).refreshUpdate();
  }

  addToRecentRead() async {
    List<RecentRead> recentList = HiveService.getRecentReadBox();
    RecentRead recentRead = RecentRead(state.metaCombine.mangaMeta, DateTime.now());
    if (recentList.length > 30) {
      recentList.removeAt(0);
    }
    if (recentList.contains(recentRead)) {
      recentList.remove(recentRead);
    }
    recentList.add(recentRead);
    await HiveService.putToRecentReadBox(recentList);

    ref.read(recentProvider.notifier).renewRecent();
  }
}

final mangaDetailProvider =
    StateNotifierProvider.family<MangaDetailStateNotifier, MangaDetailStateData, MangaMetaCombine>(
        (ref, metaCombine) => MangaDetailStateNotifier(ref, metaCombine));
