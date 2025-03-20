import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../forgot_password/forgot_password_screen.dart';
import '../sign_up/sign_up_screen.dart';
import 'login_provider.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.5),
      end: Offset.zero,
    ).animate(
        CurvedAnimation(parent: _animationController, curve: Curves.easeOut));

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<LoginProvider>(
      builder: (context, loginProvider, _) {
        return Scaffold(
          body: Stack(
            children: [
              // Background gradient
              Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Color(0xFFF8F9FA),
                      Colors.white,
                    ],
                  ),
                ),
              ),

              SafeArea(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24.0),
                    child: Form(
                      key: loginProvider.formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 20),
                          // Logo and welcome text
                          Center(
                            child: Hero(
                              tag: 'logo',
                              child: Container(
                                height: 120,
                                width: 120,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.1),
                                      blurRadius: 20,
                                      offset: const Offset(0, 10),
                                    ),
                                  ],
                                ),
                                child: ClipOval(
                                  child: Image.asset(
                                    'assets/image 8.png',
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 40),
                          FadeTransition(
                            opacity: _fadeAnimation,
                            child: SlideTransition(
                              position: _slideAnimation,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Welcome Back',
                                    style: Theme.of(context)
                                        .textTheme
                                        .headlineMedium
                                        ?.copyWith(
                                          fontWeight: FontWeight.bold,
                                          color: Colors.black87,
                                        ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    'Sign in to continue',
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodyLarge
                                        ?.copyWith(
                                          color: Colors.black54,
                                        ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 40),

                          // Error message
                          if (loginProvider.errorMessage != null)
                            AnimatedContainer(
                              duration: const Duration(milliseconds: 300),
                              margin: const EdgeInsets.only(bottom: 20),
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: Colors.red.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                    color: Colors.red.withOpacity(0.3)),
                              ),
                              child: Row(
                                children: [
                                  Icon(Icons.error_outline,
                                      color: Colors.red[700]),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Text(
                                      loginProvider.errorMessage!,
                                      style: TextStyle(color: Colors.red[700]),
                                    ),
                                  ),
                                ],
                              ),
                            ),

                          // Email field
                          _buildInputField(
                            label: 'Email',
                            hintText: 'Enter your email',
                            icon: Icons.email_outlined,
                            onChanged: loginProvider.setEmail,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter your email';
                              }
                              if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$')
                                  .hasMatch(value)) {
                                return 'Please enter a valid email';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 24),

                          // Password field
                          _buildPasswordField(
                            loginProvider: loginProvider,
                          ),

                          // Forgot password
                          Align(
                            alignment: Alignment.centerRight,
                            child: TextButton(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) =>
                                          const ForgotPasswordScreen()),
                                );
                              },
                              style: TextButton.styleFrom(
                                foregroundColor: const Color(0xFF9DBA76),
                              ),
                              child: const Text('Forgot Password?'),
                            ),
                          ),

                          const SizedBox(height: 32),

                          // Login button
                          _buildLoginButton(loginProvider, context),

                          const SizedBox(height: 24),

                          // Sign up section
                          Center(
                            child: Column(
                              children: [
                                const Text(
                                  "Don't have an account?",
                                  style: TextStyle(color: Colors.black54),
                                ),
                                TextButton(
                                  onPressed: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) =>
                                              const SignUpScreen()),
                                    );
                                  },
                                  child: const Text(
                                    'Sign Up',
                                    style: TextStyle(
                                      color: Color(0xFF9DBA76),
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),

              // Loading overlay
              if (loginProvider.isLoading)
                Container(
                  color: Colors.black12,
                  child: Center(
                    child: Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 24,
                          ),
                        ],
                      ),
                      child: const Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          CircularProgressIndicator(
                            valueColor: AlwaysStoppedAnimation<Color>(
                                Color(0xFF9DBA76)),
                          ),
                          SizedBox(height: 16),
                          Text('Logging in...'),
                        ],
                      ),
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildInputField({
    required String label,
    required String hintText,
    required IconData icon,
    required Function(String) onChanged,
    required String? Function(String?) validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: TextFormField(
            onChanged: onChanged,
            validator: validator,
            decoration: InputDecoration(
              hintText: hintText,
              hintStyle: TextStyle(color: Colors.grey[400]),
              prefixIcon: Icon(icon, color: const Color(0xFF9DBA76)),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              filled: true,
              fillColor: Colors.white,
              contentPadding: const EdgeInsets.all(16),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPasswordField({
    required LoginProvider loginProvider,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Password',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: TextFormField(
            onChanged: loginProvider.setPassword,
            obscureText: !loginProvider.isPasswordVisible,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter your password';
              }
              return null;
            },
            decoration: InputDecoration(
              hintText: 'Enter your password',
              hintStyle: TextStyle(color: Colors.grey[400]),
              prefixIcon:
                  const Icon(Icons.lock_outline, color: Color(0xFF9DBA76)),
              suffixIcon: IconButton(
                icon: Icon(
                  loginProvider.isPasswordVisible
                      ? Icons.visibility_outlined
                      : Icons.visibility_off_outlined,
                  color: Colors.grey[600],
                ),
                onPressed: () => loginProvider.togglePassword(),
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              filled: true,
              fillColor: Colors.white,
              contentPadding: const EdgeInsets.all(16),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLoginButton(LoginProvider loginProvider, BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: () async {
          if (loginProvider.formKey.currentState!.validate()) {
            await loginProvider.login(context);
          }
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF9DBA76),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: 0,
        ),
        child: const Text(
          'Log In',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}
