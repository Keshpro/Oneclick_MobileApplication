import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'job_booking_screen.dart'; // Corrected import for booking screen
import 'package:oneclick/core/theme/app_theme.dart'; // UI only: Fresh Teal tokens

class WorkerProfileScreen extends StatelessWidget {
  final Map<String, dynamic> worker;

  const WorkerProfileScreen({super.key, required this.worker});

  @override
  Widget build(BuildContext context) {
    // Extract dynamic profile details safely from Firestore structure
    final name = worker['name']?.toString() ?? 'Worker';
    final isAvailable = worker['isAvailable'] == true ||
        worker['status'] == 'active' ||
        worker['status'] == 'approved';
    final category = worker['category']?.toString() ?? 'Technician';

    // Safely extract providerDetails sub-map if present
    final providerDetails =
        worker['providerDetails'] as Map<String, dynamic>? ?? {};
    final hourlyRate = providerDetails['hourlyRate']?.toString() ??
        worker['hourlyRate']?.toString() ??
        worker['rate']?.toString() ??
        '1500';
    final experience = providerDetails['experienceYears']?.toString() ??
        worker['experience']?.toString() ??
        '3+';
    final rating = worker['rating']?.toString() ?? '5.0';
    final jobsDone = worker['jobsDone']?.toString() ?? '25+';

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('$category Profile'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        systemOverlayStyle: SystemUiOverlayStyle.light,
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.surface,
          boxShadow: [
            BoxShadow(
              color: AppColors.textDark.withValues(alpha: 0.08),
              blurRadius: 16,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: SafeArea(
          child: Row(
            children: [
              Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Hourly Rate',
                    style: TextStyle(color: AppColors.textSecondary, fontSize: 12),
                  ),
                  Text(
                    'LKR $hourlyRate/hr',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textDark,
                    ),
                  ),
                ],
              ),
              const Spacer(),
              SizedBox(
                height: 48,
                width: 160,
                child: ElevatedButton(
                  onPressed: isAvailable
                      ? () {
                          // Correctly navigates to JobBookingScreen with worker data
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => JobBookingScreen(worker: worker),
                            ),
                          );
                        }
                      : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppRadius.button),
                    ),
                  ),
                  child: const Text(
                    'Book Now',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Profile Card
            _card(
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 44,
                    backgroundColor: AppColors.primary.withValues(alpha: 0.12),
                    child: Text(
                      name.isNotEmpty ? name.substring(0, 1).toUpperCase() : 'W',
                      style: const TextStyle(
                        fontSize: 36,
                        fontWeight: FontWeight.w700,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    name,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textDark,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    category,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColors.primary,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: isAvailable
                          ? AppColors.success.withValues(alpha: 0.12)
                          : Colors.red.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Text(
                      isAvailable ? 'Available for work' : 'Currently Busy',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: isAvailable ? AppColors.success : Colors.red,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Divider(color: _lineColor),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildStatItem(
                          Icons.star_rounded, rating, 'Rating', Colors.amber),
                      _buildStatItem(Icons.task_alt_rounded, jobsDone,
                          'Jobs Done', AppColors.primary),
                      _buildStatItem(Icons.work_history_rounded,
                          '$experience Yrs', 'Experience', AppColors.success),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // About Section
            _card(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'About Professional',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textDark,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Verified $category with over $experience years of field experience on OneClick. Specialized in quick response, quality maintenance, and guaranteed work satisfaction for home and business needs.',
                    style: const TextStyle(
                        color: AppColors.textSecondary, height: 1.5, fontSize: 14),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Portfolio / Recent Work Preview
            _card(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Recent Work Portfolio',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textDark,
                    ),
                  ),
                  const SizedBox(height: 16),
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                      crossAxisSpacing: 8,
                      mainAxisSpacing: 8,
                    ),
                    itemCount: 3,
                    itemBuilder: (context, index) {
                      return Container(
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: 0.06),
                          borderRadius: BorderRadius.circular(AppRadius.button),
                          border: Border.all(color: _lineColor),
                        ),
                        child: Icon(Icons.handyman_outlined,
                            color: AppColors.primary.withValues(alpha: 0.5),
                            size: 32),
                      );
                    },
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Reviews Section
            _card(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Customer Reviews',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textDark,
                        ),
                      ),
                      Text(
                        'Rating: $rating / 5.0',
                        style: const TextStyle(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w700,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _buildReviewItem(
                    'Kasun Fernando',
                    'Very efficient and professional service! Fixed the issue cleanly in short time.',
                    5,
                  ),
                  const Divider(height: 32, color: _lineColor),
                  _buildReviewItem(
                    'Nimali Silva',
                    'Punctual and polite. Solved our home problem without any hassle.',
                    5,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  static const Color _lineColor = Color(0xFFD9ECEA);

  // White Fresh Teal card (radius 16, soft shadow)
  Widget _card({required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.card),
        boxShadow: [
          BoxShadow(
            color: AppColors.textDark.withValues(alpha: 0.06),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: child,
    );
  }

  Widget _buildStatItem(
      IconData icon, String value, String label, Color iconColor) {
    return Column(
      children: [
        Icon(icon, color: iconColor, size: 24),
        const SizedBox(height: 8),
        Text(value,
            style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: AppColors.textDark)),
        const SizedBox(height: 4),
        Text(label,
            style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
      ],
    );
  }

  Widget _buildReviewItem(String name, String comment, int stars) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            CircleAvatar(
              radius: 16,
              backgroundColor: AppColors.primary.withValues(alpha: 0.12),
              child: Text(
                name.isNotEmpty ? name[0] : 'U',
                style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    color: AppColors.primary,
                    fontSize: 12),
              ),
            ),
            const SizedBox(width: 8),
            Text(name,
                style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                    color: AppColors.textDark)),
            const Spacer(),
            Row(
              children: List.generate(
                5,
                (index) => Icon(
                  Icons.star_rounded,
                  size: 16,
                  color: index < stars ? Colors.amber : _lineColor,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          comment,
          style: const TextStyle(
              color: AppColors.textSecondary, fontSize: 12, height: 1.4),
        ),
      ],
    );
  }
}