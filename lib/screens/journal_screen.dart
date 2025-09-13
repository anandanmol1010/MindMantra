import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_state.dart';
import '../widgets/crisis_alert_dialog.dart';

class JournalScreen extends StatefulWidget {
  const JournalScreen({super.key});

  @override
  State<JournalScreen> createState() => _JournalScreenState();
}

class _JournalScreenState extends State<JournalScreen> {
  final TextEditingController _textController = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  bool _isSubmitting = false;

  @override
  void dispose() {
    _textController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Daily Journal'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Consumer<AppState>(
        builder: (context, appState, child) {
          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildWelcomeSection(appState),
                const SizedBox(height: 24),
                _buildJournalPrompt(),
                const SizedBox(height: 16),
                _buildJournalInput(),
                const SizedBox(height: 16),
                _buildSubmitButton(appState),
                const SizedBox(height: 24),
                _buildRecentEntries(),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildWelcomeSection(AppState appState) {
    final userName = appState.userProfile?.displayName ?? 'there';
    final now = DateTime.now();
    final hour = now.hour;
    String greeting;
    
    if (hour < 12) {
      greeting = 'Good morning';
    } else if (hour < 17) {
      greeting = 'Good afternoon';
    } else {
      greeting = 'Good evening';
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '$greeting, $userName!',
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'How are you feeling today? Take a moment to reflect and share your thoughts.',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
              ),
            ),
            if (appState.userStats != null && appState.userStats!.streak > 0) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.local_fire_department,
                      size: 16,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${appState.userStats!.streak} day streak!',
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildJournalPrompt() {
    final prompts = [
      'What emotions am I experiencing right now?',
      'What am I grateful for today?',
      'What challenges did I face today?',
      'What made me smile today?',
      'How did I take care of myself today?',
      'What would I like to improve tomorrow?',
    ];

    final randomPrompt = prompts[DateTime.now().day % prompts.length];

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Today\'s Reflection Prompt',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              randomPrompt,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildJournalInput() {
    return Expanded(
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: TextField(
            controller: _textController,
            focusNode: _focusNode,
            maxLines: null,
            expands: true,
            textAlignVertical: TextAlignVertical.top,
            decoration: const InputDecoration(
              hintText: 'Start writing your thoughts here...\n\nThere\'s no right or wrong way to journal. Just let your thoughts flow naturally.',
              border: InputBorder.none,
              hintStyle: TextStyle(
                color: Colors.grey,
                height: 1.5,
              ),
            ),
            style: const TextStyle(
              fontSize: 16,
              height: 1.5,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSubmitButton(AppState appState) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _isSubmitting || _textController.text.trim().isEmpty
            ? null
            : () => _submitJournalEntry(appState),
        child: _isSubmitting
            ? const SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.send),
                  const SizedBox(width: 8),
                  Text(appState.localOnlyMode 
                      ? 'Save Entry' 
                      : 'Save & Analyze Entry'),
                ],
              ),
      ),
    );
  }

  Widget _buildRecentEntries() {
    return const Expanded(
      flex: 0,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Recent Entries',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Your recent journal entries will appear here.',
            style: TextStyle(
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _submitJournalEntry(AppState appState) async {
    final text = _textController.text.trim();
    if (text.isEmpty) return;

    setState(() {
      _isSubmitting = true;
    });

    try {
      // Check for crisis triggers
      final hasCrisisTriggers = appState.checkForCrisisTriggers(text);
      
      if (hasCrisisTriggers) {
        await _showCrisisAlert();
      }

      // Create journal entry
      final journalId = await appState.createJournalEntry(text);
      
      if (journalId != null && !appState.localOnlyMode) {
        // Analyze entry with AI
        await appState.analyzeJournalEntry(journalId, text);
      }

      // Clear the text field
      _textController.clear();
      _focusNode.unfocus();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(appState.localOnlyMode 
                ? 'Journal entry saved locally!' 
                : 'Journal entry saved and analyzed!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to save journal entry. Please try again.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  Future<void> _showCrisisAlert() async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return const CrisisAlertDialog();
      },
    );
  }
}
