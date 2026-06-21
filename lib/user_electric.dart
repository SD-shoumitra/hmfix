import 'package:flutter/material.dart';
import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'user_electric_bookform.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'login.dart';

class UserElectricScreen extends StatefulWidget {

  final String serviceType;
  final String pageTitle;

  const UserElectricScreen({
    super.key,
    required this.serviceType,
    required this.pageTitle,
  });

  @override
  State<UserElectricScreen> createState() =>
      _UserElectricScreenState();
}

class _UserElectricScreenState extends State<UserElectricScreen> {
  late Timer _timer;
  String _currentTime = "";
  String _currentDate = "";

  @override
  void initState() {
    super.initState();
    _updateTime();
    // প্রতি মিনিটে বা সেকেন্ডে সময় আপডেট করার জন্য টাইমার
    _timer = Timer.periodic(const Duration(minutes: 1), (timer) {
      _updateTime();
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  void _updateTime() {
    final now = DateTime.now();
    
    // Formatting Time (English, 12-hour format, AM/PM, no seconds)
    int hour = now.hour % 12;
    if (hour == 0) hour = 12;
    String minute = now.minute.toString().padLeft(2, '0');
    String period = now.hour >= 12 ? "PM" : "AM";
    
    // Formatting Date (English format)
    List<String> months = [
      'January', 'February', 'March', 'April', 'May', 'June', 
      'July', 'August', 'September', 'October', 'November', 'December'
    ];
    String day = now.day.toString();
    String month = months[now.month - 1];
    String year = now.year.toString();

    if (mounted) {
      setState(() {
        _currentTime = "${hour.toString().padLeft(2, '0')}:$minute $period";
        _currentDate = "$day $month, $year";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFF),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF1B263B)),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          widget.pageTitle,
          style: TextStyle(
            color: Color(0xFF1B263B),
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        centerTitle: true,

      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Real-time Time and Date Bar
          Container(
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: const Color(0xFFF0F6FF),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFD1E4FF)),
            ),
            child: Row(
              children: [
                const Icon(Icons.access_time_filled, color: Color(0xFF0066FF), size: 22),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _currentTime,
                        style: const TextStyle(
                          color: Color(0xFF0066FF),
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                      Text(
                        _currentDate,
                        style: const TextStyle(
                          color: Color(0xFF1B263B),
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
                const Icon(Icons.calendar_today_rounded, color: Color(0xFF0066FF), size: 20),
              ],
            ),
          ),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Text(
              widget.pageTitle,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1B263B),
              ),
            ),
          ),

    Expanded(
        child: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('workers')
            .where('serviceType', isEqualTo: widget.serviceType,)
            .where('isAvailable', isEqualTo: true)
            .snapshots(),
        builder: (context, snapshot) {

        if (snapshot.connectionState ==
        ConnectionState.waiting) {
        return const Center(
        child: CircularProgressIndicator(),
        );
        }

        if (!snapshot.hasData ||
        snapshot.data!.docs.isEmpty) {
          return Center(
            child: Text(
              "কোনো ${widget.pageTitle} পাওয়া যায়নি",
            ),
          );
        }

        final workers = snapshot.data!.docs;

        return ListView.builder(
        padding: const EdgeInsets.symmetric(
        horizontal: 16,
        ),
        itemCount: workers.length,
        itemBuilder: (context, index) {

        final worker =
        workers[index].data()
        as Map<String, dynamic>;

        return _buildElectricianCard(
        worker,
        );
        },
        );
        },
        ),
        ),
        ],
      ),
    );
  }

  // all worker card

  Widget _buildElectricianCard(
      Map<String, dynamic> worker,
      ) {

    return GestureDetector(
      // aunthication check
      onTap: () {

        final user = FirebaseAuth.instance.currentUser;

        if (user == null) {

          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => const LoginScreen(),
            ),
          );

        } else {

          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => UserElectricBookForm(
                worker: worker,
              ),
            ),
          );

        }
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            // Profile Image
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.grey.shade100,
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(40),
                child: const Icon(Icons.person, size: 50, color: Colors.grey),
              ),
            ),
            const SizedBox(width: 16),
            // Details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        worker['name'] ?? "",
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1B263B),
                        ),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          const Text(
                            "অভিজ্ঞতা",
                            style: TextStyle(color: Colors.grey, fontSize: 11),
                          ),
                          Text(
                            "${worker['experience'] ?? ""}",
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                              color: Colors.black87,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  Text(
                    worker['serviceType'] ?? "",
                    style: const TextStyle(color: Colors.grey, fontSize: 13),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.star, color: Colors.blue, size: 18),
                          const SizedBox(width: 4),
                          Text(
                            "${worker['rating'] ?? 0}",
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.blue,
                            ),
                          ),

                        ],
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            "৳ ${worker['serviceCharge'] ?? 0}",
                            style: const TextStyle(
                              color: Colors.green,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          const Text(
                            "(সার্ভিস চার্জ)",
                            style: TextStyle(color: Colors.grey, fontSize: 10),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
