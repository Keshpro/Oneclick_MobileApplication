import 'dart:async';
import 'package:flutter/material.dart';
import 'package:firebase_ai/firebase_ai.dart'; // Required for Gemini AI connection

class AiAssistantScreen extends StatefulWidget {
  const AiAssistantScreen({super.key});

  @override
  State<AiAssistantScreen> createState() => _AiAssistantScreenState();
}

class _AiAssistantScreenState extends State<AiAssistantScreen> {
  // ============================================================
  // COLORS: Defining the OneClick Health color palette
  // ============================================================
  static const Color _background = Color(0xFFF4FBF8);
  static const Color _primary = Color(0xFF059669);
  static const Color _primaryDark = Color(0xFF064E3B);
  static const Color _mint = Color(0xFFD1FAE5);
  static const Color _text = Color(0xFF10231D);
  static const Color _muted = Color(0xFF64748B);

  // ============================================================
  // CONTROLLERS: To manage text input and scrolling
  // ============================================================
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  // ============================================================
  // CHAT DATA: Storing the conversation state
  // ============================================================
  final List<_ChatMessage> _messages = [];
  bool _isTyping = false; // Tracks if AI is currently thinking

  // ============================================================
  // FIREBASE AI: Variables to hold the Gemini model and chat session
  // ============================================================
  late final GenerativeModel _model;
  late final ChatSession _chat;

  // Preset questions for the user to tap quickly
  final List<String> _quickQuestions = [
    'Which doctor should I see?',
    'I have a headache',
    'I have stomach pain',
    'Find a cardiologist',
  ];

  // ============================================================
  // INITIALIZE: Runs once when the screen is opened
  // ============================================================
  @override
  void initState() {
    super.initState();

    // Setup the AI connection
    _initializeAI();

    // Add the first welcome message from the AI to the screen
    _messages.add(
      const _ChatMessage(
        text: 'Hi! I’m OneClick Health AI 👋\n\n'
            'I can help you understand general health information, '
            'choose the right type of doctor, and guide you through '
            'OneClick Health.\n\n'
            'How can I help you today?',
        isUser: false,
      ),
    );
  }

  // Setup Firebase AI and set strict rules for medical safety
  void _initializeAI() {
    _model = FirebaseAI.googleAI().generativeModel(
      model: 'gemini-3.8-flash', // FIXED: Changed to the correct Gemini model version
      systemInstruction: Content.system('''
You are OneClick Health AI.

You are a healthcare information and navigation assistant inside
the OneClick mobile application.

YOUR PURPOSE:
1. Provide simple general health information.
2. Help users understand what type of doctor may be appropriate.
3. Help users navigate healthcare services.
4. Explain common health topics in easy language.
5. Encourage users to contact qualified healthcare professionals
   when professional assessment is appropriate.

DOCTOR SPECIALTIES YOU MAY RECOMMEND:
- General Physician
- Cardiologist
- Dermatologist
- Pediatrician
- Dentist
- Ophthalmologist
- ENT Specialist

IMPORTANT MEDICAL SAFETY RULES:
- Never claim that you have diagnosed the user.
- Never provide a definitive medical diagnosis.
- Never prescribe medication.
- Never provide medication dosages.
- Never tell a user to stop prescribed medication.
- Never tell a user to change prescribed medication.
- Do not replace a doctor or qualified healthcare professional.

If the user describes potentially serious symptoms, tell the user that urgent professional medical attention may be needed and advise them to contact their local emergency medical service.

COMMUNICATION STYLE:
- Be friendly, calm, and concise.
- Use simple English.
- Do not pretend that AI advice is a medical diagnosis.
'''),
    );

    // Start a continuous chat session to remember previous messages
    _chat = _model.startChat();
  }

  // ============================================================
  // DISPOSE: Clean up memory when screen is closed
  // ============================================================
  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  // ============================================================
  // SEND MESSAGE: Logic for handling user input and AI response
  // ============================================================
  Future<void> _sendMessage([String? quickMessage]) async {
    // Get text from quick button or input field
    final String message = quickMessage ?? _messageController.text.trim();

    // Do nothing if empty or AI is already typing
    if (message.isEmpty || _isTyping) return;

    // Close the keyboard
    FocusScope.of(context).unfocus();

    // 1. Show user message on screen and show typing indicator
    setState(() {
      _messages.add(_ChatMessage(text: message, isUser: true));
      _isTyping = true;
    });

    _messageController.clear();
    _scrollToBottom();

    // 2. LOCAL EMERGENCY CHECK (Before asking Gemini)
    final emergency = _detectEmergency(message);
    if (emergency) {
      await Future.delayed(const Duration(milliseconds: 400));
      if (!mounted) return;

      // Immediately show emergency warning without waiting for network
      setState(() {
        _messages.add(
          const _ChatMessage(
            text: 'This could require urgent medical attention.\n\n'
                'Please contact your local emergency medical service '
                'or go to the nearest emergency department now. '
                'Do not rely on this assistant for an emergency.',
            isUser: false,
            recommendation: _DoctorRecommendation(
              title: 'Emergency Care',
              subtitle: 'Seek immediate professional medical help',
              icon: Icons.emergency_rounded,
              isEmergency: true,
            ),
          ),
        );
        _isTyping = false;
      });
      _scrollToBottom();
      return; // Stop here, do not send to Gemini
    }

    // 3. SEND TO GEMINI AI
    try {
      final response = await _chat.sendMessage(Content.text(message));
      if (!mounted) return;

      final String responseText = response.text?.trim() ?? '';
      final String aiText = responseText.isNotEmpty
          ? responseText
          : 'Sorry, I could not generate a response. Please try again.';

      // Check if AI or user mentioned a doctor specialty
      final recommendation = _detectRecommendation(message, aiText);

      // Add AI response to the screen
      setState(() {
        _messages.add(
          _ChatMessage(
            text: aiText,
            isUser: false,
            recommendation: recommendation,
          ),
        );
        _isTyping = false; // Stop loading animation
      });
      _scrollToBottom();
      
    } catch (error) {
      // Handle Network or API errors
      debugPrint('OneClick Health AI Error: $error');
      if (!mounted) return;

      setState(() {
        _messages.add(
          const _ChatMessage(
            text: 'I’m having trouble connecting to the AI service right now.\n\n'
                'Please check your internet connection and try again.',
            isUser: false,
          ),
        );
        _isTyping = false;
      });
      _scrollToBottom();
    }
  }

  // ============================================================
  // EMERGENCY DETECTION: Checks if user input has danger words
  // ============================================================
  bool _detectEmergency(String message) {
    final text = message.toLowerCase();
    const emergencyWords = [
      'chest pain', 'cant breathe', "can't breathe", 'cannot breathe',
      'difficulty breathing', 'severe breathing', 'unconscious',
      'not breathing', 'severe bleeding', 'bleeding heavily', 'stroke',
      'heart attack', 'overdose', 'suicide', 'suicidal', 'kill myself',
    ];

    for (final word in emergencyWords) {
      if (text.contains(word)) return true;
    }
    return false;
  }

  // ============================================================
  // DOCTOR RECOMMENDATION DETECTION: Matches text to specialties
  // ============================================================
  _DoctorRecommendation? _detectRecommendation(String userMessage, String aiResponse) {
    final text = '${userMessage.toLowerCase()} ${aiResponse.toLowerCase()}';

    if (_containsAny(text, ['cardiologist', 'cardiology', 'heart specialist'])) {
      return const _DoctorRecommendation(title: 'Cardiologist', subtitle: 'Heart & cardiovascular specialist', icon: Icons.favorite_rounded);
    }
    if (_containsAny(text, ['dermatologist', 'dermatology', 'skin specialist'])) {
      return const _DoctorRecommendation(title: 'Dermatologist', subtitle: 'Skin, hair & nail specialist', icon: Icons.face_rounded);
    }
    if (_containsAny(text, ['pediatrician', 'paediatrician', 'pediatric', 'paediatric'])) {
      return const _DoctorRecommendation(title: 'Pediatrician', subtitle: 'Healthcare for children', icon: Icons.child_care_rounded);
    }
    if (_containsAny(text, ['dentist', 'dental'])) {
      return const _DoctorRecommendation(title: 'Dentist', subtitle: 'Dental & oral health', icon: Icons.medical_services_rounded);
    }
    if (_containsAny(text, ['ophthalmologist', 'ophthalmology', 'eye specialist'])) {
      return const _DoctorRecommendation(title: 'Ophthalmologist', subtitle: 'Eye & vision specialist', icon: Icons.visibility_rounded);
    }
    if (_containsAny(text, ['ent specialist', 'otolaryngologist'])) {
      return const _DoctorRecommendation(title: 'ENT Specialist', subtitle: 'Ear, nose & throat specialist', icon: Icons.hearing_rounded);
    }
    if (_containsAny(text, ['general physician', 'general doctor', 'primary care doctor'])) {
      return const _DoctorRecommendation(title: 'General Physician', subtitle: 'General medical assessment', icon: Icons.health_and_safety_rounded);
    }
    return null;
  }

  // Helper function to check if text contains any word from a list
  bool _containsAny(String text, List<String> words) {
    for (final word in words) {
      if (text.contains(word)) return true;
    }
    return false;
  }

  // ============================================================
  // SCROLL: Automatically scroll to the newest message
  // ============================================================
  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_scrollController.hasClients) return;
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeOut,
      );
    });
  }

  // ============================================================
  // DOCTOR ACTION: Bottom sheet when clicking a doctor suggestion
  // ============================================================
  void _openDoctorSearch(_DoctorRecommendation recommendation) {
    if (recommendation.isEmergency) {
      _showEmergencySheet();
      return;
    }

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) {
        return Container(
          padding: const EdgeInsets.fromLTRB(22, 12, 22, 28),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
          ),
          child: SafeArea(
            top: false,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(width: 44, height: 5, decoration: BoxDecoration(color: const Color(0xFFE2E8F0), borderRadius: BorderRadius.circular(20))),
                const SizedBox(height: 24),
                Container(
                  width: 62, height: 62,
                  decoration: const BoxDecoration(color: _mint, shape: BoxShape.circle),
                  child: Icon(recommendation.icon, color: _primary, size: 30),
                ),
                const SizedBox(height: 16),
                Text(recommendation.title, style: const TextStyle(color: _text, fontSize: 20, fontWeight: FontWeight.w800)),
                const SizedBox(height: 7),
                Text(recommendation.subtitle, textAlign: TextAlign.center, style: const TextStyle(color: _muted, fontSize: 13)),
                const SizedBox(height: 22),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.pop(sheetContext); // Close bottom sheet
                      // This sends the selected doctor specialty back to Patient Home
                      Navigator.pop(context, recommendation.title); 
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _primary, foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 15),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                    ),
                    icon: const Icon(Icons.search_rounded),
                    label: const Text('Explore Doctors', style: TextStyle(fontWeight: FontWeight.w700)),
                  ),
                ),
                const SizedBox(height: 7),
                TextButton(
                  onPressed: () => Navigator.pop(sheetContext),
                  child: const Text('Continue chatting', style: TextStyle(color: _primary, fontWeight: FontWeight.w700)),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // ============================================================
  // EMERGENCY SHEET: Shown when emergency care is recommended
  // ============================================================
  void _showEmergencySheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) {
        return Container(
          padding: const EdgeInsets.fromLTRB(22, 12, 22, 28),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
          ),
          child: SafeArea(
            top: false,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(width: 44, height: 5, decoration: BoxDecoration(color: const Color(0xFFE2E8F0), borderRadius: BorderRadius.circular(20))),
                const SizedBox(height: 22),
                const CircleAvatar(radius: 31, backgroundColor: Color(0xFFFEE2E2), child: Icon(Icons.emergency_rounded, color: Color(0xFFDC2626), size: 31)),
                const SizedBox(height: 15),
                const Text('Urgent medical care', style: TextStyle(color: _text, fontSize: 20, fontWeight: FontWeight.w800)),
                const SizedBox(height: 9),
                const Text('If this is a medical emergency, contact your local emergency medical service or go to the nearest emergency department immediately.', textAlign: TextAlign.center, style: TextStyle(color: _muted, height: 1.5)),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(sheetContext),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFDC2626), foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 15),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                    ),
                    child: const Text('Close'),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // ============================================================
  // INFO: Bottom sheet explaining app limitations
  // ============================================================
  void _showInfo() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          padding: const EdgeInsets.fromLTRB(24, 12, 24, 30),
          decoration: const BoxDecoration(color: Colors.white, borderRadius: BorderRadius.vertical(top: Radius.circular(28))),
          child: const SafeArea(
            top: false,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(height: 12),
                Icon(Icons.health_and_safety_rounded, color: _primary, size: 40),
                SizedBox(height: 15),
                Text('About Health AI', style: TextStyle(color: _text, fontSize: 20, fontWeight: FontWeight.w800)),
                SizedBox(height: 12),
                Text('OneClick Health AI provides general health information and navigation support. It does not diagnose conditions, prescribe medication, or replace a qualified healthcare professional.', textAlign: TextAlign.center, style: TextStyle(color: _muted, fontSize: 13, height: 1.55)),
              ],
            ),
          ),
        );
      },
    );
  }

  // ============================================================
  // BUILD: The main UI layout of the screen
  // ============================================================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _background,

      // Top App Bar
      appBar: AppBar(
        backgroundColor: _primaryDark,
        foregroundColor: Colors.white,
        elevation: 0,
        titleSpacing: 0,
        title: const Row(
          children: [
            CircleAvatar(radius: 19, backgroundColor: _mint, child: Icon(Icons.auto_awesome_rounded, color: _primaryDark, size: 20)),
            SizedBox(width: 11),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('OneClick Health AI', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w800)),
                  SizedBox(height: 2),
                  Row(
                    children: [
                      CircleAvatar(radius: 3, backgroundColor: Color(0xFF34D399)),
                      SizedBox(width: 5),
                      Text('Powered by Gemini', style: TextStyle(color: Color(0xFFA7F3D0), fontSize: 10.5)),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            tooltip: 'About Health AI',
            onPressed: _showInfo,
            icon: const Icon(Icons.info_outline_rounded),
          ),
          const SizedBox(width: 5),
        ],
      ),

      // Screen Body
      body: Column(
        children: [
          // Safety Disclaimer Notice at the top
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            color: const Color(0xFFFFFBEB),
            child: const Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.info_outline_rounded, color: Color(0xFFD97706), size: 17),
                SizedBox(width: 8),
                Expanded(child: Text('General guidance only — not a medical diagnosis.', style: TextStyle(color: Color(0xFF92400E), fontSize: 11.5, fontWeight: FontWeight.w600))),
              ],
            ),
          ),

          // Main Chat Message List
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.fromLTRB(14, 18, 14, 14),
              itemCount: _messages.length + (_isTyping ? 1 : 0),
              itemBuilder: (context, index) {
                // Show typing animation if AI is loading
                if (index == _messages.length && _isTyping) {
                  return const _TypingBubble();
                }

                final message = _messages[index];
                return _MessageBubble(
                  message: message,
                  onRecommendationTap: message.recommendation == null ? null : () => _openDoctorSearch(message.recommendation!),
                );
              },
            ),
          ),

          // Quick Questions (Only show at the start of conversation)
          if (_messages.length <= 2)
            Container(
              height: 47,
              padding: const EdgeInsets.only(bottom: 7),
              child: ListView.separated(
                padding: const EdgeInsets.symmetric(horizontal: 13),
                scrollDirection: Axis.horizontal,
                itemCount: _quickQuestions.length,
                separatorBuilder: (_, __) => const SizedBox(width: 8),
                itemBuilder: (context, index) {
                  return ActionChip(
                    onPressed: () => _sendMessage(_quickQuestions[index]),
                    backgroundColor: Colors.white,
                    side: const BorderSide(color: Color(0xFFDCEFE7)),
                    avatar: const Icon(Icons.auto_awesome_rounded, size: 15, color: _primary),
                    label: Text(_quickQuestions[index], style: const TextStyle(color: _primaryDark, fontSize: 11.5, fontWeight: FontWeight.w600)),
                  );
                },
              ),
            ),

          // Bottom Input Area
          _buildInputArea(),
        ],
      ),
    );
  }

  // ============================================================
  // INPUT AREA WIDGET: Text field and send button
  // ============================================================
  Widget _buildInputArea() {
    return SafeArea(
      top: false,
      child: Container(
        padding: const EdgeInsets.fromLTRB(12, 9, 12, 10),
        decoration: BoxDecoration(
          color: Colors.white,
          border: const Border(top: BorderSide(color: Color(0xFFE5E7EB))),
          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 14, offset: const Offset(0, -5))],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Expanded(
              child: Container(
                constraints: const BoxConstraints(minHeight: 50, maxHeight: 120),
                decoration: BoxDecoration(color: const Color(0xFFF1F5F4), borderRadius: BorderRadius.circular(25)),
                child: TextField(
                  controller: _messageController,
                  minLines: 1, maxLines: 4,
                  textCapitalization: TextCapitalization.sentences,
                  textInputAction: TextInputAction.newline,
                  decoration: const InputDecoration(
                    hintText: 'Ask about your health...',
                    hintStyle: TextStyle(color: _muted, fontSize: 13),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(horizontal: 18, vertical: 15),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
            Material(
              color: _primary,
              shape: const CircleBorder(),
              child: InkWell(
                onTap: _isTyping ? null : () => _sendMessage(),
                customBorder: const CircleBorder(),
                child: SizedBox(
                  width: 50, height: 50,
                  child: _isTyping
                      ? const Padding(padding: EdgeInsets.all(15), child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                      : const Icon(Icons.arrow_upward_rounded, color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ============================================================
// MODELS: Data structures for chat and recommendations
// ============================================================
class _ChatMessage {
  final String text;
  final bool isUser;
  final _DoctorRecommendation? recommendation;

  const _ChatMessage({required this.text, required this.isUser, this.recommendation});
}

class _DoctorRecommendation {
  final String title;
  final String subtitle;
  final IconData icon;
  final bool isEmergency;

  const _DoctorRecommendation({required this.title, required this.subtitle, required this.icon, this.isEmergency = false});
}

// ============================================================
// CHAT BUBBLE WIDGET: Displays a single message
// ============================================================
class _MessageBubble extends StatelessWidget {
  final _ChatMessage message;
  final VoidCallback? onRecommendationTap;

  const _MessageBubble({required this.message, required this.onRecommendationTap});

  @override
  Widget build(BuildContext context) {
    final isUser = message.isUser;

    return Padding(
      padding: const EdgeInsets.only(bottom: 13),
      child: Row(
        mainAxisAlignment: isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          // AI Avatar
          if (!isUser) ...[
            const CircleAvatar(radius: 16, backgroundColor: Color(0xFFD1FAE5), child: Icon(Icons.auto_awesome_rounded, color: Color(0xFF047857), size: 16)),
            const SizedBox(width: 8),
          ],

          // Message Container
          Flexible(
            child: Column(
              crossAxisAlignment: isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
              children: [
                Container(
                  constraints: const BoxConstraints(maxWidth: 320),
                  padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 12),
                  decoration: BoxDecoration(
                    color: isUser ? const Color(0xFF059669) : Colors.white,
                    borderRadius: BorderRadius.only(
                      topLeft: const Radius.circular(18), topRight: const Radius.circular(18),
                      bottomLeft: Radius.circular(isUser ? 18 : 5), bottomRight: Radius.circular(isUser ? 5 : 18),
                    ),
                    border: !isUser ? Border.all(color: const Color(0xFFE1EEE9)) : null,
                  ),
                  child: Text(message.text, style: TextStyle(color: isUser ? Colors.white : const Color(0xFF1F2937), fontSize: 13.5, height: 1.5)),
                ),

                // Doctor Recommendation Card (if AI suggests a doctor)
                if (message.recommendation != null) ...[
                  const SizedBox(height: 8),
                  _RecommendationCard(recommendation: message.recommendation!, onTap: onRecommendationTap),
                ],
              ],
            ),
          ),
          if (isUser) const SizedBox(width: 5),
        ],
      ),
    );
  }
}

// ============================================================
// RECOMMENDATION CARD WIDGET: Visual card for doctor types
// ============================================================
class _RecommendationCard extends StatelessWidget {
  final _DoctorRecommendation recommendation;
  final VoidCallback? onTap;

  const _RecommendationCard({required this.recommendation, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final emergency = recommendation.isEmergency;
    final color = emergency ? const Color(0xFFDC2626) : const Color(0xFF059669);
    final lightColor = emergency ? const Color(0xFFFEE2E2) : const Color(0xFFD1FAE5);

    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(17),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(17),
        child: Container(
          constraints: const BoxConstraints(maxWidth: 320),
          padding: const EdgeInsets.all(13),
          decoration: BoxDecoration(borderRadius: BorderRadius.circular(17), border: Border.all(color: emergency ? const Color(0xFFFECACA) : const Color(0xFFBBE7D6))),
          child: Row(
            children: [
              Container(width: 44, height: 44, decoration: BoxDecoration(color: lightColor, borderRadius: BorderRadius.circular(13)), child: Icon(recommendation.icon, color: color, size: 23)),
              const SizedBox(width: 11),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(recommendation.title, style: const TextStyle(color: Color(0xFF1F2937), fontSize: 13.5, fontWeight: FontWeight.w800)),
                    const SizedBox(height: 3),
                    Text(recommendation.subtitle, style: const TextStyle(color: Color(0xFF64748B), fontSize: 10.5, height: 1.3)),
                  ],
                ),
              ),
              const SizedBox(width: 5),
              Icon(Icons.arrow_forward_ios_rounded, color: color, size: 15),
            ],
          ),
        ),
      ),
    );
  }
}

// ============================================================
// TYPING ANIMATION WIDGET: 3 animated dots
// ============================================================
class _TypingBubble extends StatefulWidget {
  const _TypingBubble();
  @override
  State<_TypingBubble> createState() => _TypingBubbleState();
}

class _TypingBubbleState extends State<_TypingBubble> {
  int _activeDot = 0;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(milliseconds: 350), (_) {
      if (!mounted) return;
      setState(() {
        _activeDot = (_activeDot + 1) % 3;
      });
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 13),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          const CircleAvatar(radius: 16, backgroundColor: Color(0xFFD1FAE5), child: Icon(Icons.auto_awesome_rounded, color: Color(0xFF047857), size: 16)),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(color: Colors.white, borderRadius: const BorderRadius.only(topLeft: Radius.circular(18), topRight: Radius.circular(18), bottomRight: Radius.circular(18), bottomLeft: Radius.circular(5)), border: Border.all(color: const Color(0xFFE1EEE9))),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: List.generate(3, (index) {
                final active = index == _activeDot;
                return AnimatedContainer(
                  duration: const Duration(milliseconds: 200), margin: const EdgeInsets.symmetric(horizontal: 2),
                  width: active ? 8 : 6, height: active ? 8 : 6,
                  decoration: BoxDecoration(color: active ? const Color(0xFF059669) : const Color(0xFFA7D7C5), shape: BoxShape.circle),
                );
              }),
            ),
          ),
        ],
      ),
    );
  }
}