import 'package:flutter/material.dart';
import '../../services/auth_service.dart';
import '../../utils/custom_toast.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final AuthService _authService = AuthService();
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  
  bool _isLoading = false;

  Future<void> _resetPassword() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      try {
        await _authService.sendPasswordResetEmail(_emailController.text.trim());
        
        if (!mounted) return;
        
        CustomToast.showSuccess(
          context,
          title: 'Email Terkirim',
          message: 'Link reset password telah dikirim ke email kamu',
        );
        
        // Wait a bit then go back to login
        Future.delayed(const Duration(seconds: 2), () {
          if (mounted) Navigator.pop(context);
        });
        
      } catch (e) {
        if (!mounted) return;
        
        String errorMessage = 'Terjadi kesalahan';
        if (e.toString().contains('user-not-found')) {
          errorMessage = 'Email tidak terdaftar';
        } else {
          errorMessage = e.toString().split(']').last.trim();
        }

        CustomToast.showError(
          context,
          title: 'Reset Password Gagal',
          message: e.toString().contains('user-not-found')
              ? 'Email tidak terdaftar'
              : e.toString().split(']').last.trim(),
        );
      } finally {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0F0C29) : const Color(0xFFF8F9FE),
      body: Stack(
        children: [
          // Decorative Background Blobs
          Positioned(
            top: -100,
            right: -100,
            child: _buildBackgroundCircle(isDark ? const Color(0xFF8100D1).withOpacity(0.1) : const Color(0xFF8100D1).withOpacity(0.05), 300),
          ),
          Positioned(
            bottom: -50,
            left: -50,
            child: _buildBackgroundCircle(isDark ? const Color(0xFF302B63).withOpacity(0.1) : const Color(0xFF8100D1).withOpacity(0.03), 200),
          ),

          SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Custom App Bar
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: isDark ? Colors.white.withOpacity(0.05) : Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.05),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Icon(
                          Icons.arrow_back_ios_new_rounded,
                          size: 18,
                          color: isDark ? Colors.white : const Color(0xFF8100D1),
                        ),
                      ),
                    ),
                  ),
                ),

                Expanded(
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.symmetric(horizontal: 32.0),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          const SizedBox(height: 20),
                          
                          // Illustrative Header
                          TweenAnimationBuilder<double>(
                            duration: const Duration(milliseconds: 1000),
                            tween: Tween(begin: 0.0, end: 1.0),
                            curve: Curves.elasticOut,
                            builder: (context, value, child) {
                              return Transform.scale(
                                scale: value,
                                child: Container(
                                  padding: const EdgeInsets.all(24),
                                  decoration: BoxDecoration(
                                    color: isDark ? Colors.white.withOpacity(0.05) : Colors.white,
                                    shape: BoxShape.circle,
                                    boxShadow: [
                                      BoxShadow(
                                        color: const Color(0xFF8100D1).withOpacity(0.15),
                                        blurRadius: 40,
                                        spreadRadius: 5,
                                      ),
                                    ],
                                  ),
                                  child: const Icon(
                                    Icons.lock_person_rounded,
                                    size: 64,
                                    color: Color(0xFF8100D1),
                                  ),
                                ),
                              );
                            },
                          ),
                          
                          const SizedBox(height: 40),
                          
                          Text(
                            'Lupa Password?',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 32,
                              fontWeight: FontWeight.w900,
                              letterSpacing: -1,
                              color: isDark ? Colors.white : const Color(0xFF2D3436),
                            ),
                          ),
                          
                          const SizedBox(height: 12),
                          
                          Text(
                            'Masukkan alamat email Anda untuk menerima instruksi pemulihan kata sandi.',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 15,
                              color: isDark ? Colors.grey[400] : Colors.grey[600],
                              height: 1.6,
                            ),
                          ),
                          
                          const SizedBox(height: 48),
                          
                          // Input Field with Label Above
                          Align(
                            alignment: Alignment.centerLeft,
                            child: Padding(
                              padding: const EdgeInsets.only(left: 4, bottom: 8),
                              child: Text(
                                'Email',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                  color: isDark ? Colors.grey[300] : Colors.grey[700],
                                ),
                              ),
                            ),
                          ),
                          
                          TextFormField(
                            controller: _emailController,
                            keyboardType: TextInputType.emailAddress,
                            style: TextStyle(color: isDark ? Colors.white : Colors.black87),
                            decoration: InputDecoration(
                              hintText: 'nama@email.com',
                              hintStyle: TextStyle(color: Colors.grey.withOpacity(0.5), fontSize: 15),
                              prefixIcon: const Icon(Icons.alternate_email_rounded, color: Color(0xFF8100D1), size: 20),
                              filled: true,
                              fillColor: isDark ? Colors.white.withOpacity(0.05) : Colors.white,
                              contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(16),
                                borderSide: BorderSide.none,
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(16),
                                borderSide: BorderSide(color: isDark ? Colors.white.withOpacity(0.1) : Colors.transparent),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(16),
                                borderSide: const BorderSide(color: Color(0xFF8100D1), width: 2),
                              ),
                              errorBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(16),
                                borderSide: const BorderSide(color: Colors.redAccent, width: 1),
                              ),
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) return 'Email wajib diisi';
                              if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
                                return 'Format email tidak valid';
                              }
                              return null;
                            },
                          ),
                          
                          const SizedBox(height: 32),
                          
                          // Luxury Action Button
                          SizedBox(
                            width: double.infinity,
                            height: 60,
                            child: ElevatedButton(
                              onPressed: _isLoading ? null : _resetPassword,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF8100D1),
                                foregroundColor: Colors.white,
                                elevation: 8,
                                shadowColor: const Color(0xFF8100D1).withOpacity(0.4),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(18),
                                ),
                              ),
                              child: _isLoading
                                  ? const SizedBox(
                                      height: 24,
                                      width: 24,
                                      child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                                    )
                                  : const Text(
                                      'Reset Password',
                                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, letterSpacing: 0.5),
                                    ),
                            ),
                          ),
                          
                          const SizedBox(height: 40),
                          
                          // Back link
                          GestureDetector(
                            onTap: () => Navigator.pop(context),
                            child: RichText(
                              text: TextSpan(
                                children: [
                                  TextSpan(
                                    text: 'Ingat kata sandi? ',
                                    style: TextStyle(color: isDark ? Colors.grey[500] : Colors.grey[600], fontSize: 14),
                                  ),
                                  const TextSpan(
                                    text: 'Kembali ke Login',
                                    style: TextStyle(
                                      color: Color(0xFF8100D1),
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14,
                                      decoration: TextDecoration.underline,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 40),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBackgroundCircle(Color color, double size) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
      ),
    );
  }

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }
}
