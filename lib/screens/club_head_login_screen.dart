import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import 'create_event_screen.dart';

class ClubHeadLoginScreen extends StatefulWidget {
  const ClubHeadLoginScreen({super.key});
  @override
  State<ClubHeadLoginScreen> createState() => _ClubHeadLoginScreenState();
}

class _ClubHeadLoginScreenState extends State<ClubHeadLoginScreen>
    with SingleTickerProviderStateMixin {
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _obscure = true;
  bool _loading = false;
  late AnimationController _anim;

  @override
  void initState() {
    super.initState();
    _anim = AnimationController(vsync: this, duration: const Duration(milliseconds: 700))..forward();
  }

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passCtrl.dispose();
    _anim.dispose();
    super.dispose();
  }

  void _login() async {
    if (!_formKey.currentState!.validate()) return;
    
    setState(() => _loading = true);
    await Future.delayed(const Duration(milliseconds: 1200));
    if (!mounted) return;
    setState(() => _loading = false);
    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => const CreateEventScreen(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) => FadeTransition(opacity: animation, child: child),
        transitionDuration: const Duration(milliseconds: 400),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundWhite,
      body: SafeArea(
        child: FadeTransition(
          opacity: CurvedAnimation(parent: _anim, curve: Curves.easeOut),
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const SizedBox(height: 16),
              GestureDetector(
                onTap: () => Navigator.of(context).pop(),
                child: Container(
                  width: 44, height: 44,
                  decoration: BoxDecoration(color: AppColors.panelGray, borderRadius: BorderRadius.circular(14), border: Border.all(color: AppColors.borderGray)),
                  child: const Icon(Icons.arrow_back_rounded, size: 20, color: AppColors.textPrimary),
                ),
              ),
              const SizedBox(height: 40),
              Container(
                width: 56, height: 56,
                decoration: BoxDecoration(color: AppColors.accentVioletLight, borderRadius: BorderRadius.circular(16)),
                child: const Icon(Icons.admin_panel_settings_rounded, color: AppColors.accentViolet, size: 28),
              ),
              const SizedBox(height: 24),
              Text('Club Head Portal', style: Theme.of(context).textTheme.displayMedium),
              const SizedBox(height: 8),
              Text('Sign in to manage your club events.', style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: AppColors.textTertiary, height: 1.5)),
              const SizedBox(height: 40),
              
              Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _label('Email'),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _emailCtrl,
                      keyboardType: TextInputType.emailAddress,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Email is required';
                        }
                        final emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+$');
                        if (!emailRegex.hasMatch(value.trim())) {
                          return 'Please enter a valid email address';
                        }
                        return null;
                      },
                      decoration: const InputDecoration(
                        hintText: 'you@college.edu',
                        prefixIcon: Padding(
                          padding: EdgeInsets.only(left: 16, right: 12),
                          child: Icon(Icons.mail_outline_rounded, size: 20, color: AppColors.iconGray),
                        ),
                        prefixIconConstraints: BoxConstraints(minWidth: 0, minHeight: 0),
                      ),
                    ),
                    const SizedBox(height: 20),
                    _label('Password'),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _passCtrl,
                      obscureText: _obscure,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Password is required';
                        }
                        if (value.length < 6) {
                          return 'Password must be at least 6 characters';
                        }
                        return null;
                      },
                      decoration: InputDecoration(
                        hintText: '••••••••',
                        prefixIcon: const Padding(
                          padding: EdgeInsets.only(left: 16, right: 12),
                          child: Icon(Icons.lock_outline_rounded, size: 20, color: AppColors.iconGray),
                        ),
                        prefixIconConstraints: const BoxConstraints(minWidth: 0, minHeight: 0),
                        suffixIcon: GestureDetector(
                          onTap: () => setState(() => _obscure = !_obscure),
                          child: Padding(
                            padding: const EdgeInsets.only(right: 12),
                            child: Icon(
                              _obscure ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                              size: 20,
                              color: AppColors.iconGray,
                            ),
                          ),
                        ),
                        suffixIconConstraints: const BoxConstraints(minWidth: 0, minHeight: 0),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              Align(
                alignment: Alignment.centerRight,
                child: GestureDetector(
                  onTap: () => ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: const Text('Password reset link sent!'), backgroundColor: AppColors.primaryTeal, behavior: SnackBarBehavior.floating, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)))),
                  child: Text('Forgot Password?', style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppColors.accentViolet, fontWeight: FontWeight.w500)),
                ),
              ),
              const SizedBox(height: 36),
              SizedBox(
                width: double.infinity, height: 56,
                child: ElevatedButton(
                  onPressed: _loading ? null : _login,
                  style: ElevatedButton.styleFrom(backgroundColor: AppColors.accentViolet, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)), elevation: 0),
                  child: _loading
                    ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(strokeWidth: 2.5, color: Colors.white))
                    : const Row(mainAxisAlignment: MainAxisAlignment.center, children: [Text('Login', style: TextStyle(fontSize: 16, color: Colors.white, fontWeight: FontWeight.bold)), SizedBox(width: 8), Icon(Icons.arrow_forward_rounded, size: 20)]),
                ),
              ),
              const SizedBox(height: 32),
              Row(children: [Expanded(child: Container(height: 1, color: AppColors.borderGray)), Padding(padding: const EdgeInsets.symmetric(horizontal: 16), child: Text('OR', style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.textTertiary, fontWeight: FontWeight.w500))), Expanded(child: Container(height: 1, color: AppColors.borderGray))]),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity, height: 52,
                child: OutlinedButton(
                  onPressed: () => Navigator.of(context).pop(),
                  style: OutlinedButton.styleFrom(side: const BorderSide(color: AppColors.borderGray), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))),
                  child: Text('Continue as Student →', style: Theme.of(context).textTheme.titleMedium?.copyWith(color: AppColors.textSecondary, fontWeight: FontWeight.w500)),
                ),
              ),
            ]),
          ),
        ),
      ),
    );
  }

  Widget _label(String t) => Text(t, style: Theme.of(context).textTheme.titleMedium?.copyWith(fontSize: 14, fontWeight: FontWeight.w500, color: AppColors.textSecondary));
}
