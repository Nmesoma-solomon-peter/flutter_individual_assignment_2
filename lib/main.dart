import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:async';

// Import BLoCs
import 'blocs/auth/auth_bloc.dart';
import 'blocs/auth/auth_event.dart';
import 'blocs/auth/auth_state.dart';
import 'blocs/notes/notes_bloc.dart';

// Import repositories
import 'repositories/auth_repository.dart';
import 'repositories/note_repository.dart';

// Import models
import 'models/note.dart';

// Import screens
import 'screens/auth_screen.dart';
import 'screens/notes_screen.dart';

// Import constants
import 'constants/colors.dart';

bool firebaseInitialized = false;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Try to initialize Firebase
  try {
    await Firebase.initializeApp();
    firebaseInitialized = true;
    print('Firebase initialized successfully');
  } catch (e) {
    print('Firebase initialization error: $e');
    print('Running in mock mode - Firebase features will be simulated');
    firebaseInitialized = false;
  }
  
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider<AuthRepository>(
          create: (context) {
            if (firebaseInitialized) {
              try {
                return AuthRepository();
              } catch (e) {
                print('Failed to create AuthRepository: $e');
                return MockAuthRepository();
              }
            } else {
              return MockAuthRepository();
            }
          },
        ),
        RepositoryProvider<NoteRepository>(
          create: (context) {
            if (firebaseInitialized) {
              try {
                return NoteRepository();
              } catch (e) {
                print('Failed to create NoteRepository: $e');
                return MockNoteRepository();
              }
            } else {
              return MockNoteRepository();
            }
          },
        ),
      ],
      child: MultiBlocProvider(
        providers: [
          BlocProvider<AuthBloc>(
            create: (context) {
              return AuthBloc(
                authRepository: context.read<AuthRepository>(),
              )..add(CheckAuthStatusEvent());
            },
          ),
          BlocProvider<NotesBloc>(
            create: (context) {
              return NotesBloc(
                noteRepository: context.read<NoteRepository>(),
              );
            },
          ),
        ],
        child: MaterialApp(
          title: 'Notes App',
          debugShowCheckedModeBanner: false,
          theme: ThemeData(
            colorScheme: ColorScheme.fromSeed(
              seedColor: AppColors.purple,
              brightness: Brightness.light,
            ),
            useMaterial3: true,
            fontFamily: GoogleFonts.poppins().fontFamily,
            appBarTheme: AppBarTheme(
              backgroundColor: AppColors.purple,
              foregroundColor: AppColors.white,
              elevation: 0,
              centerTitle: true,
            ),
            elevatedButtonTheme: ElevatedButtonThemeData(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.purple,
                foregroundColor: AppColors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
            ),
            inputDecorationTheme: InputDecorationTheme(
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              filled: true,
              fillColor: AppColors.secondaryBackground,
            ),
          ),
          home: const AuthWrapper(),
        ),
      ),
    );
  }
}

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    // In demo mode, show notes screen directly
    if (!firebaseInitialized) {
      return const NotesScreen();
    }

    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        if (state is AuthAuthenticated) {
          return const NotesScreen();
        } else if (state is AuthUnauthenticated) {
          return const AuthScreen();
        } else {
          // Show loading screen while checking auth status
          return Scaffold(
            backgroundColor: AppColors.primaryBackground,
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.note_alt,
                    size: 80,
                    color: AppColors.purple,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Notes App',
                    style: GoogleFonts.poppins(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: AppColors.purple,
                    ),
                  ),
                  const SizedBox(height: 24),
                  const CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(AppColors.purple),
                  ),
                ],
              ),
            ),
          );
        }
      },
    );
  }
}

// Mock repositories for testing without Firebase
class MockAuthRepository extends AuthRepository {
  bool _isAuthenticated = false;
  final StreamController<User?> _authStateController = StreamController<User?>.broadcast();

  @override
  User? get currentUser => _isAuthenticated ? null : null; // Return null in demo mode

  @override
  Stream<User?> get authStateChanges => _authStateController.stream;

  @override
  Future<UserCredential> signUp(String email, String password) async {
    await Future.delayed(const Duration(seconds: 1));
    _isAuthenticated = true;
    _authStateController.add(null); // In demo mode, we don't have a real user
    throw UnimplementedError('Firebase not configured - this is demo mode. Please set up Firebase to use authentication features.');
  }

  @override
  Future<UserCredential> signIn(String email, String password) async {
    await Future.delayed(const Duration(seconds: 1));
    _isAuthenticated = true;
    _authStateController.add(null); // In demo mode, we don't have a real user
    throw UnimplementedError('Firebase not configured - this is demo mode. Please set up Firebase to use authentication features.');
  }

  @override
  Future<void> signOut() async {
    await Future.delayed(const Duration(milliseconds: 500));
    _isAuthenticated = false;
    _authStateController.add(null);
  }
}

class MockNoteRepository extends NoteRepository {
  final List<Note> _mockNotes = [
    Note(
      id: '1',
      text: 'Welcome to Notes App! This is a demo note.',
      createdAt: DateTime.now().subtract(const Duration(hours: 2)),
      updatedAt: DateTime.now().subtract(const Duration(hours: 2)),
      userId: 'demo-user-id',
    ),
    Note(
      id: '2',
      text: 'You can add, edit, and delete notes. This is demo mode - Firebase is not configured.',
      createdAt: DateTime.now().subtract(const Duration(hours: 1)),
      updatedAt: DateTime.now().subtract(const Duration(hours: 1)),
      userId: 'demo-user-id',
    ),
  ];

  @override
  String? get currentUserId => 'demo-user-id';

  @override
  Future<List<Note>> fetchNotes() async {
    await Future.delayed(const Duration(milliseconds: 800));
    return List.from(_mockNotes);
  }

  @override
  Future<void> addNote(String text) async {
    await Future.delayed(const Duration(milliseconds: 500));
    final newNote = Note(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      text: text,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      userId: 'demo-user-id',
    );
    _mockNotes.insert(0, newNote);
  }

  @override
  Future<void> updateNote(String id, String text) async {
    await Future.delayed(const Duration(milliseconds: 500));
    final index = _mockNotes.indexWhere((note) => note.id == id);
    if (index != -1) {
      _mockNotes[index] = _mockNotes[index].copyWith(
        text: text,
        updatedAt: DateTime.now(),
      );
    }
  }

  @override
  Future<void> deleteNote(String id) async {
    await Future.delayed(const Duration(milliseconds: 300));
    _mockNotes.removeWhere((note) => note.id == id);
  }
}
