import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_state.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final TextEditingController _nameController = TextEditingController();
  bool _isEditing = false;

  @override
  void initState() {
    super.initState();
    _loadUserProfile();
  }

  void _loadUserProfile() {
    final appState = Provider.of<AppState>(context, listen: false);
    if (appState.userProfile != null) {
      _nameController.text = appState.userProfile!.displayName ?? '';
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(_isEditing ? Icons.check : Icons.edit),
            onPressed: _toggleEditing,
          ),
        ],
      ),
      body: Consumer<AppState>(
        builder: (context, appState, child) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildProfileHeader(appState),
                const SizedBox(height: 24),
                _buildStatsSection(appState),
                const SizedBox(height: 24),
                _buildSettingsSection(appState),
                const SizedBox(height: 24),
                _buildPrivacySection(appState),
                const SizedBox(height: 24),
                _buildAboutSection(),
                const SizedBox(height: 24),
                _buildSignOutSection(appState),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildProfileHeader(AppState appState) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            CircleAvatar(
              radius: 50,
              backgroundColor: Theme.of(context).colorScheme.primary,
              child: Text(
                _getInitials(appState.userProfile?.displayName ?? 'Anonymous'),
                style: const TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
            const SizedBox(height: 16),
            if (_isEditing) ...[
              TextField(
                controller: _nameController,
                textAlign: TextAlign.center,
                decoration: const InputDecoration(
                  hintText: 'Enter your name',
                  border: OutlineInputBorder(),
                ),
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ] else ...[
              Text(
                appState.userProfile?.displayName ?? 'Anonymous User',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
            const SizedBox(height: 8),
            Text(
              'Member since ${_formatDate(appState.userProfile?.createdAt ?? DateTime.now())}',
              style: const TextStyle(
                color: Colors.grey,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatsSection(AppState appState) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Your Journey',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildStatItem(
                    'Streak',
                    '${appState.userStats?.streak ?? 0} days',
                    Icons.local_fire_department,
                    Colors.orange,
                  ),
                ),
                Expanded(
                  child: _buildStatItem(
                    'Entries',
                    '${appState.userStats?.totalJournalEntries ?? 0}',
                    Icons.book,
                    Colors.blue,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildStatItem(
                    'Chats',
                    '${appState.userStats?.totalChatSessions ?? 0}',
                    Icons.chat,
                    Colors.green,
                  ),
                ),
                Expanded(
                  child: _buildStatItem(
                    'Badges',
                    '${appState.userStats?.badges.length ?? 0}',
                    Icons.emoji_events,
                    Colors.amber,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(String label, String value, IconData icon, Color color) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: color, size: 24),
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: Colors.grey,
          ),
        ),
      ],
    );
  }

  Widget _buildSettingsSection(AppState appState) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Settings',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            _buildSettingItem(
              'Local-Only Mode',
              'Keep all data on your device',
              Icons.security,
              Switch(
                value: appState.localOnlyMode,
                onChanged: (value) async {
                  await appState.setLocalOnlyMode(value);
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          value 
                              ? 'Local-only mode enabled. Data will stay on your device.'
                              : 'Local-only mode disabled. Cloud features enabled.',
                        ),
                      ),
                    );
                  }
                },
              ),
            ),
            const Divider(),
            _buildSettingItem(
              'Notifications',
              'Reminder notifications',
              Icons.notifications,
              Switch(
                value: false, // Placeholder - implement notification settings
                onChanged: (value) {
                  // TODO: Implement notification settings
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPrivacySection(AppState appState) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Privacy & Data',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            _buildPrivacyItem(
              'Data Encryption',
              'Your data is encrypted and secure',
              Icons.lock,
              Colors.green,
            ),
            const SizedBox(height: 12),
            _buildPrivacyItem(
              'Anonymous Authentication',
              'No personal information required',
              Icons.person_off,
              Colors.blue,
            ),
            const SizedBox(height: 12),
            _buildPrivacyItem(
              'Crisis Detection',
              'Local trigger word detection active',
              Icons.warning,
              Colors.orange,
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () => _showPrivacyPolicy(context),
                child: const Text('View Privacy Policy'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAboutSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'About MindMitra',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'MindMitra is your AI-powered mental health companion designed to support your wellness journey through journaling, mood tracking, and supportive conversations.',
              style: TextStyle(fontSize: 14),
            ),
            const SizedBox(height: 16),
            const Text(
              'Version 1.0.0',
              style: TextStyle(
                color: Colors.grey,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSignOutSection(AppState appState) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Account',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () => _showSignOutDialog(appState),
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.red,
                  side: const BorderSide(color: Colors.red),
                ),
                child: const Text('Sign Out'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSettingItem(String title, String subtitle, IconData icon, Widget trailing) {
    return Row(
      children: [
        Icon(icon, color: Colors.grey[600]),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                subtitle,
                style: const TextStyle(
                  fontSize: 12,
                  color: Colors.grey,
                ),
              ),
            ],
          ),
        ),
        trailing,
      ],
    );
  }

  Widget _buildPrivacyItem(String title, String subtitle, IconData icon, Color color) {
    return Row(
      children: [
        Icon(icon, color: color, size: 20),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                subtitle,
                style: const TextStyle(
                  fontSize: 12,
                  color: Colors.grey,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  String _getInitials(String name) {
    final words = name.split(' ');
    if (words.length >= 2) {
      return '${words[0][0]}${words[1][0]}'.toUpperCase();
    } else if (words.isNotEmpty) {
      return words[0][0].toUpperCase();
    }
    return 'A';
  }

  String _formatDate(DateTime date) {
    final months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return '${months[date.month - 1]} ${date.year}';
  }

  Future<void> _toggleEditing() async {
    if (_isEditing) {
      // Save changes
      final appState = Provider.of<AppState>(context, listen: false);
      if (appState.userProfile != null) {
        final updatedProfile = appState.userProfile!.copyWith(
          displayName: _nameController.text.trim().isEmpty 
              ? 'Anonymous User' 
              : _nameController.text.trim(),
        );
        await appState.updateUserProfile(updatedProfile);
      }
    }
    
    setState(() {
      _isEditing = !_isEditing;
    });
  }

  void _showPrivacyPolicy(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Privacy Policy'),
        content: const SingleChildScrollView(
          child: Text(
            'MindMitra Privacy Policy\n\n'
            '1. Data Collection: We collect only the data you provide through journaling and chat interactions.\n\n'
            '2. Data Usage: Your data is used solely to provide AI-powered insights and support.\n\n'
            '3. Data Storage: Data is encrypted and stored securely. In local-only mode, data never leaves your device.\n\n'
            '4. Data Sharing: We do not share your personal data with third parties.\n\n'
            '5. Crisis Detection: We use local keyword detection to identify potential crisis situations and provide appropriate resources.\n\n'
            '6. Your Rights: You can delete your data at any time by signing out and clearing app data.',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showSignOutDialog(AppState appState) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Sign Out'),
        content: const Text(
          'Are you sure you want to sign out? Your data will remain safe and you can sign back in anytime.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.of(context).pop();
              await appState.signOut();
              if (context.mounted) {
                Navigator.of(context).pushNamedAndRemoveUntil(
                  '/splash',
                  (route) => false,
                );
              }
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Sign Out'),
          ),
        ],
      ),
    );
  }
}
