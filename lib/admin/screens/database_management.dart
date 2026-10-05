import 'package:flutter/material.dart';

class DatabaseManagement extends StatelessWidget {
  const DatabaseManagement({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Database Management'),
        backgroundColor: const Color(0xff032744), // Primary Color
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(18.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'System Data Overview',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xFF111827),
              ),
            ),
            const SizedBox(height: 16),
            
            // Database Statistics Cards
            _buildStatCard(Icons.people, 'Users', '1,248 Records', Colors.blue),
            const SizedBox(height: 12),
            _buildStatCard(Icons.fastfood, 'Food Orders', '520 Records', Colors.green),
            const SizedBox(height: 12),
            _buildStatCard(Icons.local_grocery_store, 'Grocery Items', '340 Records', Colors.orange),
            const SizedBox(height: 12),
            _buildStatCard(Icons.history, 'Audit Logs', '2,150 Records', Colors.purple),
            
            const SizedBox(height: 32),
            const Divider(),
            const SizedBox(height: 16),
            
            const Text(
              'Database Actions',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF111827),
              ),
            ),
            const SizedBox(height: 16),
            
            // Backup Button
            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton.icon(
                onPressed: () {
                  // TODO: Implement actual database backup logic with backend
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Database backup initiated...'),
                      backgroundColor: Colors.green,
                    ),
                  );
                },
                icon: const Icon(Icons.cloud_download),
                label: const Text(
                  'Backup Database',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xff032744),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Reusable Widget for Data Statistics
  Widget _buildStatCard(IconData icon, String title, String count, Color color) {
    return Card(
      elevation: 1,
      shadowColor: Colors.black.withOpacity(0.1),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            Container(
               padding: const EdgeInsets.all(12),
               decoration: BoxDecoration(
                 color: color.withOpacity(0.15),
                 borderRadius: BorderRadius.circular(12),
               ),
               child: Icon(icon, color: color, size: 28),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    count,
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            ),
            Icon(Icons.chevron_right, color: Colors.grey.shade400),
          ],
        ),
      ),
    );
  }
}