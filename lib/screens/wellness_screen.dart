import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_state.dart';
import '../widgets/breathing_animation.dart';

class WellnessScreen extends StatefulWidget {
  const WellnessScreen({super.key});

  @override
  State<WellnessScreen> createState() => _WellnessScreenState();
}

class _WellnessScreenState extends State<WellnessScreen> {
  List<String> _completedActivities = [];

  @override
  void initState() {
    super.initState();
    _loadCompletedActivities();
  }

  Future<void> _loadCompletedActivities() async {
    final appState = Provider.of<AppState>(context, listen: false);
    final completed = await appState.getCompletedActivities();
    setState(() {
      _completedActivities = completed;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Wellness Activities'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Consumer<AppState>(
        builder: (context, appState, child) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildWelcomeSection(),
                const SizedBox(height: 24),
                _buildBreathingSection(),
                const SizedBox(height: 24),
                _buildMindfulnessSection(),
                const SizedBox(height: 24),
                _buildWellnessTipsSection(),
                const SizedBox(height: 24),
                _buildProgressSection(),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildWelcomeSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.green.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.self_improvement,
                    color: Colors.green,
                    size: 28,
                  ),
                ),
                const SizedBox(width: 16),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Wellness Center',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'Take a moment for yourself',
                        style: TextStyle(
                          color: Colors.grey,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Text(
              'Explore guided activities designed to help you relax, focus, and improve your mental well-being.',
              style: TextStyle(fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBreathingSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Breathing Exercise',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Practice deep breathing to reduce stress and anxiety. Follow the animation to breathe in and out slowly.',
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 20),
            const Center(
              child: BreathingAnimation(),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => _markActivityCompleted('breathing_exercise'),
                child: Text(
                  _completedActivities.contains('breathing_exercise')
                      ? 'Completed ✓'
                      : 'Mark as Completed',
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMindfulnessSection() {
    final mindfulnessActivities = [
      {
        'id': 'body_scan',
        'title': '5-Minute Body Scan',
        'description': 'Focus on each part of your body, starting from your toes and moving up to your head.',
        'duration': '5 min',
        'icon': Icons.accessibility_new,
      },
      {
        'id': 'gratitude_practice',
        'title': 'Gratitude Practice',
        'description': 'Think of three things you\'re grateful for today and reflect on why they matter to you.',
        'duration': '3 min',
        'icon': Icons.favorite,
      },
      {
        'id': 'mindful_walking',
        'title': 'Mindful Walking',
        'description': 'Take a slow walk and focus on each step, your breathing, and your surroundings.',
        'duration': '10 min',
        'icon': Icons.directions_walk,
      },
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Mindfulness Activities',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        ...mindfulnessActivities.map((activity) => _buildActivityCard(activity)),
      ],
    );
  }

  Widget _buildWellnessTipsSection() {
    final wellnessTips = [
      {
        'id': 'hydration_tip',
        'title': 'Stay Hydrated',
        'description': 'Drink a glass of water mindfully. Notice the temperature, taste, and how it feels.',
        'icon': Icons.local_drink,
        'color': Colors.blue,
      },
      {
        'id': 'nature_connection',
        'title': 'Connect with Nature',
        'description': 'Spend 5 minutes observing nature - plants, sky, or even a single leaf.',
        'icon': Icons.nature,
        'color': Colors.green,
      },
      {
        'id': 'digital_detox',
        'title': 'Digital Break',
        'description': 'Take a 15-minute break from all screens and electronic devices.',
        'icon': Icons.phone_android,
        'color': Colors.orange,
      },
      {
        'id': 'positive_affirmation',
        'title': 'Positive Affirmation',
        'description': 'Say something kind to yourself. You deserve compassion and understanding.',
        'icon': Icons.psychology,
        'color': Colors.purple,
      },
      {
        'id': 'gentle_stretch',
        'title': 'Gentle Stretching',
        'description': 'Do some light stretches to release tension in your neck, shoulders, and back.',
        'icon': Icons.fitness_center,
        'color': Colors.teal,
      },
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Wellness Tips',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        ...wellnessTips.map((tip) => _buildTipCard(tip)),
      ],
    );
  }

  Widget _buildActivityCard(Map<String, dynamic> activity) {
    final isCompleted = _completedActivities.contains(activity['id']);
    
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                activity['icon'] as IconData,
                color: Colors.blue,
                size: 24,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          activity['title'] as String,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.grey[200],
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          activity['duration'] as String,
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.grey,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    activity['description'] as String,
                    style: const TextStyle(
                      color: Colors.grey,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton(
                      onPressed: () => _markActivityCompleted(activity['id'] as String),
                      child: Text(
                        isCompleted ? 'Completed ✓' : 'Mark as Completed',
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTipCard(Map<String, dynamic> tip) {
    final isCompleted = _completedActivities.contains(tip['id']);
    
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: (tip['color'] as Color).withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                tip['icon'] as IconData,
                color: tip['color'] as Color,
                size: 24,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    tip['title'] as String,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    tip['description'] as String,
                    style: const TextStyle(
                      color: Colors.grey,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton(
                      onPressed: () => _markActivityCompleted(tip['id'] as String),
                      child: Text(
                        isCompleted ? 'Completed ✓' : 'Mark as Completed',
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressSection() {
    final totalActivities = 9; // 1 breathing + 3 mindfulness + 5 tips
    final completedCount = _completedActivities.length;
    final progressPercentage = completedCount / totalActivities;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Your Progress',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '$completedCount of $totalActivities activities completed',
                  style: const TextStyle(color: Colors.grey),
                ),
                Text(
                  '${(progressPercentage * 100).round()}%',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            LinearProgressIndicator(
              value: progressPercentage,
              backgroundColor: Colors.grey[200],
              valueColor: AlwaysStoppedAnimation<Color>(
                Theme.of(context).colorScheme.primary,
              ),
            ),
            if (completedCount == totalActivities) ...[
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.celebration, color: Colors.green),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Congratulations! You\'ve completed all wellness activities today!',
                        style: TextStyle(
                          color: Colors.green,
                          fontWeight: FontWeight.w600,
                        ),
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

  Future<void> _markActivityCompleted(String activityId) async {
    if (_completedActivities.contains(activityId)) return;

    final appState = Provider.of<AppState>(context, listen: false);
    await appState.markActivityCompleted(activityId);
    
    setState(() {
      _completedActivities.add(activityId);
    });

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Activity completed! Great job! 🎉'),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 2),
        ),
      );
    }
  }
}
