import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'worker_amar_kaaj.dart';
import 'package:flutter/services.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'worker_dashboard.dart';

class WorkerRequestsScreen extends StatefulWidget {
  const WorkerRequestsScreen({super.key});

  @override
  State<WorkerRequestsScreen> createState() => _WorkerRequestsScreenState();
}

class _WorkerRequestsScreenState extends State<WorkerRequestsScreen> {
  @override
  Widget build(BuildContext context) {

    final user = FirebaseAuth.instance.currentUser;

    String workerPhone = "";

    if (user != null) {
      if (user.email != null &&
          user.email!.contains('@hmfix.com')) {

        workerPhone =
        user.email!.split('@')[0];

      } else {

        workerPhone =
            user.phoneNumber
                ?.replaceAll('+88', '') ?? "";
      }
    }
    print("Worker Phone: $workerPhone");
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFF),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF1B263B)),
          onPressed: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (_) => const WorkerDashboard(),
              ),
            );
          },
        ),
        title: const Text(
          "নতুন রিকোয়েস্ট",
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
          // Request List time anujai filtaring kora
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('requests')
                  .where(
                'workerPhone',
                isEqualTo: workerPhone,
              )
                  .where(
                'status',
                whereIn: ['pending', 'accepted'],
              )

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
                  return const Center(
                    child: Text(
                      "কোনো নতুন রিকোয়েস্ট নেই",
                    ),
                  );
                }

                final requests = snapshot.data!.docs;
                // time anuji sort kora request
                requests.sort((a, b) {
                  Timestamp ta = a['createdAt'] ?? Timestamp.now();
                  Timestamp tb = b['createdAt'] ?? Timestamp.now();
                  return tb.compareTo(ta);
                });

                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: requests.length,
                  itemBuilder: (context, index) {

                    final request =
                    requests[index].data()
                    as Map<String, dynamic>;

                    return _buildRequestCard(
                      request,
                      requests[index].id,
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

  //request card

  Widget _buildRequestCard(
      Map<String, dynamic> request,
      String requestId,
      ){

    final status = request['status'] ?? 'pending';
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const CircleAvatar(
                radius: 20,
                backgroundColor: Color(0xFFE8F0FE),
                child: Icon(Icons.person, color: Color(0xFF0066FF), size: 24),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  request['customerName'] ?? "",
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1B263B),
                  ),
                ),
              ),

            ],
          ),
          const SizedBox(height: 16),
          Text(
            request['serviceType'] ?? "",
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                request['address'] ?? "",
                style: const TextStyle(color: Colors.grey, fontSize: 13),
              ),
              Text(
                "৳ ${request['serviceCharge'] ?? 0}",
                style: const TextStyle(
                  color: Colors.green,
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                request['createdAt'] != null
                    ? (request['createdAt'] as Timestamp)
                    .toDate()
                    .toString()
                    .substring(0,16)
                    : "",
                style: const TextStyle(color: Colors.grey, fontSize: 13),
              ),
            ],
          ),
          const SizedBox(height: 20),
          if (status == 'pending')
          Row(
            children: [

              // Details
              Expanded(
                child: OutlinedButton(
                  onPressed: () {

                    showDialog(
                      context: context,
                      builder: (_) => AlertDialog(
                        title: Text(
                          request['customerName'] ?? "",
                        ),
                        content: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment:
                          CrossAxisAlignment.start,
                          children: [

                            Text(
                              "ফোন: ${request['customerPhone'] ?? ""}",
                            ),

                            Text(
                              "ঠিকানা: ${request['address'] ?? ""}",
                            ),

                            Text(
                              "কাজ: ${request['workType'] ?? ""}",
                            ),

                            Text(
                              "তারিখ: ${request['date'] ?? ""}",
                            ),

                            Text(
                              "সময়: ${request['time'] ?? ""}",
                            ),

                            Text(
                              "বিস্তারিত: ${request['details'] ?? ""}",
                            ),
                          ],
                        ),


                      ),
                    );

                  },
                  child: const Text("বিস্তারিত"),
                ),
              ),

              const SizedBox(width: 8),

              // Reject
              Expanded(
                child: ElevatedButton(
                  onPressed: () async {

                    await FirebaseFirestore.instance
                        .collection('requests')
                        .doc(requestId)
                        .update({

                      "status": "rejected",

                    });

                    ScaffoldMessenger.of(context)
                        .showSnackBar(
                      const SnackBar(
                        content: Text("রিকোয়েস্ট বাতিল করা হয়েছে"),
                      ),
                    );
                  },

                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                  ),

                  child: const Text(
                    "রিজেক্ট",
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ),

              const SizedBox(width: 8),

              // Accept
              Expanded(
                child: ElevatedButton(
                  onPressed: () async {

                    final user =
                        FirebaseAuth.instance.currentUser;

                    String workerPhone = "";

                    if (user?.email != null &&
                        user!.email!.contains('@hmfix.com')) {

                      workerPhone =
                      user.email!.split('@')[0];

                    } else {

                      workerPhone =
                          user?.phoneNumber
                              ?.replaceAll('+88', '') ?? "";
                    }

                    await FirebaseFirestore.instance
                        .collection('requests')
                        .doc(requestId)
                        .update({

                      "status": "accepted",
                      "assignedWorker": workerPhone,

                    });



                    ScaffoldMessenger.of(context)
                        .showSnackBar(
                      const SnackBar(
                        content: Text("রিকোয়েস্ট গ্রহণ করা হয়েছে"),
                      ),
                    );
                  },

                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0066FF),
                  ),

                  child: const Text(
                    "একসেপ্ট",
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
          if (status == 'accepted') ...[
            const SizedBox(height: 16),

            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.green.shade50,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Row(
                children: [
                  Icon(Icons.check_circle, color: Colors.green),
                  SizedBox(width: 8),
                  Text(
                    "আপনি এই রিকোয়েস্ট একসেপ্ট করেছেন",
                    style: TextStyle(
                      color: Colors.green,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 12),

            Text(
              "নাম: ${request['customerName'] ?? ''}",
              style: const TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 6),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    "মোবাইল: ${request['customerPhone'] ?? ''}",
                  ),
                ),

                GestureDetector(
                  onTap: () {
                    Clipboard.setData(
                      ClipboardData(
                        text: request['customerPhone'] ?? '',
                      ),
                    );

                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text("নাম্বার কপি হয়েছে"),
                      ),
                    );
                  },
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.copy,
                        size: 16,
                        color: Colors.blue,
                      ),
                      SizedBox(width: 4),
                      Text(
                        "কপি করে কল করুন",
                        style: TextStyle(
                          color: Colors.blue,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),


            const SizedBox(height: 6),

            Text(
              "ঠিকানা: ${request['address'] ?? ''}",
            ),

            const SizedBox(height: 16),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () async {

                  await FirebaseFirestore.instance
                      .collection('requests')
                      .doc(requestId)
                      .update({
                    'status': 'ongoing',
                  });

                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const WorkerMyJobsScreen(),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                ),
                child: const Text(
                  "সার্ভিস শুরু করুন",
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ),
          ],

        ],
      ),
    );
  }
}
