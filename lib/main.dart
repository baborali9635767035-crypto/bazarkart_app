import 'package:flutter/material.dart';

void main() {
  runApp(const BazarKartApp());
}

class BazarKartApp extends StatelessWidget {
  const BazarKartApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'BazarKart Dropshipping',
      theme: ThemeData(
        primarySwatch: Colors.deepOrange,
        scaffoldBackgroundColor: const Color(0xFFF9F6F0),
      ),
      home: const MainContainerScreen(),
    );
  }
}

class MainContainerScreen extends StatefulWidget {
  const MainContainerScreen({super.key});

  @override
  State<MainContainerScreen> createState() => _MainContainerScreenState();
}

class _MainContainerScreenState extends State<MainContainerScreen> {
  bool isAdminMode = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          isAdminMode ? 'BazarKart - Admin Panel' : 'BazarKart Store',
          style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        backgroundColor: isAdminMode ? Colors.black87 : Colors.deepOrange,
        actions: [
          Row(
            children: [
              Text(
                isAdminMode ? 'Admin' : 'User',
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
              Switch(
                value: isAdminMode,
                activeColor: Colors.white,
                onChanged: (value) {
                  setState(() {
                    isAdminMode = value;
                  });
                },
              ),
            ],
          ),
        ],
      ),
      body: isAdminMode ? const AdminDashboard() : const CustomerHomeScreen(),
    );
  }
}

class CustomerHomeScreen extends StatelessWidget {
  const CustomerHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final List<Map<String, String>> categories = [
      {'name': 'Electronics', 'icon': '⚡'},
      {'name': 'Fashion', 'icon': '👕'},
      {'name': 'Home Decor', 'icon': '🏡'},
      {'name': 'Gadgets', 'icon': '📱'},
    ];

    final List<Map<String, String>> products = [
      {'title': 'Smart Watch X1', 'price': '\$29.99', 'image': '⌚'},
      {'title': 'Wireless Earbuds', 'price': '\$19.99', 'image': '🎧'},
      {'title': 'Mini LED Projector', 'price': '\$45.00', 'image': '📽️'},
      {'title': 'Fitness Band', 'price': '\$15.50', 'image': '🏃'},
    ];

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.deepOrange.shade50,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.deepOrange.shade200),
            ),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Global Dropshipping Store',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.deepOrange),
                ),
                SizedBox(height: 8),
                Text(
                  'Welcome! Browse winning products and order instantly.',
                  style: TextStyle(fontSize: 14, color: Colors.black87),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          const Text('Categories', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 10),
          SizedBox(
            height: 90,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: categories.length,
              itemBuilder: (context, index) {
                return Container(
                  width: 85,
                  margin: const EdgeInsets.only(right: 12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(categories[index]['icon']!, style: const TextStyle(fontSize: 28)),
                      const SizedBox(height: 6),
                      Text(categories[index]['name']!, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w500)),
                    ],
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 20),
          const Text('Hot Products', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 10),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: products.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 0.8,
            ),
            itemBuilder: (context, index) {
              return Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(products[index]['image']!, style: const TextStyle(fontSize: 45)),
                    const SizedBox(height: 10),
                    Text(products[index]['title']!, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                    const SizedBox(height: 4),
                    Text(products[index]['price']!, style: const TextStyle(color: Colors.deepOrange, fontWeight: FontWeight.bold, fontSize: 15)),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

class AdminDashboard extends StatelessWidget {
  const AdminDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: ListView(
        children: [
          const Text('Owner Dashboard', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
          const SizedBox(height: 15),
          Row(
            children: [
              Expanded(child: _buildStatCard('Total Orders', '12', Colors.blue)),
              const SizedBox(width: 10),
              Expanded(child: _buildStatCard('Total Revenue', '\$450', Colors.green)),
            ],
          ),
          const SizedBox(height: 20),
          const Text('Admin Controls', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 10),
          ListTile(
            tileColor: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            leading: const Icon(Icons.add_box, color: Colors.deepOrange),
            title: const Text('Add New Product'),
            subtitle: const Text('Import items for dropshipping'),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () {},
          ),
          const SizedBox(height: 10),
          ListTile(
            tileColor: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            leading: const Icon(Icons.list_alt, color: Colors.indigo),
            title: const Text('Manage Orders'),
            subtitle: const Text('Check customer purchases'),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () {},
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String title, String value, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontSize: 14, color: Colors.grey)),
          const SizedBox(height: 8),
          Text(value, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: color)),
        ],
      ),
    );
  }
}
