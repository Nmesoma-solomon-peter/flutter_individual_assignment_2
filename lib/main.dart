import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:google_fonts/google_fonts.dart';

// Import BLoCs
import 'blocs/auth/auth_bloc.dart';
import 'blocs/auth/auth_event.dart';
import 'blocs/auth/auth_state.dart';
import 'blocs/notes/notes_bloc.dart';

// Import repositories
import 'repositories/auth_repository.dart';
import 'repositories/note_repository.dart';

// Import screens
import 'screens/auth_screen.dart';
import 'screens/notes_screen.dart';

// Import constants
import 'constants/colors.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Firebase
  try {
    await Firebase.initializeApp();
  } catch (e) {
    print('Firebase initialization error: $e');
    // For now, we'll continue without Firebase for development
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
          create: (context) => AuthRepository(),
        ),
        RepositoryProvider<NoteRepository>(
          create: (context) => NoteRepository(),
        ),
      ],
      child: MultiBlocProvider(
        providers: [
          BlocProvider<AuthBloc>(
            create: (context) => AuthBloc(
              authRepository: context.read<AuthRepository>(),
            )..add(CheckAuthStatusEvent()),
          ),
          BlocProvider<NotesBloc>(
            create: (context) => NotesBloc(
              noteRepository: context.read<NoteRepository>(),
            ),
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
