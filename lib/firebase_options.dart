// ATENÇÃO: Este arquivo é um STUB temporário.
// Substitua pelo arquivo gerado pelo FlutterFire CLI:
//   flutter pub global activate flutterfire_cli
//   flutterfire configure
//
// Documentação: https://firebase.flutter.dev/docs/cli

import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) return web;
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      default:
        throw UnsupportedError(
          'Firebase não configurado para esta plataforma.\n'
          'Execute: flutterfire configure',
        );
    }
  }

  // TODO: substitua pelos valores reais após rodar `flutterfire configure`
  static const web = FirebaseOptions(
    apiKey: 'YOUR_API_KEY',
    appId: 'YOUR_APP_ID',
    messagingSenderId: 'YOUR_SENDER_ID',
    projectId: 'YOUR_PROJECT_ID',
    storageBucket: 'YOUR_BUCKET',
    authDomain: 'YOUR_AUTH_DOMAIN',
  );

  static const android = FirebaseOptions(
    apiKey: 'YOUR_API_KEY',
    appId: 'YOUR_APP_ID',
    messagingSenderId: 'YOUR_SENDER_ID',
    projectId: 'YOUR_PROJECT_ID',
    storageBucket: 'YOUR_BUCKET',
  );
}
