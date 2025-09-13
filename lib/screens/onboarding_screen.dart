import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_state.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  final TextEditingController _nameController = TextEditingController();

  final List<OnboardingPage> _pages = [
    OnboardingPage(
      icon: Icons.psychology,
      title: 'Welcome to MindMitra',
      description: 'Your personal AI-powered mental health companion, here to support your wellness journey.',
    ),
    OnboardingPage(
      icon: Icons.book,
      title: 'Daily Journaling',
      description: 'Express your thoughts and feelings. Our AI analyzes your entries to provide insights into your emotional patterns.',
    ),
    OnboardingPage(
      icon: Icons.chat_bubble_outline,
      title: 'AI Support Chat',
      description: 'Chat with our compassionate AI whenever you need someone to listen and provide supportive guidance.',
    ),
    OnboardingPage(
      icon: Icons.insights,
      title: 'Mood Tracking',
      description: 'Visualize your emotional journey with detailed charts and insights to understand your mental health patterns.',
    ),
    OnboardingPage(
      icon: Icons.self_improvement,
      title: 'Wellness Activities',
      description: 'Access guided breathing exercises, mindfulness tips, and wellness activities tailored for you.',
    ),
  ];

  @override
  void dispose() {
    _nameController.dispose();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                onPageChanged: (index) {
                  setState(() {
                    _currentPage = index;
                  });
                },
                itemCount: _pages.length + 1, // +1 for name input page
                itemBuilder: (context, index) {
                  if (index < _pages.length) {
                    return _buildOnboardingPage(_pages[index]);
                  } else {
                    return _buildNameInputPage();
                  }
                },
              ),
            ),
            _buildBottomSection(),
          ],
        ),
      ),
    );
  }

  Widget _buildOnboardingPage(OnboardingPage page) {
    return Padding(
      padding: const EdgeInsets.all(32.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(30),
            ),
            child: Icon(
              page.icon,
              size: 60,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
          const SizedBox(height: 40),
          Text(
            page.title,
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          Text(
            page.description,
            style: const TextStyle(
              fontSize: 16,
              color: Colors.grey,
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildNameInputPage() {
    return Padding(
      padding: const EdgeInsets.all(32.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.person,
            size: 80,
            color: Color(0xFF6B73FF),
          ),
          const SizedBox(height: 40),
          const Text(
            'What should we call you?',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          const Text(
            'This helps us personalize your experience. You can always change this later.',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey,
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 40),
          TextField(
            controller: _nameController,
            decoration: InputDecoration(
              hintText: 'Enter your name (optional)',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 16,
              ),
            ),
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 18),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomSection() {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        children: [
          // Page indicators
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(
              _pages.length + 1,
              (index) => Container(
                margin: const EdgeInsets.symmetric(horizontal: 4),
                width: _currentPage == index ? 24 : 8,
                height: 8,
                decoration: BoxDecoration(
                  color: _currentPage == index
                      ? Theme.of(context).colorScheme.primary
                      : Colors.grey.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
          ),
          const SizedBox(height: 24),
          // Navigation buttons
          Row(
            children: [
              if (_currentPage > 0)
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      _pageController.previousPage(
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeInOut,
                      );
                    },
                    child: const Text('Back'),
                  ),
                ),
              if (_currentPage > 0) const SizedBox(width: 16),
              Expanded(
                child: ElevatedButton(
                  onPressed: _handleNext,
                  child: Text(
                    _currentPage == _pages.length ? 'Get Started' : 'Next',
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _handleNext() {
    if (_currentPage < _pages.length) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      _completeOnboarding();
    }
  }

  Future<void> _completeOnboarding() async {
    final appState = Provider.of<AppState>(context, listen: false);
    
    // Update user profile with name if provided
    if (appState.userProfile != null) {
      final updatedProfile = appState.userProfile!.copyWith(
        displayName: _nameController.text.trim().isEmpty 
            ? 'Anonymous User' 
            : _nameController.text.trim(),
      );
      await appState.updateUserProfile(updatedProfile);
    }
    
    // Mark onboarding as complete
    await appState.completeOnboarding();
    
    if (!mounted) return;
    
    // Navigate to home screen
    Navigator.pushReplacementNamed(context, '/home');
  }
}

class OnboardingPage {
  final IconData icon;
  final String title;
  final String description;

  OnboardingPage({
    required this.icon,
    required this.title,
    required this.description,
  });
}
