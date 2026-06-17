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
      drawer: const Drawer(),
      body: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance
            .collection('workers')
            .doc(userPhone)
            .snapshots(),
        builder: (context, snapshot) {
          String name = "রাকিব হাসান";
          String profession = "ইলেকট্রিশিয়ান";
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

              }
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


              return SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header
                    Container(
                      padding: const EdgeInsets.only(
                          top: 50, left: 20, right: 20, bottom: 30),
                      decoration: const BoxDecoration(
                        color: Color(0xFF1B263B), // Dark blue background
                        borderRadius: BorderRadius.only(
                          bottomLeft: Radius.circular(30),
                          bottomRight: Radius.circular(30),
                        ),
                      ),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Builder(builder: (context) {
                                return IconButton(
                                  icon: const Icon(
                                      Icons.menu, color: Colors.white),
                                  onPressed: () =>
                                      Scaffold.of(context).openDrawer(),
                                );
                              }),
                              Stack(
                                children: [
                                  const Icon(Icons.notifications_none,
                                      color: Colors.white, size: 28),
                                  Positioned(
                                    right: 0,
                                    top: 0,
                                    child: Container(
                                      padding: const EdgeInsets.all(2),
                                      decoration: BoxDecoration(
                                        color: Colors.red,
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      constraints: const BoxConstraints(
                                          minWidth: 16, minHeight: 16),
                                      // notification count
                                      child: Text(
                                        '$pendingCount',
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 10,
                                        ),
                                        textAlign: TextAlign.center,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          Row(
                            children: [
                              const CircleAvatar(
                                radius: 40,
                                backgroundColor: Colors.white,
                                child: CircleAvatar(
                                  radius: 38,
                                  backgroundImage: NetworkImage(
                                      'https://via.placeholder.com/150'), // worker banner
                                ),
                              ),
                              const SizedBox(width: 15),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "হ্যালো, $name",
                                    style: const TextStyle(color: Colors.white,
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold),
                                  ),
                                  const SizedBox(height: 5),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 10, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: Colors.white.withOpacity(0.2),
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: Row(
                                      children: [
                                        Icon(Icons.circle, color: isOnline
                                            ? Colors.green
                                            : Colors.grey, size: 10),
                                        const SizedBox(width: 5),
                                        Text(isOnline ? "Online" : "Offline",
                                            style: const TextStyle(
                                                color: Colors.white,
                                                fontSize: 12)),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(height: 5),
                                  Text(profession, style: const TextStyle(
                                      color: Colors.white70, fontSize: 14)),
                                ],
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 20),

                    // Today's Summary
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text("সারসংক্ষেপ", style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold)),
                          const SizedBox(height: 15),
                          GridView.count(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            crossAxisCount: 2,
                            crossAxisSpacing: 15,
                            mainAxisSpacing: 15,
                            childAspectRatio: 1.5,
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
                              _buildSummaryCard(
                                "আজকের আয়",
                                "৳ ${userData['totalEarnings'] ?? 0}",
                                Icons.account_balance_wallet_outlined,
                                Colors.teal,
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
                              fontSize: 18, fontWeight: FontWeight.bold)),
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
                                  "আয়", Icons.payments_outlined, Colors.blue),
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
                      padding: const EdgeInsets.all(15),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(15),
                        border: Border.all(color: Colors.grey.shade200),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text("আমি কাজ নিতে আগ্রহী", style: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.w500)),
                          Switch(
                            value: isAvailable,
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
                    const SizedBox(height: 100),
                    // Bottom padding for FAB/NavBar
                  ],
                ),
              );
            },
          );
        },
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) {
          setState(() => _selectedIndex = index);
          if (index == 1) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const WorkerRequestsScreen()),
            );
          } else if (index == 2) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const WorkerMyJobsScreen()),
            );
          } else if (index == 4) {
             Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const WorkerProfileScreen()),
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
          BottomNavigationBarItem(icon: Icon(Icons.payments_outlined), label: 'আয়'),
          BottomNavigationBarItem(icon: Icon(Icons.person_outline), label: 'প্রোফাইল'),
        ],
      ),
    );
  }

  Widget _buildSummaryCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.grey.shade100),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10, offset: const Offset(0, 5)),
        ],
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
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: color, size: 20),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(title, style: const TextStyle(fontSize: 12, color: Colors.grey, overflow: TextOverflow.ellipsis)),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(value, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildActionItem(String label, IconData icon, Color color, {String? badge, VoidCallback? onTap}) {
    return InkWell(
      onTap: onTap,
      child: Column(
        children: [
          Stack(
            children: [
              Container(
                padding: const EdgeInsets.all(15),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: color, size: 28),
              ),
              if (badge != null)
                Positioned(
                  right: 0,
                  top: 0,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(color: Colors.red, shape: BoxShape.circle),
                    child: Text(badge, style: const TextStyle(color: Colors.white, fontSize: 10)),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 8),
          Text(label, textAlign: TextAlign.center, style: const TextStyle(fontSize: 12, color: Color(0xFF1B263B), fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }
}
