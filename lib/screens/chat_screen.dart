import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_state.dart';
import '../services/firestore_service.dart';
import '../models/chat_message.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final FocusNode _focusNode = FocusNode();
  
  String? _currentChatId;
  List<ChatMessage> _messages = [];
  bool _isLoading = false;
  bool _isSendingMessage = false;

  @override
  void initState() {
    super.initState();
    _initializeChat();
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  Future<void> _initializeChat() async {
    final appState = Provider.of<AppState>(context, listen: false);
    
    setState(() {
      _isLoading = true;
    });

    try {
      final chatId = await appState.createChatSession();
      if (chatId != null) {
        setState(() {
          _currentChatId = chatId;
          _messages = [];
        });

        if (!appState.localOnlyMode) {
          // Listen to chat updates from Firestore
          final firestoreService = FirestoreService();
          firestoreService.getChatSession(chatId).listen((chatSession) {
            if (chatSession != null && mounted) {
              setState(() {
                _messages = chatSession.messages;
              });
              _scrollToBottom();
            }
          });
        }

        // Add welcome message
        _addWelcomeMessage(appState);
      }
    } catch (e) {
      print('Error initializing chat: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _addWelcomeMessage(AppState appState) {
    final welcomeMessage = ChatMessage(
      role: 'bot',
      text: appState.localOnlyMode
          ? 'Hello! I\'m MindMitra. While in local-only mode, I can\'t provide AI responses, but this space is yours to reflect and organize your thoughts.'
          : 'Hello! I\'m MindMitra, your AI mental health companion. I\'m here to listen, support, and provide guidance. How are you feeling today?',
      timestamp: DateTime.now(),
    );

    setState(() {
      _messages.add(welcomeMessage);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('AI Support Chat'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _initializeChat,
            tooltip: 'New Chat',
          ),
        ],
      ),
      body: Consumer<AppState>(
        builder: (context, appState, child) {
          if (_isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          return Column(
            children: [
              if (appState.localOnlyMode) _buildLocalModeNotice(),
              Expanded(
                child: _buildMessagesList(),
              ),
              _buildMessageInput(appState),
            ],
          );
        },
      ),
    );
  }

  Widget _buildLocalModeNotice() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.blue.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.blue.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Icon(Icons.info, color: Colors.blue[700], size: 20),
          const SizedBox(width: 8),
          const Expanded(
            child: Text(
              'Local-only mode: AI responses are disabled for privacy',
              style: TextStyle(fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessagesList() {
    if (_messages.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.chat_bubble_outline,
              size: 64,
              color: Colors.grey,
            ),
            SizedBox(height: 16),
            Text(
              'Start a conversation',
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.all(16),
      itemCount: _messages.length,
      itemBuilder: (context, index) {
        final message = _messages[index];
        return _buildMessageBubble(message);
      },
    );
  }

  Widget _buildMessageBubble(ChatMessage message) {
    final isUser = message.role == 'user';
    
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        mainAxisAlignment: isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!isUser) ...[
            CircleAvatar(
              radius: 16,
              backgroundColor: Theme.of(context).colorScheme.primary,
              child: const Icon(
                Icons.psychology,
                size: 16,
                color: Colors.white,
              ),
            ),
            const SizedBox(width: 8),
          ],
          Flexible(
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isUser 
                    ? Theme.of(context).colorScheme.primary
                    : Colors.grey[100],
                borderRadius: BorderRadius.circular(16).copyWith(
                  bottomLeft: isUser ? const Radius.circular(16) : const Radius.circular(4),
                  bottomRight: isUser ? const Radius.circular(4) : const Radius.circular(16),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    message.text,
                    style: TextStyle(
                      color: isUser ? Colors.white : Colors.black87,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _formatTime(message.timestamp),
                    style: TextStyle(
                      color: isUser 
                          ? Colors.white.withOpacity(0.7)
                          : Colors.grey[600],
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (isUser) ...[
            const SizedBox(width: 8),
            CircleAvatar(
              radius: 16,
              backgroundColor: Colors.grey[300],
              child: const Icon(
                Icons.person,
                size: 16,
                color: Colors.grey,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildMessageInput(AppState appState) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        border: Border(
          top: BorderSide(color: Colors.grey[300]!),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _messageController,
              focusNode: _focusNode,
              maxLines: null,
              textCapitalization: TextCapitalization.sentences,
              decoration: InputDecoration(
                hintText: 'Type your message...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: Colors.grey[100],
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 12,
                ),
              ),
              onSubmitted: (_) => _sendMessage(appState),
            ),
          ),
          const SizedBox(width: 8),
          Container(
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary,
              borderRadius: BorderRadius.circular(24),
            ),
            child: IconButton(
              icon: _isSendingMessage
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : const Icon(Icons.send, color: Colors.white),
              onPressed: _isSendingMessage ? null : () => _sendMessage(appState),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _sendMessage(AppState appState) async {
    final message = _messageController.text.trim();
    if (message.isEmpty || _currentChatId == null) return;

    setState(() {
      _isSendingMessage = true;
    });

    try {
      // Add user message immediately
      final userMessage = ChatMessage(
        role: 'user',
        text: message,
        timestamp: DateTime.now(),
      );

      setState(() {
        _messages.add(userMessage);
        _messageController.clear();
      });

      _scrollToBottom();

      // Check for crisis triggers
      if (appState.checkForCrisisTriggers(message)) {
        await _showCrisisAlert();
      }

      // Get bot response
      final botResponse = await appState.sendChatMessage(_currentChatId!, message);
      
      if (botResponse != null) {
        final botMessage = ChatMessage(
          role: 'bot',
          text: botResponse,
          timestamp: DateTime.now(),
        );

        if (appState.localOnlyMode) {
          // In local mode, add the message directly to the UI
          setState(() {
            _messages.add(botMessage);
          });
          _scrollToBottom();
        }
        // In cloud mode, the message will be added via Firestore listener
      }
    } catch (e) {
      print('Error sending message: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to send message. Please try again.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSendingMessage = false;
        });
      }
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  String _formatTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inMinutes < 1) {
      return 'Just now';
    } else if (difference.inHours < 1) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inDays < 1) {
      return '${difference.inHours}h ago';
    } else {
      return '${dateTime.day}/${dateTime.month} ${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')}';
    }
  }

  Future<void> _showCrisisAlert() async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: const Row(
            children: [
              Icon(Icons.warning, color: Colors.red, size: 28),
              SizedBox(width: 12),
              Text('Support Available'),
            ],
          ),
          content: const Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'I notice you might be going through a difficult time. While I\'m here to support you, please consider reaching out to a mental health professional.',
              ),
              SizedBox(height: 16),
              Text(
                'Crisis Helpline: AASRA +91-98204 66726',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('I understand'),
            ),
          ],
        );
      },
    );
  }
}
