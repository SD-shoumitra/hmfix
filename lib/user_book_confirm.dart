import 'package:flutter/material.dart';
import 'user_order_tracking.dart';

class UserBookConfirm extends StatelessWidget {
  final Map<String, dynamic> worker;
  final String workType;
  final String details;
  final String address;
  final String date;
  final String time;
  const UserBookConfirm({
    super.key,
    required this.worker,
    required this.workType,
    required this.details,
    required this.address,
    required this.date,
    required this.time,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Column(
              children: [
                const SizedBox(height: 60),
                // Success Icon and Confetti (simulated with icons/widgets)
                Center(
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      Container(
                        width: 100,
                        height: 100,
                        decoration: const BoxDecoration(
                          color: Color(0xFF27AE60),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.check,
                          color: Colors.white,
                          size: 60,
                        ),
                      ),
                      // Simulated Confetti
                      ..._buildConfetti(),
                    ],
                  ),
                ),

                const SizedBox(height: 32),
                const Text(
                  "অনুরোধ সফল হয়েছে!",
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1B263B),
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  "আপনার অনুরোধ গ্রহণ করা হয়েছে",
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey,
                  ),
                ),
                const SizedBox(height: 40),
                // Worker Card
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.grey.shade200),
                  ),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 35,
                        backgroundColor: Colors.grey.shade100,
                        child: const Icon(Icons.person, size: 40, color: Colors.grey),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              worker['name'] ?? "",
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF1B263B),
                              ),
                            ),
                            Text(
                              worker['serviceType'] ?? "",
                              style: const TextStyle(
                                fontSize: 14,
                                color: Colors.grey,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: const Color(0xFFE8F5E9),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(Icons.star, color: Color(0xFF27AE60), size: 16),
                                  const SizedBox(width: 4),
                                  Text(
                                    "${worker['rating'] ?? 0}",
                                    style: const TextStyle(
                                      color: Color(0xFF27AE60),
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // Request Summary
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "অনুরোধের তথ্য",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text("কাজ: $workType"),
                      Text("তারিখ: $date"),
                      Text("সময়: $time"),
                      Text("ঠিকানা: $address"),
                      Text("বিস্তারিত: $details"),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // Info Box
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF0F6FF),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.description_outlined,
                          color: Color(0xFF0066FF),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          "${worker['name'] ?? ''} এর কাছে আপনার অনুরোধপাঠানো হয়েছে। তিনি শীঘ্রই আপনার সাথে যোগাযোগ করবেন।",
                          style: const TextStyle(
                            fontSize: 14,
                            color: Color(0xFF1B263B),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 30),
                // Buttons
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => UserOrderTracking(worker: worker),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF0066FF),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 0,
                    ),
                    child: const Text(
                      "অর্ডার ট্র্যাক করুন",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                TextButton(
                  onPressed: () {
                    Navigator.of(context).popUntil((route) => route.isFirst);
                  },
                  child: const Text(
                    "হোমে ফিরে যান",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF0066FF),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }

  List<Widget> _buildConfetti() {
    return [
      Positioned(top: 0, left: -20, child: _confettiPiece(Colors.red, 10, 4)),
      Positioned(top: 20, right: -30, child: _confettiPiece(Colors.blue, 8, 8)),
      Positioned(bottom: 10, left: -40, child: _confettiPiece(Colors.orange, 12, 4)),
      Positioned(bottom: 30, right: -20, child: _confettiPiece(Colors.green, 6, 12)),
      Positioned(top: -20, right: 10, child: _confettiPiece(Colors.blue, 10, 4)),
      Positioned(bottom: -10, left: 10, child: _confettiPiece(Colors.orange, 8, 8)),
    ];
  }

  Widget _confettiPiece(Color color, double width, double height) {
    return Transform.rotate(
      angle: 0.5,
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(2),
        ),
      ),
    );
  }
}
