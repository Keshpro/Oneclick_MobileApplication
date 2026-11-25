
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

const Color _teal = Color(0xFF0D9488);
const Color _dark = Color(0xFF102D38);
const Color _background = Color(0xFFF5F8FA);

class MockOffer {
  final String id;
  final String title;
  final String description;
  final String category;
  final String discount;
  final String code;
  final String expiry;
  final IconData icon;
  final Color color;
  final bool featured;

  const MockOffer({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    required this.discount,
    required this.code,
    required this.expiry,
    required this.icon,
    required this.color,
    this.featured = false,
  });
}

const List<MockOffer> mockOffers = [
  MockOffer(
    id: '1',
    title: 'Your Next Meal, For Less',
    description:
        'Enjoy delicious meals with an exclusive demo discount.',
    category: 'Food',
    discount: '30% OFF',
    code: 'FOOD30',
    expiry: '3 days left',
    icon: Icons.restaurant_rounded,
    color: Color(0xFFFF7448),
    featured: true,
  ),
  MockOffer(
    id: '2',
    title: 'Fresh Grocery Savings',
    description: 'Save on everyday grocery essentials.',
    category: 'Groceries',
    discount: '25% OFF',
    code: 'FRESH25',
    expiry: '5 days left',
    icon: Icons.local_grocery_store_rounded,
    color: Color(0xFF20A879),
  ),
  MockOffer(
    id: '3',
    title: 'Healthcare Made Easier',
    description:
        'Special savings on eligible doctor consultations.',
    category: 'Doctor',
    discount: '15% OFF',
    code: 'CARE15',
    expiry: '7 days left',
    icon: Icons.medical_services_rounded,
    color: Color(0xFF4389E8),
  ),
  MockOffer(
    id: '4',
    title: 'Fix It & Save',
    description:
        'Save on home maintenance and repair services.',
    category: 'QuickFix',
    discount: '20% OFF',
    code: 'FIX20',
    expiry: '2 days left',
    icon: Icons.handyman_rounded,
    color: Color(0xFF8B5CF6),
  ),
  MockOffer(
    id: '5',
    title: 'Ride Home Safely',
    description:
        'A special promotion for your next driver booking.',
    category: 'Driver',
    discount: 'Rs. 500 OFF',
    code: 'RIDE500',
    expiry: '4 days left',
    icon: Icons.directions_car_filled_rounded,
    color: Color(0xFFDE9A24),
  ),
  MockOffer(
    id: '6',
    title: 'Weekend Food Treat',
    description: 'Make your weekend meals even better.',
    category: 'Food',
    discount: '20% OFF',
    code: 'WEEKEND20',
    expiry: '6 days left',
    icon: Icons.lunch_dining_rounded,
    color: Color(0xFFE85D75),
  ),
  MockOffer(
    id: '7',
    title: 'Family Grocery Deal',
    description:
        'More value for your weekly grocery shopping.',
    category: 'Groceries',
    discount: 'Rs. 750 OFF',
    code: 'FAMILY750',
    expiry: '8 days left',
    icon: Icons.shopping_basket_rounded,
    color: Color(0xFF2B9D8F),
  ),
  MockOffer(
    id: '8',
    title: 'Home Care Special',
    description:
        'A little extra savings on household services.',
    category: 'QuickFix',
    discount: '15% OFF',
    code: 'HOME15',
    expiry: '10 days left',
    icon: Icons.home_repair_service_rounded,
    color: Color(0xFF6675D8),
  ),
];

class OffersScreen extends StatefulWidget {
  final VoidCallback? onBack;

  const OffersScreen({
    super.key,
    this.onBack,
  });

  @override
  State<OffersScreen> createState() => _OffersScreenState();
}

class _OffersScreenState extends State<OffersScreen> {
  String _category = 'All';
  String _search = '';

  final Set<String> _favorites = {};
  final TextEditingController _searchController =
      TextEditingController();

  static const List<String> categories = [
    'All',
    'Food',
    'Groceries',
    'Doctor',
    'QuickFix',
    'Driver',
  ];

  List<MockOffer> get _filteredOffers {
    final query = _search.trim().toLowerCase();

    return mockOffers.where((offer) {
      final matchesCategory =
          _category == 'All' ||
          offer.category == _category;

      final matchesSearch =
          query.isEmpty ||
          offer.title.toLowerCase().contains(query) ||
          offer.description.toLowerCase().contains(query) ||
          offer.category.toLowerCase().contains(query);

      return matchesCategory && matchesSearch;
    }).toList();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _goBack() {
    if (widget.onBack != null) {
      widget.onBack!();
      return;
    }

    final navigator = Navigator.of(context);

    if (navigator.canPop()) {
      navigator.pop();
    } else {
      Navigator.maybePop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final offers = _filteredOffers;

    return Scaffold(
      backgroundColor: _background,

      appBar: _buildAppBar(),

      body: SafeArea(
        bottom: false,
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding:
                    const EdgeInsets.only(top: 20),
                child: _buildFeaturedBanner(),
              ),
            ),

            SliverToBoxAdapter(
              child: _buildSearch(),
            ),

            SliverToBoxAdapter(
              child: _buildCategories(),
            ),

            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(
                  20,
                  24,
                  20,
                  14,
                ),
                child: Row(
                  children: [
                    const Expanded(
                      child: Text(
                        'Exclusive Deals',
                        style: TextStyle(
                          fontSize: 21,
                          fontWeight: FontWeight.w800,
                          color: _dark,
                        ),
                      ),
                    ),
                    Text(
                      '${offers.length} offers',
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: _teal,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            if (offers.isEmpty)
              const SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.all(45),
                  child: Column(
                    children: [
                      Icon(
                        Icons.search_off_rounded,
                        size: 55,
                        color: Colors.grey,
                      ),
                      SizedBox(height: 12),
                      Text(
                        'No matching offers found',
                      ),
                    ],
                  ),
                ),
              )
            else
              SliverPadding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                ),
                sliver: SliverLayoutBuilder(
                  builder: (context, constraints) {
                    final columns =
                        constraints.crossAxisExtent >= 850
                            ? 3
                            : constraints.crossAxisExtent >=
                                    550
                                ? 2
                                : 1;

                    return SliverGrid(
                      gridDelegate:
                          SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: columns,
                        crossAxisSpacing: 14,
                        mainAxisSpacing: 14,
                        mainAxisExtent: 225,
                      ),
                      delegate:
                          SliverChildBuilderDelegate(
                        (context, index) {
                          return _buildOfferCard(
                            offers[index],
                          );
                        },
                        childCount: offers.length,
                      ),
                    );
                  },
                ),
              ),

            const SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.fromLTRB(
                  20,
                  22,
                  20,
                  120,
                ),
                child: Text(
                  'DEMO OFFERS ONLY • Discounts, codes and expiry labels are sample data and cannot be redeemed.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 11,
                    height: 1.5,
                    color: Colors.grey,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ==================================================
  // MODERN APP BAR WITH BACK BUTTON
  // ==================================================

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: _teal,
      foregroundColor: Colors.white,
      elevation: 0,
      scrolledUnderElevation: 0,
      toolbarHeight: 76,
      automaticallyImplyLeading: false,
      titleSpacing: 12,

      leadingWidth: 58,

      leading: Padding(
        padding: const EdgeInsets.only(
          left: 12,
          top: 12,
          bottom: 12,
        ),
        child: Material(
          color: Colors.white.withValues(alpha: .16),
          borderRadius: BorderRadius.circular(14),
          child: InkWell(
            onTap: _goBack,
            borderRadius: BorderRadius.circular(14),
            child: const Icon(
              Icons.arrow_back_ios_new_rounded,
              color: Colors.white,
              size: 19,
            ),
          ),
        ),
      ),

      title: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Offers & Rewards',
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.w800,
            ),
          ),
          SizedBox(height: 4),
          Text(
            'Exclusive deals just for you',
            style: TextStyle(
              color: Colors.white70,
              fontSize: 11,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),

      actions: [
        IconButton(
          tooltip: 'Saved Offers',
          onPressed: _showFavorites,
          icon: Badge(
            isLabelVisible: _favorites.isNotEmpty,
            label: Text('${_favorites.length}'),
            child: const Icon(
              Icons.favorite_border_rounded,
              color: Colors.white,
              size: 25,
            ),
          ),
        ),
        const SizedBox(width: 12),
      ],

      systemOverlayStyle:
          SystemUiOverlayStyle.light,
    );
  }

  // ==================================================
  // FEATURED BANNER
  // ==================================================

  Widget _buildFeaturedBanner() {
    final offer = mockOffers.first;

    return Container(
      margin: const EdgeInsets.symmetric(
        horizontal: 20,
      ),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF0D9488),
            Color(0xFF075B60),
            Color(0xFF102D38),
          ],
        ),
        borderRadius: BorderRadius.circular(25),
        boxShadow: [
          BoxShadow(
            color: _teal.withValues(alpha: .22),
            blurRadius: 22,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned(
            right: -35,
            top: -35,
            child: CircleAvatar(
              radius: 105,
              backgroundColor:
                  Colors.white.withValues(alpha: .06),
            ),
          ),

          Positioned(
            right: 12,
            bottom: 15,
            child: Icon(
              Icons.restaurant_rounded,
              size: 105,
              color: Colors.white.withValues(alpha: .12),
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(23),
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(
                    horizontal: 11,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white
                        .withValues(alpha: .17),
                    borderRadius:
                        BorderRadius.circular(20),
                  ),
                  child: const Text(
                    '✦ FEATURED DEMO DEAL',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                      letterSpacing: .8,
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                const Text(
                  'BIG SAVINGS.\nBETTER DAYS.',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 29,
                    fontWeight: FontWeight.w900,
                    height: 1.08,
                  ),
                ),

                const SizedBox(height: 12),

                const Text(
                  'Explore our sample offers across OneClick services.',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 13,
                    height: 1.5,
                  ),
                ),

                const SizedBox(height: 18),

                Row(
                  children: [
                    Container(
                      padding:
                          const EdgeInsets.symmetric(
                        horizontal: 13,
                        vertical: 10,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius:
                            BorderRadius.circular(13),
                      ),
                      child: const Text(
                        'UP TO 30% OFF',
                        style: TextStyle(
                          color: _teal,
                          fontWeight: FontWeight.w900,
                          fontSize: 13,
                        ),
                      ),
                    ),

                    const SizedBox(width: 10),

                    TextButton.icon(
                      onPressed: () {
                        _showOfferDetails(offer);
                      },
                      icon: const Icon(
                        Icons.arrow_forward_rounded,
                        size: 17,
                      ),
                      label: const Text('Explore'),
                      style: TextButton.styleFrom(
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ==================================================
  // SEARCH
  // ==================================================

  Widget _buildSearch() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        20,
        22,
        20,
        0,
      ),
      child: TextField(
        controller: _searchController,

        onChanged: (value) {
          setState(() {
            _search = value;
          });
        },

        decoration: InputDecoration(
          hintText:
              'Search offers and categories...',
          hintStyle:
              const TextStyle(fontSize: 13),

          prefixIcon: const Icon(
            Icons.search_rounded,
            color: _teal,
          ),

          suffixIcon: _search.isEmpty
              ? null
              : IconButton(
                  onPressed: () {
                    _searchController.clear();

                    setState(() {
                      _search = '';
                    });
                  },
                  icon: const Icon(
                    Icons.close_rounded,
                  ),
                ),

          filled: true,
          fillColor: Colors.white,

          border: OutlineInputBorder(
            borderRadius:
                BorderRadius.circular(17),
            borderSide: BorderSide.none,
          ),

          contentPadding:
              const EdgeInsets.symmetric(
            vertical: 17,
          ),
        ),
      ),
    );
  }

  // ==================================================
  // CATEGORIES
  // ==================================================

  Widget _buildCategories() {
    return SizedBox(
      height: 72,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding:
            const EdgeInsets.symmetric(
          horizontal: 20,
        ),

        itemCount: categories.length,

        separatorBuilder: (_, __) {
          return const SizedBox(width: 9);
        },

        itemBuilder: (context, index) {
          final category = categories[index];
          final selected =
              _category == category;

          return Center(
            child: ChoiceChip(
              label: Text(category),
              selected: selected,
              showCheckmark: false,
              selectedColor: _teal,
              backgroundColor: Colors.white,

              side: BorderSide(
                color: selected
                    ? _teal
                    : const Color(0xFFE3EAED),
              ),

              labelStyle: TextStyle(
                color: selected
                    ? Colors.white
                    : _dark,
                fontWeight: FontWeight.w700,
                fontSize: 12,
              ),

              onSelected: (_) {
                setState(() {
                  _category = category;
                });
              },
            ),
          );
        },
      ),
    );
  }

  // ==================================================
  // OFFER CARD
  // ==================================================

  Widget _buildOfferCard(MockOffer offer) {
    final isSaved =
        _favorites.contains(offer.id);

    return Material(
      color: Colors.white,
      borderRadius:
          BorderRadius.circular(22),

      child: InkWell(
        onTap: () {
          _showOfferDetails(offer);
        },

        borderRadius:
            BorderRadius.circular(22),

        child: Container(
          padding:
              const EdgeInsets.all(17),

          decoration: BoxDecoration(
            borderRadius:
                BorderRadius.circular(22),

            border: Border.all(
              color:
                  const Color(0xFFE9EFF1),
            ),
          ),

          child: Column(
            crossAxisAlignment:
                CrossAxisAlignment.start,

            children: [
              Row(
                children: [
                  Container(
                    width: 53,
                    height: 53,

                    decoration: BoxDecoration(
                      color: offer.color
                          .withValues(alpha: .12),

                      borderRadius:
                          BorderRadius.circular(16),
                    ),

                    child: Icon(
                      offer.icon,
                      color: offer.color,
                      size: 27,
                    ),
                  ),

                  const Spacer(),

                  Container(
                    padding:
                        const EdgeInsets.symmetric(
                      horizontal: 11,
                      vertical: 7,
                    ),

                    decoration: BoxDecoration(
                      color: offer.color
                          .withValues(alpha: .10),

                      borderRadius:
                          BorderRadius.circular(11),
                    ),

                    child: Text(
                      offer.discount,

                      style: TextStyle(
                        color: offer.color,
                        fontWeight:
                            FontWeight.w900,
                        fontSize: 12,
                      ),
                    ),
                  ),

                  IconButton(
                    tooltip: isSaved
                        ? 'Remove from saved'
                        : 'Save offer',

                    onPressed: () {
                      setState(() {
                        if (isSaved) {
                          _favorites.remove(
                            offer.id,
                          );
                        } else {
                          _favorites.add(
                            offer.id,
                          );
                        }
                      });
                    },

                    icon: Icon(
                      isSaved
                          ? Icons.favorite_rounded
                          : Icons
                              .favorite_border_rounded,

                      color: isSaved
                          ? Colors.redAccent
                          : Colors.grey,

                      size: 21,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 13),

              Text(
                offer.category.toUpperCase(),

                style: TextStyle(
                  fontSize: 10,
                  color: offer.color,
                  fontWeight:
                      FontWeight.w800,
                  letterSpacing: 1,
                ),
              ),

              const SizedBox(height: 5),

              Text(
                offer.title,
                maxLines: 1,
                overflow:
                    TextOverflow.ellipsis,

                style: const TextStyle(
                  color: _dark,
                  fontSize: 16,
                  fontWeight:
                      FontWeight.w800,
                ),
              ),

              const SizedBox(height: 5),

              Text(
                offer.description,
                maxLines: 2,
                overflow:
                    TextOverflow.ellipsis,

                style: const TextStyle(
                  color: Colors.grey,
                  fontSize: 12,
                  height: 1.35,
                ),
              ),

              const Spacer(),

              const Divider(height: 12),

              Row(
                children: [
                  const Icon(
                    Icons.schedule_rounded,
                    size: 15,
                    color: Colors.grey,
                  ),

                  const SizedBox(width: 5),

                  Text(
                    offer.expiry,

                    style: const TextStyle(
                      fontSize: 11,
                      color: Colors.grey,
                    ),
                  ),

                  const Spacer(),

                  const Text(
                    'View Deal',

                    style: TextStyle(
                      fontSize: 12,
                      fontWeight:
                          FontWeight.w800,
                      color: _teal,
                    ),
                  ),

                  const SizedBox(width: 3),

                  const Icon(
                    Icons.arrow_forward_rounded,
                    color: _teal,
                    size: 16,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ==================================================
  // OFFER DETAILS BOTTOM SHEET
  // ==================================================

  void _showOfferDetails(MockOffer offer) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor:
          Colors.transparent,

      builder: (sheetContext) {
        return Container(
          padding: EdgeInsets.fromLTRB(
            24,
            15,
            24,
            MediaQuery.viewPaddingOf(
                  sheetContext,
                ).bottom +
                25,
          ),

          decoration:
              const BoxDecoration(
            color: Colors.white,
            borderRadius:
                BorderRadius.vertical(
              top: Radius.circular(28),
            ),
          ),

          child: Column(
            mainAxisSize:
                MainAxisSize.min,

            children: [
              Container(
                height: 5,
                width: 42,

                decoration: BoxDecoration(
                  color: Colors.black12,
                  borderRadius:
                      BorderRadius.circular(10),
                ),
              ),

              const SizedBox(height: 22),

              CircleAvatar(
                radius: 37,

                backgroundColor:
                    offer.color
                        .withValues(alpha: .12),

                child: Icon(
                  offer.icon,
                  color: offer.color,
                  size: 37,
                ),
              ),

              const SizedBox(height: 15),

              Text(
                offer.discount,

                style: TextStyle(
                  color: offer.color,
                  fontSize: 29,
                  fontWeight:
                      FontWeight.w900,
                ),
              ),

              const SizedBox(height: 8),

              Text(
                offer.title,
                textAlign:
                    TextAlign.center,

                style: const TextStyle(
                  fontSize: 21,
                  fontWeight:
                      FontWeight.w800,
                  color: _dark,
                ),
              ),

              const SizedBox(height: 9),

              Text(
                offer.description,
                textAlign:
                    TextAlign.center,

                style: const TextStyle(
                  fontSize: 13,
                  color: Colors.grey,
                  height: 1.5,
                ),
              ),

              const SizedBox(height: 24),

              Container(
                padding:
                    const EdgeInsets.all(17),

                decoration: BoxDecoration(
                  color: _background,

                  borderRadius:
                      BorderRadius.circular(17),

                  border: Border.all(
                    color: const Color(
                      0xFFDCE7EA,
                    ),
                  ),
                ),

                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment:
                            CrossAxisAlignment.start,

                        children: [
                          const Text(
                            'DEMO PROMO CODE',

                            style: TextStyle(
                              fontSize: 10,
                              color: Colors.grey,
                              letterSpacing: 1,
                              fontWeight:
                                  FontWeight.bold,
                            ),
                          ),

                          const SizedBox(height: 5),

                          Text(
                            offer.code,

                            style:
                                const TextStyle(
                              fontSize: 21,
                              fontWeight:
                                  FontWeight.w900,
                              color: _dark,
                              letterSpacing: 1.2,
                            ),
                          ),
                        ],
                      ),
                    ),

                    IconButton.filledTonal(
                      tooltip:
                          'Copy demo code',

                      onPressed: () async {
                        await Clipboard.setData(
                          ClipboardData(
                            text: offer.code,
                          ),
                        );

                        if (!sheetContext
                            .mounted) {
                          return;
                        }

                        ScaffoldMessenger.of(
                          sheetContext,
                        ).showSnackBar(
                          const SnackBar(
                            content: Text(
                              'Demo code copied. Not redeemable.',
                            ),
                          ),
                        );
                      },

                      icon: const Icon(
                        Icons.copy_rounded,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 14),

              Row(
                mainAxisAlignment:
                    MainAxisAlignment.center,

                children: [
                  const Icon(
                    Icons.schedule_rounded,
                    size: 16,
                    color: Colors.grey,
                  ),

                  const SizedBox(width: 6),

                  Text(
                    'Sample expiry: ${offer.expiry}',

                    style:
                        const TextStyle(
                      color: Colors.grey,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 12),

              const Text(
                'Preview only. This offer is not active and cannot be redeemed.',
                textAlign:
                    TextAlign.center,

                style: TextStyle(
                  fontSize: 11,
                  color: Colors.grey,
                ),
              ),

              const SizedBox(height: 22),

              SizedBox(
                width: double.infinity,

                child: FilledButton(
                  onPressed: () {
                    Navigator.pop(
                      sheetContext,
                    );
                  },

                  style:
                      FilledButton.styleFrom(
                    backgroundColor: _teal,

                    padding:
                        const EdgeInsets.symmetric(
                      vertical: 17,
                    ),

                    shape:
                        RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.circular(15),
                    ),
                  ),

                  child: const Text(
                    'Continue Exploring',

                    style: TextStyle(
                      fontWeight:
                          FontWeight.w800,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // ==================================================
  // SAVED OFFERS BOTTOM SHEET
  // ==================================================

  void _showFavorites() {
    final saved = mockOffers
        .where(
          (offer) =>
              _favorites.contains(
                offer.id,
              ),
        )
        .toList();

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,

      builder: (sheetContext) {
        return SafeArea(
          child: Padding(
            padding:
                const EdgeInsets.all(20),

            child: Column(
              mainAxisSize:
                  MainAxisSize.min,

              children: [
                const Text(
                  'Saved Offers',

                  style: TextStyle(
                    fontSize: 21,
                    fontWeight:
                        FontWeight.w800,
                  ),
                ),

                const SizedBox(height: 15),

                if (saved.isEmpty)
                  const Padding(
                    padding:
                        EdgeInsets.all(25),

                    child: Text(
                      'No saved offers yet.\nTap the heart on an offer to save it.',
                      textAlign:
                          TextAlign.center,
                    ),
                  )
                else
                  ConstrainedBox(
                    constraints:
                        const BoxConstraints(
                      maxHeight: 400,
                    ),

                    child: ListView.builder(
                      shrinkWrap: true,
                      itemCount:
                          saved.length,

                      itemBuilder:
                          (context, index) {
                        final offer =
                            saved[index];

                        return ListTile(
                          leading: Icon(
                            offer.icon,
                            color:
                                offer.color,
                          ),

                          title: Text(
                            offer.title,
                          ),

                          subtitle: Text(
                            offer.discount,
                          ),

                          trailing:
                              const Icon(
                            Icons
                                .chevron_right_rounded,
                          ),

                          onTap: () {
                            Navigator.pop(
                              sheetContext,
                            );

                            _showOfferDetails(
                              offer,
                            );
                          },
                        );
                      },
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}
