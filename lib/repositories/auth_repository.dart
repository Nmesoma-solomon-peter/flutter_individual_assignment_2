import 'package:firebase_auth/firebase_auth.dart';
import '../utils/logger.dart';

class AuthRepository {
  FirebaseAuth? _auth;
  static const Duration _timeout = Duration(seconds: 30);

  FirebaseAuth get _firebaseAuth {
    _auth ??= FirebaseAuth.instance;
    return _auth!;
  }

  // Get current user
  User? get currentUser => _firebaseAuth.currentUser;

  // Stream of auth state changes
  Stream<User?> get authStateChanges => _firebaseAuth.authStateChanges();

  // Sign up with email and password
  Future<UserCredential> signUp(String email, String password) async {
    Logger.log('AuthRepository: Attempting sign up for email: $email', tag: 'AuthRepository');
    try {
      final result = await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      ).timeout(_timeout);
      
      Logger.log('AuthRepository: Sign up successful for user: ${result.user?.email}', tag: 'AuthRepository');
      return result;
    } on FirebaseAuthException catch (e) {
      Logger.error('AuthRepository: Firebase auth exception during sign up: ${e.code} - ${e.message}', tag: 'AuthRepository');
      String message;
      switch (e.code) {
        case 'weak-password':
          message = 'The password provided is too weak.';
          break;
        case 'email-already-in-use':
          message = 'An account already exists for that email.';
          break;
        case 'invalid-email':
          message = 'Please provide a valid email address.';
          break;
        case 'operation-not-allowed':
          message = 'Email/password accounts are not enabled. Please contact support.';
          break;
        case 'network-request-failed':
          message = 'Network error. Please check your internet connection.';
          break;
        default:
          message = 'An error occurred during sign up: ${e.message}';
      }
      throw Exception(message);
    } catch (e) {
      Logger.error('AuthRepository: Unexpected error during sign up: $e', tag: 'AuthRepository');
      if (e.toString().contains('timeout')) {
        throw Exception('Sign up timed out. Please check your internet connection and try again.');
      }
      throw Exception('An unexpected error occurred during sign up: ${e.toString()}');
    }
  }

  // Sign in with email and password
  Future<UserCredential> signIn(String email, String password) async {
    Logger.log('AuthRepository: Attempting sign in for email: $email', tag: 'AuthRepository');
    try {
      final result = await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      ).timeout(_timeout);
      
      Logger.log('AuthRepository: Sign in successful for user: ${result.user?.email}', tag: 'AuthRepository');
      return result;
    } on FirebaseAuthException catch (e) {
      Logger.error('AuthRepository: Firebase auth exception during sign in: ${e.code} - ${e.message}', tag: 'AuthRepository');
      String message;
      switch (e.code) {
        case 'user-not-found':
          message = 'No user found for that email.';
          break;
        case 'wrong-password':
          message = 'Wrong password provided.';
          break;
        case 'invalid-email':
          message = 'Please provide a valid email address.';
          break;
        case 'user-disabled':
          message = 'This account has been disabled.';
          break;
        case 'too-many-requests':
          message = 'Too many failed attempts. Please try again later.';
          break;
        case 'network-request-failed':
          message = 'Network error. Please check your internet connection.';
          break;
        default:
          message = 'An error occurred during sign in: ${e.message}';
      }
      throw Exception(message);
    } catch (e) {
      Logger.error('AuthRepository: Unexpected error during sign in: $e', tag: 'AuthRepository');
      if (e.toString().contains('timeout')) {
        throw Exception('Sign in timed out. Please check your internet connection and try again.');
      }
      throw Exception('An unexpected error occurred during sign in: ${e.toString()}');
    }
  }

  // Sign out
  Future<void> signOut() async {
    try {
      await _firebaseAuth.signOut().timeout(_timeout);
    } catch (e) {
      if (e.toString().contains('timeout')) {
        throw Exception('Sign out timed out. Please try again.');
      }
      throw Exception('Failed to sign out: $e');
    }
  }
} 