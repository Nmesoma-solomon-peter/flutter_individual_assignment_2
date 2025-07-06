import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../repositories/auth_repository.dart';
import '../../utils/logger.dart';
import 'auth_event.dart';
import 'auth_state.dart';
import 'dart:async';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthRepository _authRepository;
  StreamSubscription<User?>? _authStateSubscription;
  Timer? _timeoutTimer;
  static const Duration _timeout = Duration(seconds: 30);
  String? _currentOperation; // Track current operation type

  AuthBloc({required AuthRepository authRepository})
      : _authRepository = authRepository,
        super(AuthInitial()) {
    on<SignUpEvent>(_onSignUp);
    on<SignInEvent>(_onSignIn);
    on<SignOutEvent>(_onSignOut);
    on<CheckAuthStatusEvent>(_onCheckAuthStatus);
    on<ClearAuthErrorEvent>(_onClearAuthError);

    // Listen to auth state changes with proper error handling
    _authStateSubscription = _authRepository.authStateChanges.listen(
      (user) {
        // Cancel timeout timer when auth state changes
        _timeoutTimer?.cancel();
        
        Logger.log('AuthBloc: Auth state changed - User: ${user?.email ?? 'null'}', tag: 'AuthBloc');
        
        if (user != null) {
          // Only emit authenticated if we're not already in that state
          if (state is! AuthAuthenticated || (state as AuthAuthenticated).user.uid != user.uid) {
            Logger.log('AuthBloc: Emitting AuthAuthenticated for user: ${user.email}', tag: 'AuthBloc');
            // Check if this was a sign up or sign in operation
            if (state is AuthLoading) {
              if (_currentOperation == 'signup') {
                // ignore: invalid_use_of_visible_for_testing_member
                emit(AuthSuccess('Account created successfully! Welcome, ${user.email}!'));
                // Auto-transition to authenticated after 2 seconds
                Timer(const Duration(seconds: 2), () {
                  if (state is AuthSuccess) {
                    // ignore: invalid_use_of_visible_for_testing_member
                    emit(AuthAuthenticated(user));
                  }
                });
              } else if (_currentOperation == 'signin') {
                // ignore: invalid_use_of_visible_for_testing_member
                emit(AuthSuccess('Welcome back, ${user.email}!'));
                // Auto-transition to authenticated after 2 seconds
                Timer(const Duration(seconds: 2), () {
                  if (state is AuthSuccess) {
                    // ignore: invalid_use_of_visible_for_testing_member
                    emit(AuthAuthenticated(user));
                  }
                });
              } else {
                // ignore: invalid_use_of_visible_for_testing_member
                emit(AuthAuthenticated(user));
              }
              _currentOperation = null; // Reset operation flag
            } else if (state is AuthSuccess) {
              // If we're already in success state, transition to authenticated
              // ignore: invalid_use_of_visible_for_testing_member
              emit(AuthAuthenticated(user));
            } else {
              // ignore: invalid_use_of_visible_for_testing_member
              emit(AuthAuthenticated(user));
            }
          }
        } else {
          // Only emit unauthenticated if we're not already in that state and not in error state
          if (state is! AuthUnauthenticated && state is! AuthError) {
            Logger.log('AuthBloc: Emitting AuthUnauthenticated', tag: 'AuthBloc');
            // Check if this was a sign out operation
            if (state is AuthLoading) {
              if (_currentOperation == 'signout') {
                // ignore: invalid_use_of_visible_for_testing_member
                emit(AuthSuccess('Signed out successfully!'));
                // Auto-transition to unauthenticated after 2 seconds
                Timer(const Duration(seconds: 2), () {
                  if (state is AuthSuccess) {
                    // ignore: invalid_use_of_visible_for_testing_member
                    emit(AuthUnauthenticated());
                  }
                });
              } else {
                // ignore: invalid_use_of_visible_for_testing_member
                emit(AuthUnauthenticated());
              }
              _currentOperation = null; // Reset operation flag
            } else if (state is AuthSuccess) {
              // If we're already in success state, transition to unauthenticated
              // ignore: invalid_use_of_visible_for_testing_member
              emit(AuthUnauthenticated());
            } else {
              // ignore: invalid_use_of_visible_for_testing_member
              emit(AuthUnauthenticated());
            }
          }
        }
      },
      onError: (error) {
        // Handle auth state listener errors
        _timeoutTimer?.cancel();
        Logger.error('AuthBloc: Auth state listener error: $error', tag: 'AuthBloc');
        if (state is AuthLoading) {
          // ignore: invalid_use_of_visible_for_testing_member
          emit(AuthError('Authentication failed: ${error.toString()}'));
        }
      },
    );
  }

  @override
  Future<void> close() {
    _authStateSubscription?.cancel();
    _timeoutTimer?.cancel();
    return super.close();
  }

  void _startTimeoutTimer() {
    _timeoutTimer?.cancel();
    _timeoutTimer = Timer(_timeout, () {
      if (state is AuthLoading) {
        // ignore: invalid_use_of_visible_for_testing_member
        emit(AuthError('Authentication timed out. Please check your internet connection and try again.'));
      }
    });
  }

  Future<void> _onSignUp(SignUpEvent event, Emitter<AuthState> emit) async {
    Logger.log('AuthBloc: Processing SignUpEvent for email: ${event.email}', tag: 'AuthBloc');
    _currentOperation = 'signup';
    emit(AuthLoading());
    _startTimeoutTimer();
    
    try {
      await _authRepository.signUp(event.email, event.password);
      Logger.log('AuthBloc: SignUp completed successfully', tag: 'AuthBloc');
      // Don't emit success here - let the auth state listener handle it
      // This prevents race conditions
    } catch (e) {
      _timeoutTimer?.cancel();
      _currentOperation = null; // Reset operation flag on error
      Logger.error('AuthBloc: SignUp error: $e', tag: 'AuthBloc');
      // Always emit error state when an error occurs during sign-up
      // This ensures we transition out of loading state
      emit(AuthError(e.toString()));
    }
  }

  Future<void> _onSignIn(SignInEvent event, Emitter<AuthState> emit) async {
    Logger.log('AuthBloc: Processing SignInEvent for email: ${event.email}', tag: 'AuthBloc');
    _currentOperation = 'signin';
    emit(AuthLoading());
    _startTimeoutTimer();
    
    try {
      await _authRepository.signIn(event.email, event.password);
      Logger.log('AuthBloc: SignIn completed successfully', tag: 'AuthBloc');
      // Don't emit success here - let the auth state listener handle it
      // This prevents race conditions
    } catch (e) {
      _timeoutTimer?.cancel();
      _currentOperation = null; // Reset operation flag on error
      Logger.error('AuthBloc: SignIn error: $e', tag: 'AuthBloc');
      // Always emit error state when an error occurs during sign-in
      // This ensures we transition out of loading state
      emit(AuthError(e.toString()));
    }
  }

  Future<void> _onSignOut(SignOutEvent event, Emitter<AuthState> emit) async {
    _currentOperation = 'signout';
    emit(AuthLoading());
    _startTimeoutTimer();
    
    try {
      await _authRepository.signOut();
      // Don't emit success here - let the auth state listener handle it
      // This prevents race conditions
    } catch (e) {
      _timeoutTimer?.cancel();
      _currentOperation = null; // Reset operation flag on error
      // Always emit error state when an error occurs during sign-out
      // This ensures we transition out of loading state
      emit(AuthError(e.toString()));
    }
  }

  Future<void> _onCheckAuthStatus(
      CheckAuthStatusEvent event, Emitter<AuthState> emit) async {
    try {
      final user = _authRepository.currentUser;
      if (user != null) {
        emit(AuthAuthenticated(user));
      } else {
        emit(AuthUnauthenticated());
      }
    } catch (e) {
      emit(AuthError('Failed to check authentication status: ${e.toString()}'));
    }
  }

  Future<void> _onClearAuthError(
      ClearAuthErrorEvent event, Emitter<AuthState> emit) async {
    emit(AuthInitial());
  }
} 