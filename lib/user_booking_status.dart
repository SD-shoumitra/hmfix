import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'user_order_tracking.dart';

class UserBookingStatusScreen extends StatefulWidget {
  const UserBookingStatusScreen({super.key});

  @override
  State<UserBookingStatusScreen> createState() => _UserBookingStatusScreenState();
}

class _UserBookingStatusScreenState extends State<UserBookingStatusScreen> {
  int _selectedFilterIndex = 0;
  final List<String> _filters = ["সব", "চলমান", "সম্পন্ন", "ক্যানসেল"];

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFF),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          "বুকিং লিস্ট",
          style: TextStyle(
            color: Color(0xFF1B263B),
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          // Filter Bar
          Container(
            height: 60,
            color: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 10),
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: _filters.length,
              itemBuilder: (context, index) {
                bool isSelected = _selectedFilterIndex == index;
                return Padding(
                  padding: const EdgeInsets.only(right: 10),
                  child: InkWell(
                    onTap: () => setState(() => _selectedFilterIndex = index),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: isSelected ? const Color(0xFF0066FF) : Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(25),
                      ),
                      child: Text(
                        _filters[index],
                        style: TextStyle(
                          color: isSelected ? Colors.white : Colors.grey.shade600,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),

          // Bookings List
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: _getBookingsStream(user?.uid),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Center(child: Text("আপনার কোনো বুকিং নেই"));
                }

                final bookings = snapshot.data!.docs;

                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: bookings.length,
                  itemBuilder: (context, index) {
                    final bookingData = bookings[index].data() as Map<String, dynamic>;
                    return _buildBookingCard(
                      bookingData,
                      bookings[index].id,
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

  Stream<QuerySnapshot> _getBookingsStream(String? userId) {
    var query = FirebaseFirestore.instance
        .collection('requests')
        .where('customerUid', isEqualTo: userId);

    if (_selectedFilterIndex == 1) {
      query = query.where('status', isEqualTo: 'ongoing');
    } else if (_selectedFilterIndex == 2) {
      query = query.where('status', isEqualTo: 'completed');
    } else if (_selectedFilterIndex == 3) {
      query = query.where('status', isEqualTo: 'rejected');
    }

    return query.snapshots();
  }

  Widget _buildBookingCard(
      Map<String, dynamic> booking,
      String bookingId,
      ){
    String status = booking['status'] ?? 'ongoing';
    String statusBangla = "";
    Color statusColor = Colors.grey;
    Color statusBgColor = Colors.grey.shade100;

    if (status == 'pending') {
      statusBangla = "অপেক্ষমাণ";
      statusColor = Colors.orange;
      statusBgColor = Colors.orange.shade50;
    }
    else if (status == 'accepted') {
      statusBangla = "গৃহীত";
      statusColor = Colors.blue;
      statusBgColor = Colors.blue.shade50;
    }
    else if (status == 'ongoing') {
      statusBangla = "চলমান";
      statusColor = const Color(0xFF27AE60);
      statusBgColor = const Color(0xFFE8F5E9);
    }
    else if (status == 'completed') {
      statusBangla = "সম্পন্ন";
      statusColor = const Color(0xFF0066FF);
      statusBgColor = const Color(0xFFE3F2FD);
    }
    else if (status == 'rejected') {
      statusBangla = "বাতিল";
      statusColor = Colors.red;
      statusBgColor = Colors.red.shade50;
    }

    return GestureDetector(
      onTap: () {
        // Mocking worker data for tracking screen as it expects it
        final workerData = {
          'name': booking['workerName'] ?? 'কর্মী',
          'serviceType': booking['serviceType'] ?? '',
          'rating': 4.8,
        };
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => UserOrderTracking(worker: workerData),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.02),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: statusBgColor,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    statusBangla,
                    style: TextStyle(
                      color: statusColor,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const Icon(Icons.chevron_right, color: Colors.grey),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                CircleAvatar(
                  radius: 25,
                  backgroundColor: Colors.grey.shade100,
                  child: const Icon(Icons.person, color: Colors.grey),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        booking['workerName'] ?? "কর্মীর নাম",
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1B263B),
                        ),
                      ),
                      Text(
                        booking['serviceType'] ?? "সার্ভিস টাইপ",
                        style: const TextStyle(color: Colors.grey, fontSize: 13),
                      ),
                    ],
                  ),
                ),
                Text(
                  "৳ ${booking['serviceCharge'] ?? 0}",
                  style: const TextStyle(
                    color: Color(0xFF27AE60),
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            const Divider(),
            const SizedBox(height: 4),
            Row(
              children: [
                const Icon(Icons.calendar_today, size: 14, color: Colors.grey),
                const SizedBox(width: 6),
                Text(
                  booking['date'] ?? "তারিখ",
                  style: const TextStyle(color: Colors.grey, fontSize: 12),
                ),
                const SizedBox(width: 16),
                const Icon(Icons.access_time, size: 14, color: Colors.grey),
                const SizedBox(width: 6),
                Text(
                  booking['time'] ?? "সময়",
                  style: const TextStyle(color: Colors.grey, fontSize: 12),
                ),
              ],
            ),
            const SizedBox(height: 12),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => UserOrderTracking(
                        worker: booking,
                      ),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF0066FF),
                ),
                child: const Text(
                  "অর্ডার ট্র্যাক করুন",
                  style: TextStyle(
                    color: Colors.white,
                  ),
                ),
              ),
            ),

          ],
        ),
      ),
    );
  }
}
