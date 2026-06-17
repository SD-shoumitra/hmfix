import 'package:flutter/material.dart';

class UserOrderTracking extends StatelessWidget {
  final Map<String, dynamic> worker;
  const UserOrderTracking({super.key, required this.worker});

  @override
  Widget build(BuildContext context) {
    final status = worker['status'] ?? 'pending';
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
          "অর্ডার ট্র্যাক করুন",
          style: TextStyle(
            color: Color(0xFF1B263B),
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        centerTitle: false,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Service Card
            _buildCard(
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF0F6FF),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(Icons.bolt, color: Color(0xFF0066FF)),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    "সার্ভিস: ${worker['workType'] ?? ''}",
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF1B263B),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Worker Card
            const Text(
              "কর্মী:",
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1B263B),
              ),
            ),
            const SizedBox(height: 8),
            _buildCard(
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 35,
                    backgroundColor: Colors.grey.shade100,
                    child: const Icon(Icons.person, size: 45, color: Colors.grey),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          worker['workerName'] ?? "কর্মী",
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF1B263B),
                          ),
                        ),
                        Text(
                          worker['serviceType'] ?? "ইলেকট্রিশিয়ান",
                          style: const TextStyle(
                            fontSize: 14,
                            color: Colors.grey,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            const Icon(Icons.star, color: Color(0xFF0066FF), size: 16),
                            const SizedBox(width: 4),
                            Text(
                              "${worker['rating'] ?? 4.8}",
                              style: const TextStyle(
                                color: Color(0xFF0066FF),
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(width: 4),
                            const Text(
                              "(120+)",
                              style: TextStyle(color: Colors.grey, fontSize: 12),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Status Timeline Card
            const Text(
              "অবস্থা:",
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1B263B),
              ),
            ),
            const SizedBox(height: 8),

            _buildCard(
              child: Column(
                children: [
                  _buildTimelineItem(
                    "অনুরোধ পাঠানো হয়েছে",
                    true,
                    true,
                  ),

                  _buildTimelineItem(
                    "কর্মী অনুরোধ গ্রহণ করেছেন",
                    status == 'accepted' ||
                        status == 'ongoing' ||
                        status == 'completed',
                    true,
                  ),

                  _buildTimelineItem(
                    "কাজ শুরু হয়েছে",
                    status == 'ongoing' ||
                        status == 'completed',
                    true,
                    isCurrent: status == 'ongoing',
                  ),

                  _buildTimelineItem(
                    "কাজ সম্পন্ন হয়েছে",
                    status == 'completed',
                    status == 'completed',
                    isLast: true,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Date & Time Card
            _buildCard(
              child: Column(
                children: [
                  Row(
                    children: [
                      _buildIconBox(Icons.calendar_month_outlined),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "তারিখ:",
                            style: TextStyle(
                              color: Colors.grey,
                              fontSize: 12,
                            ),
                          ),
                          Text(
                            worker['date'] ?? '',
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF1B263B),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 12),
                    child: Divider(height: 1),
                  ),
                  Row(
                    children: [
                      _buildIconBox(Icons.access_time),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "সময়:",
                            style: TextStyle(color: Colors.grey, fontSize: 12),
                          ),
                          Text(
                            worker['time'] ?? '',
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF1B263B),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),

            // Home Button
            SizedBox(
              width: double.infinity,
              height: 54,
              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.of(context).popUntil((route) => route.isFirst);
                },
                icon: const Icon(Icons.home, color: Colors.white),
                label: const Text(
                  "হোমে ফিরুন",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF0066FF),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 0,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCard({required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade100),
      ),
      child: child,
    );
  }

  Widget _buildIconBox(IconData icon) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: const Color(0xFFF0F6FF),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Icon(icon, color: const Color(0xFF0066FF), size: 20),
    );
  }

  Widget _buildTimelineItem(String title, bool isCompleted, bool isPast, {bool isCurrent = false, bool isLast = false}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          children: [
            Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isCompleted ? const Color(0xFF27AE60) : Colors.white,
                border: Border.all(
                  color: isCompleted
                      ? const Color(0xFF27AE60)
                      : isCurrent
                          ? const Color(0xFF0066FF)
                          : Colors.grey.shade300,
                  width: isCurrent ? 6 : 1.5,
                ),
              ),
              child: isCompleted
                  ? const Icon(Icons.check, color: Colors.white, size: 16)
                  : null,
            ),
            if (!isLast)
              Container(
                width: 1.5,
                height: 40,
                color: isPast ? (isCompleted ? const Color(0xFF27AE60) : const Color(0xFF0066FF)) : Colors.grey.shade200,
              ),
          ],
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(top: 2),
            child: Text(
              title,
              style: TextStyle(
                fontSize: 14,
                fontWeight: isCurrent ? FontWeight.bold : FontWeight.w500,
                color: isCurrent || isCompleted ? const Color(0xFF1B263B) : Colors.grey,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
