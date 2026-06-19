import 'package:flutter/material.dart';
import 'user_book_confirm.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class UserElectricBookForm extends StatefulWidget {
  final Map<String, dynamic> worker;
  const UserElectricBookForm({super.key, required this.worker});

  @override
  State<UserElectricBookForm> createState() => _UserElectricBookFormState();
}

class _UserElectricBookFormState extends State<UserElectricBookForm> {
  String? _selectedWork;
  final TextEditingController _detailsController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _dateController = TextEditingController();
  final TextEditingController _timeController = TextEditingController();

  List<String> getWorkOptions() {

    switch (widget.worker['serviceType']) {

      case 'ইলেকট্রিশিয়ান':
        return [
          "সুইচ সমস্যা",
          "লাইট ফিটিং",
          "ফ্যান ইনস্টল",
          "সকেট সমস্যা",
          "অন্যান্য",
        ];

      case 'প্লাম্বার':
        return [
          "পাইপ লিক",
          "ট্যাপ সমস্যা",
          "বেসিন ফিটিং",
          "ড্রেন সমস্যা",
          "অন্যান্য",
        ];

      case 'ক্লিনার':
        return [
          "বাসা পরিষ্কার",
          "বাথরুম পরিষ্কার",
          "কিচেন পরিষ্কার",
          "অফিস পরিষ্কার",
          "অন্যান্য",
        ];

      case 'বাবুর্চি':
        return [
          "দৈনিক রান্না",
          "পার্টি রান্না",
          "বিয়ে অনুষ্ঠান",
          "আকিকা",
          "অন্যান্য",
        ];

      case 'কসাই':
        return [
          "গরু কাটা",
          "খাসি কাটা",
          "মাংস প্রসেসিং",
          "কুরবানী সার্ভিস",
          "অন্যান্য",
        ];

      case 'এসি সার্ভিস':
        return [
          "এসি ইনস্টল",
          "এসি সার্ভিসিং",
          "গ্যাস রিফিল",
          "এসি রিপেয়ার",
          "অন্যান্য",
        ];

      default:
        return ["অন্যান্য"];
    }
  }

  @override
  void dispose() {
    _detailsController.dispose();
    _addressController.dispose();
    _dateController.dispose();
    _timeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF1B263B)),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          widget.worker['serviceType'] ?? '',
          style: const TextStyle(
            color: Color(0xFF1B263B),
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        centerTitle: false,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1.0),
          child: Container(
            color: Colors.grey.shade200,
            height: 1.0,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "কোন কাজটি করাতে চান?",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1B263B),
              ),
            ),
            const SizedBox(height: 8),
            ...getWorkOptions().map((option) => RadioListTile<String>(
                  title: Text(option),
                  value: option,
                  groupValue: _selectedWork,
                  onChanged: (value) {
                    setState(() {
                      _selectedWork = value;
                    });
                  },
                  contentPadding: EdgeInsets.zero,
                  dense: true,
                  activeColor: const Color(0xFF0066FF),
                )),
            const SizedBox(height: 24),
            _buildLabel("সমস্যার বিবরণ"),
            const SizedBox(height: 8),
            _buildTextField(_detailsController, "সমস্যার বিস্তারিত লিখুন...", maxLines: 4),
            const SizedBox(height: 24),
            _buildLabel("ঠিকানা"),
            const SizedBox(height: 8),
            _buildTextField(_addressController, "আপনার ঠিকানা লিখুন..."),
            const SizedBox(height: 24),
            _buildLabel("তারিখ"),
            const SizedBox(height: 8),
            _buildTextField(_dateController, "তারিখ লিখুন... (যেমন: ২৩ জুন, ২০২৬)"),
            const SizedBox(height: 24),
            _buildLabel("সময়"),
            const SizedBox(height: 8),
            _buildTextField(_timeController, "সময় লিখুন... (যেমন: সকাল ১০টা)"),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: () async {

                  if (_selectedWork == null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text("কাজের ধরন নির্বাচন করুন"),
                      ),
                    );
                    return;
                  }

                  if (_detailsController.text.trim().isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text("সমস্যার বিবরণ লিখুন"),
                      ),
                    );
                    return;
                  }

                  if (_addressController.text.trim().isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text("ঠিকানা লিখুন"),
                      ),
                    );
                    return;
                  }

                  if (_dateController.text.trim().isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text("তারিখ নির্বাচন করুন"),
                      ),
                    );
                    return;
                  }

                  if (_timeController.text.trim().isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text("সময় নির্বাচন করুন"),
                      ),
                    );
                    return;
                  }

                  try {
                    final user = FirebaseAuth.instance.currentUser;

                    final phone =
                    user!.phoneNumber!.replaceAll('+88', '');

                    final userDoc = await FirebaseFirestore.instance
                        .collection('users')
                        .doc(phone)
                        .get();

                    final customerName = userDoc['name'];

                    await FirebaseFirestore.instance
                        .collection('requests')
                        .add({
                      'workerName': widget.worker['name'],
                      'workerPhone': widget.worker['phone'],

                      'serviceType': widget.worker['serviceType'],
                      'serviceCharge': widget.worker['serviceCharge'],

                      'customerUid': user?.uid,
                      'customerPhone': user?.phoneNumber,
                      'customerName': customerName,

                      'workType': _selectedWork,
                      'details': _detailsController.text.trim(),
                      'address': _addressController.text.trim(),
                      'date': _dateController.text.trim(),
                      'time': _timeController.text.trim(),

                      'status': 'pending',
                      'createdAt': Timestamp.now(),
                    });

                    if (!mounted) return;

                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => UserBookConfirm(
                          worker: widget.worker,
                          workType: _selectedWork!,
                          details: _detailsController.text.trim(),
                          address: _addressController.text.trim(),
                          date: _dateController.text.trim(),
                          time: _timeController.text.trim(),
                        ),
                      ),
                    );
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text("রিকোয়েস্ট পাঠানো যায়নি: $e"),
                      ),
                    );
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF0066FF),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  "অনুরোধ পাঠান",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
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

  Widget _buildLabel(String text) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 15,
        fontWeight: FontWeight.bold,
        color: Color(0xFF1B263B),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String hint, {int maxLines = 1}) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 14),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF0066FF)),
        ),
      ),
    );
  }
}
