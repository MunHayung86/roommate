import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;
import 'package:firebase_core/firebase_core.dart';

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return web;
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      case TargetPlatform.macOS:
        return macos;
      case TargetPlatform.windows:
        return windows;
      case TargetPlatform.linux:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for linux - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyAMCmxPPepRO5ZHmuuXmcUMuDPkdyKkpss',
    appId: '1:814227573447:web:b1e5f8fab0834a930e8ce2',
    messagingSenderId: '814227573447',
    projectId: 'roommate-4ace9',
    authDomain: 'roommate-4ace9.firebaseapp.com',
    storageBucket: 'roommate-4ace9.firebasestorage.app',
    measurementId: 'G-5CFJE0TWX1',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyCNdmdf39fvB387nTXtvsCpBq5nPIcTJK8',
    appId: '1:814227573447:android:7ed7c3d08bc1b3ac0e8ce2',
    messagingSenderId: '814227573447',
    projectId: 'roommate-4ace9',
    storageBucket: 'roommate-4ace9.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyCCbSjkanedDPxEMUVAWW1lR4lyhHaWHmU',
    appId: '1:814227573447:ios:6936b1eeb301f8d40e8ce2',
    messagingSenderId: '814227573447',
    projectId: 'roommate-4ace9',
    storageBucket: 'roommate-4ace9.firebasestorage.app',
    iosBundleId: 'com.example.roommate',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyCCbSjkanedDPxEMUVAWW1lR4lyhHaWHmU',
    appId: '1:814227573447:ios:6936b1eeb301f8d40e8ce2',
    messagingSenderId: '814227573447',
    projectId: 'roommate-4ace9',
    storageBucket: 'roommate-4ace9.firebasestorage.app',
    iosBundleId: 'com.example.roommate',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyAMCmxPPepRO5ZHmuuXmcUMuDPkdyKkpss',
    appId: '1:814227573447:web:759f43d6a7fd6cc90e8ce2',
    messagingSenderId: '814227573447',
    projectId: 'roommate-4ace9',
    authDomain: 'roommate-4ace9.firebaseapp.com',
    storageBucket: 'roommate-4ace9.firebasestorage.app',
    measurementId: 'G-HPSBRD2ZRM',
  );
}
