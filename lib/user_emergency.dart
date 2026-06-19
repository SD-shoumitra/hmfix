import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class UserEmergencyScreen extends StatelessWidget {
  const UserEmergencyScreen({super.key});

  void _copyNumber(BuildContext context, String number) {
    Clipboard.setData(ClipboardData(text: number));

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("$number কপি হয়েছে, কল করুন"),
        backgroundColor: Colors.green,
      ),
    );
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
        title: const Text(
          "জরুরি সেবা",
          style: TextStyle(
            color: Color(0xFF1B263B),
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [

            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFFFEBEE),
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Row(
                children: [
                  Icon(
                    Icons.warning_amber_rounded,
                    color: Colors.red,
                    size: 40,
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      "জরুরি প্রয়োজনে নিচের নম্বরগুলো ব্যবহার করুন",
                      style: TextStyle(
                        color: Colors.red,
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            _emergencyCard(
              context,
              title: "পুলিশ",
              subtitle: "আপনার নিরাপত্তার জন্য",
              number: "999",
              icon: Icons.local_police,
              color: Colors.blue,
            ),

            const SizedBox(height: 16),

            _emergencyCard(
              context,
              title: "অ্যাম্বুলেন্স",
              subtitle: "জরুরি চিকিৎসা সেবার জন্য",
              number: "999",
              icon: Icons.medical_services,
              color: Colors.red,
            ),

            const SizedBox(height: 16),

            _emergencyCard(
              context,
              title: "ফায়ার সার্ভিস",
              subtitle: "অগ্নিকাণ্ডের জন্য",
              number: "999",
              icon: Icons.local_fire_department,
              color: Colors.orange,
            ),

            const SizedBox(height: 24),

            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFEAF2FF),
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.info, color: Colors.blue),
                  SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      "শুধুমাত্র জরুরি প্রয়োজনে এই নম্বরগুলো ব্যবহার করুন।",
                      style: TextStyle(
                        fontSize: 13,
                        color: Color(0xFF1B263B),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _emergencyCard(
      BuildContext context, {
        required String title,
        required String subtitle,
        required String number,
        required IconData icon,
        required Color color,
      }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [

          CircleAvatar(
            radius: 28,
            backgroundColor: color.withOpacity(0.1),
            child: Icon(
              icon,
              color: color,
              size: 30,
            ),
          ),

          const SizedBox(width: 16),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1B263B),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: const TextStyle(
                    color: Colors.grey,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),

          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 10,
            ),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Text(
                  number,
                  style: TextStyle(
                    color: color,
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
                const SizedBox(width: 8),
                InkWell(
                  onTap: () => _copyNumber(context, number),
                  child: Icon(
                    Icons.copy,
                    color: color,
                    size: 20,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}