import 'package:go_router/go_router.dart';
import 'package:justice_mango/app/data/model/manga_meta_combine.dart';
import 'package:justice_mango/app/modules/home/home_screen.dart';
import 'package:justice_mango/app/modules/manga_detail/manga_detail_screen.dart';
import 'package:justice_mango/app/modules/reader/reader_screen.dart';
import 'package:justice_mango/app/modules/reader/reader_screen_args.dart';
import 'package:justice_mango/app/route/routes.dart';

// class AppPages {
//   static final pages = [
//     GetPage(
//       name: Routes.home,
//       page: () => const HomeScreen(),
//       binding: HomePageBinding(),
//       transition: Transition.cupertino,
//     ),
// GetPage(
//   name: Routes.MANGA_DETAIL,
//   page: () => MangaDetailScreen(),
//   binding: MangaDetailBinding(),
//   transition: Transition.cupertino,
// ),
// note: issue with binding: dispose all controllers
// GetPage(
//   name: Routes.READER,
//   page: () => ReaderScreen(),
//   binding: ReaderBinding(),
//   transition: Transition.cupertino,
// ),
//   ];
// }
final appRouter = GoRouter(
  initialLocation: Routes.home,
  routes: [
    GoRoute(
      path: HomeScreen.routeName,
      builder: (context, state) => const HomeScreen(),
    ),
    GoRoute(
      path: MangaDetailScreen.routeName,
      builder: (context, state) =>
          MangaDetailScreen(metaCombine: state.extra as MangaMetaCombine),
    ),
    GoRoute(
      path: ReaderScreen.routeName,
      builder: (context, state) =>
          ReaderScreen(readerScreenArgs: state.extra as ReaderScreenArgs),
    ),
  ],
);
