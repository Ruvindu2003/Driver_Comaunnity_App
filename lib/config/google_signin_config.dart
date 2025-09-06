import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';

class GoogleSignInConfig {
  static GoogleSignIn getGoogleSignIn() {
    // Minimal Google Sign-In configuration - no scopes to avoid People API
    return GoogleSignIn(
      // Use the web client ID for all platforms
      clientId: kIsWeb ? '345739627083-bg6lh9krgoi19l7dimr4arstagflmevq.apps.googleusercontent.com' : null,
      
      scopes: [],
    );
  }
}

