
import 'package:flutter/material.dart';

import '../services/worker_auth_service.dart';
import 'incoming_requests_screen.dart';
import 'worker_jobs_screen.dart';
import 'worker_profile_screen.dart';

class WorkerDashboardScreen extends StatefulWidget {
  const WorkerDashboardScreen({super.key});

  @override
  State<WorkerDashboardScreen> createState() =>
      _WorkerDashboardScreenState();
}

class _WorkerDashboardScreenState
    extends State<WorkerDashboardScreen> {
  final WorkerAuthService _authService =
      WorkerAuthService.instance;

  Map<String, dynamic>? workerData;

  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadWorker();
  }

  Future<void> _loadWorker() async {
    try {
      final data = await _authService.getCurrentWorker();

      if (!mounted) return;

      setState(() {
        workerData = data;
        isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        isLoading = false;
      });
    }
  }

  // Navigate to Incoming Requests
  void _openIncomingRequests() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const IncomingRequestsScreen(),
      ),
    );
  }

  // Navigate to My Jobs
  void _openMyJobs() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const WorkerJobsScreen(),
      ),
    );
  }

  // Navigate to Worker Profile
  void _openMyProfile() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const WorkerProfileScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (workerData == null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.person_off,
              size: 60,
              color: Colors.grey,
            ),
            const SizedBox(height: 12),
            const Text(
              'Worker data not found.',
              style: TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 12),
            ElevatedButton.icon(
              onPressed: () {
                setState(() {
                  isLoading = true;
                });
                _loadWorker();
              },
              icon: const Icon(Icons.refresh),
              label: const Text('Try Again'),
            ),
          ],
        ),
      );
    }

    final name = workerData!['name']?.toString() ?? '';
    final username =
        workerData!['username']?.toString() ?? '';
    final category =
        workerData!['category']?.toString() ?? '';
    final area = workerData!['area']?.toString() ?? '';
    final phone = workerData!['phone']?.toString() ?? '';
    final rating = workerData!['rating'] ?? 0;
    final jobsCompleted = workerData!['jobsCompleted'] ?? 0;
    final experience = workerData!['experience'] ?? 0;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Worker Dashboard'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            tooltip: 'My Profile',
            onPressed: _openMyProfile,
            icon: const Icon(Icons.account_circle),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Welcome section
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [
                    Color(0xFF1565C0),
                    Color(0xFF42A5F5),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const CircleAvatar(
                    radius: 30,
                    backgroundColor: Colors.white,
                    child: Icon(
                      Icons.person,
                      size: 35,
                      color: Colors.blue,
                    ),
                  ),
                  const SizedBox(height: 15),
                  const Text(
                    'Welcome back,',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    name,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 25,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    '@$username',
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 15,
                    ),
                  ),
                  const SizedBox(height: 15),
                  Row(
                    children: [
                      const Icon(
                        Icons.build,
                        color: Colors.white,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          category,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                          ),
                        ),
                      ),
                      const Icon(
                        Icons.location_on,
                        color: Colors.white,
                      ),
                      const SizedBox(width: 5),
                      Expanded(
                        child: Text(
                          area,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 25),

            const Text(
              'Worker Information',
              style: TextStyle(
                fontSize: 21,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 12),

            _infoCard(
              icon: Icons.person,
              title: 'Username',
              value: username,
            ),

            _infoCard(
              icon: Icons.phone,
              title: 'Phone',
              value: phone,
            ),

            _infoCard(
              icon: Icons.build,
              title: 'Category',
              value: category,
            ),

            _infoCard(
              icon: Icons.location_on,
              title: 'Area',
              value: area,
            ),

            _infoCard(
              icon: Icons.star,
              title: 'Rating',
              value: rating.toString(),
            ),

            _infoCard(
              icon: Icons.work,
              title: 'Jobs Completed',
              value: jobsCompleted.toString(),
            ),

            _infoCard(
              icon: Icons.timeline,
              title: 'Experience',
              value: '$experience years',
            ),

            const SizedBox(height: 25),

            const Text(
              'Manage Your Work',
              style: TextStyle(
                fontSize: 21,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 12),

            // Incoming Requests button
            _navigationCard(
              icon: Icons.inbox_outlined,
              title: 'Incoming Requests',
              subtitle:
                  'View customer service requests',
              color: Colors.orange,
              onTap: _openIncomingRequests,
            ),

            // My Jobs button
            _navigationCard(
              icon: Icons.work_outline,
              title: 'My Jobs',
              subtitle:
                  'Manage accepted and completed jobs',
              color: Colors.green,
              onTap: _openMyJobs,
            ),

            // My Profile button
            _navigationCard(
              icon: Icons.person_outline,
              title: 'My Profile',
              subtitle:
                  'View and edit your worker profile',
              color: Colors.blue,
              onTap: _openMyProfile,
            ),

            const SizedBox(height: 20),

            const Card(
              child: Padding(
                padding: EdgeInsets.all(20),
                child: Row(
                  children: [
                    Icon(
                      Icons.notifications_active,
                      size: 35,
                      color: Colors.blue,
                    ),
                    SizedBox(width: 15),
                    Expanded(
                      child: Text(
                        'Manage your requests, jobs, '
                        'and profile from this dashboard.',
                        style: TextStyle(fontSize: 16),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _infoCard({
    required IconData icon,
    required String title,
    required String value,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: Icon(
          icon,
          color: Colors.blue,
          size: 28,
        ),
        title: Text(
          title,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: Text(
          value.isEmpty ? 'Not provided' : value,
        ),
      ),
    );
  }

  Widget _navigationCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      child: ListTile(
        contentPadding: const EdgeInsets.all(12),
        leading: CircleAvatar(
          backgroundColor: color.withAlpha(30),
          child: Icon(
            icon,
            color: color,
          ),
        ),
        title: Text(
          title,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        subtitle: Text(subtitle),
        trailing: const Icon(
          Icons.arrow_forward_ios,
          size: 18,
        ),
        onTap: onTap,
      ),
    );
  }
}
