import "package:firebase_core/firebase_core.dart";
import "package:starlist/src/core/config/firebase_config.dart";

class FirebaseInitializer {
  static Future<void> initialize() async {
    await Firebase.initializeApp(
      options: FirebaseOptions(
        apiKey: FirebaseConfig.apiKey,
        authDomain: FirebaseConfig.authDomain,
        projectId: FirebaseConfig.projectId,
        storageBucket: FirebaseConfig.storageBucket,
        messagingSenderId: FirebaseConfig.messagingSenderId,
        appId: FirebaseConfig.appId,
      ),
    );
  }
}
