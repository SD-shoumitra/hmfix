import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'worker_profile.dart';
import 'worker_requests_screen.dart';
import 'worker_amar_kaaj.dart';

class WorkerDashboard extends StatefulWidget {
  const WorkerDashboard({super.key});

  @override
  State<WorkerDashboard> createState() => _WorkerDashboardState();
}

class _WorkerDashboardState extends State<WorkerDashboard> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    String? userPhone;
    if (user != null) {
      if (user.email != null && user.email!.contains('@hmfix.com')) {
        userPhone = user.email!.split('@')[0];
      } else if (user.phoneNumber != null) {
        userPhone = user.phoneNumber!.replaceAll('+88', '');
      }
    }

    return Scaffold(
      backgroundColor: Colors.white,
      body: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance
            .collection('workers')
            .doc(userPhone)
            .snapshots(),
        builder: (context, snapshot) {
          String name = "";
          String profession = "";
          bool isOnline = true;
          bool isAvailable = true;

          Map<String, dynamic> userData = {};
          int pendingCount = 0;
          int ongoingCount = 0;
          int completedCount = 0;

          if (snapshot.hasData && snapshot.data!.exists) {
            userData = snapshot.data!.data() as Map<String, dynamic>;

            name = userData['name'] ?? name;
            profession = userData['serviceType'] ?? profession;
            isOnline = userData['isOnline'] ?? isOnline;
            isAvailable = userData['isAvailable'] ?? isAvailable;
          }

          return StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection('requests')
                .where('workerPhone', isEqualTo: userPhone)
                .snapshots(),

            builder: (context, requestSnapshot) {
              pendingCount = 0;
              ongoingCount = 0;
              completedCount = 0;
              if (requestSnapshot.hasData) {
                for (var doc in requestSnapshot.data!.docs) {
                  final data = doc.data() as Map<String, dynamic>;

                  if (data['status'] == 'pending') {
                    pendingCount++;
                  }

                  if (data['status'] == 'ongoing') {
                    ongoingCount++;
                  }

                  if (data['status'] == 'completed') {
                    completedCount++;
                  }
                }
              }

              return Column(
                children: [
                  // Fixed Header
                  Container(
                    padding: const EdgeInsets.only(
                        top: 70, left: 24, right: 24, bottom: 40),
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          Color(0xFF1B263B),
                          Color(0xFF0D1B2A),
                        ],
                      ),
                      borderRadius: BorderRadius.only(
                        bottomLeft: Radius.circular(40),
                        bottomRight: Radius.circular(40),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black38,
                          blurRadius: 20,
                          offset: Offset(0, 10),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white.withOpacity(0.3), width: 3),
                          ),
                          child: CircleAvatar(
                            radius: 42,
                            backgroundColor: Colors.white.withOpacity(0.1),
                            child: const Icon(Icons.person, color: Colors.white, size: 45),
                          ),
                        ),
                        const SizedBox(width: 20),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "হ্যালো, $name",
                                style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 22,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 0.5),
                              ),
                              const SizedBox(height: 10),
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 10, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: Colors.white.withOpacity(0.15),
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: Row(
                                      children: [
                                        Icon(Icons.circle, color: isOnline
                                            ? Colors.green
                                            : Colors.grey, size: 10),
                                        const SizedBox(width: 6),
                                        Text(isOnline ? "Online" : "Offline",
                                            style: const TextStyle(
                                                color: Colors.white,
                                                fontSize: 12,
                                                fontWeight: FontWeight.w600)),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Text(
                                    profession, 
                                    style: TextStyle(
                                      color: Colors.white.withOpacity(0.7), 
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500
                                    )
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Scrollable Body
                  Expanded(
                    child: SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 30),

                          // Today's Summary
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text("সারসংক্ষেপ", style: TextStyle(
                                    fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF1B263B))),
                                const SizedBox(height: 15),
                                GridView.count(
                                  shrinkWrap: true,
                                  physics: const NeverScrollableScrollPhysics(),
                                  crossAxisCount: 2,
                                  crossAxisSpacing: 15,
                                  mainAxisSpacing: 15,
                                  childAspectRatio: 1.4,
                                  children: [
                                    _buildSummaryCard(
                                      "নতুন রিকোয়েস্ট",
                                      "$pendingCount",
                                      Icons.assignment_outlined,
                                      Colors.blue,
                                    ),
                                    _buildSummaryCard(
                                      "চলমান কাজ",
                                      "$ongoingCount",
                                      Icons.check_circle_outline,
                                      Colors.green,
                                    ),
                                    _buildSummaryCard(
                                      "সম্পন্ন কাজ",
                                      "$completedCount",
                                      Icons.calendar_today_outlined,
                                      Colors.blueAccent,
                                    ),
                                    StreamBuilder<QuerySnapshot>(
                                      stream: FirebaseFirestore.instance
                                          .collection('ratings')
                                          .where('workerPhone', isEqualTo: userPhone)
                                          .snapshots(),
                                      builder: (context, reviewSnapshot) {

                                        double avgRating = 0;
                                        int reviewCount = 0;

                                        if (reviewSnapshot.hasData &&
                                            reviewSnapshot.data!.docs.isNotEmpty) {

                                          reviewCount = reviewSnapshot.data!.docs.length;

                                          double total = 0;

                                          for (var doc in reviewSnapshot.data!.docs) {
                                            total +=
                                                (doc['rating'] as num).toDouble();
                                          }

                                          avgRating = total / reviewCount;
                                        }

                                        return _buildSummaryCard(
                                          "রেটিং",
                                          reviewCount == 0
                                              ? "0.0"
                                              : avgRating.toStringAsFixed(1),
                                          Icons.star,
                                          Colors.orange,
                                        );
                                      },
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 30),

                          // Quick Actions
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text("দ্রুত অ্যাকশন", style: TextStyle(
                                    fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF1B263B))),
                                const SizedBox(height: 15),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    _buildActionItem(
                                      "নতুন\nরিকোয়েস্ট",
                                      Icons.edit_note,
                                      Colors.blue,
                                      badge: pendingCount > 0
                                          ? pendingCount.toString()
                                          : null,
                                      onTap: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(builder: (
                                              _) => const WorkerRequestsScreen()),
                                        );
                                      },
                                    ),
                                    _buildActionItem(
                                      "আমার কাজ",
                                      Icons.calendar_month,
                                      Colors.indigo,
                                      onTap: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(builder: (
                                              _) => const WorkerMyJobsScreen()),
                                        );
                                      },
                                    ),
                                    _buildActionItem(
                                        "প্রোফাইল", Icons.person_outline, Colors.blue,
                                        onTap: () {
                                          Navigator.push(context, MaterialPageRoute(
                                              builder: (
                                                  _) => const WorkerProfileScreen()));
                                        }),
                                  ],
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 30),

                          // Interest Toggle
                          Container(
                            margin: const EdgeInsets.symmetric(horizontal: 20),
                            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(20),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.05),
                                  blurRadius: 15,
                                  offset: const Offset(0, 5),
                                )
                              ],
                              border: Border.all(color: Colors.grey.shade100),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text("আমি কাজ নিতে আগ্রহী", style: TextStyle(
                                    fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF1B263B))),
                                Switch(
                                  value: isAvailable,
                                  activeColor: Colors.blue,
                                  onChanged: (value) async {
                                    await FirebaseFirestore.instance
                                        .collection('workers')
                                        .doc(userPhone)
                                        .update({
                                      'isAvailable': value,
                                    });
                                  },
                                )
                              ],
                            ),
                          ),
                          const SizedBox(height: 40),
                        ],
                      ),
                    ),
                  ),
                ],
              );
            },
          );
        },
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) {

          if (index == _selectedIndex) return;

          if (index == 0) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (_) => const WorkerDashboard(),
              ),
            );
          }

          else if (index == 1) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (_) => const WorkerRequestsScreen(),
              ),
            );
          }

          else if (index == 2) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (_) => const WorkerMyJobsScreen(),
              ),
            );
          }

          else if (index == 3) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (_) => const WorkerProfileScreen(),
              ),
            );
          }
        },

        type: BottomNavigationBarType.fixed,
        selectedItemColor: Colors.blue,
        unselectedItemColor: Colors.grey,
        showUnselectedLabels: true,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'হোম'),
          BottomNavigationBarItem(icon: Icon(Icons.mail_outline), label: 'রিকোয়েস্ট'),
          BottomNavigationBarItem(icon: Icon(Icons.calendar_today), label: 'আমার কাজ'),
          BottomNavigationBarItem(icon: Icon(Icons.person_outline), label: 'প্রোফাইল'),
        ],
      ),
    );
  }

  Widget _buildSummaryCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 15, offset: const Offset(0, 8)),
        ],
        border: Border.all(color: Colors.grey.shade100),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: color, size: 22),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(title, style: TextStyle(fontSize: 12, color: Colors.grey.shade600, fontWeight: FontWeight.w600, overflow: TextOverflow.ellipsis)),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(value, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF1B263B))),
        ],
      ),
    );
  }

  Widget _buildActionItem(String label, IconData icon, Color color, {String? badge, VoidCallback? onTap}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Column(
        children: [
          Stack(
            children: [
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.08),
                  shape: BoxShape.circle,
                  border: Border.all(color: color.withOpacity(0.15), width: 1.5)
                ),
                child: Icon(icon, color: color, size: 30),
              ),
              if (badge != null)
                Positioned(
                  right: 0,
                  top: 0,
                  child: Container(
                    padding: const EdgeInsets.all(5),
                    decoration: const BoxDecoration(color: Colors.red, shape: BoxShape.circle),
                    child: Text(badge, style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 10),
          Text(label, textAlign: TextAlign.center, style: const TextStyle(fontSize: 13, color: Color(0xFF1B263B), fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}
