
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'firebase_options.dart';
import 'app/app.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 1. Initialize Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // 2. Supabase Configuration
  const supabaseUrl =
      'https://ptustmvvlnddubqqowmp.supabase.co';

  const supabasePublishableKey =
      'sb_publishable_XSwpu4rj_ZBjMS-GKdo1rA_S0Nga1A9';

  // 3. Initialize Supabase
  await Supabase.initialize(
    url: supabaseUrl,
    publishableKey: supabasePublishableKey,
    accessToken: () async {
      return FirebaseAuth.instance.currentUser?.getIdToken();
    },
  );

  // 4. Initialize Firebase App Check
  if (!kIsWeb) {
    await FirebaseAppCheck.instance.activate(
      providerAndroid: kDebugMode
          ? const AndroidDebugProvider()
          : const AndroidPlayIntegrityProvider(),
      providerApple: kDebugMode
          ? const AppleDebugProvider()
          : const AppleAppAttestProvider(),
    );
  } else {
    // Configure a real reCAPTCHA v3 site key
    // before enabling Web App Check.
    const recaptchaSiteKey =
        String.fromEnvironment('RECAPTCHA_V3_SITE_KEY');

    if (recaptchaSiteKey.isNotEmpty) {
      await FirebaseAppCheck.instance.activate(
        providerWeb: ReCaptchaV3Provider(
          recaptchaSiteKey,
        ),
      );
    }
  }

  // 5. Launch OneClick Application
  runApp(const MyApp());
}
