import 'package:flutter/material.dart';
import 'add_subscription_screen.dart';

class SubscriptionsScreen extends StatefulWidget {
  const SubscriptionsScreen({super.key});

  @override
  State<SubscriptionsScreen> createState() =>
      _SubscriptionsScreenState();
}

class _SubscriptionsScreenState extends State<SubscriptionsScreen> {
  static const Color bg = Color(0xFFF9F7FF);
  static const Color surface = Color(0xFFFBF9FF);
  static const Color ink = Color(0xFF292B43);
  static const Color muted = Color(0xFF6F7185);
  static const Color purple = Color(0xFF5E5BFF);
  static const Color purple2 = Color(0xFF7C35FF);
  static const Color danger = Color(0xFFCE334B);

  String selectedFilter = 'All';
  String selectedCurrency = 'USD';

  final List<SubscriptionItem> subscriptions = const [
    SubscriptionItem(
      name: 'Adobe Creative Cloud',
      subtitle: 'All Apps Individual • Monthly',
      price: '\$54.99',
      renewal: 'Renews in 5 days',
      usage: 'Often used',
      icon: Icons.layers_outlined,
      category: 'Productivity & AI',
      priceHiked: true,
    ),
    SubscriptionItem(
      name: 'ChatGPT Plus',
      subtitle: 'OpenAI • Monthly',
      price: '\$20.00',
      renewal: 'Renews Dec 01',
      usage: 'Daily usage',
      icon: Icons.psychology_outlined,
      category: 'Productivity & AI',
    ),
    SubscriptionItem(
      name: 'Claude Pro',
      subtitle: 'Anthropic • Monthly',
      price: '\$20.00',
      renewal: 'Renews Dec 04',
      usage: 'Rarely used',
      icon: Icons.memory_outlined,
      category: 'Productivity & AI',
    ),
    SubscriptionItem(
      name: 'Spotify Family',
      subtitle: 'Premium 6 Accounts • Monthly',
      price: '\$19.99',
      renewal: 'Renews Nov 24',
      usage: 'Often used',
      icon: Icons.music_note,
      category: 'Entertainment & Media',
    ),
    SubscriptionItem(
      name: 'Netflix Standard',
      subtitle: '1080p 2-Screens • Monthly',
      price: '\$15.99',
      renewal: 'Renews Nov 19',
      usage: 'Unused this month',
      icon: Icons.tv_outlined,
      category: 'Entertainment & Media',
    ),
    SubscriptionItem(
      name: 'iCloud+ 2TB',
      subtitle: 'Apple Family Storage • Monthly',
      price: '\$9.99',
      renewal: 'Renews Nov 28',
      usage: '1.4 TB / 2 TB used',
      icon: Icons.cloud_done_outlined,
      category: 'Storage & Utilities',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bg,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 30),
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 600),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildHeader(),

                        const SizedBox(height: 24),

                        _buildForecastCard(),

                        const SizedBox(height: 28),

                        _buildAICheckup(),

                        const SizedBox(height: 34),

                        _buildRenewals(),

                        const SizedBox(height: 30),

                        _buildFilters(),

                        const SizedBox(height: 28),

                        _buildCategory(
                          title: 'PRODUCTIVITY & AI',
                          total: '\$94.99/mo',
                          icon: Icons.terminal_outlined,
                          items: subscriptions
                              .where(
                                (item) =>
                                    item.category ==
                                    'Productivity & AI',
                              )
                              .toList(),
                        ),

                        const SizedBox(height: 28),

                        _buildCategory(
                          title: 'ENTERTAINMENT & MEDIA',
                          total: '\$35.98/mo',
                          icon: Icons.play_circle_outline,
                          items: subscriptions
                              .where(
                                (item) =>
                                    item.category ==
                                    'Entertainment & Media',
                              )
                              .toList(),
                        ),

                        const SizedBox(height: 28),

                        _buildCategory(
                          title: 'STORAGE & UTILITIES',
                          total: '\$9.99/mo',
                          icon: Icons.cloud_outlined,
                          items: subscriptions
                              .where(
                                (item) =>
                                    item.category ==
                                    'Storage & Utilities',
                              )
                              .toList(),
                        ),

                        const SizedBox(height: 38),

                        _buildAddSubscriptionButton(),

                        const SizedBox(height: 35),
                      ],
                    ),
                  ),
                ),
              ),
            ),

            _buildBottomNavigation(),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // HEADER
  // ============================================================

  Widget _buildHeader() {
    return Row(
      children: [
        _circleIcon(
          Icons.shield_outlined,
          color: purple,
        ),

        const SizedBox(width: 14),

        const Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'My Subscriptions',
                style: TextStyle(
                  color: ink,
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                ),
              ),
              SizedBox(height: 3),
              Row(
                children: [
                  Icon(
                    Icons.circle,
                    color: purple,
                    size: 7,
                  ),
                  SizedBox(width: 6),
                  Text(
                    'VAULT',
                    style: TextStyle(
                      color: muted,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),

        _headerButton(
          Icons.search,
          () => _message('Search subscriptions'),
        ),

        const SizedBox(width: 9),

        Stack(
          clipBehavior: Clip.none,
          children: [
            _headerButton(
              Icons.notifications_none_rounded,
              () => _message('Notifications'),
            ),
            Positioned(
              right: 7,
              top: 5,
              child: Container(
                width: 9,
                height: 9,
                decoration: const BoxDecoration(
                  color: purple,
                  shape: BoxShape.circle,
                ),
              ),
            ),
          ],
        ),

        const SizedBox(width: 9),

        Container(
          width: 47,
          height: 47,
          decoration: const BoxDecoration(
            color: purple,
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.person_outline_rounded,
            color: Colors.white,
          ),
        ),
      ],
    );
  }

  // ============================================================
  // FORECAST
  // ============================================================

  Widget _buildForecastCard() {
    return _card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text(
                'SPENDING FORECAST',
                style: TextStyle(
                  color: Color(0xFF484A68),
                  fontWeight: FontWeight.w700,
                  fontSize: 14,
                  letterSpacing: .3,
                ),
              ),

              const SizedBox(width: 8),

              const Icon(
                Icons.circle,
                color: purple,
                size: 8,
              ),

              const Spacer(),

              _currencyButton('USD'),

              const SizedBox(width: 6),

              _currencyButton('EUR'),
            ],
          ),

          const SizedBox(height: 26),

          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              const Text(
                '\$148.50',
                style: TextStyle(
                  color: ink,
                  fontSize: 42,
                  fontWeight: FontWeight.w700,
                  letterSpacing: -1,
                ),
              ),

              const SizedBox(width: 8),

              const Padding(
                padding: EdgeInsets.only(bottom: 7),
                child: Text(
                  '/mo',
                  style: TextStyle(
                    color: Color(0xFF4E506A),
                    fontSize: 18,
                  ),
                ),
              ),

              const Spacer(),

              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 7,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF8FB),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: _shadow(),
                ),
                child: const Row(
                  children: [
                    Icon(
                      Icons.trending_up,
                      color: danger,
                      size: 17,
                    ),
                    SizedBox(width: 5),
                    Text(
                      '+4.2%',
                      style: TextStyle(
                        color: danger,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 2),

          Row(
            children: [
              const Text(
                'Projected ',
                style: TextStyle(
                  color: muted,
                  fontSize: 14,
                ),
              ),
              const Text(
                '\$1,782.00',
                style: TextStyle(
                  color: ink,
                  fontWeight: FontWeight.w700,
                  fontSize: 14,
                ),
              ),
              const Text(
                '/year',
                style: TextStyle(
                  color: muted,
                  fontSize: 14,
                ),
              ),
              const Spacer(),
              Text(
                'vs last month',
                style: TextStyle(
                  color: muted.withOpacity(.9),
                  fontSize: 11,
                ),
              ),
            ],
          ),

          const SizedBox(height: 30),

          Row(
            children: [
              Expanded(
                child: _statCard(
                  number: '9',
                  label: 'Active Subs',
                  color: purple,
                ),
              ),

              const SizedBox(width: 14),

              Expanded(
                child: _statCard(
                  number: '2',
                  label: 'Trials Ending',
                  color: purple2,
                ),
              ),

              const SizedBox(width: 14),

              Expanded(
                child: _statCard(
                  number: '1',
                  label: 'Price Hike',
                  color: danger,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _currencyButton(String currency) {
    final selected = selectedCurrency == currency;

    return GestureDetector(
      onTap: () {
        setState(() {
          selectedCurrency = currency;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 8,
        ),
        decoration: BoxDecoration(
          color: const Color(0xFFFAF9FF),
          borderRadius: BorderRadius.circular(22),
          boxShadow: selected ? _shadow() : null,
        ),
        child: Text(
          currency == 'USD' ? 'USD \$' : 'EUR €',
          style: TextStyle(
            color: selected ? purple : ink,
            fontWeight:
                selected ? FontWeight.w600 : FontWeight.w400,
          ),
        ),
      ),
    );
  }

  Widget _statCard({
    required String number,
    required String label,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(
        vertical: 16,
        horizontal: 5,
      ),
      decoration: BoxDecoration(
        color: const Color(0xFFFBFAFF),
        borderRadius: BorderRadius.circular(28),
        boxShadow: _shadow(),
      ),
      child: Column(
        children: [
          Text(
            number,
            style: TextStyle(
              color: color,
              fontSize: 20,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            label,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Color(0xFF56586F),
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // AI CHECKUP
  // ============================================================

  Widget _buildAICheckup() {
    return _card(
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: const BoxDecoration(
                  color: Color(0xFFFBFAFF),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.auto_awesome,
                  color: purple2,
                  size: 28,
                ),
              ),

              const SizedBox(width: 15),

              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            'AI Checkup Ready',
                            style: TextStyle(
                              color: ink,
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                        SizedBox(width: 8),
                        _NewBadge(),
                      ],
                    ),

                    SizedBox(height: 6),

                    Text.rich(
                      TextSpan(
                        style: TextStyle(
                          color: Color(0xFF54566E),
                          fontSize: 14,
                          height: 1.4,
                        ),
                        children: [
                          TextSpan(
                            text: '3 optimizations found. '
                                'You can trim up to ',
                          ),
                          TextSpan(
                            text: '\$34.00/mo',
                            style: TextStyle(
                              color: purple,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          TextSpan(
                            text:
                                ' in duplicate streaming & dormant tiers.',
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),

          Align(
            alignment: Alignment.centerRight,
            child: _pillButton(
              icon: Icons.bolt,
              text: 'Run Checkup',
              color: purple,
              onTap: () {
                _message('AI subscription checkup started.');
              },
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // ACTION REQUIRED
  // ============================================================

  Widget _buildRenewals() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Row(
          children: [
            Expanded(
              child: Text(
                'ACTION REQUIRED & RENEWALS',
                style: TextStyle(
                  color: Color(0xFF4A4C68),
                  fontWeight: FontWeight.w700,
                  fontSize: 14,
                  letterSpacing: .3,
                ),
              ),
            ),
            Text(
              '2 Urgent',
              style: TextStyle(
                color: purple,
                fontWeight: FontWeight.w600,
                fontSize: 13,
              ),
            ),
          ],
        ),

        const SizedBox(height: 16),

        SizedBox(
          height: 195,
          child: ListView(
            scrollDirection: Axis.horizontal,
            children: [
              _renewalCard(
                title: 'HBO Max',
                subtitle: 'Free 7-Day Trial',
                badge: '3 days left',
                description:
                    'Converts to \$15.99/mo on Nov 08 unless cancelled.',
                icon: Icons.movie_outlined,
              ),

              const SizedBox(width: 16),

              _renewalCard(
                title: 'Figma Pro',
                subtitle: 'Annual Billing',
                badge: '7 days',
                description:
                    'Auto-charge amount will renew automatically.',
                icon: Icons.brush_outlined,
                urgent: false,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _renewalCard({
    required String title,
    required String subtitle,
    required String badge,
    required String description,
    required IconData icon,
    bool urgent = true,
  }) {
    return Container(
      width: 340,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: surface,
        borderRadius: BorderRadius.circular(28),
        boxShadow: _shadow(),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _circleIcon(
                icon,
                color: purple,
                size: 45,
              ),

              const SizedBox(width: 12),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        color: ink,
                        fontWeight: FontWeight.w700,
                        fontSize: 16,
                      ),
                    ),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        color: purple,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),

              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 11,
                  vertical: 7,
                ),
                decoration: BoxDecoration(
                  color: urgent
                      ? const Color(0xFFFF7087)
                      : const Color(0xFFF1F0FF),
                  borderRadius: BorderRadius.circular(9),
                ),
                child: Text(
                  badge,
                  style: TextStyle(
                    color: urgent ? Colors.white : purple,
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 14),

          Text(
            description,
            style: const TextStyle(
              color: Color(0xFF5E6078),
              fontSize: 13,
              height: 1.4,
            ),
          ),

          const Spacer(),

          Row(
            children: [
              Expanded(
                child: TextButton(
                  onPressed: () {
                    _message('$title cancellation selected.');
                  },
                  child: Text(
                    'Cancel',
                    style: TextStyle(
                      color: urgent ? danger : muted,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),

              Expanded(
                child: TextButton(
                  onPressed: () {
                    _message('$title kept.');
                  },
                  child: const Text(
                    'Keep Plan',
                    style: TextStyle(
                      color: purple,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ============================================================
  // FILTERS
  // ============================================================

  Widget _buildFilters() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          _filter('All', '11'),
          const SizedBox(width: 10),
          _filter('Active', '9'),
          const SizedBox(width: 10),
          _filter('Free Trials', '2'),
          const SizedBox(width: 10),
          _filter('Cancelled', '4'),
        ],
      ),
    );
  }

  Widget _filter(String title, String count) {
    final selected = selectedFilter == title;

    return GestureDetector(
      onTap: () {
        setState(() {
          selectedFilter = title;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: 17,
          vertical: 10,
        ),
        decoration: BoxDecoration(
          color: const Color(0xFFFAF9FF),
          borderRadius: BorderRadius.circular(24),
          boxShadow: _shadow(),
        ),
        child: Text(
          '$title ($count)',
          style: TextStyle(
            color: selected ? purple : const Color(0xFF55576E),
            fontSize: 13,
            fontWeight:
                selected ? FontWeight.w600 : FontWeight.w400,
          ),
        ),
      ),
    );
  }

  // ============================================================
  // CATEGORY
  // ============================================================

  Widget _buildCategory({
    required String title,
    required String total,
    required IconData icon,
    required List<SubscriptionItem> items,
  }) {
    return Column(
      children: [
        Row(
          children: [
            Icon(
              icon,
              color: purple,
              size: 19,
            ),

            const SizedBox(width: 9),

            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  color: Color(0xFF4A4C68),
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  letterSpacing: .3,
                ),
              ),
            ),

            Text(
              total,
              style: const TextStyle(
                color: Color(0xFF4A4C68),
                fontWeight: FontWeight.w700,
                fontSize: 14,
              ),
            ),
          ],
        ),

        const SizedBox(height: 15),

        ...items.map(
          (item) => Padding(
            padding: const EdgeInsets.only(bottom: 17),
            child: _subscriptionCard(item),
          ),
        ),
      ],
    );
  }

  Widget _subscriptionCard(SubscriptionItem item) {
    return _card(
      padding: const EdgeInsets.all(19),
      child: Column(
        children: [
          Row(
            children: [
              _circleIcon(
                item.icon,
                color: purple,
                size: 50,
              ),

              const SizedBox(width: 14),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            item.name,
                            style: const TextStyle(
                              color: ink,
                              fontSize: 17,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),

                        if (item.priceHiked) ...[
                          const SizedBox(width: 7),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 7,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFF7188),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Text(
                              'Price Hiked',
                              style: TextStyle(
                                color: Color(0xFF7D0921),
                                fontSize: 10,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),

                    const SizedBox(height: 4),

                    Text(
                      item.subtitle,
                      style: const TextStyle(
                        color: Color(0xFF55576F),
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(width: 10),

              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    item.price,
                    style: const TextStyle(
                      color: ink,
                      fontSize: 17,
                      fontWeight: FontWeight.w700,
                    ),
                  ),

                  const SizedBox(height: 3),

                  const Text(
                    '/mo',
                    style: TextStyle(
                      color: Color(0xFF575970),
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ],
          ),

          const SizedBox(height: 18),

          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFF5F3FA),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.circle,
                      size: 7,
                      color: item.usage.contains('Rarely') ||
                              item.usage.contains('Unused')
                          ? muted
                          : purple,
                    ),
                    const SizedBox(width: 5),
                    Text(
                      item.usage,
                      style: const TextStyle(
                        color: Color(0xFF56586E),
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),

              const Spacer(),

              Text(
                item.renewal,
                style: const TextStyle(
                  color: Color(0xFF56586E),
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ============================================================
  // ADD SUBSCRIPTION
  // ============================================================

Widget _buildAddSubscriptionButton() {
  return Center(
    child: _pillButton(
      icon: Icons.add_circle,
      text: 'Add Subscription',
      color: purple,
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const AddSubscriptionScreen(),
          ),
        );
      },
    ),
  );
}

  // ============================================================
  // BOTTOM NAVIGATION
  // ============================================================

  Widget _buildBottomNavigation() {
    return Container(
      padding: const EdgeInsets.fromLTRB(28, 14, 28, 18),
      decoration: BoxDecoration(
        color: bg,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(.04),
            blurRadius: 12,
            offset: const Offset(0, -3),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _navItem(
              Icons.home_outlined,
              'Home',
              false,
            ),
            _navItem(
              Icons.folder_copy_outlined,
              'Vault',
              false,
            ),
            _navItem(
              Icons.credit_card,
              'Subs',
              true,
            ),
            _navItem(
              Icons.handshake_outlined,
              'Sharing',
              false,
            ),
          ],
        ),
      ),
    );
  }

  Widget _navItem(
    IconData icon,
    String label,
    bool selected,
  ) {
    return InkWell(
      borderRadius: BorderRadius.circular(25),
      onTap: () {
        if (!selected) {
          _message('$label navigation will be connected.');
        }
      },
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 8,
        ),
        decoration: selected
            ? BoxDecoration(
                color: const Color(0xFFF4F2FC),
                borderRadius: BorderRadius.circular(25),
                boxShadow: _shadow(),
              )
            : null,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: selected ? purple : muted,
              size: 24,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                color: selected ? purple : muted,
                fontSize: 11,
                fontWeight:
                    selected ? FontWeight.w700 : FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // REUSABLE
  // ============================================================

  Widget _card({
    required Widget child,
    EdgeInsetsGeometry padding = const EdgeInsets.all(24),
  }) {
    return Container(
      width: double.infinity,
      padding: padding,
      decoration: BoxDecoration(
        color: surface,
        borderRadius: BorderRadius.circular(30),
        boxShadow: _shadow(),
      ),
      child: child,
    );
  }

  Widget _circleIcon(
    IconData icon, {
    required Color color,
    double size = 50,
  }) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: const Color(0xFFFBFAFF),
        shape: BoxShape.circle,
        boxShadow: _shadow(),
      ),
      child: Icon(
        icon,
        color: color,
        size: size * .48,
      ),
    );
  }

  Widget _headerButton(
    IconData icon,
    VoidCallback onTap,
  ) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(50),
      child: _circleIcon(
        icon,
        color: muted,
        size: 46,
      ),
    );
  }

  Widget _pillButton({
    required IconData icon,
    required String text,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(28),
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: 22,
          vertical: 14,
        ),
        decoration: BoxDecoration(
          color: const Color(0xFFFBFAFF),
          borderRadius: BorderRadius.circular(28),
          boxShadow: _shadow(),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: color,
              size: 20,
            ),
            const SizedBox(width: 9),
            Text(
              text,
              style: TextStyle(
                color: color,
                fontSize: 15,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<BoxShadow> _shadow() {
    return [
      BoxShadow(
        color: Colors.white.withOpacity(.9),
        offset: const Offset(-4, -4),
        blurRadius: 10,
      ),
      BoxShadow(
        color: Colors.black.withOpacity(.07),
        offset: const Offset(5, 7),
        blurRadius: 15,
      ),
    ];
  }

  // ============================================================
  // DIALOGS / DEMO ACTIONS
  // ============================================================

  void _message(String text) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(text),
      ),
    );
  }

  void _showAddSubscriptionDialog() {
    final nameController = TextEditingController();
    final priceController = TextEditingController();

    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Add Subscription'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: 'Subscription name',
                  hintText: 'e.g. YouTube Premium',
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: priceController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Monthly price',
                  prefixText: '\$ ',
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext);
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext);

                _message(
                  'Subscription UI added. Backend connection comes next.',
                );
              },
              child: const Text(
                'Add',
                style: TextStyle(
                  color: purple,
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

// ================================================================
// SUBSCRIPTION MODEL
// ================================================================

class SubscriptionItem {
  final String name;
  final String subtitle;
  final String price;
  final String renewal;
  final String usage;
  final IconData icon;
  final String category;
  final bool priceHiked;

  const SubscriptionItem({
    required this.name,
    required this.subtitle,
    required this.price,
    required this.renewal,
    required this.usage,
    required this.icon,
    required this.category,
    this.priceHiked = false,
  });
}

// ================================================================
// NEW BADGE
// ================================================================

class _NewBadge extends StatelessWidget {
  const _NewBadge();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 7,
        vertical: 4,
      ),
      decoration: BoxDecoration(
        color: const Color(0xFF823AFF),
        borderRadius: BorderRadius.circular(7),
      ),
      child: const Text(
        'NEW',
        style: TextStyle(
          color: Colors.white,
          fontSize: 10,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}