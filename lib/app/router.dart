import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_birmingham_hub/app/navigation_shell.dart';
import 'package:flutter_birmingham_hub/features/home/home_screen.dart';
import 'package:flutter_birmingham_hub/features/cfp/cfp_screen.dart';
import 'package:flutter_birmingham_hub/features/speakers/screens/speakers_list_screen.dart';
import 'package:flutter_birmingham_hub/features/speakers/screens/speaker_profile_screen.dart';
import 'package:flutter_birmingham_hub/features/agenda/agenda_screen.dart';
import 'package:flutter_birmingham_hub/features/agenda/screens/event_agenda_screen.dart';
import 'package:flutter_birmingham_hub/features/feedback/feedback_screen.dart';
import 'package:flutter_birmingham_hub/features/admin/admin_screen.dart';
import 'package:flutter_birmingham_hub/features/admin/screens/admin_login_screen.dart';
import 'package:flutter_birmingham_hub/features/admin/screens/admin_dashboard_screen.dart';
import 'package:flutter_birmingham_hub/features/admin/screens/event_management_screen.dart';
import 'package:flutter_birmingham_hub/features/admin/screens/talk_submissions_screen.dart';
import 'package:flutter_birmingham_hub/features/admin/screens/agenda_builder_screen.dart';
import 'package:flutter_birmingham_hub/features/admin/screens/insights_screen.dart';

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
            child: SpeakersListScreen(),
          ),
          routes: [
            GoRoute(
              path: ':id',
              name: 'speaker-profile',
              pageBuilder: (context, state) => NoTransitionPage(
                child: SpeakerProfileScreen(
                  speakerId: state.pathParameters['id']!,
                ),
              ),
            ),
          ],
        ),
        GoRoute(
          path: '/agenda',
          name: 'agenda',
          pageBuilder: (context, state) => const NoTransitionPage(
            child: AgendaScreen(),
          ),
          routes: [
            GoRoute(
              path: ':eventId',
              name: 'event-agenda',
              pageBuilder: (context, state) => NoTransitionPage(
                child: EventAgendaScreen(
                  eventId: state.pathParameters['eventId']!,
                ),
              ),
            ),
          ],
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
          routes: [
            GoRoute(
              path: 'login',
              name: 'admin-login',
              pageBuilder: (context, state) => const NoTransitionPage(
                child: AdminLoginScreen(),
              ),
            ),
            GoRoute(
              path: 'dashboard',
              name: 'admin-dashboard',
              pageBuilder: (context, state) => const NoTransitionPage(
                child: AdminDashboardScreen(),
              ),
            ),
            GoRoute(
              path: 'events',
              name: 'admin-events',
              pageBuilder: (context, state) => const NoTransitionPage(
                child: EventManagementScreen(),
              ),
            ),
            GoRoute(
              path: 'submissions',
              name: 'admin-submissions',
              pageBuilder: (context, state) => const NoTransitionPage(
                child: TalkSubmissionsScreen(),
              ),
            ),
            GoRoute(
              path: 'agenda-builder/:eventId',
              name: 'admin-agenda-builder',
              pageBuilder: (context, state) => NoTransitionPage(
                child: AgendaBuilderScreen(
                  eventId: state.pathParameters['eventId']!,
                ),
              ),
            ),
            GoRoute(
              path: 'insights',
              name: 'admin-insights',
              pageBuilder: (context, state) => const NoTransitionPage(
                child: InsightsScreen(),
              ),
            ),
          ],
        ),
      ],
    ),
  ],
);
