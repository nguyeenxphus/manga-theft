import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:justice_mango/app/data/model/chapter_info.dart';
import 'package:justice_mango/app/data/model/manga_meta_combine.dart';
import 'package:justice_mango/app/modules/manga_detail/manga_detail_provider.dart';
import 'package:justice_mango/app/modules/reader/reader_screen.dart';
import 'package:justice_mango/app/modules/reader/reader_screen_args.dart';

class ChapterCard extends ConsumerWidget {
  final List<ChapterInfo> chaptersInfo;
  final int index;
  final MangaMetaCombine metaCombine;
  final bool isRead;

  const ChapterCard({
    Key? key,
    required this.chaptersInfo,
    required this.index,
    required this.metaCombine,
    this.isRead = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return InkWell(
      onTap: () {
        // Get.to(
        //   () => ReaderScreen(
        //     readerScreenArgs: ReaderScreenArgs(
        //       metaCombine: metaCombine,
        //       chaptersInfo: chaptersInfo,
        //       index: index,
        //     ),
        //   ),
        // );
        GoRouter.of(context).go(
          ReaderScreen.routeName,
          extra: ReaderScreenArgs(
            metaCombine: metaCombine,
            chaptersInfo: chaptersInfo,
            index: index,
          ),
        );
        final mangaDetailNotifier =
            ref.read(mangaDetailProvider(metaCombine).notifier);
        mangaDetailNotifier.addToRecentRead();
      },
      child: Card(
        margin: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 6,
        ),
        elevation: isRead ? 1 : 3,
        color: isRead ? Colors.grey[300] : Colors.white,
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: 8.0,
            vertical: 14,
          ),
          child: Text(
            chaptersInfo[index].name ?? '',
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ),
      ),
    );
  }
}
