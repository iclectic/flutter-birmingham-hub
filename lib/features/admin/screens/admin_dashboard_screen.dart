import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_birmingham_hub/features/admin/providers/admin_providers.dart';
import 'package:go_router/go_router.dart';

class AdminDashboardScreen extends ConsumerWidget {
  const AdminDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isAdmin = ref.watch(isUserAdminProvider);

    return isAdmin.when(
      data: (isAdmin) {
        if (!isAdmin) {
          // Redirect to login if not admin
          WidgetsBinding.instance.addPostFrameCallback((_) {
            context.go('/admin/login');
          });
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }

        return _buildDashboard(context, ref);
      },
      loading: () => const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      ),
      error: (_, __) => Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('Error loading admin status'),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => context.go('/admin/login'),
                child: const Text('Go to Login'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDashboard(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Sign Out',
            onPressed: () async {
              await ref.read(adminAuthServiceProvider).signOut();
              if (context.mounted) {
                context.go('/admin/login');
              }
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Admin Dashboard',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 24),
            
            // Stats cards
            Wrap(
              spacing: 16,
              runSpacing: 16,
              children: [
                _buildStatCard(
                  context,
                  icon: Icons.event,
                  title: 'Events',
                  count: '3',
                  color: Colors.blue,
                ),
                _buildStatCard(
                  context,
                  icon: Icons.people,
                  title: 'Speakers',
                  count: '12',
                  color: Colors.green,
                ),
                _buildStatCard(
                  context,
                  icon: Icons.edit_note,
                  title: 'Submissions',
                  count: '24',
                  color: Colors.orange,
                ),
                _buildStatCard(
                  context,
                  icon: Icons.calendar_today,
                  title: 'Agenda Items',
                  count: '18',
                  color: Colors.purple,
                ),
              ],
            ),
            
            const SizedBox(height: 32),
            
            // Admin features
            Text(
              'Admin Features',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 16),
            
            // Feature cards
            Wrap(
              spacing: 16,
              runSpacing: 16,
              children: [
                _buildFeatureCard(
                  context,
                  icon: Icons.event_available,
                  title: 'Event Management',
                  description: 'Create and manage events',
                  onTap: () => context.go('/admin/events'),
                ),
                _buildFeatureCard(
                  context,
                  icon: Icons.rate_review,
                  title: 'Talk Submissions',
                  description: 'Review and manage talk submissions',
                  onTap: () => context.go('/admin/submissions'),
                ),
                _buildFeatureCard(
                  context,
                  icon: Icons.view_timeline,
                  title: 'Agenda Builder',
                  description: 'Create and manage event agendas',
                  onTap: () => context.go('/admin/events'),
                ),
                _buildFeatureCard(
                  context,
                  icon: Icons.insights,
                  title: 'Insights',
                  description: 'View analytics and statistics',
                  onTap: () => context.go('/admin/insights'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String count,
    required Color color,
  }) {
    return SizedBox(
      width: 180,
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Icon(icon, size: 48, color: color),
              const SizedBox(height: 8),
              Text(
                count,
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: color,
                    ),
              ),
              const SizedBox(height: 4),
              Text(
                title,
                style: Theme.of(context).textTheme.bodyMedium,
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFeatureCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String description,
    required VoidCallback onTap,
  }) {
    return SizedBox(
      width: 300,
      child: Card(
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(icon, size: 32, color: Theme.of(context).colorScheme.primary),
                const SizedBox(height: 12),
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 8),
                Text(
                  description,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: 16),
                Align(
                  alignment: Alignment.centerRight,
                  child: Icon(
                    Icons.arrow_forward,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
