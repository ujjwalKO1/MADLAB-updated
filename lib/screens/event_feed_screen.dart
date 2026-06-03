import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../theme/app_theme.dart';
import '../models/event_model.dart';
import '../providers/event_provider.dart';
import 'onboarding_screen.dart';

class EventFeedScreen extends StatefulWidget {
  final bool isDarkMode;
  final ValueChanged<bool> onThemeChanged;

  const EventFeedScreen({
    super.key,
    required this.isDarkMode,
    required this.onThemeChanged,
  });
  @override
  State<EventFeedScreen> createState() => _EventFeedScreenState();
}

class _EventFeedScreenState extends State<EventFeedScreen> with SingleTickerProviderStateMixin {
  final _searchCtrl = TextEditingController();
  final _provider = EventProvider();
  String _activeFilter = 'All';
  String? _selectedClub;
  int _navIndex = 0;
  late AnimationController _anim;

  // Profile setting values
  bool _mockNotification = true;

  @override
  void initState() {
    super.initState();
    _anim = AnimationController(vsync: this, duration: const Duration(milliseconds: 600))..forward();
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    _anim.dispose();
    super.dispose();
  }

  List<EventModel> get _filteredEvents {
    var events = _provider.events;
    if (_searchCtrl.text.isNotEmpty) {
      events = _provider.searchEvents(_searchCtrl.text);
    }
    if (_activeFilter != 'All') {
      events = events.where((e) => e.applicationType == _activeFilter).toList();
    }
    if (_selectedClub != null) {
      events = events.where((e) => e.clubName == _selectedClub).toList();
    }
    return events;
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _provider,
      builder: (context, _) {
        return Scaffold(
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          body: SafeArea(
            child: FadeTransition(
              opacity: CurvedAnimation(parent: _anim, curve: Curves.easeOut),
              child: _buildBody(),
            ),
          ),
          bottomNavigationBar: _buildBottomNav(),
        );
      },
    );
  }

  Widget _buildBody() {
    switch (_navIndex) {
      case 0:
        return _buildExploreTab();
      case 1:
        return _buildTicketsTab();
      case 2:
        return _buildProfileTab();
      default:
        return const SizedBox.shrink();
    }
  }

  Widget _buildExploreTab() {
    return Column(
      children: [
        // Top bar
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
          child: Row(children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Explore Events', style: Theme.of(context).textTheme.headlineLarge),
                  const SizedBox(height: 2),
                  Text('Find your next campus experience', style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppColors.textTertiary)),
                ],
              ),
            ),
            Container(
              width: 44, height: 44,
              decoration: BoxDecoration(
                gradient: const LinearGradient(colors: [AppColors.primaryTeal, AppColors.accentViolet]),
                borderRadius: BorderRadius.circular(14),
              ),
              child: const Icon(Icons.notifications_none_rounded, color: Colors.white, size: 22),
            ),
          ]),
        ),
        const SizedBox(height: 16),
        // Search bar
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Container(
            decoration: BoxDecoration(color: AppColors.surfaceWhite, borderRadius: BorderRadius.circular(16), border: Border.all(color: AppColors.borderGray), boxShadow: AppShadows.soft),
            child: TextField(
              controller: _searchCtrl,
              onChanged: (_) => setState(() {}),
              decoration: const InputDecoration(
                hintText: 'Search events, clubs...',
                prefixIcon: Padding(padding: EdgeInsets.only(left: 16, right: 12), child: Icon(Icons.search_rounded, size: 22, color: AppColors.iconGray)),
                prefixIconConstraints: BoxConstraints(minWidth: 0, minHeight: 0),
                border: InputBorder.none, enabledBorder: InputBorder.none, focusedBorder: InputBorder.none,
                fillColor: Colors.transparent, filled: true,
                contentPadding: EdgeInsets.symmetric(vertical: 16),
              ),
            ),
          ),
        ),
        const SizedBox(height: 16),
        // Filter chips
        SizedBox(
          height: 40,
          child: ListView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            children: [
              _buildChip('All', null),
              const SizedBox(width: 8),
              _buildChip('Registration', Icons.app_registration_rounded),
              const SizedBox(width: 8),
              _buildChip('Volunteering', Icons.volunteer_activism_rounded),
              const SizedBox(width: 8),
              _buildClubDropdownChip(),
            ],
          ),
        ),
        const SizedBox(height: 12),
        // Event list
        Expanded(
          child: _filteredEvents.isEmpty
              ? Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.event_busy_rounded, size: 56, color: AppColors.borderGray),
                      const SizedBox(height: 12),
                      Text('No events found', style: Theme.of(context).textTheme.titleMedium?.copyWith(color: AppColors.textTertiary)),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.fromLTRB(20, 4, 20, 100),
                  itemCount: _filteredEvents.length,
                  itemBuilder: (ctx, i) => _EventCard(event: _filteredEvents[i], index: i),
                ),
        ),
      ],
    );
  }

  Widget _buildTicketsTab() {
    final tickets = _provider.registeredEvents;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('My Registrations', style: Theme.of(context).textTheme.headlineLarge),
              const SizedBox(height: 2),
              Text('Passes and volunteering roles you applied for', style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppColors.textTertiary)),
            ],
          ),
        ),
        Expanded(
          child: tickets.isEmpty
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(32),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 80, height: 80,
                          decoration: BoxDecoration(color: AppColors.primaryTealLight, shape: BoxShape.circle),
                          child: const Icon(Icons.confirmation_num_outlined, size: 36, color: AppColors.primaryTeal),
                        ),
                        const SizedBox(height: 20),
                        Text('No active tickets yet', style: Theme.of(context).textTheme.titleLarge),
                        const SizedBox(height: 8),
                        Text(
                          'Register or sign up for volunteering roles on the Explore feed to see your tickets here.',
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppColors.textTertiary, height: 1.4),
                        ),
                        const SizedBox(height: 24),
                        ElevatedButton.icon(
                          onPressed: () => setState(() => _navIndex = 0),
                          icon: const Icon(Icons.explore_rounded, size: 18),
                          label: const Text('Browse Events'),
                        ),
                      ],
                    ),
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 100),
                  itemCount: tickets.length,
                  itemBuilder: (ctx, i) {
                    final ticket = tickets[i];
                    return _buildTicketCard(ticket);
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildTicketCard(EventModel event) {
    final isVolunteer = event.applicationType == 'Volunteering';
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: AppColors.surfaceWhite,
        borderRadius: BorderRadius.circular(20),
        boxShadow: AppShadows.soft,
        border: Border.all(color: AppColors.borderGray.withValues(alpha: 0.5)),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Row(
          children: [
            // Left color accent bar
            Container(
              width: 8,
              height: 110,
              color: isVolunteer ? AppColors.accentOrange : AppColors.primaryTeal,
            ),
            const SizedBox(width: 16),
            // Middle section
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: isVolunteer ? AppColors.volunteerTagBg : AppColors.registrationTagBg,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      isVolunteer ? 'Volunteering Pass' : 'Entry Ticket',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: isVolunteer ? AppColors.volunteerTag : AppColors.registrationTag,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(event.name, style: Theme.of(context).textTheme.titleLarge?.copyWith(fontSize: 16)),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.groups_2_rounded, size: 14, color: AppColors.textTertiary),
                      const SizedBox(width: 6),
                      Text(event.clubName, style: Theme.of(context).textTheme.bodySmall),
                    ],
                  ),
                ],
              ),
            ),
            // Right ticket action section
            Padding(
              padding: const EdgeInsets.only(right: 16),
              child: OutlinedButton(
                onPressed: () => _showTicketPass(event),
                style: OutlinedButton.styleFrom(
                  side: BorderSide(color: isVolunteer ? AppColors.accentOrange : AppColors.primaryTeal),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.qr_code_rounded,
                      size: 16,
                      color: isVolunteer ? AppColors.accentOrange : AppColors.primaryTeal,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      'View Pass',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: isVolunteer ? AppColors.accentOrange : AppColors.primaryTeal,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showTicketPass(EventModel event) {
    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        backgroundColor: Colors.transparent,
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            boxShadow: AppShadows.elevated,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Ticket Header
              Container(
                padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 24),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: event.applicationType == 'Volunteering'
                        ? [AppColors.accentOrange, const Color(0xFFFF9100)]
                        : [AppColors.primaryTeal, AppColors.primaryTealDark],
                  ),
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      event.applicationType == 'Volunteering' ? 'VOLUNTEER PASS' : 'ADMIT ONE',
                      style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w800, letterSpacing: 1.5),
                    ),
                    const Icon(Icons.favorite_rounded, color: Colors.white, size: 18),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    Text(
                      event.name,
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontSize: 22, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Organized by ${event.clubName}',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppColors.textTertiary),
                    ),
                    const SizedBox(height: 20),
                    // Dashed line cut outs
                    Row(
                      children: List.generate(
                        15,
                        (index) => Expanded(
                          child: Container(
                            margin: const EdgeInsets.symmetric(horizontal: 3),
                            height: 1.5,
                            color: AppColors.borderGray,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    // Barcode / QR Section
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.panelGray,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: AppColors.borderGray),
                      ),
                      child: Column(
                        children: [
                          // Custom high fidelity CSS-like QR code layout in Flutter widgets
                          Container(
                            width: 140,
                            height: 140,
                            padding: const EdgeInsets.all(8),
                            color: Colors.white,
                            child: GridView.builder(
                              physics: const NeverScrollableScrollPhysics(),
                              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 7,
                                crossAxisSpacing: 3,
                                mainAxisSpacing: 3,
                              ),
                              itemCount: 49,
                              itemBuilder: (context, index) {
                                // Design mock patterns to resemble an actual QR code
                                final isPattern = (index < 7 && index % 6 == 0) || // Top-left block
                                    (index >= 42 && index % 6 == 0) || // Bottom-left block
                                    (index % 7 == 6 && index < 7) || // Top-right block
                                    (index > 9 && index < 12) ||
                                    (index > 22 && index < 26) ||
                                    (index % 5 == 0 && index > 15) ||
                                    (index % 3 == 1 && index > 30);
                                return Container(
                                  decoration: BoxDecoration(
                                    color: isPattern ? AppColors.textPrimary : Colors.transparent,
                                    borderRadius: BorderRadius.circular(1.5),
                                  ),
                                );
                              },
                            ),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'TICKET ID: #${event.id}-${1000 + DateTime.now().millisecond}',
                            style: const TextStyle(
                              fontFamily: 'Courier',
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      'Please present this code at the gate/desk for check-in.',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(fontSize: 11, color: AppColors.textTertiary),
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: ElevatedButton(
                        onPressed: () => Navigator.of(ctx).pop(),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.panelGray,
                          foregroundColor: AppColors.textPrimary,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        child: const Text('Close Pass', style: TextStyle(fontWeight: FontWeight.bold)),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProfileTab() {
    final cs = Theme.of(context).colorScheme;
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
      child: Column(
        children: [
          const SizedBox(height: 12),
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              'Student Settings',
              style: Theme.of(context).textTheme.headlineLarge,
            ),
          ),
          const SizedBox(height: 6),
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              'Manage your app preferences and support options.',
              style: Theme.of(context)
                  .textTheme
                  .bodyMedium
                  ?.copyWith(color: AppColors.textTertiary),
            ),
          ),
          const SizedBox(height: 28),
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              'Settings & Preferences',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
            ),
          ),
          const SizedBox(height: 12),
          Container(
            decoration: BoxDecoration(
              color: cs.surface,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppColors.borderGray),
            ),
            child: Column(
              children: [
                _buildToggleSetting(
                  'Enable Push Notifications',
                  'Receive alerts for upcoming event updates',
                  Icons.notifications_active_outlined,
                  _mockNotification,
                  (val) => setState(() => _mockNotification = val),
                ),
                Divider(height: 1, color: AppColors.borderGray.withValues(alpha: 0.5)),
                _buildToggleSetting(
                  'Dark Theme Mode',
                  'Switch between light and dark appearance',
                  Icons.dark_mode_outlined,
                  widget.isDarkMode,
                  widget.onThemeChanged,
                ),
                Divider(height: 1, color: AppColors.borderGray.withValues(alpha: 0.5)),
                _buildLinkSetting(
                  'Help & Support Desk',
                  Icons.help_outline_rounded,
                  () => ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Support ticketing system mock launched!'))),
                ),
              ],
            ),
          ),
          const SizedBox(height: 36),
          // Go Home Button
          SizedBox(
            width: double.infinity,
            height: 54,
            child: ElevatedButton.icon(
              onPressed: _goHome,
              icon: const Icon(Icons.home_rounded, size: 20, color: Colors.white),
              label: const Text('Go to Home', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryTeal,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
            ),
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildToggleSetting(String title, String subtitle, IconData icon, bool val, ValueChanged<bool> onChange) {
    return ListTile(
      leading: Icon(icon, color: AppColors.textSecondary),
      title: Text(title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
      subtitle: Text(subtitle, style: const TextStyle(fontSize: 11, color: AppColors.textTertiary)),
      trailing: Switch(
        value: val,
        onChanged: onChange,
        activeTrackColor: AppColors.primaryTeal,
      ),
    );
  }

  Widget _buildLinkSetting(String title, IconData icon, VoidCallback onTap) {
    return ListTile(
      onTap: onTap,
      leading: Icon(icon, color: AppColors.textSecondary),
      title: Text(title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
      trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 14, color: AppColors.iconGray),
    );
  }

  void _goHome() {
    Navigator.of(context).pushAndRemoveUntil(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => OnboardingScreen(
          isDarkMode: widget.isDarkMode,
          onThemeChanged: widget.onThemeChanged,
        ),
        transitionsBuilder: (context, animation, secondaryAnimation, child) => FadeTransition(opacity: animation, child: child),
        transitionDuration: const Duration(milliseconds: 400),
      ),
      (route) => false,
    );
  }

  Widget _buildChip(String label, IconData? icon) {
    final active = _activeFilter == label && _selectedClub == null;
    return GestureDetector(
      onTap: () => setState(() { _activeFilter = label; _selectedClub = null; }),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: EdgeInsets.symmetric(horizontal: icon != null ? 14 : 20, vertical: 8),
        decoration: BoxDecoration(
          color: active ? AppColors.primaryTeal : AppColors.surfaceWhite,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: active ? AppColors.primaryTeal : AppColors.borderGray),
          boxShadow: active ? [BoxShadow(color: AppColors.primaryTeal.withValues(alpha: 0.2), blurRadius: 8, offset: const Offset(0, 3))] : [],
        ),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          if (icon != null) ...[Icon(icon, size: 16, color: active ? Colors.white : AppColors.textSecondary), const SizedBox(width: 6)],
          Text(label, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: active ? Colors.white : AppColors.textSecondary)),
        ]),
      ),
    );
  }

  Widget _buildClubDropdownChip() {
    final active = _selectedClub != null;
    return PopupMenuButton<String>(
      onSelected: (v) => setState(() { _selectedClub = v; _activeFilter = 'All'; }),
      offset: const Offset(0, 44),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      itemBuilder: (context) => _provider.clubNames.map((c) => PopupMenuItem(value: c, child: Text(c))).toList(),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: active ? AppColors.accentViolet : AppColors.surfaceWhite,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: active ? AppColors.accentViolet : AppColors.borderGray),
        ),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          Icon(Icons.groups_rounded, size: 16, color: active ? Colors.white : AppColors.textSecondary),
          const SizedBox(width: 6),
          Text(_selectedClub ?? 'Clubs', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: active ? Colors.white : AppColors.textSecondary)),
          const SizedBox(width: 4),
          Icon(Icons.keyboard_arrow_down_rounded, size: 16, color: active ? Colors.white : AppColors.iconGray),
        ]),
      ),
    );
  }

  Widget _buildBottomNav() {
    return Container(
      decoration: BoxDecoration(color: AppColors.surfaceWhite, boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.06), blurRadius: 20, offset: const Offset(0, -4))]),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
          child: Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
            _navItem(0, Icons.explore_rounded, 'Explore'),
            _navItem(1, Icons.confirmation_num_outlined, 'Tickets'),
            _navItem(2, Icons.person_outline_rounded, 'Profile'),
          ]),
        ),
      ),
    );
  }

  Widget _navItem(int idx, IconData icon, String label) {
    final active = _navIndex == idx;
    return GestureDetector(
      onTap: () => setState(() => _navIndex = idx),
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: active ? AppColors.primaryTealLight : Colors.transparent,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          Icon(icon, size: 22, color: active ? AppColors.primaryTeal : AppColors.iconGray),
          if (active) ...[
            const SizedBox(width: 8),
            Text(label, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.primaryTeal)),
          ],
        ]),
      ),
    );
  }
}

class _EventCard extends StatefulWidget {
  final EventModel event;
  final int index;
  const _EventCard({required this.event, required this.index});
  @override
  State<_EventCard> createState() => _EventCardState();
}

class _EventCardState extends State<_EventCard> with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  bool _pressed = false;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 500));
    Future.delayed(Duration(milliseconds: widget.index * 100), () { if (mounted) _ctrl.forward(); });
  }

  @override
  void dispose() { _ctrl.dispose(); super.dispose(); }

  void _handleRegistration(EventModel e) async {
    final isVolunteer = e.applicationType == 'Volunteering';
    final provider = EventProvider();
    
    if (provider.isRegistered(e.id)) {
      // Already registered, just attempt to open the form
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Opening form for ${e.name}...'),
        backgroundColor: AppColors.primaryTeal,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ));
      
      final uri = Uri.parse(e.formLink);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      }
      return;
    }

    // Register the student
    provider.registerForEvent(e.id);

    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(isVolunteer ? 'Registered as volunteer for ${e.name}!' : 'Entry ticket generated for ${e.name}!'),
      backgroundColor: AppColors.success,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    ));

    // Try to open external form
    final uri = Uri.parse(e.formLink);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    final e = widget.event;
    final isVolunteer = e.applicationType == 'Volunteering';
    final isRegistered = EventProvider().isRegistered(e.id);

    return FadeTransition(
      opacity: CurvedAnimation(parent: _ctrl, curve: Curves.easeOut),
      child: SlideTransition(
        position: Tween<Offset>(begin: const Offset(0, 0.15), end: Offset.zero).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOutCubic)),
        child: GestureDetector(
          onTapDown: (_) => setState(() => _pressed = true),
          onTapUp: (_) => setState(() => _pressed = false),
          onTapCancel: () => setState(() => _pressed = false),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            transform: _pressed ? Matrix4.diagonal3Values(0.98, 0.98, 1.0) : Matrix4.identity(),
            transformAlignment: Alignment.center,
            margin: const EdgeInsets.only(bottom: 16),
            decoration: BoxDecoration(color: AppColors.surfaceWhite, borderRadius: BorderRadius.circular(20), boxShadow: AppShadows.soft, border: Border.all(color: AppColors.borderGray.withValues(alpha: 0.5))),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              // Image
              ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                child: Image.asset(e.imagePath, height: 170, width: double.infinity, fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Container(height: 170, color: AppColors.panelGray, child: const Center(child: Icon(Icons.image_rounded, size: 40, color: AppColors.iconGray))),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Row(children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: isVolunteer ? AppColors.volunteerTagBg : AppColors.registrationTagBg,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(isVolunteer ? 'Volunteer' : 'Registration', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: isVolunteer ? AppColors.volunteerTag : AppColors.registrationTag)),
                    ),
                    const Spacer(),
                    Icon(
                      isRegistered ? Icons.bookmark_rounded : Icons.bookmark_border_rounded, 
                      size: 22, 
                      color: isRegistered ? AppColors.primaryTeal : AppColors.iconGray
                    ),
                  ]),
                  const SizedBox(height: 12),
                  Text(e.name, style: Theme.of(context).textTheme.titleLarge?.copyWith(fontSize: 17)),
                  const SizedBox(height: 4),
                  Row(children: [
                    Icon(Icons.groups_2_rounded, size: 16, color: AppColors.textTertiary),
                    const SizedBox(width: 6),
                    Text(e.clubName, style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppColors.textTertiary)),
                  ]),
                  const SizedBox(height: 14),
                  SizedBox(
                    width: double.infinity, height: 44,
                    child: ElevatedButton(
                      onPressed: () => _handleRegistration(e),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: isRegistered
                            ? AppColors.success
                            : (isVolunteer ? AppColors.accentOrange : AppColors.primaryTeal),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        elevation: 0,
                      ),
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                          Text(
                            isRegistered
                                ? 'Registered (Open Form)'
                                : (isVolunteer ? 'Volunteer Now' : 'Register Now'),
                            maxLines: 1,
                            style: const TextStyle(
                              fontSize: 16,
                              height: 1.2,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Icon(
                            isRegistered ? Icons.check_circle_outline_rounded : Icons.open_in_new_rounded,
                            size: 16,
                            color: Colors.white,
                          ),
                        ]),
                      ),
                    ),
                  ),
                ]),
              ),
            ]),
          ),
        ),
      ),
    );
  }
}
