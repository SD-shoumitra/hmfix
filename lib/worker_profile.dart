import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'login.dart';
import 'worker_edit_profile.dart';
import 'worker_dashboard.dart';

class WorkerProfileScreen extends StatelessWidget {
  const WorkerProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    // ইউজার থেকে ফোন নাম্বার বের করার লজিক
    String? userPhone;
    if (user != null) {
      if (user.email != null && user.email!.contains('@hmfix.com')) {
        userPhone = user.email!.split('@')[0];
      } else if (user.phoneNumber != null) {
        userPhone = user.phoneNumber!.replaceAll('+88', '');
      }
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFF),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          'প্রোফাইল',
          style: TextStyle(
            color: Color(0xFF1E232C),
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back,
            color: Color(0xFF1E232C),
          ),
          onPressed: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (_) => const WorkerDashboard(),
              ),
            );
          },
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_outlined, color: Color(0xFF1E232C)),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const WorkerEditProfileScreen(),
                  ),
                );
              },
          ),
        ],
      ),
      body: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance
            .collection('workers')
            .doc(userPhone)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || !snapshot.data!.exists) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.person_off_outlined, size: 80, color: Colors.grey),
                  const SizedBox(height: 16),
                  const Text('তথ্য পাওয়া যায়নি', style: TextStyle(fontSize: 18, color: Colors.grey)),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('ফিরে যান'),
                  ),
                ],
              ),
            );
          }

          var userData = snapshot.data!.data() as Map<String, dynamic>;

          return SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              children: [
                const SizedBox(height: 10),
                // Profile Header
                Center(
                  child: Column(
                    children: [
                      Stack(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.grey.shade200, width: 1),
                            ),
                            child: const CircleAvatar(
                              radius: 55,
                              backgroundColor: Color(0xFFE8F0FE),
                              child: Icon(Icons.person, size: 65, color: Color(0xFF0066FF)),
                            ),
                          ),
                          Positioned(
                            bottom: 5,
                            right: 5,
                            child: Container(
                              padding: const EdgeInsets.all(4),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                shape: BoxShape.circle,
                                border: Border.all(color: Colors.grey.shade300),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.1),
                                    blurRadius: 4,
                                  ),
                                ],
                              ),
                              child: const Icon(Icons.camera_alt_outlined, size: 20, color: Colors.grey),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        userData['name'] ?? 'রাকিব হাসান',
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1E232C),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        userData['phone'] ?? '01712-345678',
                        style: const TextStyle(fontSize: 15, color: Colors.grey),
                      ),
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                        decoration: BoxDecoration(
                          color: userData['isOnline'] == true
                              ? const Color(0xFFE8F5E9)
                              : const Color(0xFFFFEBEE),
                          borderRadius: BorderRadius.circular(25),
                          border: Border.all(
                            color: userData['isOnline'] == true
                                ? const Color(0xFFC8E6C9)
                                : const Color(0xFFFFCDD2),
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                          Container(
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: userData['isOnline'] == true
                                ? const Color(0xFF4CAF50)
                                : Colors.red,
                            shape: BoxShape.circle,
                          ),
                        ),
                            const SizedBox(width: 8),
                            Text(
                              userData['isOnline'] == true ? 'Online' : 'Offline',
                              style: TextStyle(
                                color: userData['isOnline'] == true
                                    ? const Color(0xFF2E7D32)
                                    : Colors.red,
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                              ),
                            )
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 30),

                // Info Card
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.04),
                        blurRadius: 20,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      _buildInfoRow(
                        icon: Icons.handyman_outlined,
                        label: 'পেশা',
                        value: userData['serviceType'] ?? 'ইলেকট্রিশিয়ান',
                      ),
                      _buildDivider(),
                      _buildInfoRow(
                        icon: Icons.calendar_today_outlined,
                        label: 'অভিজ্ঞতা',
                        value: userData['experience'] ?? '৫ বছর',
                      ),
                      _buildDivider(),
                      _buildInfoRow(
                        icon: Icons.location_on_outlined,
                        label: 'সার্ভিস এরিয়া',
                        value: userData['serviceArea'] ?? 'ধানমন্ডি, মিরপুর, উত্তরা',
                      ),
                      _buildDivider(),
                      _buildInfoRow(
                        icon: Icons.star_outline,
                        label: 'গড় রেটিং',
                        value: "${userData['rating'] ?? 0.0}",
                        isRating: true,
                      ),
                      _buildDivider(),
                      _buildInfoRow(
                        icon: Icons.assignment_turned_in_outlined,
                        label: 'মোট কাজ',
                        value: "${userData['totalJobs'] ?? 0} টি",
                      ),
                      _buildDivider(),
                      _buildInfoRow(
                        icon: Icons.calendar_month_outlined,
                        label: 'যোগদানের তারিখ',
                        value: userData['createdAt'] != null
                            ? (userData['createdAt'] as Timestamp)
                            .toDate()
                            .toString()
                            .split(' ')[0]
                            : "N/A",
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 35),

                // toggle logic

                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 15,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.04),
                        blurRadius: 20,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.power_settings_new,
                        color: Color(0xFF0066FF),
                      ),

                      const SizedBox(width: 12),

                      const Text(
                        "Online Status",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      const Spacer(),

                      Switch(
                        value: userData['isOnline'] ?? false,
                        onChanged: (value) async {
                          await FirebaseFirestore.instance
                              .collection('workers')
                              .doc(userPhone)
                              .update({
                            'isOnline': value,
                          });
                        },
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                // Logout Button
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: OutlinedButton(
                    onPressed: () async {
                      await FirebaseAuth.instance.signOut();
                      if (context.mounted) {
                        Navigator.pushAndRemoveUntil(
                          context,
                          MaterialPageRoute(builder: (_) => const LoginScreen()),
                          (route) => false,
                        );
                      }
                    },
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Color(0xFFFFEBEE)),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      backgroundColor: Colors.transparent,
                    ),




                    child: const Text(

                      'লগ আউট',
                      style: TextStyle(
                        color: Colors.redAccent,
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 40),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildInfoRow({
    required IconData icon,
    required String label,
    required String value,
    bool isRating = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Row(
        children: [
          Icon(icon, color: Colors.grey.shade500, size: 24),
          const SizedBox(width: 16),
          Text(
            label,
            style: const TextStyle(
              fontSize: 16,
              color: Colors.black87,
              fontWeight: FontWeight.w500,
            ),
          ),
          const Spacer(),
          if (isRating)
            const Icon(Icons.star, color: Colors.amber, size: 20),
          if (isRating) const SizedBox(width: 6),
          Text(
            value,
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: isRating ? Colors.black87 : Colors.grey.shade700,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDivider() {
    return Divider(
      height: 1,
      thickness: 1,
      indent: 20,
      endIndent: 20,
      color: Colors.grey.shade100,
    );
  }
}
