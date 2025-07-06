# Notes App with Firebase

A Flutter notes application with Firebase Authentication and Firestore database, built using BLoC pattern for state management.

## Features

- 🔐 **Firebase Authentication** - Email/password sign up and sign in
- 📝 **CRUD Operations** - Create, read, update, and delete notes
- 🎨 **Modern UI** - Beautiful Material Design 3 interface
- 📱 **Responsive Design** - Works on all screen sizes
- 🔄 **Real-time Updates** - Notes sync across devices
- 🎯 **Clean Architecture** - BLoC pattern for state management

## Firebase Setup Instructions

### 1. Create Firebase Project

1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Click "Create a project" or "Add project"
3. Enter a project name (e.g., "notes-app")
4. Choose whether to enable Google Analytics (optional)
5. Click "Create project"

### 2. Add Android App

1. In your Firebase project, click the Android icon (🤖)
2. Enter your Android package name: `com.example.individual_assignment_two`
3. Enter app nickname: "Notes App"
4. Click "Register app"

### 3. Download Configuration File

1. Download the `google-services.json` file
2. Replace the existing file in `android/app/google-services.json`
3. **Important**: Never commit the real `google-services.json` to version control

### 4. Enable Authentication

1. In Firebase Console, go to "Authentication" → "Sign-in method"
2. Enable "Email/Password" provider
3. Click "Save"

### 5. Enable Firestore Database

1. In Firebase Console, go to "Firestore Database"
2. Click "Create database"
3. Choose "Start in test mode" (for development)
4. Select a location close to your users
5. Click "Done"

### 6. Set Firestore Security Rules

In Firestore Database → Rules, replace with:

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /notes/{noteId} {
      allow read, write: if request.auth != null && request.auth.uid == resource.data.userId;
      allow create: if request.auth != null && request.auth.uid == request.resource.data.userId;
    }
  }
}
```

### 7. Install Android NDK

1. Open Android Studio
2. Go to Tools → SDK Manager → SDK Tools
3. Check "NDK (Side by side)" and install version `27.0.12077973`
4. Or run: `sdkmanager --install "ndk;27.0.12077973"`

## Project Structure

```
lib/
├── blocs/           # BLoC state management
│   ├── auth/        # Authentication BLoC
│   └── notes/       # Notes BLoC
├── constants/       # App constants (colors, etc.)
├── models/          # Data models
├── repositories/    # Data layer (Firebase)
├── screens/         # UI screens
└── widgets/         # Reusable widgets
```

## Getting Started

1. **Clone the repository**
   ```bash
   git clone <repository-url>
   cd individual_assignment_two
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Set up Firebase** (follow instructions above)

4. **Run the app**
   ```bash
   flutter run
   ```

## Dependencies

- `flutter_bloc` - State management
- `firebase_core` - Firebase initialization
- `firebase_auth` - Authentication
- `cloud_firestore` - Database
- `google_fonts` - Typography
- `provider` - Dependency injection

## Usage

1. **Sign Up**: Create a new account with email and password
2. **Sign In**: Use your credentials to access the app
3. **Add Notes**: Tap the + button to create new notes
4. **Edit Notes**: Tap on a note to edit its content
5. **Delete Notes**: Long press a note and select delete
6. **Sign Out**: Use the logout button in the app bar

## Security

- All notes are tied to the authenticated user
- Users can only access their own notes
- Firestore security rules prevent unauthorized access
- Authentication is handled securely by Firebase

## Troubleshooting

### Firebase Initialization Error
- Ensure `google-services.json` is in `android/app/`
- Check that package name matches Firebase project
- Verify Firebase project is properly configured

### Build Errors
- Run `flutter clean` and `flutter pub get`
- Ensure Android NDK version 27.0.12077973 is installed
- Check that minSdkVersion is 23 or higher

### Authentication Issues
- Verify Email/Password provider is enabled in Firebase
- Check Firestore security rules
- Ensure user is properly authenticated

## Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Add tests if applicable
5. Submit a pull request

## License

This project is licensed under the MIT License.
