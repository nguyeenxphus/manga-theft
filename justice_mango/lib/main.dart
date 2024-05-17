import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:justice_mango/app/route/app_router.dart';

import 'app/data/service/hive_service.dart';
import 'app/data/service/source_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await EasyLocalization.ensureInitialized();
  // SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  // SystemChrome.setEnabledSystemUIMode(SystemUiMode.leanBack);
  await HiveService.init();
  await SourceService.init();
  runApp(
    // GetMaterialApp(
    //   // smartManagement: SmartManagement.keepFactory,
    //   initialRoute: Routes.home,
    //   getPages: AppPages.pages,
    //   locale: SourceService.selectedLocale,
    //   translationsKeys: translationMap,
    //   debugShowCheckedModeBanner: false,
    //   theme: appThemeData,
    //   builder: (context, child) {
    //     final mediaQueryData = MediaQuery.of(context);
    //     return MediaQuery(
    //       data: mediaQueryData.copyWith(textScaler: const TextScaler.linear(1.0)),
    //       child: child!,
    //     );
    //   },
    // ),
    ProviderScope(
      child: EasyLocalization(
        supportedLocales: SourceService.allLocalesSupported,
        startLocale: SourceService.selectedLocale,
        fallbackLocale: SourceService.selectedLocale,
        saveLocale: true,
        path: 'assets/translations',
        child: const MyApp(),
      ),
    ),
  );
  //runApp(TestApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();
    SchedulerBinding.instance.addPostFrameCallback((timeStamp) {});
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Fluffy',
      locale: context.locale,
      localizationsDelegates: context.localizationDelegates,
      supportedLocales: context.supportedLocales,
      routeInformationParser: appRouter.routeInformationParser,
      routeInformationProvider: appRouter.routeInformationProvider,
      routerDelegate: appRouter.routerDelegate,
    );
  }
}
