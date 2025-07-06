import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import '../blocs/auth/auth_bloc.dart';
import '../blocs/auth/auth_event.dart';
import '../blocs/auth/auth_state.dart';
import '../constants/colors.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLogin = true;
  bool _obscurePassword = true;
  double _passwordStrength = 0.0; // Password strength indicator

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _calculatePasswordStrength(String password) {
    double strength = 0.0;
    
    if (password.isEmpty) {
      setState(() {
        _passwordStrength = 0.0;
      });
      return;
    }
    
    // Length contribution (up to 25%)
    strength += (password.length / 16.0) * 0.25;
    
    // Character variety contribution (up to 75%)
    int variety = 0;
    if (RegExp(r'[a-z]').hasMatch(password)) variety++;
    if (RegExp(r'[A-Z]').hasMatch(password)) variety++;
    if (RegExp(r'[0-9]').hasMatch(password)) variety++;
    if (RegExp(r'[!@#$%^&*(),.?":{}|<>]').hasMatch(password)) variety++;
    
    strength += (variety / 4.0) * 0.75;
    
    // Penalty for consecutive characters
    for (int i = 0; i < password.length - 2; i++) {
      if (password[i] == password[i + 1] && password[i] == password[i + 2]) {
        strength -= 0.2;
        break;
      }
    }
    
    // Ensure strength is between 0 and 1
    strength = strength.clamp(0.0, 1.0);
    
    setState(() {
      _passwordStrength = strength;
    });
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      if (_isLogin) {
        context.read<AuthBloc>().add(SignInEvent(
              email: _emailController.text.trim(),
              password: _passwordController.text,
            ));
      } else {
        context.read<AuthBloc>().add(SignUpEvent(
              email: _emailController.text.trim(),
              password: _passwordController.text,
            ));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primaryBackground,
      body: BlocListener<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is AuthError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: AppColors.error,
                behavior: SnackBarBehavior.floating,
                duration: const Duration(seconds: 8),
                action: SnackBarAction(
                  label: 'Try Again',
                  textColor: AppColors.white,
                  onPressed: () {
                    ScaffoldMessenger.of(context).hideCurrentSnackBar();
                    // Clear the form and allow retry
                    _emailController.clear();
                    _passwordController.clear();
                    // Clear the error state and reset to initial state
                    context.read<AuthBloc>().add(ClearAuthErrorEvent());
                  },
                ),
              ),
            );
          } else if (state is AuthAuthenticated) {
            // Show success message when user is authenticated
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Welcome back, ${state.user.email ?? 'User'}!'),
                backgroundColor: Colors.green,
                behavior: SnackBarBehavior.floating,
                duration: const Duration(seconds: 3),
              ),
            );
          } else if (state is AuthSuccess) {
            // Show success message for operations like sign out
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: AppColors.success,
                behavior: SnackBarBehavior.floating,
                duration: const Duration(seconds: 3),
              ),
            );
          }
        },
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // App Logo/Title
                    Icon(
                      Icons.note_alt,
                      size: 80,
                      color: AppColors.purple,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Notes App',
                      style: GoogleFonts.poppins(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: AppColors.purple,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _isLogin ? 'Welcome back!' : 'Create your account',
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        color: AppColors.secondaryText,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 48),

                    // Email Field
                    TextFormField(
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      enabled: !BlocProvider.of<AuthBloc>(context).state.isLoading,
                      decoration: InputDecoration(
                        labelText: 'Email',
                        prefixIcon: Icon(Icons.email, color: AppColors.purple),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: AppColors.purple),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: AppColors.purple),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: AppColors.darkPurple, width: 2),
                        ),
                        filled: true,
                        fillColor: AppColors.secondaryBackground,
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your email';
                        }
                        if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
                          return 'Please enter a valid email';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // Password Field
                    TextFormField(
                      controller: _passwordController,
                      obscureText: _obscurePassword,
                      enabled: !BlocProvider.of<AuthBloc>(context).state.isLoading,
                      onChanged: (value) {
                        if (!_isLogin) {
                          _calculatePasswordStrength(value);
                          setState(() {}); // Trigger rebuild for requirements checklist
                        }
                      },
                      decoration: InputDecoration(
                        labelText: 'Password',
                        prefixIcon: Icon(Icons.lock, color: AppColors.purple),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscurePassword ? Icons.visibility : Icons.visibility_off,
                            color: AppColors.purple,
                          ),
                          onPressed: () {
                            setState(() {
                              _obscurePassword = !_obscurePassword;
                            });
                          },
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: AppColors.purple),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: AppColors.purple),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: AppColors.darkPurple, width: 2),
                        ),
                        filled: true,
                        fillColor: AppColors.secondaryBackground,
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your password';
                        }
                        
                        // Check minimum length
                        if (value.length < 8) {
                          return 'Password must be at least 8 characters long';
                        }
                        
                        // Check for at least one uppercase letter
                        if (!RegExp(r'[A-Z]').hasMatch(value)) {
                          return 'Password must contain at least one uppercase letter';
                        }
                        
                        // Check for at least one lowercase letter
                        if (!RegExp(r'[a-z]').hasMatch(value)) {
                          return 'Password must contain at least one lowercase letter';
                        }
                        
                        // Check for at least one digit
                        if (!RegExp(r'[0-9]').hasMatch(value)) {
                          return 'Password must contain at least one number';
                        }
                        
                        // Check for at least one special character
                        if (!RegExp(r'[!@#$%^&*(),.?":{}|<>]').hasMatch(value)) {
                          return 'Password must contain at least one special character (!@#\$%^&*)';
                        }
                        
                        // Check for no consecutive characters
                        for (int i = 0; i < value.length - 2; i++) {
                          if (value[i] == value[i + 1] && value[i] == value[i + 2]) {
                            return 'Password cannot contain 3 consecutive identical characters';
                          }
                        }
                        
                        return null;
                      },
                    ),
                    // Password Strength Indicator
                    _buildPasswordStrengthIndicator(),
                    const SizedBox(height: 24),

                    // Password Requirements
                    _buildPasswordRequirements(),

                    // Submit Button
                    BlocBuilder<AuthBloc, AuthState>(
                      builder: (context, state) {
                        return ElevatedButton(
                          onPressed: state.isLoading ? null : _submitForm,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.purple,
                            foregroundColor: AppColors.white,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: 2,
                          ),
                          child: state.isLoading
                              ? Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const SizedBox(
                                      height: 20,
                                      width: 20,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        valueColor: AlwaysStoppedAnimation<Color>(AppColors.white),
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Text(
                                      _isLogin ? 'Signing In...' : 'Creating Account...',
                                      style: GoogleFonts.poppins(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                )
                              : Text(
                                  _isLogin ? 'Sign In' : 'Sign Up',
                                  style: GoogleFonts.poppins(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                        );
                      },
                    ),
                    const SizedBox(height: 16),

                    // Toggle between Login and Sign Up
                    BlocBuilder<AuthBloc, AuthState>(
                      builder: (context, state) {
                        return TextButton(
                          onPressed: state.isLoading ? null : () {
                            setState(() {
                              _isLogin = !_isLogin;
                              _passwordStrength = 0.0; // Reset password strength
                            });
                          },
                          child: Text(
                            _isLogin
                                ? 'Don\'t have an account? Sign Up'
                                : 'Already have an account? Sign In',
                            style: GoogleFonts.poppins(
                              color: state.isLoading ? AppColors.secondaryText : AppColors.purple,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPasswordStrengthIndicator() {
    if (_isLogin) return const SizedBox.shrink(); // Don't show for login
    
    Color strengthColor;
    String strengthText;
    
    if (_passwordStrength < 0.3) {
      strengthColor = Colors.red;
      strengthText = 'Weak';
    } else if (_passwordStrength < 0.6) {
      strengthColor = Colors.orange;
      strengthText = 'Fair';
    } else if (_passwordStrength < 0.8) {
      strengthColor = Colors.yellow[700]!;
      strengthText = 'Good';
    } else {
      strengthColor = Colors.green;
      strengthText = 'Strong';
    }
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: LinearProgressIndicator(
                value: _passwordStrength,
                backgroundColor: Colors.grey[300],
                valueColor: AlwaysStoppedAnimation<Color>(strengthColor),
                minHeight: 4,
              ),
            ),
            const SizedBox(width: 12),
            Text(
              strengthText,
              style: GoogleFonts.poppins(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: strengthColor,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          'Password strength: ${(_passwordStrength * 100).toInt()}%',
          style: GoogleFonts.poppins(
            fontSize: 11,
            color: AppColors.secondaryText,
          ),
        ),
      ],
    );
  }

  Widget _buildPasswordRequirements() {
    if (_isLogin) return const SizedBox.shrink(); // Don't show for login
    
    final password = _passwordController.text;
    
    final requirements = [
      {
        'text': 'At least 8 characters long',
        'met': password.length >= 8,
      },
      {
        'text': 'Contains uppercase letter (A-Z)',
        'met': RegExp(r'[A-Z]').hasMatch(password),
      },
      {
        'text': 'Contains lowercase letter (a-z)',
        'met': RegExp(r'[a-z]').hasMatch(password),
      },
      {
        'text': 'Contains number (0-9)',
        'met': RegExp(r'[0-9]').hasMatch(password),
      },
      {
        'text': 'Contains special character (!@#\$%^&*)',
        'met': RegExp(r'[!@#$%^&*(),.?":{}|<>]').hasMatch(password),
      },
      {
        'text': 'No 3 consecutive identical characters',
        'met': !_hasConsecutiveChars(password),
      },
    ];
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 8),
        Text(
          'Password Requirements:',
          style: GoogleFonts.poppins(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: AppColors.primaryText,
          ),
        ),
        const SizedBox(height: 4),
        ...requirements.map((req) => Padding(
          padding: const EdgeInsets.only(bottom: 2),
          child: Row(
            children: [
              Icon(
                req['met'] as bool ? Icons.check_circle : Icons.circle_outlined,
                size: 16,
                color: req['met'] as bool ? Colors.green : Colors.grey,
              ),
              const SizedBox(width: 8),
              Text(
                req['text'] as String,
                style: GoogleFonts.poppins(
                  fontSize: 11,
                  color: req['met'] as bool ? Colors.green : AppColors.secondaryText,
                ),
              ),
            ],
          ),
        )).toList(),
      ],
    );
  }
  
  bool _hasConsecutiveChars(String password) {
    for (int i = 0; i < password.length - 2; i++) {
      if (password[i] == password[i + 1] && password[i] == password[i + 2]) {
        return true;
      }
    }
    return false;
  }
} 