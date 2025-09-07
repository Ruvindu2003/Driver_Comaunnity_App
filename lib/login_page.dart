import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'services/auth_service.dart';
import 'home_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  bool _isLoading = false;
  final int _retryCount = 0;
  static const int _maxRetries = 3;
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isSignUp = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
    
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutCubic,
    ));
    
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _signInWithEmail() async {
    if (_emailController.text.isEmpty || _passwordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter both email and password'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final authService = Provider.of<AuthService>(context, listen: false);
      UserCredential? userCredential;
      
      if (_isSignUp) {
        userCredential = await authService.createUserWithEmailAndPassword(
          _emailController.text.trim(),
          _passwordController.text,
        );
      } else {
        userCredential = await authService.signInWithEmailAndPassword(
          _emailController.text.trim(),
          _passwordController.text,
        );
      }
      
      // For mock authentication, always navigate to home page
      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const HomePage()),
        );
      }
    } catch (e) {
      print('Sign-in error: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Sign-in failed: $e'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _signInAsGuest() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final authService = Provider.of<AuthService>(context, listen: false);
      final userCredential = await authService.signInAnonymously();
      
      // For mock authentication, always navigate to home page
      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const HomePage()),
        );
      }
    } catch (e) {
      print('Guest sign-in error: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Guest sign-in failed: $e'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF667eea),
              Color(0xFF764ba2),
            ],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: SlideTransition(
                  position: _slideAnimation,
        child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // App Logo/Icon
                      Container(
                        width: 120,
                        height: 120,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 20,
                              offset: const Offset(0, 10),
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.directions_bus,
                          size: 60,
                          color: Color(0xFF667eea),
                        ),
                      ),
                      
                      const SizedBox(height: 40),
                      
                      // Welcome Text
                      const Text(
                        'Welcome to',
                        style: TextStyle(
                          fontSize: 24,
                          color: Colors.white70,
                          fontWeight: FontWeight.w300,
                        ),
                      ),
                      
                      const SizedBox(height: 8),
                      
                      Text(
                        _isSignUp ? 'Create Account' : 'Driver Management',
                        style: const TextStyle(
                          fontSize: 32,
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      
                      const SizedBox(height: 16),
                      
                      Text(
                        _isSignUp 
                            ? 'Create a new account to get started'
                            : 'Sign in to manage your bus routes and schedules',
                        style: const TextStyle(
                          fontSize: 16,
                          color: Colors.white70,
                          fontWeight: FontWeight.w400,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      
                      const SizedBox(height: 60),
                      
                      // Email/Password Form
                      Column(
                        children: [
                          // Email Field
                          Container(
                            width: double.infinity,
                            height: 56,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(28),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.1),
                                  blurRadius: 10,
                                  offset: const Offset(0, 5),
                                ),
                              ],
                            ),
                            child: TextField(
                              controller: _emailController,
                              keyboardType: TextInputType.emailAddress,
                              decoration: const InputDecoration(
                                hintText: 'Enter your email',
                                prefixIcon: Icon(Icons.email, color: Color(0xFF667eea)),
                                border: InputBorder.none,
                                contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                              ),
                            ),
                          ),
                          
                          const SizedBox(height: 20),
                          
                          // Password Field
                          Container(
                            width: double.infinity,
                            height: 56,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(28),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.1),
                                  blurRadius: 10,
                                  offset: const Offset(0, 5),
                                ),
                              ],
                            ),
                            child: TextField(
                              controller: _passwordController,
                              obscureText: true,
                              decoration: const InputDecoration(
                                hintText: 'Enter your password',
                                prefixIcon: Icon(Icons.lock, color: Color(0xFF667eea)),
                                border: InputBorder.none,
                                contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                              ),
                            ),
                          ),
                          
                          const SizedBox(height: 30),
                          
                          // Sign In/Sign Up Button
                          Container(
                            width: double.infinity,
                            height: 56,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(28),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.1),
                                  blurRadius: 10,
                                  offset: const Offset(0, 5),
                                ),
                              ],
                            ),
                            child: Material(
                              color: Colors.transparent,
                              child: InkWell(
                                borderRadius: BorderRadius.circular(28),
                                onTap: _isLoading ? null : _signInWithEmail,
                                child: _isLoading
                                    ? const Center(
                                        child: SizedBox(
                                          width: 24,
                                          height: 24,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2,
                                            valueColor: AlwaysStoppedAnimation<Color>(
                                              Color(0xFF667eea),
                                            ),
                                          ),
                                        ),
                                      )
                                    : Center(
                                        child: Text(
                                          _isSignUp ? 'Create Account' : 'Sign In',
                                          style: const TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w600,
                                            color: Color(0xFF333333),
                                          ),
                                        ),
                                      ),
                              ),
                            ),
                          ),
                          
                          const SizedBox(height: 20),
                          
                          // Toggle Sign In/Sign Up
                          TextButton(
                            onPressed: () {
                              setState(() {
                                _isSignUp = !_isSignUp;
                              });
                            },
                            child: Text(
                              _isSignUp 
                                  ? 'Already have an account? Sign In'
                                  : 'Don\'t have an account? Sign Up',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 14,
                              ),
                            ),
                          ),
                          
                          const SizedBox(height: 20),
                          
                          // Continue as Guest Button
                          TextButton(
                            onPressed: _isLoading ? null : _signInAsGuest,
                            child: const Text(
                              'Continue as Guest',
                              style: TextStyle(
                                color: Colors.white70,
                                fontSize: 16,
                                decoration: TextDecoration.underline,
                              ),
                            ),
                          ),
                        ],
                      ),
                      
                      const SizedBox(height: 40),
                      
                      // Additional Info
                      const Text(
                        'By signing in, you agree to our Terms of Service\nand Privacy Policy',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.white60,
                          fontWeight: FontWeight.w400,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
