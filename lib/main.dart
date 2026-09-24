import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const BazarKartApp());
}

class BazarKartApp extends StatelessWidget {
  const BazarKartApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'BazarKart',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.deepOrange,
        scaffoldBackgroundColor: Colors.grey[100],
      ),
      home: const HomePage(),
    );
  }
}

// ----------------- ১. হোম পেজ (প্রোডাক্ট লিস্ট) -----------------
class HomePage extends StatelessWidget {
  const HomePage({Key? key}) : super(key: key);

  final List<Map<String, dynamic>> products = const [
    {'name': 'প্রিমিয়াম বাসমতি চাল (৫ কেজি)', 'price': 650.0, 'image': 'https://images.unsplash.com/photo-1586201375761-83865001e31c?w=500'},
    {'name': 'সরিষার খাঁটি তেল (১ লিটার)', 'price': 220.0, 'image': 'https://images.unsplash.com/photo-1474979266404-7eaacbcd87c5?w=500'},
    {'name': 'দেশি মসুর ডাল (১ কেজি)', 'price': 140.0, 'image': 'https://images.unsplash.com/photo-1585670149967-b4f4daab7634?w=500'},
    {'name': 'ফ্রেশ চিনাবাদাম (১ কেজি)', 'price': 180.0, 'image': 'https://images.unsplash.com/photo-1567306226416-28f0efdc88ce?w=500'},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('BazarKart - বাজার কার্ট', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.deepOrange,
        actions: [
          // অ্যাডমিন প্যানেলে যাওয়ার বাটন
          IconButton(
            icon: const Icon(Icons.admin_panel_settings),
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) => const AdminLoginPage()));
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(10.0),
        child: GridView.builder(
          itemCount: products.length,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            childAspectRatio: 0.75,
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
          ),
          itemBuilder: (context, index) {
            final product = products[index];
            return Card(
              elevation: 3,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: ClipRRect(
                      borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                      child: Image.network(
                        product['image'],
                        fit: BoxFit.cover,
                        width: double.infinity,
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          product['name'],
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '৳${product['price']}',
                          style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                        const SizedBox(height: 8),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.deepOrange,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 4),
                            ),
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => CheckoutPage(
                                    productName: product['name'],
                                    productPrice: product['price'],
                                  ),
                                ),
                              );
                            },
                            child: const Text('অর্ডার করুন (Buy Now)', style: TextStyle(fontSize: 12)),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

// ----------------- ২. চেকআউট ও ক্যাশ অন ডেলিভারি পেজ -----------------
class CheckoutPage extends StatefulWidget {
  final String productName;
  final double productPrice;

  const CheckoutPage({Key? key, required this.productName, required this.productPrice}) : super(key: key);

  @override
  _CheckoutPageState createState() => _CheckoutPageState();
}

class _CheckoutPageState extends State<CheckoutPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  bool _isLoading = false;

  Future<void> _placeOrder() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);

      try {
        // ফায়ারস্টোর ডাটাবেজে ক্যাশ অন ডেলিভারি অর্ডার সেভ করা হচ্ছে
        await FirebaseFirestore.instance.collection('orders').add({
          'productName': widget.productName,
          'productPrice': widget.productPrice,
          'customerName': _nameController.text.trim(),
          'customerPhone': _phoneController.text.trim(),
          'deliveryAddress': _addressController.text.trim(),
          'paymentMethod': 'Cash on Delivery (COD)',
          'orderDate': Timestamp.now(),
          'status': 'Pending',
        });

        setState(() => _isLoading = false);

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('অর্ডার সফলভাবে সম্পন্ন হয়েছে! ধন্যবাদ।')),
        );
        Navigator.pop(context);
      } catch (e) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('সমস্যা হয়েছে: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('চেকআউট ও ক্যাশ অন ডেলিভারি'),
        backgroundColor: Colors.deepOrange,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              Card(
                color: Colors.orange[50],
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('প্রোডাক্ট: ${widget.productName}', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 5),
                      Text('মূল্য: ৳${widget.productPrice}', style: const TextStyle(fontSize: 15, color: Colors.green, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 5),
                      const Text('পেমেন্ট পদ্ধতি: ক্যাশ অন ডেলিভারি (Cash on Delivery)', style: TextStyle(fontSize: 13, color: Colors.grey)),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'আপনার নাম', border: OutlineInputBorder()),
                validator: (val) => val!.isEmpty ? 'নাম লিখুন' : null,
              ),
              const SizedBox(height: 15),
              TextFormField(
                controller: _phoneController,
                keyboardType: TextInputType.phone,
                decoration: const InputDecoration(labelText: 'মোবাইল নম্বর', border: OutlineInputBorder()),
                validator: (val) => val!.isEmpty ? 'মোবাইল নম্বর লিখুন' : null,
              ),
              const SizedBox(height: 15),
              TextFormField(
                controller: _addressController,
                maxLines: 3,
                decoration: const InputDecoration(labelText: 'সম্পূর্ণ ডেলিভারি ঠিকানা (বাসা, রোড, এলাকা, জেলা)', border: OutlineInputBorder()),
                validator: (val) => val!.isEmpty ? 'ঠিকানা লিখুন' : null,
              ),
              const SizedBox(height: 25),
              _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.deepOrange,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      onPressed: _placeOrder,
                      child: const Text('অর্ডার কনফার্ম করুন (Place Order)', style: TextStyle(fontSize: 16)),
                    ),
            ],
          ),
        ),
      ),
    );
  }
}

// ----------------- ৩. অ্যাডমিন লগইন পেজ -----------------
class AdminLoginPage extends StatefulWidget {
  const AdminLoginPage({Key? key}) : super(key: key);

  @override
  _AdminLoginPageState createState() => _AdminLoginPageState();
}

class _AdminLoginPageState extends State<AdminLoginPage> {
  final TextEditingController _phoneController = TextEditingController();
  final String adminSecretPhone = "01700000000"; // আপনার পছন্দমতো অ্যাডমিন নম্বর এখানে দিতে পারেন

  void _verifyAdmin() {
    if (_phoneController.text.trim() == adminSecretPhone) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const AdminDashboardPage()),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('ভুল ফোন নম্বর! এটি অ্যাডমিন নম্বর নয়।')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('অ্যাডমিন লগইন'), backgroundColor: Colors.deepOrange),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.lock_person, size: 80, color: Colors.deepOrange),
            const SizedBox(height: 20),
            const Text('অ্যাডমিন প্যানেলে প্রবেশ করতে আপনার নিবন্ধিত ফোন নম্বরটি দিন', textAlign: TextAlign.center, style: TextStyle(fontSize: 16)),
            const SizedBox(height: 20),
            TextField(
              controller: _phoneController,
              keyboardType: TextInputType.phone,
              decoration: const InputDecoration(labelText: 'অ্যাডমিন মোবাইল নম্বর', border: OutlineInputBorder()),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: Colors.deepOrange, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(vertical: 12)),
                onPressed: _verifyAdmin,
                child: const Text('লগইন করুন', style: TextStyle(fontSize: 16)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ----------------- ৪. অ্যাডমিন ড্যাশবোর্ড (অর্ডার লিস্ট দেখার পেজ) -----------------
class AdminDashboardPage extends StatelessWidget {
  const AdminDashboardPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('অ্যাডমিন প্যানেল - অর্ডারের তালিকা'),
        backgroundColor: Colors.deepOrange,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('orders').orderBy('orderDate', descending: true).snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('এখনো কোনো অর্ডার আসেনি!', style: TextStyle(fontSize: 16)));
          }

          final orders = snapshot.data!.docs;

          return ListView.builder(
            itemCount: orders.length,
            itemBuilder: (context, index) {
              final order = orders[index];
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                child: ListTile(
                  title: Text(order['productName'], style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 4),
                      Text('ক্রেতার নাম: ${order['customerName']}'),
                      Text('মোবাইল: ${order['customerPhone']}'),
                      Text('ঠিকানা: ${order['deliveryAddress']}'),
                      Text('মূল্য: ৳${order['productPrice']} (${order['paymentMethod']})', style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold)),
                    ],
                  ),
                  isThreeLine: true,
                  trailing: const Icon(Icons.shopping_bag, color: Colors.deepOrange),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
