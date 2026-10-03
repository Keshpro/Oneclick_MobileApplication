Widget _statCard({
  required String title,
  required String value,
  required IconData icon,
  required Color iconColor,
  String? subtitle,
}) {
  return Card(
    elevation: 2,
    shadowColor: Colors.black12,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    child: Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(9),
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          const SizedBox(height: 12),
          Card(
            child: ListTile(
              leading: const Icon(
                Icons.storefront_rounded,
                color: Colors.green,
                size: 36,
              ),
              title: const Text('Food Seller Applications'),
              subtitle: const Text(
                'Review and approve food seller applications',
              ),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const FoodAdminSellerApplicationsScreen(),
                  ),
                );
              },
            ),
          ),
          Card(
            child: ListTile(
              leading: const Icon(
                Icons.manage_accounts,
                color: Colors.indigo,
                size: 36,
              ),
              title: const Text('User Management'),
              subtitle: const Text('View, update, or remove users (CRUD)'),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const UserManagementScreen(),
                  ),
                );
              },
            ),
          ),

          if (subtitle != null) ...[
            const SizedBox(height: 3),
            Text(
              subtitle,
              style: TextStyle(fontSize: 11, color: Colors.grey.shade500),
            ),
          ],
        ],
      ),
    ),
  );
}

// ================================================================
// CATEGORY AUDIT TABS
// ================================================================
