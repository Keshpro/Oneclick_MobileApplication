import 'package:flutter/material.dart';
import 'provider_role_selection_screen.dart';

class ProviderRulesScreen extends StatefulWidget {
  const ProviderRulesScreen({super.key});

  @override
  State<ProviderRulesScreen> createState() =>
      _ProviderRulesScreenState();
}

class _ProviderRulesScreenState
    extends State<ProviderRulesScreen> {
  bool _accepted = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F7FC),

      appBar: AppBar(
        backgroundColor: const Color(0xFFF7F7FC),
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        title: const Text(
          'Earn with OneClick',
          style: TextStyle(
            fontWeight: FontWeight.w800,
          ),
        ),
      ),

      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding:
                    const EdgeInsets.fromLTRB(
                  24,
                  16,
                  24,
                  20,
                ),
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 64,
                      height: 64,
                      decoration: BoxDecoration(
                        gradient:
                            const LinearGradient(
                          colors: [
                            Color(0xFF5B4DFF),
                            Color(0xFF2E1FA6),
                          ],
                        ),
                        borderRadius:
                            BorderRadius.circular(20),
                      ),
                      child: const Icon(
                        Icons.handshake_outlined,
                        color: Colors.white,
                        size: 32,
                      ),
                    ),

                    const SizedBox(height: 22),

                    const Text(
                      'Provider Rules & Regulations',
                      style: TextStyle(
                        fontSize: 27,
                        fontWeight: FontWeight.w900,
                        color: Color(0xFF17152A),
                      ),
                    ),

                    const SizedBox(height: 10),

                    const Text(
                      'Please review these requirements before applying to provide services through OneClick.',
                      style: TextStyle(
                        color: Color(0xFF747187),
                        fontSize: 14,
                        height: 1.5,
                      ),
                    ),

                    const SizedBox(height: 28),

                    const _RuleCard(
                      number: '01',
                      title: 'Provide accurate information',
                      description:
                          'All personal, professional and verification information submitted must be accurate and belong to you.',
                    ),

                    const _RuleCard(
                      number: '02',
                      title: 'Valid documents required',
                      description:
                          'You must provide valid professional or licence information required for your selected provider role.',
                    ),

                    const _RuleCard(
                      number: '03',
                      title: 'Verification required',
                      description:
                          'Submitting an application does not automatically activate a provider account. OneClick must review and approve it first.',
                    ),

                    const _RuleCard(
                      number: '04',
                      title: 'Keep information updated',
                      description:
                          'Provider details, licences and professional information should remain accurate and up to date.',
                    ),

                    const _RuleCard(
                      number: '05',
                      title: 'Responsible service',
                      description:
                          'Providers are expected to use OneClick responsibly and provide services professionally and respectfully.',
                    ),

                    const _RuleCard(
                      number: '06',
                      title: 'Account review',
                      description:
                          'OneClick may review provider information when necessary and may restrict provider access when submitted information cannot be verified.',
                    ),

                    const SizedBox(height: 8),

                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius:
                            BorderRadius.circular(18),
                        border: Border.all(
                          color:
                              const Color(0xFFE4E2EC),
                        ),
                      ),
                      child: CheckboxListTile(
                        value: _accepted,
                        activeColor:
                            const Color(0xFF5B4DFF),
                        controlAffinity:
                            ListTileControlAffinity
                                .leading,
                        title: const Text(
                          'I have read and agree to the OneClick provider rules and regulations.',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight:
                                FontWeight.w600,
                            height: 1.4,
                          ),
                        ),
                        onChanged: (value) {
                          setState(() {
                            _accepted =
                                value ?? false;
                          });
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),

            Container(
              padding:
                  const EdgeInsets.fromLTRB(
                24,
                14,
                24,
                18,
              ),
              decoration: const BoxDecoration(
                color: Colors.white,
                border: Border(
                  top: BorderSide(
                    color: Color(0xFFE4E2EC),
                  ),
                ),
              ),
              child: SafeArea(
                top: false,
                child: SizedBox(
                  width: double.infinity,
                  height: 54,
                  child: ElevatedButton(
                    onPressed: !_accepted
                        ? null
                        : () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) =>
                                    const ProviderRoleSelectionScreen(),
                              ),
                            );
                          },
                    style:
                        ElevatedButton.styleFrom(
                      backgroundColor:
                          const Color(0xFF5B4DFF),
                      foregroundColor: Colors.white,
                      disabledBackgroundColor:
                          const Color(0xFFE1DFEA),
                      disabledForegroundColor:
                          const Color(0xFF9692A5),
                      elevation: 0,
                      shape:
                          RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.circular(
                          16,
                        ),
                      ),
                    ),
                    child: const Text(
                      'AGREE & CONTINUE',
                      style: TextStyle(
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _RuleCard extends StatelessWidget {
  final String number;
  final String title;
  final String description;

  const _RuleCard({
    required this.number,
    required this.title,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: const Color(0xFFE4E2EC),
        ),
      ),
      child: Row(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          Container(
            width: 40,
            height: 40,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: const Color(0xFF5B4DFF)
                  .withValues(alpha: .08),
              borderRadius:
                  BorderRadius.circular(12),
            ),
            child: Text(
              number,
              style: const TextStyle(
                color: Color(0xFF5B4DFF),
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Color(0xFF17152A),
                    fontSize: 14,
                    fontWeight:
                        FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  description,
                  style: const TextStyle(
                    color: Color(0xFF747187),
                    fontSize: 12.5,
                    height: 1.45,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}