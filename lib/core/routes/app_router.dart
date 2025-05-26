import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';
import 'package:stashly/core/routes/scaffold_large.dart';
import 'package:stashly/core/routes/scaffold_small.dart';

import '../../views/folders_view.dart';
import '../../views/home_view.dart';
import '../../views/settings_view.dart';

final _rootNavigatorKey = GlobalKey<NavigatorState>();
final _homeNavigatorKey = GlobalKey<NavigatorState>();
final _foldersNavigatorKey = GlobalKey<NavigatorState>();
final _settingsNavigatorKey = GlobalKey<NavigatorState>();

/// App route configuration using GoRouter
class AppRouter {
  /// Creates the router configuration
  static GoRouter createRouter() {
    return GoRouter(
      initialLocation: HomeView.routePath,
      navigatorKey: _rootNavigatorKey,
      routes: [
        StatefulShellRoute.indexedStack(
          builder: (context, state, navigationShell) {
            return LayoutBuilder(
              builder: (context, constraints) {
                if (context.isPhone || context.isPortrait) {
                  return ScaffoldSmall(navigationShell: navigationShell);
                } else {
                  return ScaffoldLarge(navigationShell: navigationShell);
                }
              },
            );
          },
          branches: [
            StatefulShellBranch(
              navigatorKey: _homeNavigatorKey,
              routes: [
                GoRoute(
                  path: HomeView.routePath,
                  name: HomeView.routeName,
                  builder: (context, state) => const HomeView(),
                ),
              ],
            ),
            StatefulShellBranch(
              navigatorKey: _foldersNavigatorKey,
              routes: [
                GoRoute(
                  path: FoldersView.routePath,
                  name: FoldersView.routeName,
                  builder: (context, state) => const FoldersView(),
                ),
              ],
            ),
            StatefulShellBranch(
              navigatorKey: _settingsNavigatorKey,
              routes: [
                GoRoute(
                  path: SettingsView.routePath,
                  name: SettingsView.routeName,
                  builder: (context, state) => const SettingsView(),
                ),
              ],
            ),
          ],
        ),
        // GoRoute(
        //   path: '/bookmark/:id',
        //   name: 'bookmarkDetail',
        //   builder: (context, state) {
        //     final bookmarkId = state.pathParameters['id'] ?? '';
        //     return BookmarkDetailView(bookmarkId: bookmarkId);
        //   },
        // ),
        // GoRoute(
        //   path: '/favorites',
        //   name: 'favorites',
        //   builder: (context, state) => const FavoritesView(),
        // ),
        // GoRoute(
        //   path: '/settings',
        //   name: 'settings',
        //   builder: (context, state) => const SettingsView(),
        // ),
        // GoRoute(
        //   path: '/add-bookmark',
        //   name: 'addBookmark',
        //   builder: (context, state) {
        //     final initialUrl = state.extra as String?;
        //     return AddBookmarkView(initialUrl: initialUrl);
        //   },
        // ),
        // GoRoute(
        //   path: '/folders',
        //   name: 'folders',
        //   builder: (context, state) => const FoldersView(),
        // ),
        // GoRoute(
        //   path: '/create-folder',
        //   name: 'createFolder',
        //   builder: (context, state) => const FolderFormView(),
        // ),
        // GoRoute(
        //   path: '/edit-folder/:id',
        //   name: 'editFolder',
        //   builder: (context, state) {
        //     final folderId = state.pathParameters['id'] ?? '';
        //     return FolderFormView(folderId: folderId);
        //   },
        // ),
        // GoRoute(
        //   path: '/edit-bookmark/:id',
        //   name: 'editBookmark',
        //   builder: (context, state) {
        //     final bookmarkId = state.pathParameters['id'] ?? '';
        //     return EditBookmarkView(bookmarkId: bookmarkId);
        //   },
        // ),
      ],
      errorBuilder: (context, state) => Scaffold(
        body: Center(
          child: Text(
            'Route not found: ${state.uri.path}',
            style: Theme.of(context).textTheme.titleLarge,
          ),
        ),
      ),
    );
  }
}
