import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/infrastructure/config/supabase_config.dart';
import 'app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    // Initialize Supabase
    await SupabaseConfig.initialize();
  } catch (e) {
    debugPrint('Failed to initialize Supabase: $e');
    // Continue without Supabase for development
  }

  runApp(
    const ProviderScope(
      child: GigoBertApp(),
    ),
  );
}