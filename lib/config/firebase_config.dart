/// Firebase configuration loaded from environment variables
/// Keep sensitive data out of version control
class FirebaseConfig {
  // Common configuration
  static const String projectId = String.fromEnvironment(
    'FIREBASE_PROJECT_ID',
    defaultValue: 'baddie-app-version',
  );
  static const String messagingSenderId = String.fromEnvironment(
    'FIREBASE_MESSAGING_SENDER_ID',
    defaultValue: '670900854214',
  );
  static const String authDomain = String.fromEnvironment(
    'FIREBASE_AUTH_DOMAIN',
    defaultValue: 'baddie-app-version.firebaseapp.com',
  );
  static const String storageBucket = String.fromEnvironment(
    'FIREBASE_STORAGE_BUCKET',
    defaultValue: 'baddie-app-version.firebasestorage.app',
  );

  // Web configuration
  static const String webApiKey = String.fromEnvironment(
    'FIREBASE_WEB_API_KEY',
    defaultValue: 'AIzaSyBAvwZpTAUe1mb6Kgn_TOovHEJ_QpGPtpc',
  );
  static const String webAppId = String.fromEnvironment(
    'FIREBASE_WEB_APP_ID',
    defaultValue: '1:670900854214:web:9a915f00a37022430226c7',
  );

  // Android configuration
  static const String androidApiKey = String.fromEnvironment(
    'FIREBASE_ANDROID_API_KEY',
    defaultValue: 'AIzaSyBBIdyzmPbuA-kO81nYGZCQ3BdJ0IPon2c',
  );
  static const String androidAppId = String.fromEnvironment(
    'FIREBASE_ANDROID_APP_ID',
    defaultValue: '1:670900854214:android:ab3d2711046ffffe0226c7',
  );

  // iOS configuration
  static const String iosApiKey = String.fromEnvironment(
    'FIREBASE_IOS_API_KEY',
    defaultValue: 'AIzaSyDdJnEJuphJAdN7Jr82pX0gCssYUhXHzwo',
  );
  static const String iosAppId = String.fromEnvironment(
    'FIREBASE_IOS_APP_ID',
    defaultValue: '1:670900854214:ios:b216bd89592bef640226c7',
  );
  static const String iosBundleId = String.fromEnvironment(
    'FIREBASE_IOS_BUNDLE_ID',
    defaultValue: 'com.example.baddieApp',
  );

  // Windows configuration
  static const String windowsAppId = String.fromEnvironment(
    'FIREBASE_WINDOWS_APP_ID',
    defaultValue: '1:670900854214:web:35b28d1985344d090226c7',
  );
}
