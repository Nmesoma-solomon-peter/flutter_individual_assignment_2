import 'package:firebase_auth/firebase_auth.dart';

abstract class AuthState {
  bool get isLoading => false;
}

class AuthInitial extends AuthState {}

class AuthLoading extends AuthState {
  @override
  bool get isLoading => true;
}

class AuthAuthenticated extends AuthState {
  final User user;
  AuthAuthenticated(this.user);
}

class AuthUnauthenticated extends AuthState {}

class AuthError extends AuthState {
  final String message;
  AuthError(this.message);
} 