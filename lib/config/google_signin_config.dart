import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';

class GoogleSignInConfig {
  static GoogleSignIn getGoogleSignIn() {
    if (kIsWeb) {
      // For web platform
      return GoogleSignIn(
        clientId: 'YOUR_WEB_CLIENT_ID.apps.googleusercontent.com',
        scopes: ['email', 'profile'],
        // Web-specific configurations
        hostedDomain: '', // Optional: restrict to specific domain
        // Use popup for better UX on web
     );
    } else {
      // For mobile platforms (Android/iOS)
      return GoogleSignIn(
        scopes: ['email', 'profile'],
        // Mobile-specific configurations
        serverClientId: 'YOUR_WEB_CLIENT_ID.apps.googleusercontent.com', // Use web client ID for server verification
      );
    }
  }
}

