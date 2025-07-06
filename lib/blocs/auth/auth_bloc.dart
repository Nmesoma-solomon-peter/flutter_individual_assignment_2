import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../repositories/auth_repository.dart';
import 'auth_event.dart';
import 'auth_state.dart';
import 'dart:async';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthRepository _authRepository;
  StreamSubscription<User?>? _authStateSubscription;
  Timer? _timeoutTimer;
  static const Duration _timeout = Duration(seconds: 30);

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
        
        print('AuthBloc: Auth state changed - User: ${user?.email ?? 'null'}');
        
        if (user != null) {
          // Only emit authenticated if we're not already in that state
          if (state is! AuthAuthenticated || (state as AuthAuthenticated).user.uid != user.uid) {
            print('AuthBloc: Emitting AuthAuthenticated for user: ${user.email}');
            emit(AuthAuthenticated(user));
          }
        } else {
          // Only emit unauthenticated if we're not already in that state and not in error state
          if (state is! AuthUnauthenticated && state is! AuthError) {
            print('AuthBloc: Emitting AuthUnauthenticated');
            emit(AuthUnauthenticated());
          }
        }
      },
      onError: (error) {
        // Handle auth state listener errors
        _timeoutTimer?.cancel();
        print('AuthBloc: Auth state listener error: $error');
        if (state is AuthLoading) {
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
        emit(AuthError('Authentication timed out. Please check your internet connection and try again.'));
      }
    });
  }

  Future<void> _onSignUp(SignUpEvent event, Emitter<AuthState> emit) async {
    print('AuthBloc: Processing SignUpEvent for email: ${event.email}');
    emit(AuthLoading());
    _startTimeoutTimer();
    
    try {
      await _authRepository.signUp(event.email, event.password);
      print('AuthBloc: SignUp completed successfully');
      // Don't emit success here - let the auth state listener handle it
      // This prevents race conditions
    } catch (e) {
      _timeoutTimer?.cancel();
      print('AuthBloc: SignUp error: $e');
      // Always emit error state when an error occurs during sign-up
      // This ensures we transition out of loading state
      emit(AuthError(e.toString()));
    }
  }

  Future<void> _onSignIn(SignInEvent event, Emitter<AuthState> emit) async {
    print('AuthBloc: Processing SignInEvent for email: ${event.email}');
    emit(AuthLoading());
    _startTimeoutTimer();
    
    try {
      await _authRepository.signIn(event.email, event.password);
      print('AuthBloc: SignIn completed successfully');
      // Don't emit success here - let the auth state listener handle it
      // This prevents race conditions
    } catch (e) {
      _timeoutTimer?.cancel();
      print('AuthBloc: SignIn error: $e');
      // Always emit error state when an error occurs during sign-in
      // This ensures we transition out of loading state
      emit(AuthError(e.toString()));
    }
  }

  Future<void> _onSignOut(SignOutEvent event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    _startTimeoutTimer();
    
    try {
      await _authRepository.signOut();
      // Don't emit success here - let the auth state listener handle it
      // This prevents race conditions
    } catch (e) {
      _timeoutTimer?.cancel();
      // Only emit error if we're still in loading state
      if (state is AuthLoading) {
        emit(AuthError(e.toString()));
      }
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