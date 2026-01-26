import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_birmingham_hub/features/admin/services/admin_auth_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Admin auth service provider
final adminAuthServiceProvider = Provider<AdminAuthService>((ref) {
  return AdminAuthService();
});

// Admin auth state provider
final adminAuthStateProvider = StreamProvider<User?>((ref) {
  final authService = ref.watch(adminAuthServiceProvider);
  return authService.authStateChanges;
});

// Current user provider
final currentUserProvider = Provider<User?>((ref) {
  final authState = ref.watch(adminAuthStateProvider);
  return authState.when(
    data: (user) => user,
    loading: () => null,
    error: (_, __) => null,
  );
});

// Is user signed in provider
final isSignedInProvider = Provider<bool>((ref) {
  final user = ref.watch(currentUserProvider);
  return user != null;
});

// Is user admin provider
final isUserAdminProvider = FutureProvider<bool>((ref) async {
  final authService = ref.watch(adminAuthServiceProvider);
  return await authService.isUserAdmin();
});
