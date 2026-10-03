import 'package:flutter/material.dart';

class AskAIVaultScreen extends StatefulWidget {
  const AskAIVaultScreen({super.key});

  @override
  State<AskAIVaultScreen> createState() => _AskAIVaultScreenState();
}

class _AskAIVaultScreenState extends State<AskAIVaultScreen> {
  static const Color background = Color(0xFFE9EBF2);
  static const Color purple = Color(0xFF6961FF);
  static const Color ink = Color(0xFF303344);
  static const Color muted = Color(0xFF686C7C);

  final TextEditingController _questionController =
      TextEditingController();

  @override
  void dispose() {
    _questionController.dispose();
    super.dispose();
  }

  void _message(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _askQuestion() {
    final question = _questionController.text.trim();

    if (question.isEmpty) {
      _message('Enter a question first.');
      return;
    }

    _message('Vault AI question submitted');
    _questionController.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: background,

      // =========================================================
      // APP BAR
      // =========================================================

      appBar: AppBar(
        backgroundColor: background,
        foregroundColor: ink,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        leadingWidth: 72,
        leading: Padding(
          padding: const EdgeInsets.only(left: 16),
          child: _roundButton(
            icon: Icons.arrow_back,
            onTap: () => Navigator.pop(context),
          ),
        ),
        title: const Text(
          'Ask AI Vault',
          style: TextStyle(
            color: ink,
            fontSize: 20,
            fontWeight: FontWeight.w700,
          ),
        ),
        actions: [
          _roundButton(
            icon: Icons.more_vert,
            onTap: () => _message('More options'),
          ),
          const SizedBox(width: 8),
          _roundButton(
            icon: Icons.person_outline,
            purpleButton: true,
            onTap: () => _message('Profile'),
          ),
          const SizedBox(width: 16),
        ],
      ),

      // =========================================================
      // BODY
      // =========================================================

      body: SafeArea(
        top: false,
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(
                  20,
                  20,
                  20,
                  24,
                ),
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(
                      maxWidth: 650,
                    ),
                    child: Column(
                      crossAxisAlignment:
                          CrossAxisAlignment.stretch,
                      children: [
                        // =========================================
                        // ZERO KNOWLEDGE AI
                        // =========================================

                        _surface(
                          child: Row(
                            crossAxisAlignment:
                                CrossAxisAlignment.start,
                            children: [
                              _iconBadge(
                                Icons.lock_outline,
                                purple,
                              ),
                              const SizedBox(width: 14),
                              const Expanded(
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Flexible(
                                          child: Text(
                                            'ZERO-KNOWLEDGE AI',
                                            style: TextStyle(
                                              color: purple,
                                              fontSize: 15,
                                              fontWeight:
                                                  FontWeight.w600,
                                            ),
                                          ),
                                        ),
                                        SizedBox(width: 7),
                                        Icon(
                                          Icons.circle,
                                          size: 8,
                                          color: Color(
                                            0xFF9892FF,
                                          ),
                                        ),
                                      ],
                                    ),
                                    SizedBox(height: 8),
                                    Text(
                                      'Q&A operates strictly over selected documents. '
                                      'Passwords, PINs, and master backup codes are '
                                      'excluded from AI model context by hardware '
                                      'enclave policy.',
                                      style: TextStyle(
                                        color: muted,
                                        fontSize: 13,
                                        height: 1.55,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 28),

                        // =========================================
                        // INCLUDED DOCUMENTS
                        // =========================================

                        Row(
                          children: [
                            const Expanded(
                              child: Text(
                                'INCLUDED DOCUMENTS (3)',
                                style: TextStyle(
                                  color: muted,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                            TextButton(
                              onPressed: () {
                                _message(
                                  'Manage AI document context',
                                );
                              },
                              child: const Text(
                                'Manage Context',
                                style: TextStyle(
                                  color: purple,
                                ),
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 8),

                        Wrap(
                          spacing: 12,
                          runSpacing: 12,
                          children: [
                            _documentChip(
                              icon:
                                  Icons.description_outlined,
                              title: 'Lease Agreement',
                              subtitle: '14 pgs',
                            ),
                            _documentChip(
                              icon: Icons.laptop_mac,
                              title: 'MacBook Pro Warranty',
                              subtitle: '2 pgs • Active',
                            ),
                            _documentChip(
                              icon:
                                  Icons.health_and_safety_outlined,
                              title: 'Health Insurance',
                              subtitle: '6 pgs • Active',
                            ),
                          ],
                        ),

                        const SizedBox(height: 32),

                        // =========================================
                        // USER QUESTION
                        // =========================================

                        Align(
                          alignment: Alignment.centerRight,
                          child: Container(
                            constraints:
                                const BoxConstraints(
                              maxWidth: 510,
                            ),
                            padding: const EdgeInsets.all(18),
                            decoration: BoxDecoration(
                              color: background,
                              borderRadius:
                                  BorderRadius.circular(22),
                              boxShadow: _shadow(),
                            ),
                            child: const Text(
                              'When does my laptop warranty end, and '
                              'does it cover accidental liquid damage?',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: ink,
                                fontSize: 14,
                                height: 1.45,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(height: 10),

                        const Align(
                          alignment: Alignment.centerRight,
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                'Today 10:42 AM',
                                style: TextStyle(
                                  color: muted,
                                  fontSize: 11,
                                ),
                              ),
                              SizedBox(width: 5),
                              Icon(
                                Icons.done_all,
                                size: 16,
                                color: purple,
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 26),

                        // =========================================
                        // AI RESPONSE
                        // =========================================

                        _surface(
                          child: Column(
                            crossAxisAlignment:
                                CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Container(
                                    padding:
                                        const EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: 7,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.white
                                          .withAlpha(130),
                                      borderRadius:
                                          BorderRadius.circular(
                                        18,
                                      ),
                                    ),
                                    child: const Row(
                                      mainAxisSize:
                                          MainAxisSize.min,
                                      children: [
                                        Icon(
                                          Icons.auto_awesome,
                                          size: 17,
                                          color: purple,
                                        ),
                                        SizedBox(width: 6),
                                        Text(
                                          'Verified from Source Documents',
                                          style: TextStyle(
                                            color: purple,
                                            fontSize: 11,
                                            fontWeight:
                                                FontWeight.w600,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const Spacer(),
                                  IconButton(
                                    tooltip: 'Copy answer',
                                    onPressed: () {
                                      _message(
                                        'Answer copied',
                                      );
                                    },
                                    icon: const Icon(
                                      Icons.copy_outlined,
                                      color: muted,
                                    ),
                                  ),
                                  IconButton(
                                    tooltip:
                                        'Verification details',
                                    onPressed: () {
                                      _message(
                                        'Verification details',
                                      );
                                    },
                                    icon: const Icon(
                                      Icons
                                          .verified_user_outlined,
                                      color: muted,
                                    ),
                                  ),
                                ],
                              ),

                              const SizedBox(height: 20),

                              const Text.rich(
                                TextSpan(
                                  style: TextStyle(
                                    color: ink,
                                    fontSize: 14,
                                    height: 1.6,
                                  ),
                                  children: [
                                    TextSpan(
                                      text:
                                          'Your AppleCare+ coverage for MacBook Pro M2 ends on ',
                                    ),
                                    TextSpan(
                                      text:
                                          'November 24, 2025',
                                      style: TextStyle(
                                        color: purple,
                                        decoration:
                                            TextDecoration
                                                .underline,
                                      ),
                                    ),
                                    TextSpan(
                                      text:
                                          ' (renewal required).\n\n',
                                    ),
                                    TextSpan(
                                      text:
                                          'Accidental liquid damage is covered with a standard ',
                                    ),
                                    TextSpan(
                                      text:
                                          '\$299 service tier fee',
                                      style: TextStyle(
                                        color: purple,
                                      ),
                                    ),
                                    TextSpan(
                                      text:
                                          ' plus local tax.',
                                    ),
                                  ],
                                ),
                              ),

                              const SizedBox(height: 24),

                              const Row(
                                children: [
                                  Icon(
                                    Icons.link,
                                    color: muted,
                                    size: 19,
                                  ),
                                  SizedBox(width: 8),
                                  Text(
                                    'HARDWARE ENCLAVE CITATIONS',
                                    style: TextStyle(
                                      color: muted,
                                      fontSize: 12,
                                      fontWeight:
                                          FontWeight.w700,
                                    ),
                                  ),
                                ],
                              ),

                              const SizedBox(height: 14),

                              _citationCard(
                                icon: Icons.smartphone,
                                title:
                                    'MacBook Pro Warranty',
                                page: 'pg 2, §4.1',
                                description:
                                    'Clause 4.1: Coverage Limits & Inclusions',
                              ),

                              const SizedBox(height: 12),

                              _citationCard(
                                icon:
                                    Icons.receipt_long_outlined,
                                title: 'AppleCare Terms',
                                page: 'pg 1',
                                description:
                                    'Tier 2 Liquid Contact Damage',
                              ),

                              const SizedBox(height: 18),

                              Container(
                                width: double.infinity,
                                padding:
                                    const EdgeInsets.all(15),
                                decoration: BoxDecoration(
                                  color:
                                      Colors.white.withAlpha(75),
                                  borderRadius:
                                      BorderRadius.circular(20),
                                ),
                                child: const Row(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                  children: [
                                    Icon(
                                      Icons.info_outline,
                                      color: muted,
                                      size: 20,
                                    ),
                                    SizedBox(width: 10),
                                    Expanded(
                                      child: Text.rich(
                                        TextSpan(
                                          style: TextStyle(
                                            color: muted,
                                            fontSize: 12,
                                            height: 1.45,
                                          ),
                                          children: [
                                            TextSpan(
                                              text:
                                                  'Data Limitation: ',
                                              style: TextStyle(
                                                color: ink,
                                                fontWeight:
                                                    FontWeight
                                                        .w600,
                                              ),
                                            ),
                                            TextSpan(
                                              text:
                                                  'Specific battery health threshold claim terms are not present in the uploaded warranty schedule.',
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 12),

                        const Padding(
                          padding:
                              EdgeInsets.symmetric(
                            horizontal: 8,
                          ),
                          child: Row(
                            children: [
                              Text(
                                'Enclave inference: 218ms',
                                style: TextStyle(
                                  color: muted,
                                  fontSize: 11,
                                ),
                              ),
                              SizedBox(width: 12),
                              Text(
                                '•',
                                style: TextStyle(
                                  color: muted,
                                ),
                              ),
                              SizedBox(width: 12),
                              Text(
                                'Inspect Proof Hash',
                                style: TextStyle(
                                  color: purple,
                                  fontSize: 11,
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 30),

                        // =========================================
                        // SUGGESTED INQUIRIES
                        // =========================================

                        const Row(
                          children: [
                            Icon(
                              Icons.lightbulb_outline,
                              color: purple,
                              size: 20,
                            ),
                            SizedBox(width: 8),
                            Text(
                              'SUGGESTED INQUIRIES',
                              style: TextStyle(
                                color: muted,
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 14),

                        _suggestion(
                          Icons.real_estate_agent_outlined,
                          'What is my apartment lease cancellation penalty?',
                        ),

                        const SizedBox(height: 12),

                        _suggestion(
                          Icons
                              .health_and_safety_outlined,
                          'Does my health insurance cover dental out-of-network?',
                        ),

                        const SizedBox(height: 12),

                        _suggestion(
                          Icons.event_note_outlined,
                          'Summary of all upcoming renewal deadlines',
                        ),

                        const SizedBox(height: 20),
                      ],
                    ),
                  ),
                ),
              ),
            ),

            // =============================================
            // QUESTION BOX
            // =============================================

            _questionBox(),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // QUESTION INPUT
  // ============================================================

  Widget _questionBox() {
    return Container(
      color: background,
      padding: const EdgeInsets.fromLTRB(
        20,
        10,
        20,
        18,
      ),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(
            maxWidth: 650,
          ),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.fromLTRB(
                  8,
                  4,
                  6,
                  4,
                ),
                decoration: BoxDecoration(
                  color: background,
                  borderRadius:
                      BorderRadius.circular(30),
                  boxShadow: _shadow(),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 46,
                      height: 46,
                      decoration: BoxDecoration(
                        color: background,
                        shape: BoxShape.circle,
                        boxShadow: _shadow(),
                      ),
                      child: const Icon(
                        Icons.mic_none,
                        color: muted,
                      ),
                    ),

                    const SizedBox(width: 10),

                    Expanded(
                      child: TextField(
                        controller:
                            _questionController,
                        onSubmitted: (_) =>
                            _askQuestion(),
                        decoration:
                            const InputDecoration(
                          border: InputBorder.none,
                          hintText:
                              'Ask a question about your vault documents...',
                          hintStyle: TextStyle(
                            color: Color(
                              0xFF9699A8,
                            ),
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ),

                    InkWell(
                      onTap: _askQuestion,
                      borderRadius:
                          BorderRadius.circular(50),
                      child: Container(
                        width: 48,
                        height: 48,
                        decoration:
                            const BoxDecoration(
                          color: purple,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.arrow_upward,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 12),

              const Row(
                mainAxisAlignment:
                    MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.shield_outlined,
                    size: 15,
                    color: muted,
                  ),
                  SizedBox(width: 6),
                  Text(
                    'Zero-knowledge encrypted local query',
                    style: TextStyle(
                      color: muted,
                      fontSize: 10.5,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ============================================================
  // DOCUMENT CHIP
  // ============================================================

  Widget _documentChip({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 14,
        vertical: 12,
      ),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(22),
        boxShadow: _shadow(),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            color: purple,
            size: 21,
          ),
          const SizedBox(width: 10),
          Column(
            crossAxisAlignment:
                CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  color: ink,
                  fontSize: 12.5,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: const TextStyle(
                  color: muted,
                  fontSize: 10.5,
                ),
              ),
            ],
          ),
          const SizedBox(width: 12),
          const Icon(
            Icons.close,
            color: muted,
            size: 17,
          ),
        ],
      ),
    );
  }

  // ============================================================
  // CITATION
  // ============================================================

  Widget _citationCard({
    required IconData icon,
    required String title,
    required String page,
    required String description,
  }) {
    return InkWell(
      onTap: () {
        _message('Opening $title');
      },
      borderRadius: BorderRadius.circular(22),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: background,
          borderRadius: BorderRadius.circular(22),
          boxShadow: _shadow(),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: purple,
              size: 22,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          title,
                          style: const TextStyle(
                            color: ink,
                            fontSize: 13,
                            fontWeight:
                                FontWeight.w600,
                          ),
                        ),
                      ),
                      const SizedBox(width: 7),
                      Text(
                        page,
                        style: const TextStyle(
                          color: purple,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 3),
                  Text(
                    description,
                    maxLines: 1,
                    overflow:
                        TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: muted,
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            const Icon(
              Icons.arrow_forward,
              color: muted,
              size: 18,
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // SUGGESTION
  // ============================================================

  Widget _suggestion(
    IconData icon,
    String text,
  ) {
    return InkWell(
      onTap: () {
        setState(() {
          _questionController.text = text;
        });
      },
      borderRadius: BorderRadius.circular(25),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(
          horizontal: 18,
          vertical: 17,
        ),
        decoration: BoxDecoration(
          color: background,
          borderRadius: BorderRadius.circular(25),
          boxShadow: _shadow(),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: purple,
              size: 21,
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                text,
                style: const TextStyle(
                  color: ink,
                  fontSize: 13,
                ),
              ),
            ),
            const Icon(
              Icons.north_west,
              color: muted,
              size: 18,
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // ROUND BUTTON
  // ============================================================

  Widget _roundButton({
    required IconData icon,
    required VoidCallback onTap,
    bool purpleButton = false,
  }) {
    return InkWell(
      onTap: onTap,
      customBorder: const CircleBorder(),
      child: Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          color:
              purpleButton ? purple : background,
          shape: BoxShape.circle,
          boxShadow: _shadow(),
        ),
        child: Icon(
          icon,
          color: purpleButton
              ? Colors.white
              : muted,
        ),
      ),
    );
  }

  // ============================================================
  // SURFACE
  // ============================================================

  Widget _surface({
    required Widget child,
    EdgeInsetsGeometry padding =
        const EdgeInsets.all(18),
  }) {
    return Container(
      width: double.infinity,
      padding: padding,
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(24),
        boxShadow: _shadow(),
      ),
      child: child,
    );
  }

  Widget _iconBadge(
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(11),
      decoration: BoxDecoration(
        color: background,
        shape: BoxShape.circle,
        boxShadow: _shadow(),
      ),
      child: Icon(
        icon,
        color: color,
        size: 22,
      ),
    );
  }

  static List<BoxShadow> _shadow() {
    return [
      BoxShadow(
        color: Colors.white.withAlpha(220),
        offset: const Offset(-5, -5),
        blurRadius: 12,
      ),
      BoxShadow(
        color: const Color(
          0xFFB9BEC9,
        ).withAlpha(105),
        offset: const Offset(5, 5),
        blurRadius: 12,
      ),
    ];
  }
}