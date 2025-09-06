# Google Sign-In Setup Instructions

## Prerequisites
1. Firebase project created
2. Google Cloud Console project
3. Android app registered

## Step 1: Configure Firebase Console

1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Select your project: `vehical-mnagement-system`
3. Go to Authentication > Sign-in method
4. Enable Google as a sign-in provider
5. Add your app's SHA-1 fingerprint

## Step 2: Get SHA-1 Fingerprint

Run this command in your project root:
```bash
cd android
./gradlew signingReport
```

Look for the SHA1 fingerprint in the debug section and copy it.

## Step 3: Configure Google Cloud Console

1. Go to [Google Cloud Console](https://console.cloud.google.com/)
2. Select your project
3. Go to APIs & Services > Credentials
4. Create OAuth 2.0 Client ID for Android:
   - Application type: Android
   - Package name: `com.example.driver_management`
   - SHA-1 certificate fingerprint: (paste the SHA-1 from step 2)
5. Create OAuth 2.0 Client ID for Web:
   - Application type: Web application
   - Name: Driver Management Web
   - Authorized JavaScript origins: `http://localhost:3000` (for development)
   - Authorized redirect URIs: `http://localhost:3000` (for development)

## Step 4: Update Configuration Files

1. **Update `android/app/google-services.json`**:
   - Download the latest `google-services.json` from Firebase Console
   - Replace the placeholder file with the real one

2. **Update `lib/firebase_options.dart`**:
   - Make sure your Firebase configuration is correct
   - Update the `appId` field with your actual Android app ID

3. **Update `lib/config/google_signin_config.dart`**:
   - Replace `YOUR_WEB_CLIENT_ID` with your actual web client ID from Google Cloud Console

4. **Update `web/index.html`**:
   - Replace `YOUR_WEB_CLIENT_ID` with your actual web client ID from Google Cloud Console

## Step 5: Test the App

1. Run `flutter pub get` to install dependencies
2. Run `flutter run` to test the app
3. Try signing in with Google

## Troubleshooting

### Common Issues:

1. **"Sign in failed"**: Check SHA-1 fingerprint and package name
2. **"Google Sign-In not configured"**: Ensure google-services.json is properly configured
3. **"App not authorized"**: Verify OAuth client configuration in Google Cloud Console
4. **"ClientID not set"**: 
   - For web: Update `web/index.html` with correct web client ID
   - For mobile: Ensure `google-services.json` is properly configured
   - Check that you've created both Android and Web OAuth clients
5. **"popup_closed" error**:
   - This is normal when user closes the Google Sign-In popup
   - The app now handles this gracefully with retry options
   - Check browser popup blockers and allow popups for your domain
   - Ensure your web client ID is correctly configured

### Debug Steps:

1. Check Firebase Console for authentication logs
2. Verify package name matches in all configuration files
3. Ensure SHA-1 fingerprint is correctly added to Firebase project
4. Check that Google Sign-In is enabled in Firebase Authentication

## Features Included

✅ Beautiful animated login page with gradient background
✅ Google Sign-In integration
✅ Firebase Authentication
✅ Responsive design
✅ Loading states and error handling
✅ Dashboard with placeholder features
✅ Sign out functionality
✅ State management with Provider

## Next Steps

After successful setup, you can:
1. Add more authentication providers (email/password, phone)
2. Implement user profile management
3. Add role-based access control
4. Integrate with your bus management features
