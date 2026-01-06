import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_birmingham_hub/app/navigation_shell.dart';
import 'package:flutter_birmingham_hub/features/home/home_screen.dart';
import 'package:flutter_birmingham_hub/features/cfp/cfp_screen.dart';
import 'package:flutter_birmingham_hub/features/speakers/speakers_screen.dart';
import 'package:flutter_birmingham_hub/features/agenda/agenda_screen.dart';
import 'package:flutter_birmingham_hub/features/feedback/feedback_screen.dart';
import 'package:flutter_birmingham_hub/features/admin/admin_screen.dart';

final GlobalKey<NavigatorState> _rootNavigatorKey = GlobalKey<NavigatorState>();
final GlobalKey<NavigatorState> _shellNavigatorKey = GlobalKey<NavigatorState>();

final GoRouter appRouter = GoRouter(
  navigatorKey: _rootNavigatorKey,
  initialLocation: '/',
  routes: [
    ShellRoute(
      navigatorKey: _shellNavigatorKey,
      builder: (context, state, child) {
        return NavigationShell(child: child);
      },
      routes: [
        GoRoute(
          path: '/',
          name: 'home',
          pageBuilder: (context, state) => const NoTransitionPage(
            child: HomeScreen(),
          ),
        ),
        GoRoute(
          path: '/cfp',
          name: 'cfp',
          pageBuilder: (context, state) => const NoTransitionPage(
            child: CfpScreen(),
          ),
        ),
        GoRoute(
          path: '/speakers',
          name: 'speakers',
          pageBuilder: (context, state) => const NoTransitionPage(
            child: SpeakersScreen(),
          ),
        ),
        GoRoute(
          path: '/agenda',
          name: 'agenda',
          pageBuilder: (context, state) => const NoTransitionPage(
            child: AgendaScreen(),
          ),
        ),
        GoRoute(
          path: '/feedback',
          name: 'feedback',
          pageBuilder: (context, state) => const NoTransitionPage(
            child: FeedbackScreen(),
          ),
        ),
        GoRoute(
          path: '/admin',
          name: 'admin',
          pageBuilder: (context, state) => const NoTransitionPage(
            child: AdminScreen(),
          ),
        ),
      ],
    ),
  ],
);
