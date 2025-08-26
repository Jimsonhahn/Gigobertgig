import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'shared/theme/app_theme.dart';
import 'features/auth/presentation/pages/splash_page.dart';
import 'features/auth/presentation/pages/login_page.dart';
import 'features/auth/presentation/pages/register_page.dart';
import 'features/home/presentation/pages/home_page.dart';

class GigoBertApp extends ConsumerWidget {
  const GigoBertApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);

    return MaterialApp.router(
      title: 'GigoBert',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
      routerConfig: router,
      builder: (context, child) {
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(
            textScaler: TextScaler.linear(
              MediaQuery.of(context).textScaler.scale(1.0).clamp(0.8, 1.2),
            ),
          ),
          child: child!,
        );
      },
    );
  }
}

final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/splash',
    routes: [
      // Splash & Auth Routes
      GoRoute(
        path: '/splash',
        name: 'splash',
        builder: (context, state) => const SplashPage(),
      ),
      GoRoute(
        path: '/login',
        name: 'login',
        builder: (context, state) => const LoginPage(),
      ),
      GoRoute(
        path: '/register',
        name: 'register',
        builder: (context, state) => const RegisterPage(),
      ),
      
      // Main App Routes
      GoRoute(
        path: '/home',
        name: 'home',
        builder: (context, state) => const HomePage(),
        routes: [
          // Calendar
          GoRoute(
            path: '/calendar',
            name: 'calendar',
            builder: (context, state) => const Placeholder(),
          ),
          
          // Favorites
          GoRoute(
            path: '/favorites',
            name: 'favorites',
            builder: (context, state) => const Placeholder(),
          ),
          
          // Messages
          GoRoute(
            path: '/messages',
            name: 'messages',
            builder: (context, state) => const Placeholder(),
          ),
          
          // Profile
          GoRoute(
            path: '/profile',
            name: 'profile',
            builder: (context, state) => const Placeholder(),
          ),
        ],
      ),
      
      // Artist Routes
      GoRoute(
        path: '/artists',
        name: 'artists',
        builder: (context, state) => const Placeholder(),
        routes: [
          GoRoute(
            path: '/:id',
            name: 'artist-detail',
            builder: (context, state) {
              final id = state.pathParameters['id']!;
              return Placeholder(child: Text('Artist $id'));
            },
          ),
        ],
      ),
      
      // Venue Routes
      GoRoute(
        path: '/venues',
        name: 'venues',
        builder: (context, state) => const Placeholder(),
        routes: [
          GoRoute(
            path: '/:id',
            name: 'venue-detail',
            builder: (context, state) {
              final id = state.pathParameters['id']!;
              return Placeholder(child: Text('Venue $id'));
            },
          ),
        ],
      ),
      
      // Event Routes
      GoRoute(
        path: '/events',
        name: 'events',
        builder: (context, state) => const Placeholder(),
        routes: [
          GoRoute(
            path: '/:id',
            name: 'event-detail',
            builder: (context, state) {
              final id = state.pathParameters['id']!;
              return Placeholder(child: Text('Event $id'));
            },
          ),
        ],
      ),
      
      // Booking Routes
      GoRoute(
        path: '/bookings',
        name: 'bookings',
        builder: (context, state) => const Placeholder(),
        routes: [
          GoRoute(
            path: '/:id',
            name: 'booking-detail',
            builder: (context, state) {
              final id = state.pathParameters['id']!;
              return Placeholder(child: Text('Booking $id'));
            },
          ),
        ],
      ),
    ],
    
    // Error handling
    errorBuilder: (context, state) => Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline,
              size: 64,
              color: Colors.red,
            ),
            const SizedBox(height: 16),
            Text(
              'Page Not Found',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 8),
            Text(
              'The page you\'re looking for doesn\'t exist.',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => context.go('/home'),
              child: const Text('Go Home'),
            ),
          ],
        ),
      ),
    ),
  );
});