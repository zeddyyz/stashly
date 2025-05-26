import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:stashly/controllers/bookmark_controller.dart';
import 'package:stashly/controllers/folder_controller.dart';
import 'package:stashly/repository/bookmark_repository.dart';
import 'package:stashly/services/bookmark_service.dart';
import 'package:stashly/services/folder_service.dart';
import 'package:stashly/services/preferences_service.dart';

import 'controllers/theme_controller.dart';
import 'core/routes/app_router.dart';
import 'core/theme/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // // Initialize preferences storage
  // // Important: Always call this before accessing any Prf<T> objects
  // await PrfService.init();

  // // If you're migrating from legacy SharedPreferences, uncomment this line:
  // // await PrfService.migrateFromLegacyPrefsIfNeeded();

  // Preferences service - initialized first
  final preferencesService = PreferencesService();

  await preferencesService.init();
  Get.put(preferencesService, permanent: true);

  // Repository - initialized after preferences
  final repository = BookmarkRepository();
  await repository.init();
  Get.put(repository, permanent: true);

  // Service - initialized after repository
  final bookmarkService = BookmarkService();
  await bookmarkService.init();
  Get.put(bookmarkService, permanent: true);

  // Initialize FolderService after BookmarkService

  // Initialize after BookmarkService is available
  final folderService = FolderService();
  await folderService.init();
  Get.put(folderService, permanent: true);

  // Controllers - using lazyPut for controllers
  Get.lazyPut<BookmarkController>(() => BookmarkController(), fenix: true);
  Get.lazyPut<ThemeController>(() => ThemeController(), fenix: true);
  Get.lazyPut<FolderController>(() => FolderController(), fenix: true);

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final router = AppRouter.createRouter();

    return GetMaterialApp.router(
      title: 'Stashly',
      debugShowCheckedModeBanner: false,
      routerDelegate: router.routerDelegate,
      routeInformationParser: router.routeInformationParser,
      routeInformationProvider: router.routeInformationProvider,
      theme: AppTheme.lightThemeData(context),
      darkTheme: AppTheme.darkThemeData(context),
      themeMode: ThemeMode.system,
    );
  }
}
