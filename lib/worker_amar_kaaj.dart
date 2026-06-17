import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class WorkerMyJobsScreen extends StatefulWidget {
  const WorkerMyJobsScreen({super.key});

  @override
  State<WorkerMyJobsScreen> createState() => _WorkerMyJobsScreenState();
}

class _WorkerMyJobsScreenState extends State<WorkerMyJobsScreen> {
  int _selectedFilterIndex = 0;
  final List<String> _filters = ["সব", "চলমান", "সম্পন্ন", "ক্যানসেল"];
  
  String? _getWorkerPhone() {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      if (user.email != null && user.email!.contains('@hmfix.com')) {
        return user.email!.split('@')[0];
      } else if (user.phoneNumber != null) {
        return user.phoneNumber!.replaceAll('+88', '');
      }
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final workerPhone = _getWorkerPhone();

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFF),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF1B263B)),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "আমার কাজ",
          style: TextStyle(
            color: Color(0xFF1B263B),
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        centerTitle: false,
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
          
          // Jobs List
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: _getJobsStream(workerPhone),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Center(child: Text("কোনো কাজ পাওয়া যায়নি"));
                }

                final jobs = snapshot.data!.docs;

                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: jobs.length,
                  itemBuilder: (context, index) {
                    final jobData = jobs[index].data() as Map<String, dynamic>;
                    final jobId = jobs[index].id;
                    return _buildJobCard(jobId, jobData);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Stream<QuerySnapshot> _getJobsStream(String? workerPhone) {

    var query = FirebaseFirestore.instance
        .collection('requests')
        .where(
      'assignedWorker',
      isEqualTo: workerPhone,
    );

    if (_selectedFilterIndex == 1) {
      query = query.where(
        'status',
        isEqualTo: 'ongoing',
      );
    }

    else if (_selectedFilterIndex == 2) {
      query = query.where(
        'status',
        isEqualTo: 'completed',
      );
    }

    else if (_selectedFilterIndex == 3) {
      query = query.where(
        'status',
        isEqualTo: 'rejected',
      );
    }

    return query.snapshots();
  }

  Widget _buildJobCard(String jobId, Map<String, dynamic> job) {
    String status = job['status'] ?? 'ongoing';
    String statusBangla = "";
    Color statusColor = Colors.grey;
    Color statusBgColor = Colors.grey.shade100;

    if (status == 'ongoing') {
      statusBangla = "চলমান";
      statusColor = const Color(0xFF27AE60);
      statusBgColor = const Color(0xFFE8F5E9);
    } else if (status == 'completed') {
      statusBangla = "সম্পন্ন";
      statusColor = const Color(0xFF0066FF);
      statusBgColor = const Color(0xFFE3F2FD);
    } else if (status == 'cancelled') {
      statusBangla = "ক্যানসেল";
      statusColor = Colors.red;
      statusBgColor = Colors.red.shade50;
    }

    return Container(
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
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      job['customerName'] ?? "ইউজার নাম",
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1B263B),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      job['serviceType'] ?? "সার্ভিস টাইপ",
                      style: const TextStyle(color: Colors.grey, fontSize: 13),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      job['date'] ?? "আজ, 3:00 PM",
                      style: const TextStyle(color: Colors.grey, fontSize: 12),
                    ),

                    const SizedBox(height: 8),

                    Text(
                      job['customerPhone'] ?? "",
                      style: const TextStyle(
                        color: Colors.grey,
                        fontSize: 13,
                      ),
                    ),

                    const SizedBox(height: 4),

                    Text(
                      job['address'] ?? "",
                      style: const TextStyle(
                        color: Colors.grey,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                "৳ ${job['serviceCharge'] ?? job['price'] ?? 0}",
                style: const TextStyle(
                  color: Color(0xFF27AE60),
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ],
          ),
          
          if (status == 'completed' && job['rating'] != null) ...[
            const SizedBox(height: 12),
            const Divider(),
            Row(
              children: [
                const Text("রেটিং দিয়েছেন", style: TextStyle(color: Colors.grey, fontSize: 12)),
                const Spacer(),
                Row(
                  children: List.generate(5, (index) {
                    return Icon(
                      Icons.star,
                      size: 16,
                      color: index < (job['rating'] ?? 0) ? Colors.orange : Colors.grey.shade300,
                    );
                  }),
                ),
                const SizedBox(width: 8),
                Text(
                  "${job['rating']}",
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                ),
              ],
            ),
          ],
          const SizedBox(height: 12),

          SizedBox(
            width: double.infinity,
            height: 40,
            child: OutlinedButton.icon(
              onPressed: () {

              },
              icon: const Icon(Icons.call),
              label: Text(
                job['customerPhone'] ?? "",
              ),
            ),
          ),

          if (status == 'ongoing') ...[
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              height: 40,
              child: ElevatedButton(
                onPressed: () async {
                  await FirebaseFirestore.instance
                      .collection('requests')
                      .doc(jobId)
                      .update({
                    'status': 'completed',
                  });
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF0066FF),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  elevation: 0,
                ),
                child: const Text(
                  "কাজটি সম্পন্ন করুন",
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
