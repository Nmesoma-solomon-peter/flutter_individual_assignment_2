# Notes App - Individual Assignment 2

A Flutter notes application with Firebase authentication and CRUD operations for managing personal notes.

## Features

- 🔐 **Firebase Authentication**: Email and password sign-up/login
- 📝 **CRUD Operations**: Create, Read, Update, and Delete notes
- 🎨 **Modern UI**: Beautiful interface with custom color scheme
- 📱 **Responsive Design**: Works on both mobile and tablet
- 🔄 **Real-time Sync**: Notes sync with Firestore database
- 🎯 **Clean Architecture**: BLoC pattern for state management

## Architecture

The app follows clean architecture principles with clear separation of concerns:

```
lib/
├── blocs/           # Business Logic Components (BLoC)
│   ├── auth/       # Authentication state management
│   └── notes/      # Notes CRUD state management
├── constants/       # App constants (colors, etc.)
├── models/         # Data models
├── repositories/   # Data layer (Firebase operations)
├── screens/        # UI screens
└── widgets/        # Reusable UI components
```

### State Management

The app uses **BLoC (Business Logic Component)** pattern for state management:

- **AuthBloc**: Handles authentication state (login, signup, logout)
- **NotesBloc**: Manages notes CRUD operations and state

### Data Flow

1. **UI** → **BLoC** → **Repository** → **Firebase**
2. **Firebase** → **Repository** → **BLoC** → **UI**

## Color Scheme

The app uses a custom color palette:
- **Light Green**: `#90EE90` - Success states and accents
- **Purple**: `#9370DB` - Primary brand color
- **White**: `#FFFFFF` - Background and text
- **Orange**: `#FFA500` - Call-to-action buttons

## Setup Instructions

### Prerequisites

- Flutter SDK (3.7.2 or higher)
- Dart SDK
- Android Studio / VS Code
- Firebase project

### Installation

1. **Clone the repository**
   ```bash
   git clone <repository-url>
   cd individual_assignment_two
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Firebase Setup**
   - Create a Firebase project at [Firebase Console](https://console.firebase.google.com/)
   - Enable Authentication with Email/Password
   - Create a Firestore database
   - Download configuration files:
     - Android: `google-services.json` → `android/app/`
     - iOS: `GoogleService-Info.plist` → `ios/Runner/`

4. **Run the app**
   ```bash
   flutter run
   ```

## Firebase Configuration

### Authentication
- Enable Email/Password authentication in Firebase Console
- Users can sign up with email and password
- Password validation (minimum 6 characters)

### Firestore Database
- Collection: `notes`
- Document structure:
  ```json
  {
    "text": "Note content",
    "createdAt": "timestamp",
    "updatedAt": "timestamp", 
    "userId": "user_uid"
  }
  ```

## CRUD Operations

### Create
- Tap the ➕ floating action button
- Enter note text (minimum 3 characters)
- Tap "Add" to save

### Read
- Notes are automatically fetched and displayed
- Empty state shows: "Nothing here yet—tap ➕ to add a note."

### Update
- Tap the edit icon on any note
- Modify the text
- Tap "Update" to save changes

### Delete
- Tap the delete icon on any note
- Confirm deletion in the dialog
- Note is permanently removed

## Error Handling

- **Input Validation**: Email format, password length, note content
- **Network Errors**: Retry functionality for failed operations
- **User Feedback**: SnackBar notifications for success/error states

## Testing

### Manual Testing Checklist
- [ ] User registration with valid email/password
- [ ] User login with existing credentials
- [ ] Add new notes
- [ ] Edit existing notes
- [ ] Delete notes with confirmation
- [ ] Empty state display
- [ ] Error handling for invalid inputs
- [ ] Sign out functionality

## Dependencies

```yaml
dependencies:
  flutter:
    sdk: flutter
  firebase_core: ^3.6.0
  firebase_auth: ^5.3.3
  cloud_firestore: ^5.5.0
  flutter_bloc: ^9.1.1
  google_fonts: ^6.2.1
```

## Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Test thoroughly
5. Submit a pull request

## License

This project is created for educational purposes as part of Individual Assignment 2.

## Support

For issues or questions, please refer to the assignment requirements or contact your instructor.
