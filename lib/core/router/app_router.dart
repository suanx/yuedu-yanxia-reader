import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:yuedu/data/repositories/mock_library.dart';
import 'package:yuedu/data/repositories/reading_state.dart';
import 'package:yuedu/features/reading/reading_page.dart';
import 'package:yuedu/features/shell/app_shell.dart';

final GlobalKey<NavigatorState> rootNavigatorKey =
    GlobalKey<NavigatorState>();

final appRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    navigatorKey: rootNavigatorKey,
    initialLocation: '/',
    routes: [
      GoRoute(
        path: '/',
        builder: (_, __) => const AppShell(),
      ),
      // /read/:bookId?page=  ← 书架 / 发现页点封面进来走这条
      GoRoute(
        path: '/read/:bookId',
        builder: (_, state) {
          final bookId = state.pathParameters['bookId'] ?? 'b1';
          final prefs = ref.read(readingPrefsProvider);
          final page = int.tryParse(state.uri.queryParameters['page'] ?? '') ??
              prefs.currentPage;
          final book = libraryById(bookId) ?? bookshelf.first;
          return ReadingPage(
            key: ValueKey(bookId),
            bookTitle: book.title,
            bookId: book.id,
            initialPage: page,
            totalPages: book.totalPages,
          );
        },
      ),
    ],
  );
});
