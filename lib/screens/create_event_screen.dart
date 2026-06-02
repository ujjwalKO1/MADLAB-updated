import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../models/event_model.dart';
import '../providers/event_provider.dart';
import 'event_feed_screen.dart';

class CreateEventScreen extends StatefulWidget {
  const CreateEventScreen({super.key});
  @override
  State<CreateEventScreen> createState() => _CreateEventScreenState();
}

class _CreateEventScreenState extends State<CreateEventScreen> with SingleTickerProviderStateMixin {
  final _nameCtrl = TextEditingController();
  final _clubCtrl = TextEditingController();
  final _linkCtrl = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  String _appType = 'Registration';
  bool _submitting = false;
  late AnimationController _anim;

  @override
  void initState() {
    super.initState();
    _anim = AnimationController(vsync: this, duration: const Duration(milliseconds: 600))..forward();
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _clubCtrl.dispose();
    _linkCtrl.dispose();
    _anim.dispose();
    super.dispose();
  }

  void _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _submitting = true);

    final images = [
      'assets/images/event_hackathon.png', 
      'assets/images/event_music.png', 
      'assets/images/event_sports.png', 
      'assets/images/event_art.png'
    ];
    
    final event = EventModel(
      id: '', // Server will assign the database ID
      name: _nameCtrl.text.trim(),
      clubName: _clubCtrl.text.trim(),
      applicationType: _appType,
      formLink: _linkCtrl.text.trim().isNotEmpty ? _linkCtrl.text.trim() : 'https://forms.google.com',
      imagePath: images[DateTime.now().millisecond % images.length],
    );

    final success = await EventProvider().addEvent(event);
    
    if (!mounted) return;
    setState(() => _submitting = false);

    if (success) {
      // Show success overlay
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (ctx) => const _SuccessDialog(),
      );

      await Future.delayed(const Duration(milliseconds: 2000));
      if (!mounted) return;
      Navigator.of(context).pop(); // dismiss dialog
      Navigator.of(context).pushReplacement(
        PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) => const EventFeedScreen(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) => FadeTransition(opacity: animation, child: child),
          transitionDuration: const Duration(milliseconds: 400),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Failed to publish event. Please verify your session.'),
          backgroundColor: Colors.redAccent,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
    }
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
              const SizedBox(height: 32),
              Container(
                width: 56, height: 56,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(colors: [AppColors.primaryTeal, AppColors.accentBlue], begin: Alignment.topLeft, end: Alignment.bottomRight),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Icon(Icons.add_circle_outline_rounded, color: Colors.white, size: 28),
              ),
              const SizedBox(height: 24),
              Text('Create New Event', style: Theme.of(context).textTheme.displayMedium),
              const SizedBox(height: 8),
              Text('Fill in the details to publish your event.', style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: AppColors.textTertiary)),
              const SizedBox(height: 36),
              
              Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _label('Event Name *'),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _nameCtrl,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Event name is required';
                        }
                        if (value.trim().length < 3) {
                          return 'Event name must be at least 3 characters';
                        }
                        return null;
                      },
                      decoration: const InputDecoration(hintText: 'e.g. HackFusion 2026'),
                    ),
                    const SizedBox(height: 20),
                    _label('Club Name *'),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _clubCtrl,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Club name is required';
                        }
                        return null;
                      },
                      decoration: const InputDecoration(hintText: 'e.g. Tech Club'),
                    ),
                    const SizedBox(height: 20),
                    _label('Application Type'),
                    const SizedBox(height: 8),
                    Container(
                      decoration: BoxDecoration(color: AppColors.panelGray, borderRadius: BorderRadius.circular(16), border: Border.all(color: AppColors.borderGray)),
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: _appType,
                          isExpanded: true,
                          icon: const Icon(Icons.keyboard_arrow_down_rounded, color: AppColors.iconGray),
                          items: ['Registration', 'Volunteering'].map((t) => DropdownMenuItem(value: t, child: Text(t, style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: AppColors.textPrimary)))).toList(),
                          onChanged: (v) => setState(() => _appType = v!),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    _label('External Form Link'),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _linkCtrl,
                      keyboardType: TextInputType.url,
                      validator: (value) {
                        if (value != null && value.trim().isNotEmpty) {
                          final uri = Uri.tryParse(value.trim());
                          if (uri == null || !uri.hasAbsolutePath || !uri.scheme.startsWith('http')) {
                            return 'Enter a valid URL (starting with http:// or https://)';
                          }
                        }
                        return null;
                      },
                      decoration: const InputDecoration(hintText: 'https://forms.google.com/...'),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 40),
              SizedBox(
                width: double.infinity, height: 56,
                child: ElevatedButton(
                  onPressed: _submitting ? null : _submit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryTeal,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    elevation: 0,
                  ),
                  child: _submitting
                    ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(strokeWidth: 2.5, color: Colors.white))
                    : const Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                        Icon(Icons.publish_rounded, size: 20, color: Colors.white),
                        SizedBox(width: 8),
                        Text('Submit Event', style: TextStyle(fontSize: 16, color: Colors.white, fontWeight: FontWeight.bold)),
                      ]),
                ),
              ),
              const SizedBox(height: 32),
            ]),
          ),
        ),
      ),
    );
  }

  Widget _label(String t) => Text(t, style: Theme.of(context).textTheme.titleMedium?.copyWith(fontSize: 14, fontWeight: FontWeight.w500, color: AppColors.textSecondary));
}

class _SuccessDialog extends StatefulWidget {
  const _SuccessDialog();
  @override
  State<_SuccessDialog> createState() => _SuccessDialogState();
}

class _SuccessDialogState extends State<_SuccessDialog> with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 500))..forward();
  }
  @override
  void dispose() { _ctrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ScaleTransition(
        scale: CurvedAnimation(parent: _ctrl, curve: Curves.elasticOut),
        child: Container(
          margin: const EdgeInsets.all(40),
          padding: const EdgeInsets.symmetric(horizontal: 36, vertical: 40),
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(28), boxShadow: AppShadows.elevated),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            Container(
              width: 72, height: 72,
              decoration: const BoxDecoration(color: AppColors.successLight, shape: BoxShape.circle),
              child: const Icon(Icons.check_circle_rounded, color: AppColors.success, size: 42),
            ),
            const SizedBox(height: 24),
            Text('Event Submitted\nSuccessfully!', textAlign: TextAlign.center, style: Theme.of(context).textTheme.headlineLarge?.copyWith(fontSize: 22)),
            const SizedBox(height: 12),
            Text('Redirecting to feed...', style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppColors.textTertiary)),
            const SizedBox(height: 20),
            const SizedBox(width: 28, height: 28, child: CircularProgressIndicator(strokeWidth: 2.5, color: AppColors.primaryTeal)),
          ]),
        ),
      ),
    );
  }
}
