import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'app/app.dart';
import 'core/config/env.dart';
import 'core/utils/logger.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  //  Global Flutter error handler 
  // Catches widget/rendering errors that would otherwise show the red screen.
  FlutterError.onError = (FlutterErrorDetails details) {
    AppLogger.e(
      'Flutter framework error',
      err: details.exception,
      st: details.stack,
    );
    // Still forward to the default handler so debug overlays work in dev.
    FlutterError.presentError(details);
  };

  debugPrint('[main] start');
  debugPrint('[main] Supabase config status: ${Env.configStatus}');

  await _initSupabase();

  debugPrint('[main] calling runApp');
  runApp(const BunaLensApp());
  debugPrint('[main] runApp done');
}


Future<void> _initSupabase() async {
  //  Guard: credentials not filled in yet 
  if (!Env.isConfigured) {
    debugPrint(
      '[main] ⚠️  Supabase NOT initialized.\n'
      '       Open lib/core/config/env.dart and replace the\n'
      '       placeholder values with your real project URL\n'
      '       and anon key.  The app will run in offline-only\n'
      '       mode until credentials are provided.',
    );
    return; // skip Supabase.initialize entirely — no crash
  }

  //  Attempt to connect 
  try {
    debugPrint('[main] Initializing Supabase → ${Env.supabaseUrl}');

    await Supabase.initialize(
      url: Env.supabaseUrl,
      anonKey: Env.supabaseAnonKey,
      debug: false, // flip to true to see Supabase request logs
    );

    debugPrint('[main] ✅ Supabase initialized successfully');
  } catch (e, st) {
    // Network error, wrong credentials, project paused, etc.
    // Log clearly but let the app continue — local grading still works.
    debugPrint('[main] ❌ Supabase initialization FAILED: $e');
    debugPrint('[main]    $st');
    debugPrint('[main]    App continues in offline-only mode.');
  }
}
