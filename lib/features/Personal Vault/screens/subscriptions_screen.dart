import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'subscription_details_screen.dart';
import 'ai_subscription_checkup_screen.dart';
import 'dashboard.dart';
import 'vault_screen.dart';
import 'sharing_center_screen.dart';

import '../services/subscription_service.dart';
import '../services/exchange_rate_service.dart';

class SubscriptionsScreen extends StatefulWidget {
  const SubscriptionsScreen({super.key});
  @override
  State<SubscriptionsScreen> createState() => _SubscriptionsScreenState();
}

class _SubscriptionsScreenState extends State<SubscriptionsScreen> {
  static const Color bg = Color(0xFFF8FAFC);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color ink = Color(0xFF0F172A);
  static const Color muted = Color(0xFF64748B);
  static const Color purple = Color(0xFF4F46E5);
  static const Color purple2 = Color(0xFF9333EA);
  static const Color danger = Color(0xFFF43F5E);

  final SubscriptionService _subscriptionService = SubscriptionService();
  final ExchangeRateService _exchangeRateService = ExchangeRateService();

  double? _usdToLkrRate = 300.0;
  bool _loadingExchangeRate = false;

  String selectedFilter = 'All';
  String selectedCurrency = 'USD';
  String searchQuery = '';
  List<SubscriptionItem> subscriptions = [];

  @override
  void initState() {
    super.initState();
    _fetchExchangeRate();
    if (FirebaseAuth.instance.currentUser != null) {
      _loadSubscriptions();
    }
  }

  Future<void> _fetchExchangeRate() async {
    try {
      final rate = await _exchangeRateService.getUsdToLkrRate();
      if (mounted && rate != null) {
        setState(() {
          _usdToLkrRate = rate;
          _loadingExchangeRate = false;
        });
      } else if (mounted) {
        setState(() => _loadingExchangeRate = false);
      }
    } catch (_) {
      if (mounted) setState(() => _loadingExchangeRate = false);
    }
  }

  void _loadSubscriptions() {
    _subscriptionService.getSubscriptions().listen((records) {
      if (!mounted) return;

      setState(() {
        subscriptions = records.map((record) {
          final double parsedAmount =
              double.tryParse(record.price.replaceAll(RegExp(r'[^0-9.]'), '')) ?? 0.0;
          return SubscriptionItem(
            id: record.id,
            name: record.name,
            subtitle: record.subtitle,
            price: record.price,
            renewal: record.renewal,
            usage: record.usage,
            icon: Icons.subscriptions_outlined,
            category: record.category,
            priceHiked: record.priceHiked,
            status: record.status,
            amount: parsedAmount,
            currency: record.price.contains('LKR') ? 'LKR' : 'USD',
          );
        }).toList();
      });
    });
  }

  String _statusKey(String status) {
    final normalized = status.trim().toLowerCase();
    return normalized == 'free trials' ? 'free trial' : normalized;
  }

  bool _matchesStatus(SubscriptionItem item, String filter) =>
      filter == 'All' || _statusKey(item.status) == _statusKey(filter);

  int _countFor(String filter) =>
      subscriptions.where((item) => _matchesStatus(item, filter)).length;

  double _monthlyCost(Iterable<SubscriptionItem> items) => items
      .where((item) => _statusKey(item.status) == 'active')
      .fold<double>(
        0,
        (sum, item) =>
            sum +
            (double.tryParse(item.price.replaceAll(RegExp(r'[^0-9.]'), '')) ??
                0),
      );

  double _monthlyCostInCurrency(
      Iterable<SubscriptionItem> items, String currency) {
    double total = _monthlyCost(items);
    if (currency == 'LKR' && _usdToLkrRate != null) {
      return total * _usdToLkrRate!;
    }
    return total;
  }

  String _formattedMoney(double amountUsd) {
    if (selectedCurrency == 'LKR' && _usdToLkrRate != null) {
      final lkrAmount = amountUsd * _usdToLkrRate!;
      return 'LKR ${lkrAmount.toStringAsFixed(0)}';
    }
    return '\$${amountUsd.toStringAsFixed(2)}';
  }

  double? _monthlyChangePercent() {
    if (subscriptions.isEmpty) return null;
    return 2.5; 
  }

  List<SubscriptionItem> get filteredSubscriptions {
    final query = searchQuery.trim().toLowerCase();
    return subscriptions.where((item) {
      final matchesSearch =
          item.name.toLowerCase().contains(query) ||
          item.subtitle.toLowerCase().contains(query);
      return matchesSearch && _matchesStatus(item, selectedFilter);
    }).toList();
  }

  Future<void> _deleteSubscription(SubscriptionItem item) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Delete Subscription'),
          content: Text('Are you sure you want to delete "${item.name}"?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, false),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(dialogContext, true),
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );

    if (confirmed != true) return;

    try {
      await _subscriptionService.deleteSubscription(item.id);
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Subscription deleted')));
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to delete subscription: $e')),
      );
    }
  }

  Future<void> _editSubscription(SubscriptionItem item) async {
    final nameController = TextEditingController(text: item.name);
    final subtitleController = TextEditingController(text: item.subtitle);
    final priceController = TextEditingController(text: item.price);
    final renewalController = TextEditingController(text: item.renewal);
    final usageController = TextEditingController(text: item.usage);
    final categoryController = TextEditingController(text: item.category);

    String status = item.status;
    bool priceHiked = item.priceHiked;

    final result = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text('Edit Subscription'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: nameController,
                      decoration: const InputDecoration(labelText: 'Name'),
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: subtitleController,
                      decoration: const InputDecoration(labelText: 'Subtitle'),
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: priceController,
                      decoration: const InputDecoration(labelText: 'Price'),
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: renewalController,
                      decoration: const InputDecoration(labelText: 'Renewal'),
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: usageController,
                      decoration: const InputDecoration(labelText: 'Usage'),
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: categoryController,
                      decoration: const InputDecoration(labelText: 'Category'),
                    ),
                    const SizedBox(height: 10),
                    DropdownButtonFormField<String>(
                      initialValue: status,
                      decoration: const InputDecoration(labelText: 'Status'),
                      items: const [
                        DropdownMenuItem(value: 'Active', child: Text('Active')),
                        DropdownMenuItem(value: 'Free Trial', child: Text('Free Trial')),
                        DropdownMenuItem(value: 'Cancelled', child: Text('Cancelled')),
                      ],
                      onChanged: (value) {
                        if (value != null) {
                          setDialogState(() => status = value);
                        }
                      },
                    ),
                    SwitchListTile(
                      contentPadding: EdgeInsets.zero,
                      title: const Text('Price Hiked'),
                      value: priceHiked,
                      onChanged: (value) => setDialogState(() => priceHiked = value),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(dialogContext, false),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: () => Navigator.pop(dialogContext, true),
                  child: const Text('Save'),
                ),
              ],
            );
          },
        );
      },
    );

    if (result != true) {
      nameController.dispose();
      subtitleController.dispose();
      priceController.dispose();
      renewalController.dispose();
      usageController.dispose();
      categoryController.dispose();
      return;
    }

    try {
      await _subscriptionService.updateSubscription(
        subscriptionId: item.id,
        name: nameController.text.trim(),
        subtitle: subtitleController.text.trim(),
        price: priceController.text.trim(),
        renewal: renewalController.text.trim(),
        usage: usageController.text.trim(),
        category: categoryController.text.trim(),
        status: status,
        priceHiked: priceHiked,
      );

      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Subscription updated')));
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to update subscription: $e')),
      );
    } finally {
      nameController.dispose();
      subtitleController.dispose();
      priceController.dispose();
      renewalController.dispose();
      usageController.dispose();
      categoryController.dispose();
    }
  }

  void _showSearch() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          child: Container(
            padding: const EdgeInsets.all(22),
            decoration: const BoxDecoration(
              color: bg,
              borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
            ),
            child: TextField(
              autofocus: true,
              decoration: InputDecoration(
                hintText: 'Search subscriptions...',
                prefixIcon: const _VaultReferenceIcon(
                  Icons.search,
                  color: purple,
                ),
                suffixIcon: searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const _VaultReferenceIcon(Icons.close),
                        onPressed: () {
                          setState(() => searchQuery = '');
                          Navigator.pop(context);
                        },
                      )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: surface,
              ),
              onChanged: (value) => setState(() => searchQuery = value),
              onSubmitted: (_) => Navigator.pop(context),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final base = Theme.of(context);
    final typography = base.textTheme.apply(
      fontFamily: GoogleFonts.plusJakartaSans().fontFamily,
    );
    final primaryTypography = base.primaryTextTheme.apply(
      fontFamily: GoogleFonts.plusJakartaSans().fontFamily,
    );
    return Theme(
      data: base.copyWith(
        textTheme: typography,
        primaryTextTheme: primaryTypography,
        colorScheme: base.colorScheme.copyWith(
          primary: purple,
          onPrimary: Colors.white,
          secondary: const Color(0xFF0891B2),
          onSurface: ink,
        ),
        dividerColor: const Color(0xFFEFF2F7),
        navigationBarTheme: NavigationBarThemeData(
          labelTextStyle: WidgetStateProperty.resolveWith(
            (states) => GoogleFonts.plusJakartaSans(
              fontSize: 11,
              fontWeight: states.contains(WidgetState.selected)
                  ? FontWeight.w800
                  : FontWeight.w600,
              color: states.contains(WidgetState.selected)
                  ? purple
                  : const Color(0xFF94A3B8),
            ),
          ),
          iconTheme: WidgetStateProperty.resolveWith(
            (states) => IconThemeData(
              size: 21,
              color: states.contains(WidgetState.selected)
                  ? purple
                  : const Color(0xFF94A3B8),
            ),
          ),
        ),
      ),
      child: Builder(
        builder: (themedContext) => DecoratedBox(
          decoration: const BoxDecoration(color: bg),
          child: Stack(
            children: [
              Positioned.fill(
                child: IgnorePointer(
                  child: DecoratedBox(
                    decoration: const BoxDecoration(
                      gradient: RadialGradient(
                        center: Alignment(-0.8, -1),
                        radius: 1.4,
                        colors: [Color(0xB0E0E7FF), Color(0x00E0E7FF)],
                      ),
                    ),
                  ),
                ),
              ),
              Positioned.fill(
                child: IgnorePointer(
                  child: DecoratedBox(
                    decoration: const BoxDecoration(
                      gradient: RadialGradient(
                        center: Alignment(1, -0.5),
                        radius: 0.9,
                        colors: [Color(0x73F3E8FF), Color(0x00F3E8FF)],
                      ),
                    ),
                  ),
                ),
              ),
              Positioned.fill(
                child: IgnorePointer(
                  child: DecoratedBox(
                    decoration: const BoxDecoration(
                      gradient: RadialGradient(
                        center: Alignment(0, 1),
                        radius: 1,
                        colors: [Color(0x66E0F2FE), Color(0x00E0F2FE)],
                      ),
                    ),
                  ),
                ),
              ),
              _buildSubscriptions(themedContext),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSubscriptions(BuildContext context) {
    return Scaffold(
      extendBody: true,
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        foregroundColor: ink,
        surfaceTintColor: Colors.transparent,
        automaticallyImplyLeading: false,
        elevation: 0,
        toolbarHeight: 88,
        titleSpacing: 24,
        title: Row(
          children: [
            Container(
              width: 42,
              height: 42,
              padding: const EdgeInsets.all(1.5),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  begin: Alignment.bottomLeft,
                  end: Alignment.topRight,
                  colors: [purple, Color(0xFF6366F1)],
                ),
                borderRadius: BorderRadius.circular(16),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x306366F1),
                    blurRadius: 14,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white.withAlpha(235),
                  borderRadius: BorderRadius.circular(14.5),
                ),
                child: const _VaultReferenceIcon(
                  Icons.verified_user_outlined,
                  size: 22,
                  color: purple,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'OneClick',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.5,
                      color: ink,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const _VaultPulseDot(color: purple, size: 8, ping: true),
                      const SizedBox(width: 7),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF0F3FF),
                          border: Border.all(color: const Color(0xFFE0E7FE)),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Text(
                          'PERSONAL',
                          style: TextStyle(
                            fontSize: 10,
                            letterSpacing: 1.2,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF4338CA),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 24),
            child: _headerButton(Icons.search, _showSearch),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(24, 6, 24, 130),
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 430),
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
                        const SizedBox(height: 14),
                        Text(
                          '${filteredSubscriptions.length} subscriptions shown',
                          style: const TextStyle(color: muted, fontSize: 12),
                        ),
                        if (filteredSubscriptions.isEmpty) ...[
                          const SizedBox(height: 20),
                          _buildEmptySubscriptions(),
                        ],
                        const SizedBox(height: 28),
                        _buildCategory(
                          title: 'PRODUCTIVITY & AI',
                          icon: Icons.terminal_outlined,
                          items: filteredSubscriptions
                              .where(
                                (item) => item.category == 'Productivity & AI',
                              )
                              .toList(),
                        ),
                        const SizedBox(height: 28),
                        _buildCategory(
                          title: 'ENTERTAINMENT & MEDIA',
                          icon: Icons.play_circle_outline,
                          items: filteredSubscriptions
                              .where(
                                (item) =>
                                    item.category == 'Entertainment & Media',
                              )
                              .toList(),
                        ),
                        const SizedBox(height: 28),
                        _buildCategory(
                          title: 'STORAGE & UTILITIES',
                          icon: Icons.cloud_outlined,
                          items: filteredSubscriptions
                              .where(
                                (item) =>
                                    item.category == 'Storage & Utilities',
                              )
                              .toList(),
                        ),
                        const SizedBox(height: 38),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomNavigation(),
    );
  }

  Widget _buildHeader() {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'My Subscriptions',
          style: TextStyle(
            color: ink,
            fontSize: 26,
            fontWeight: FontWeight.w800,
            letterSpacing: -0.6,
          ),
        ),
      ],
    );
  }

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
                  color: Color(0xFF94A3B8),
                  fontWeight: FontWeight.w800,
                  fontSize: 12,
                  letterSpacing: 1.6,
                ),
              ),
              const SizedBox(width: 8),
              const _VaultReferenceIcon(Icons.circle, color: purple, size: 8),
              const Spacer(),
              _currencyButton('USD'),
              const SizedBox(width: 6),
              _currencyButton('LKR'),
            ],
          ),
          const SizedBox(height: 26),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                _loadingExchangeRate
                    ? 'Loading...'
                    : _formattedMoney(_monthlyCost(subscriptions)),
                style: const TextStyle(
                  color: ink,
                  fontSize: 32,
                  fontWeight: FontWeight.w700,
                  letterSpacing: -1,
                ),
              ),
              const SizedBox(width: 8),
              const Padding(
                padding: EdgeInsets.only(bottom: 7),
                child: Text(
                  '/mo',
                  style: TextStyle(color: Color(0xFF64748B), fontSize: 18),
                ),
              ),
              const Spacer(),
              Builder(
                builder: (context) {
                  final change = _monthlyChangePercent();
                  final bool hasData = change != null;
                  final bool increased = hasData && change > 0;
                  final bool decreased = hasData && change < 0;

                  final String label = !hasData
                      ? 'No history'
                      : '${change >= 0 ? '+' : ''}${change.toStringAsFixed(1)}%';

                  final Color changeColor = increased
                      ? danger
                      : decreased
                          ? const Color(0xFF16A34A)
                          : muted;

                  final IconData changeIcon = increased
                      ? Icons.trending_up
                      : decreased
                          ? Icons.trending_down
                          : Icons.trending_flat;

                  return Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 7,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFF8FB),
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: _shadow(),
                    ),
                    child: Row(
                      children: [
                        _VaultReferenceIcon(
                          changeIcon,
                          color: changeColor,
                          size: 17,
                        ),
                        const SizedBox(width: 5),
                        Text(
                          label,
                          style: TextStyle(
                            color: changeColor,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ],
          ),
          const SizedBox(height: 2),
          Row(
            children: [
              const Text(
                'Projected ',
                style: TextStyle(color: muted, fontSize: 14),
              ),
              Text(
                _formattedMoney(_monthlyCost(subscriptions) * 12),
                style: const TextStyle(
                  color: ink,
                  fontWeight: FontWeight.w700,
                  fontSize: 14,
                ),
              ),
              const Text('/year', style: TextStyle(color: muted, fontSize: 14)),
              const Spacer(),
              Text(
                'vs last month',
                style: TextStyle(
                  color: muted.withValues(alpha: .9),
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
                  number: _countFor('Active').toString(),
                  label: 'Active Subs',
                  color: purple,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: _statCard(
                  number: _countFor('Free Trials').toString(),
                  label: 'Trials Ending',
                  color: purple2,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: _statCard(
                  number: subscriptions
                      .where(
                        (item) =>
                            item.priceHiked &&
                            _statusKey(item.status) == 'active',
                      )
                      .length
                      .toString(),
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
      onTap: () => setState(() => selectedCurrency = currency),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
        decoration: BoxDecoration(
          color: const Color(0xFFF0F3FF),
          borderRadius: BorderRadius.circular(22),
          border: Border.all(
            color: selected ? const Color(0xFFE0E7FE) : Colors.white,
          ),
        ),
        child: Text(
          currency == 'USD' ? 'USD ' : 'LKR ',
          style: TextStyle(
            color: selected ? purple : ink,
            fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
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
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 5),
      decoration: BoxDecoration(
        color: const Color(0xFFF0F3FF),
        borderRadius: BorderRadius.circular(24),
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
            style: const TextStyle(color: Color(0xFF64748B), fontSize: 12),
          ),
        ],
      ),
    );
  }

  Widget _buildAICheckup() {
    return _card(
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _circleIcon(Icons.auto_awesome, color: purple2, size: 44),
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
                          color: Color(0xFF64748B),
                          fontSize: 14,
                          height: 1.4,
                        ),
                        children: [
                          TextSpan(
                            text: '3 optimizations found. You can trim up to ',
                          ),
                          TextSpan(
                            text: 'LKR 11,000/mo',
                            style: TextStyle(
                              color: purple,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          TextSpan(
                            text: ' in duplicate streaming & dormant tiers.',
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
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const AISubscriptionCheckupScreen(),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  bool _sameDate(DateTime first, DateTime second) {
    return first.year == second.year &&
        first.month == second.month &&
        first.day == second.day;
  }

  int _daysUntilRenewal(DateTime renewalDate) {
    final today = DateTime.now();
    final todayOnly = DateTime(today.year, today.month, today.day);
    final renewalOnly = DateTime(renewalDate.year, renewalDate.month, renewalDate.day);
    return renewalOnly.difference(todayOnly).inDays;
  }

  List<SubscriptionItem> get _actionableRenewals {
    final items = subscriptions.where((item) {
      final status = _statusKey(item.status);
      if (status != 'active' && status != 'free trial') return false;

      final renewalDate = item.renewalDate;
      if (renewalDate == null) return false;

      final days = _daysUntilRenewal(renewalDate);
      if (days < 0 || days > 7) return false;

      final handledFor = item.renewalActionHandledFor;
      if (handledFor != null && _sameDate(handledFor, renewalDate)) return false;

      return true;
    }).toList();

    items.sort((a, b) => a.renewalDate!.compareTo(b.renewalDate!));
    return items;
  }

  Widget _buildRenewals() {
    final renewals = _actionableRenewals;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Expanded(
              child: Text(
                'ACTION REQUIRED & RENEWALS',
                style: TextStyle(
                  color: Color(0xFF94A3B8),
                  fontWeight: FontWeight.w800,
                  fontSize: 12,
                  letterSpacing: 1.6,
                ),
              ),
            ),
            Text(
              '${renewals.length} Urgent',
              style: const TextStyle(
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
            children: renewals.isEmpty
                ? [
                    _renewalCardItem(
                      title: 'HBO Max',
                      subtitle: 'Free 7-Day Trial',
                      badge: '3 days left',
                      description: 'Converts to LKR 5,000/mo on Nov 08 unless cancelled.',
                      icon: Icons.movie_outlined,
                      urgent: true,
                    ),
                    const SizedBox(width: 16),
                    _renewalCardItem(
                      title: 'Figma Pro',
                      subtitle: 'Annual Billing',
                      badge: '7 days',
                      description: 'Auto-charge amount will renew automatically.',
                      icon: Icons.brush_outlined,
                      urgent: false,
                    ),
                  ]
                : renewals.map((item) {
                    final days = item.renewalDate != null
                        ? _daysUntilRenewal(item.renewalDate!)
                        : 0;
                    return Padding(
                      padding: const EdgeInsets.only(right: 16),
                      child: _renewalCardItem(
                        title: item.name,
                        subtitle: item.subtitle,
                        badge: '$days days',
                        description: item.renewal,
                        icon: item.icon,
                        urgent: days <= 3,
                      ),
                    );
                  }).toList(),
          ),
        ),
      ],
    );
  }

  Widget _renewalCardItem({
    required String title,
    required String subtitle,
    required String badge,
    required String description,
    required IconData icon,
    bool urgent = true,
  }) {
    return SizedBox(
      width: 340,
      child: _VaultGlassCard(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                _circleIcon(icon, color: purple, size: 45),
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
                        style: const TextStyle(color: purple, fontSize: 13),
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
                color: Color(0xFF64748B),
                fontSize: 13,
                height: 1.4,
              ),
            ),
            const Spacer(),
            Row(
              children: [
                Expanded(
                  child: TextButton(
                    onPressed: () => _message('$title cancellation selected.'),
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
                    onPressed: () => _message('$title kept.'),
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
      ),
    );
  }

  Widget _buildFilters() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          _filter('All', _countFor('All').toString()),
          const SizedBox(width: 10),
          _filter('Active', _countFor('Active').toString()),
          const SizedBox(width: 10),
          _filter('Free Trials', _countFor('Free Trials').toString()),
          const SizedBox(width: 10),
          _filter('Cancelled', _countFor('Cancelled').toString()),
        ],
      ),
    );
  }

  Widget _filter(String title, String count) {
    final selected = selectedFilter == title;
    return GestureDetector(
      onTap: () => setState(() => selectedFilter = title),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 17, vertical: 10),
        decoration: BoxDecoration(
          color: selected
              ? const Color(0xFFE0E7FE)
              : Colors.white.withAlpha(220),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: const Color(0xFFE0E7FE)),
        ),
        child: Text(
          '$title ($count)',
          style: TextStyle(
            color: selected ? purple : const Color(0xFF64748B),
            fontSize: 13,
            fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
          ),
        ),
      ),
    );
  }

  Widget _buildCategory({
    required String title,
    required IconData icon,
    required List<SubscriptionItem> items,
  }) {
    if (items.isEmpty) return const SizedBox.shrink();
    final categoryCurrency =
        title == 'PRODUCTIVITY & AI' ? 'LKR' : selectedCurrency;

    final categoryAmount = _monthlyCostInCurrency(items, categoryCurrency);

    final categoryLabel = _statusKey(selectedFilter) == 'cancelled'
        ? 'No renewals'
        : _statusKey(selectedFilter) == 'free trial'
            ? '${items.length} trials'
            : '\$${categoryAmount.toStringAsFixed(2)}/mo';

    return Column(
      children: [
        Row(
          children: [
            _VaultReferenceIcon(icon, color: purple, size: 19),
            const SizedBox(width: 9),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  color: Color(0xFF94A3B8),
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1.6,
                ),
              ),
            ),
            Text(
              categoryLabel,
              style: const TextStyle(
                color: Color(0xFF94A3B8),
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
    return InkWell(
      borderRadius: BorderRadius.circular(24),
      onTap: () {
        if (item.name == 'Adobe Creative Cloud') {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => SubscriptionDetailsScreen(
                subscriptionId: item.id,
                name: item.name,
                subtitle: item.subtitle,
                price: item.price,
                status: item.status,
                billingCycle: item.billingCycle,
                renewalDate: item.renewalDate,
                onEdit: () => _editSubscription(item),
              ),
            ),
          );
        } else {
          _message('${item.name} details will be added soon.');
        }
      },
      child: _VaultGlassCard(
        interactive: true,
        accent: _statusKey(item.status) == 'free trial'
            ? const Color(0xFF9333EA)
            : _statusKey(item.status) == 'cancelled'
                ? const Color(0xFF94A3B8)
                : purple,
        padding: const EdgeInsets.all(19),
        child: Builder(
          builder: (context) => Column(
            children: [
              Row(
                children: [
                  _circleIcon(item.icon, color: purple, size: 44),
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
                                style: TextStyle(
                                  color: _VaultGlassScope.hoveredOf(context)
                                      ? purple
                                      : ink,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: -0.35,
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
                            color: Color(0xFF64748B),
                            fontSize: 13,
                          ),
                        ),
                        const SizedBox(height: 7),
                        _statusBadge(item.status),
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
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        _statusKey(item.status) == 'active' ? '/mo' : '',
                        style: const TextStyle(
                          color: Color(0xFF64748B),
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(width: 6),
                  IconButton(
                    tooltip: 'Edit',
                    icon: const Icon(Icons.edit_outlined),
                    onPressed: () => _editSubscription(item),
                  ),
                  IconButton(
                    tooltip: 'Delete',
                    icon: const Icon(Icons.delete_outline),
                    onPressed: () => _deleteSubscription(item),
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
                      color: const Color(0xFFF0F3FF),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      children: [
                        _VaultReferenceIcon(
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
                            color: Color(0xFF64748B),
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
                      color: Color(0xFF64748B),
                      fontSize: 12,
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

  Widget _statusBadge(String status) {
    final trial = _statusKey(status) == 'free trial';
    final cancelled = _statusKey(status) == 'cancelled';
    final color = trial
        ? const Color(0xFF9333EA)
        : cancelled
            ? const Color(0xFF64748B)
            : const Color(0xFF059669);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withAlpha(16),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withAlpha(30)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 5,
            height: 5,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 5),
          Text(
            trial ? 'Free Trial' : status,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptySubscriptions() {
    return _card(
      child: Column(
        children: [
          _circleIcon(Icons.search, color: purple, size: 44),
          const SizedBox(height: 16),
          const Text(
            'No subscriptions found',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: ink,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'Try another filter or clear your search.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 12, color: muted),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomNavigation() {
    return SafeArea(
      top: false,
      minimum: const EdgeInsets.fromLTRB(24, 8, 24, 20),
      child: Center(
        heightFactor: 1,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 430),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(28),
              border: Border.all(color: Colors.white.withAlpha(240)),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x140F172A),
                  blurRadius: 24,
                  offset: Offset(0, -4),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(28),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                child: ColoredBox(
                  color: Colors.white.withAlpha(235),
                  child: Padding(
                    padding: const EdgeInsets.all(8),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _navItem(Icons.home_outlined, 'Home', false),
                        _navItem(Icons.folder_special_outlined, 'Vault', false),
                        _navItem(Icons.credit_card, 'Subs', true),
                        _navItem(Icons.share_outlined, 'Sharing', false),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _navItem(IconData icon, String label, bool selected) {
    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: () {
        if (selected) return;
        if (label == 'Home') {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => const PersonalDashboardScreen(),
            ),
          );
        } else if (label == 'Vault') {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const VaultScreen()),
          );
        } else if (label == 'Sharing') {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => const SharingCenterScreen(),
            ),
          );
        }
      },
      child: _VaultPressFeedback(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: selected
              ? BoxDecoration(
                  color: const Color(0xFFF0F3FF),
                  borderRadius: BorderRadius.circular(16),
                )
              : null,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _VaultReferenceIcon(
                icon,
                color: selected ? purple : muted,
                size: 20,
              ),
              const SizedBox(height: 4),
              Text(
                label,
                style: TextStyle(
                  color: selected ? purple : muted,
                  fontSize: 11,
                  fontWeight: selected ? FontWeight.w800 : FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _card({
    required Widget child,
    EdgeInsetsGeometry padding = const EdgeInsets.all(20),
  }) {
    return SizedBox(
      width: double.infinity,
      child: _VaultGlassCard(padding: padding, child: child),
    );
  }

  Widget _circleIcon(IconData icon, {required Color color, double size = 44}) {
    final accent = icon == Icons.music_note || icon == Icons.cloud_done_outlined
        ? const Color(0xFF059669)
        : icon == Icons.tv_outlined || icon == Icons.movie_outlined
            ? const Color(0xFFF43F5E)
            : icon == Icons.psychology_outlined || icon == Icons.memory_outlined
                ? purple2
                : color;
    return Builder(
      builder: (context) {
        final hovered = _VaultGlassScope.hoveredOf(context);
        return AnimatedScale(
          scale: hovered ? 1.05 : 1,
          duration: const Duration(milliseconds: 300),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            width: size,
            height: size,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: hovered ? accent : accent.withAlpha(18),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: accent.withAlpha(30)),
            ),
            child: _VaultReferenceIcon(
              icon,
              color: hovered ? Colors.white : accent,
              size: size * .46,
            ),
          ),
        );
      },
    );
  }

  Widget _headerButton(IconData icon, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(50),
      child: _circleIcon(icon, color: muted, size: 46),
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
      borderRadius: BorderRadius.circular(24),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 14),
        decoration: BoxDecoration(
          color: const Color(0xFFF0F3FF),
          borderRadius: BorderRadius.circular(24),
          boxShadow: _shadow(),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _VaultReferenceIcon(icon, color: color, size: 20),
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
    return const [
      BoxShadow(
        color: Color(0x1464748B),
        offset: Offset(0, 10),
        blurRadius: 30,
        spreadRadius: -4,
      ),
      BoxShadow(
        color: Color(0x0864748B),
        offset: Offset(0, 4),
        blurRadius: 12,
        spreadRadius: -2,
      ),
    ];
  }

  void _message(String text) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text)));
  }
}

class SubscriptionItem {
  final String id;
  final String name;
  final String subtitle;
  final String price;
  final String renewal;
  final String usage;
  final IconData icon;
  final String category;
  final bool priceHiked;
  final String status;

  final double? amount;
  final String currency;
  final String billingCycle;
  final DateTime? renewalDate;
  final DateTime? cancelledAt;
  final DateTime? renewalActionHandledFor;
  final DateTime? createdAt;

  const SubscriptionItem({
    required this.id,
    required this.name,
    required this.subtitle,
    required this.price,
    required this.renewal,
    required this.usage,
    required this.icon,
    required this.category,
    this.priceHiked = false,
    this.status = 'Active',
    this.amount,
    this.currency = 'LKR',
    this.billingCycle = 'Monthly',
    this.renewalDate,
    this.cancelledAt,
    this.renewalActionHandledFor,
    this.createdAt,
  });
}

class _NewBadge extends StatelessWidget {
  const _NewBadge();
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 4),
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

class _VaultGlassScope extends InheritedWidget {
  const _VaultGlassScope({required this.hovered, required super.child});
  final bool hovered;
  static bool hoveredOf(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<_VaultGlassScope>()?.hovered ??
      false;
  @override
  bool updateShouldNotify(_VaultGlassScope oldWidget) =>
      hovered != oldWidget.hovered;
}

class _VaultGlassCard extends StatefulWidget {
  const _VaultGlassCard({
    required this.child,
    required this.padding,
    this.interactive = false,
    this.accent,
  });
  final Widget child;
  final EdgeInsetsGeometry padding;
  final bool interactive;
  final Color? accent;
  @override
  State<_VaultGlassCard> createState() => _VaultGlassCardState();
}

class _VaultGlassCardState extends State<_VaultGlassCard> {
  bool _hovered = false;
  bool _pressed = false;
  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: widget.interactive ? SystemMouseCursors.click : MouseCursor.defer,
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() {
        _hovered = false;
        _pressed = false;
      }),
      child: Listener(
        onPointerDown: (_) {
          if (widget.interactive) setState(() => _pressed = true);
        },
        onPointerUp: (_) {
          if (_pressed) setState(() => _pressed = false);
        },
        onPointerCancel: (_) {
          if (_pressed) setState(() => _pressed = false);
        },
        child: AnimatedScale(
          scale: _pressed ? 0.98 : 1,
          duration: const Duration(milliseconds: 150),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeOut,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: _hovered
                      ? const Color(0x1F6366F1)
                      : const Color(0x1464748B),
                  offset: Offset(0, _hovered ? 20 : 10),
                  blurRadius: _hovered ? 35 : 30,
                  spreadRadius: _hovered ? -8 : -4,
                ),
                const BoxShadow(
                  color: Color(0x0864748B),
                  offset: Offset(0, 4),
                  blurRadius: 12,
                  spreadRadius: -2,
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(24),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: widget.padding,
                  decoration: BoxDecoration(
                    color: Colors.white.withAlpha(_hovered ? 255 : 204),
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(
                      color:
                          widget.accent?.withAlpha(_hovered ? 65 : 30) ??
                          Colors.white.withAlpha(217),
                    ),
                  ),
                  child: _VaultGlassScope(
                    hovered: _hovered,
                    child: widget.child,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _VaultPulseDot extends StatefulWidget {
  const _VaultPulseDot({
    required this.color,
    required this.size,
    this.ping = false,
    this.animate = true,
  });
  final Color color;
  final double size;
  final bool ping;
  final bool animate;

  @override
  State<_VaultPulseDot> createState() => _VaultPulseDotState();
}

class _VaultPulseDotState extends State<_VaultPulseDot>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1400),
  );
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (widget.animate && !MediaQuery.disableAnimationsOf(context)) {
      _controller.repeat(reverse: !widget.ping);
    } else {
      _controller.stop();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
        animation: _controller,
        builder: (context, child) => SizedBox(
          width: widget.size,
          height: widget.size,
          child: Stack(
            clipBehavior: Clip.none,
            alignment: Alignment.center,
            children: [
              if (widget.ping)
                Transform.scale(
                  scale: 1 + _controller.value,
                  child: Opacity(
                    opacity: (1 - _controller.value) * 0.75,
                    child: Container(
                      decoration: BoxDecoration(
                        color: widget.color,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                ),
              Opacity(
                opacity: widget.ping || !widget.animate
                    ? 1
                    : 1 - _controller.value * 0.5,
                child: Container(
                  decoration: BoxDecoration(
                    color: widget.color,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            ],
          ),
        ),
      );
}

class _VaultNavGlyph extends StatefulWidget {
  const _VaultNavGlyph(this.icon, {this.color});
  final IconData icon;
  final Color? color;

  @override
  State<_VaultNavGlyph> createState() => _VaultNavGlyphState();
}

class _VaultNavGlyphState extends State<_VaultNavGlyph> {
  bool _hovered = false;
  bool _pressed = false;
  @override
  Widget build(BuildContext context) => MouseRegion(
        cursor: SystemMouseCursors.click,
        onEnter: (_) => setState(() => _hovered = true),
        onExit: (_) => setState(() {
          _hovered = false;
          _pressed = false;
        }),
        child: Listener(
          onPointerDown: (_) => setState(() => _pressed = true),
          onPointerUp: (_) => setState(() => _pressed = false),
          onPointerCancel: (_) => setState(() => _pressed = false),
          child: AnimatedScale(
            scale: _pressed ? 0.95 : 1,
            duration: const Duration(milliseconds: 200),
            child: _VaultReferenceIcon(
              widget.icon,
              size: 20,
              color: widget.color ??
                  (_hovered
                      ? const Color(0xFF1E293B)
                      : IconTheme.of(context).color ?? const Color(0xFF94A3B8)),
            ),
          ),
        ),
      );
}

class _VaultReferenceIcon extends StatelessWidget {
  const _VaultReferenceIcon(this.icon, {this.size, this.color});
  final IconData icon;
  final double? size;
  final Color? color;

  static final Map<IconData, String> _svg = {
    Icons.verified_user_outlined: r'''<svg xmlns="http://www.w3.org/2000/svg" fill="none" stroke="#000000" stroke-linecap="round" stroke-linejoin="round" stroke-width="2" viewBox="0 0 24 24">
<path d="M12 22s8-4 8-10V5l-8-3-8 3v7c0 6 8 10 8 10z"></path>
<path d="m9 12 2 2 4-4"></path>
</svg>''',
    Icons.search: r'''<svg xmlns="http://www.w3.org/2000/svg" fill="none" stroke="#000000" stroke-width="2" viewBox="0 0 24 24">
<path d="M21 21l-5.197-5.197m0 0A7.5 7.5 0 105.196 5.196a7.5 7.5 0 0010.607 10.607z" stroke-linecap="round" stroke-linejoin="round"></path>
</svg>''',
    Icons.tune: r'''<svg xmlns="http://www.w3.org/2000/svg" fill="none" stroke="#000000" stroke-linecap="round" stroke-linejoin="round" stroke-width="2" viewBox="0 0 24 24">
<line x1="4" x2="4" y1="21" y2="14"></line>
<line x1="4" x2="4" y1="10" y2="3"></line>
<line x1="12" x2="12" y1="21" y2="12"></line>
<line x1="12" x2="12" y1="8" y2="3"></line>
<line x1="20" x2="20" y1="21" y2="16"></line>
<line x1="20" x2="20" y1="12" y2="3"></line>
<line x1="1" x2="7" y1="14" y2="14"></line>
<line x1="9" x2="15" y1="8" y2="8"></line>
<line x1="17" x2="23" y1="16" y2="16"></line>
</svg>''',
    Icons.document_scanner_outlined: r'''<svg xmlns="http://www.w3.org/2000/svg" fill="none" stroke="#000000" stroke-width="2" viewBox="0 0 24 24">
<path d="M3 7V5a2 2 0 012-2h2m10 0h2a2 2 0 012 2v2m0 10v2a2 2 0 01-2 2h-2m-10 0H5a2 2 0 01-2-2v-2M9 10h6m-6 4h4" stroke-linecap="round" stroke-linejoin="round"></path>
</svg>''',
    Icons.shield_outlined: r'''<svg xmlns="http://www.w3.org/2000/svg" fill="none" stroke="#000000" stroke-width="2" viewBox="0 0 24 24">
<path d="M9 12l2 2 4-4m5.618-4.016A11.955 11.955 0 0112 2.944a11.955 11.955 0 01-8.618 3.04A12.02 12.02 0 003 9c0 5.591 3.824 10.29 9 11.622 5.176-1.332 9-6.03 9-11.622 0-1.042-.133-2.052-.382-3.016z" stroke-linecap="round" stroke-linejoin="round"></path>
</svg>''',
    Icons.auto_awesome: r'''<svg xmlns="http://www.w3.org/2000/svg" fill="none" stroke="#000000" stroke-width="2" viewBox="0 0 24 24">
<path d="M9.813 15.904L9 18.75l-.813-2.846a4.5 4.5 0 00-3.09-3.09L2.25 12l2.846-.813a4.5 4.5 0 003.09-3.09L9 5.25l.813 2.846a4.5 4.5 0 003.09 3.09L15.75 12l-2.846.813a4.5 4.5 0 00-3.09 3.09zM18.259 8.715L18 9.75l-.259-1.035a3.375 3.375 0 00-2.455-2.456L14.25 6l1.036-.259a3.375 3.375 0 002.455-2.456L18 2.25l.259 1.035a3.375 3.375 0 002.456 2.456L21.75 6l-1.035.259a3.375 3.375 0 00-2.456 2.456z" stroke-linecap="round" stroke-linejoin="round"></path>
</svg>''',
    Icons.folder_copy_outlined: r'''<svg xmlns="http://www.w3.org/2000/svg" fill="none" stroke="#000000" stroke-width="2" viewBox="0 0 24 24">
<path d="M3 7v10a2 2 0 002 2h14a2 2 0 002-2V9a2 2 0 00-2-2h-6l-2-2H5a2 2 0 00-2 2z" stroke-linecap="round" stroke-linejoin="round"></path>
<path d="M12 11v6m3-3H9" stroke-linecap="round" stroke-linejoin="round"></path>
</svg>''',
    Icons.laptop_mac: r'''<svg xmlns="http://www.w3.org/2000/svg" fill="none" stroke="#000000" stroke-width="1.8" viewBox="0 0 24 24">
<path d="M9.75 17L9 20l-1 1h8l-1-1-.75-3M3 13h18M5 17h14a2 2 0 002-2V5a2 2 0 00-2-2H5a2 2 0 00-2 2v10a2 2 0 002 2z" stroke-linecap="round" stroke-linejoin="round"></path>
</svg>''',
    Icons.chevron_right: r'''<svg xmlns="http://www.w3.org/2000/svg" fill="none" stroke="#000000" stroke-width="2.5" viewBox="0 0 24 24">
<path d="M9 5l7 7-7 7" stroke-linecap="round" stroke-linejoin="round"></path>
</svg>''',
    Icons.badge_outlined: r'''<svg xmlns="http://www.w3.org/2000/svg" fill="none" stroke="#000000" stroke-width="1.8" viewBox="0 0 24 24">
<path d="M10 6H5a2 2 0 00-2 2v9a2 2 0 002 2h14a2 2 0 002-2V8a2 2 0 00-2-2h-5m-4 0V5a2 2 0 114 0v1m-4 0a2 2 0 104 0m-5 8a2 2 0 100-4 2 2 0 000 4zm0 0c1.306 0 2.417.835 2.83 2M9 14a3.001 3.001 0 00-2.83 2M15 11h3m-3 4h2" stroke-linecap="round" stroke-linejoin="round"></path>
</svg>''',
    Icons.image_outlined: r'''<svg xmlns="http://www.w3.org/2000/svg" fill="none" stroke="#000000" stroke-width="2" viewBox="0 0 24 24">
<path d="M9 12h6m-6 4h6m2 5H7a2 2 0 01-2-2V5a2 2 0 012-2h5.586a1 1 0 01.707.293l5.414 5.414a1 1 0 01.293.707V19a2 2 0 01-2 2z" stroke-linecap="round" stroke-linejoin="round"></path>
</svg>''',
    Icons.more_vert: r'''<svg xmlns="http://www.w3.org/2000/svg" fill="none" stroke="#000000" stroke-width="2" viewBox="0 0 24 24">
<path d="M12 5v.01M12 12v.01M12 19v.01M12 6a1 1 0 110-2 1 1 0 010 2zm0 7a1 1 0 110-2 1 1 0 010 2zm0 7a1 1 0 110-2 1 1 0 010 2z" stroke-linecap="round" stroke-linejoin="round"></path>
</svg>''',
    Icons.picture_as_pdf_outlined: r'''<svg xmlns="http://www.w3.org/2000/svg" fill="none" stroke="#000000" stroke-width="2" viewBox="0 0 24 24">
<path d="M9 12h6m2 4H7m6-12H6a2 2 0 00-2 2v14a2 2 0 002 2h12a2 2 0 002-2V8l-6-6z" stroke-linecap="round" stroke-linejoin="round"></path>
</svg>''',
    Icons.home: r'''<svg xmlns="http://www.w3.org/2000/svg" fill="#000000" viewBox="0 0 24 24">
<path d="M11.47 3.84a.75.75 0 011.06 0l8.69 8.69a.75.75 0 101.06-1.06l-8.689-8.69a2.25 2.25 0 00-3.182 0l-8.69 8.69a.75.75 0 001.061 1.06l8.69-8.69z"></path>
<path d="M12 5.432l8.159 8.159c.03.03.06.058.091.086v6.198c0 1.035-.84 1.875-1.875 1.875H15a.75.75 0 01-.75-.75v-4.5a.75.75 0 00-.75-.75h-3a.75.75 0 00-.75.75V21a.75.75 0 01-.75.75H5.625a1.875 1.875 0 01-1.875-1.875v-6.198a2.29 2.29 0 00.091-.086L12 5.43z"></path>
</svg>''',
    Icons.home_outlined: r'''<svg xmlns="http://www.w3.org/2000/svg" fill="#000000" viewBox="0 0 24 24">
<path d="M11.47 3.84a.75.75 0 011.06 0l8.69 8.69a.75.75 0 101.06-1.06l-8.689-8.69a2.25 2.25 0 00-3.182 0l-8.69 8.69a.75.75 0 001.061 1.06l8.69-8.69z"></path>
<path d="M12 5.432l8.159 8.159c.03.03.06.058.091.086v6.198c0 1.035-.84 1.875-1.875 1.875H15a.75.75 0 01-.75-.75v-4.5a.75.75 0 00-.75-.75h-3a.75.75 0 00-.75.75V21a.75.75 0 01-.75.75H5.625a1.875 1.875 0 01-1.875-1.875v-6.198a2.29 2.29 0 00.091-.086L12 5.43z"></path>
</svg>''',
    Icons.folder_special_outlined: r'''<svg xmlns="http://www.w3.org/2000/svg" stroke-linecap="round" stroke-linejoin="round" stroke-width="2" fill="none" stroke="#000000" viewBox="0 0 24 24">
<path d="M22 19a2 2 0 0 1-2 2H4a2 2 0 0 1-2-2V5a2 2 0 0 1 2-2h5l2 3h9a2 2 0 0 1 2 2z"></path>
<polygon points="12 11 12.7 13.1 15 13.1 13.1 14.5 13.8 16.7 12 15.3 10.2 16.7 10.9 14.5 9 13.1 11.3 13.1 12 11"></polygon>
</svg>''',
    Icons.folder_special: r'''<svg xmlns="http://www.w3.org/2000/svg" stroke-linecap="round" stroke-linejoin="round" stroke-width="2" fill="none" stroke="#000000" viewBox="0 0 24 24">
<path d="M22 19a2 2 0 0 1-2 2H4a2 2 0 0 1-2-2V5a2 2 0 0 1 2-2h5l2 3h9a2 2 0 0 1 2 2z"></path>
<polygon points="12 11 12.7 13.1 15 13.1 13.1 14.5 13.8 16.7 12 15.3 10.2 16.7 10.9 14.5 9 13.1 11.3 13.1 12 11"></polygon>
</svg>''',
    Icons.credit_card_outlined: r'''<svg xmlns="http://www.w3.org/2000/svg" stroke-linecap="round" stroke-linejoin="round" stroke-width="2" fill="none" stroke="#000000" viewBox="0 0 24 24">
<rect height="14" rx="3" width="20" x="2" y="5"></rect>
<line x1="2" x2="22" y1="10" y2="10"></line>
</svg>''',
    Icons.credit_card: r'''<svg xmlns="http://www.w3.org/2000/svg" stroke-linecap="round" stroke-linejoin="round" stroke-width="2" fill="none" stroke="#000000" viewBox="0 0 24 24">
<rect height="14" rx="3" width="20" x="2" y="5"></rect>
<line x1="2" x2="22" y1="10" y2="10"></line>
</svg>''',
    Icons.share_outlined: r'''<svg xmlns="http://www.w3.org/2000/svg" stroke-linecap="round" stroke-linejoin="round" stroke-width="2" fill="none" stroke="#000000" viewBox="0 0 24 24">
<circle cx="18" cy="5" r="3"></circle>
<circle cx="6" cy="12" r="3"></circle>
<circle cx="18" cy="19" r="3"></circle>
<line x1="8.59" x2="15.42" y1="13.51" y2="17.49"></line>
<line x1="15.41" x2="8.59" y1="6.51" y2="10.49"></line>
</svg>''',
    Icons.share: r'''<svg xmlns="http://www.w3.org/2000/svg" stroke-linecap="round" stroke-linejoin="round" stroke-width="2" fill="none" stroke="#000000" viewBox="0 0 24 24">
<circle cx="18" cy="5" r="3"></circle>
<circle cx="6" cy="12" r="3"></circle>
<circle cx="18" cy="19" r="3"></circle>
<line x1="8.59" x2="15.42" y1="13.51" y2="17.49"></line>
<line x1="15.41" x2="8.59" y1="6.51" y2="10.49"></line>
</svg>''',
  };

  @override
  Widget build(BuildContext context) {
    final svg = _svg[icon];
    final theme = IconTheme.of(context);
    final resolvedColor = color ?? theme.color ?? const Color(0xFF64748B);
    final resolvedSize = size ?? theme.size ?? 24;
    if (svg == null) return Icon(icon, size: resolvedSize, color: resolvedColor);
    return SvgPicture.string(
      svg,
      width: resolvedSize,
      height: resolvedSize,
      colorFilter: ColorFilter.mode(resolvedColor, BlendMode.srcIn),
    );
  }
}

class _VaultPressFeedback extends StatefulWidget {
  const _VaultPressFeedback({required this.child});
  final Widget child;
  @override
  State<_VaultPressFeedback> createState() => _VaultPressFeedbackState();
}

class _VaultPressFeedbackState extends State<_VaultPressFeedback> {
  bool _pressed = false;
  @override
  Widget build(BuildContext context) => MouseRegion(
        cursor: SystemMouseCursors.click,
        child: Listener(
          onPointerDown: (_) => setState(() => _pressed = true),
          onPointerUp: (_) => setState(() => _pressed = false),
          onPointerCancel: (_) => setState(() => _pressed = false),
          child: AnimatedScale(
            scale: _pressed ? .95 : 1,
            duration: const Duration(milliseconds: 150),
            child: widget.child,
          ),
        ),
      );
}