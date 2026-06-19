import 'package:flutter/material.dart';
import 'services/otp_screen_worker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class WorkerRegistrationScreen extends StatefulWidget {
  const WorkerRegistrationScreen({super.key});

  @override
  State<WorkerRegistrationScreen> createState() => _WorkerRegistrationScreenState();
}

class _WorkerRegistrationScreenState extends State<WorkerRegistrationScreen> {
  bool _isObscure = true;
  bool _isObscureConfirm = true;
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _serviceChargeController = TextEditingController();

  String? selectedService;
  String? selectedExperience;

  final List<Map<String, dynamic>> services = [
    {'name': 'ইলেকট্রিশিয়ান', 'icon': Icons.electric_bolt, 'color': Colors.orange},
    {'name': 'প্লাম্বার', 'icon': Icons.plumbing, 'color': Colors.blue},
    {'name': 'এসি সার্ভিস', 'icon': Icons.ac_unit, 'color': Colors.cyan},
    {'name': 'বাবুর্চি', 'icon': Icons.restaurant, 'color': Colors.amber},
    {'name': 'কসাই', 'icon': Icons.kebab_dining, 'color': Colors.red},
    {'name': 'ক্লিনার', 'icon': Icons.format_paint, 'color': Colors.orangeAccent},
  ];

  final List<String> experienceLevels = [
    '১ বছরের কম',
    '১ - ৩ বছর',
    '৩ - ৫ বছর',
    '৫ - ১০ বছর',
    '১০ বছরের বেশি',
  ];

  @override
  void dispose() {
    _phoneController.dispose();
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _addressController.dispose();
    _serviceChargeController.dispose();
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
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            children: [
              const Text(
                'নতুন অ্যাকাউন্ট তৈরি করুন',
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1E1E1E),
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'আমাদের সার্ভিস নেটওয়ার্কে যুক্ত হোন',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey,
                ),
              ),
              const SizedBox(height: 10),
              Center(
                child: Image.asset(
                  'image/worker_register_hero.png',
                  height: 220,
                  fit: BoxFit.contain,
                ),
              ),
              const SizedBox(height: 20),

              Container(
                decoration: BoxDecoration(
                  color: const Color(0xFFF8FAFF),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: const Color(0xFFEBF0FF)),
                ),
                child: Column(
                  children: [
                    _buildInputField(
                      controller: _nameController,
                      label: 'নাম',
                      hint: 'আপনার নাম দিন',
                      icon: Icons.person_outline,
                    ),
                    _buildDivider(),
                    _buildInputField(
                      controller: _phoneController,
                      label: 'মোবাইল নাম্বার',
                      hint: '01XXXXXXXXX',
                      icon: Icons.phone_outlined,
                      keyboardType: TextInputType.phone,
                    ),
                    _buildDivider(),
                    _buildInputField(
                      controller: _emailController,
                      label: 'ইমেইল',
                      hint: 'আপনার ইমেইল দিন',
                      icon: Icons.email_outlined,
                    ),
                    _buildDivider(),
                    _buildInputField(
                      controller: _addressController,
                      label: 'ঠিকানা',
                      hint: 'আপনার এলাকা/ঠিকানা দিন',
                      icon: Icons.location_on_outlined,
                    ),

                    _buildDivider(),
                    _buildInputField(
                      controller: _serviceChargeController,
                      label: 'সার্ভিস চার্জ',
                      hint: 'যেমন: 300',
                      icon: Icons.currency_exchange,
                      keyboardType: TextInputType.number,
                    ),
                    _buildDivider(),
                    _buildDropdownField(
                      label: 'সার্ভিসের ধরন',
                      hint: selectedService ?? 'সার্ভিস নির্বাচন করুন',
                      icon: Icons.construction_outlined,
                      onTap: () => _showServicePicker(),
                      isSelected: selectedService != null,
                    ),
                    _buildDivider(),
                    _buildDropdownField(
                      label: 'অভিজ্ঞতা',
                      hint: selectedExperience ?? 'অভিজ্ঞতা নির্বাচন করুন',
                      icon: Icons.history_edu_outlined,
                      onTap: () => _showExperiencePicker(),
                      isSelected: selectedExperience != null,
                    ),
                    _buildDivider(),
                    _buildInputField(
                      controller: _passwordController,
                      label: 'পাসওয়ার্ড',
                      hint: 'পাসওয়ার্ড দিন',
                      icon: Icons.lock_outline,
                      isPassword: true,
                      isObscured: _isObscure,
                      onToggleVisibility: () => setState(() => _isObscure = !_isObscure),
                    ),
                    _buildDivider(),
                    _buildInputField(
                      controller: _confirmPasswordController,
                      label: 'পাসওয়ার্ড পুনরায় দিন',
                      hint: 'পাসওয়ার্ড পুনরায় দিন',
                      icon: Icons.lock_outline,
                      isPassword: true,
                      isObscured: _isObscureConfirm,
                      onToggleVisibility: () => setState(() => _isObscureConfirm = !_isObscureConfirm),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 30),

              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: () async {

                    String phone = _phoneController.text.trim();

                    String email = _emailController.text.trim();

                    if (email.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("ইমেইল দিন")),
                      );
                      return;
                    }

                    bool isValidEmail = RegExp(
                      r'^[\w\-\.]+@([\w\-]+\.)+[\w\-]{2,4}$',
                    ).hasMatch(email);

                    if (!isValidEmail) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("সঠিক ইমেইল দিন")),
                      );
                      return;
                    }

                    if (phone.isEmpty) {

                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('অনুগ্রহ করে মোবাইল নাম্বার দিন')),
                      );
                      return;
                    }

                    if (selectedService == null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("সার্ভিস নির্বাচন করুন")),
                      );
                      return;
                    }

                    if (selectedExperience == null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("অভিজ্ঞতা নির্বাচন করুন")),
                      );
                      return;
                    }

                    if (_passwordController.text.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("পাসওয়ার্ড দিন")),
                      );
                      return;
                    }

                    if (_passwordController.text != _confirmPasswordController.text) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("পাসওয়ার্ড মেলেনি")),
                      );
                      return;
                    }

                    if (_addressController.text.trim().isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("ঠিকানা দিন")),
                      );
                      return;
                    }

                    if (_serviceChargeController.text.trim().isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("সার্ভিস চার্জ দিন")),
                      );
                      return;
                    }

                    // চেক করা হচ্ছে নাম্বারটি আগে থেকে আছে কি না
                    var workerDoc = await FirebaseFirestore.instance
                        .collection('workers')
                        .doc(phone)
                        .get();

                    if (workerDoc.exists) {
                      if (!mounted) return;
                      showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: const Text("অ্যাকাউন্ট ইতিমধ্যে বিদ্যমান"),
                          content: const Text("আপনি আমাদের একজন রেজিস্টার্ড ইউজার। দয়া করে লগইন করুন।"),
                          actions: [
                            TextButton(
                              onPressed: () {
                                Navigator.pop(context); // ডায়ালগ বন্ধ
                                Navigator.pop(context); // লগইন স্ক্রিনে ফেরত যাওয়া
                              },
                              child: const Text("লগইন করুন"),
                            ),
                          ],
                        ),
                      );
                      return;
                    }

                    await FirebaseAuth.instance.verifyPhoneNumber(
                      phoneNumber: "+88$phone",
                      verificationCompleted: (PhoneAuthCredential credential) async {},
                      verificationFailed: (FirebaseAuthException e) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text(e.message ?? "OTP Failed")),
                        );
                      },
                      codeSent: (String verificationId, int? resendToken) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => WorkerOTPScreen(
                              phoneNumber: phone,
                              verificationId: verificationId,
                              userName: _nameController.text,
                              password: _passwordController.text,
                              serviceType: selectedService ?? "",
                              experience: selectedExperience ?? "",
                              email: _emailController.text.trim(),
                              address: _addressController.text.trim(),
                              serviceCharge: int.tryParse(
                                _serviceChargeController.text.trim(),
                              ) ??
                                  0,
                            ),
                          ),
                        );
                      },
                      codeAutoRetrievalTimeout: (String verificationId) {},
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0066FF),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 0,
                  ),
                  child: const Text(
                    'রেজিস্টার করুন',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              const SizedBox(height: 24),

              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    'ইতিমধ্যে অ্যাকাউন্ট আছে? ',
                    style: TextStyle(color: Colors.black87, fontSize: 14),
                  ),
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: const Text(
                      'লগইন করুন',
                      style: TextStyle(
                        color: Color(0xFF0066FF),
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }

  void _showServicePicker() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.fromLTRB(20, 24, 20, 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'আপনার সার্ভিসের ধরন বেছে নিন',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 24),
              Flexible(
                child: GridView.builder(
                  shrinkWrap: true,
                  itemCount: services.length,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    mainAxisSpacing: 16,
                    crossAxisSpacing: 16,
                    childAspectRatio: 1,
                  ),
                  itemBuilder: (context, index) {
                    bool isSelected = selectedService == services[index]['name'];
                    return InkWell(
                      onTap: () {
                        setState(() => selectedService = services[index]['name']);
                        Navigator.pop(context);
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          color: isSelected ? services[index]['color'].withOpacity(0.1) : Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: isSelected ? services[index]['color'] : const Color(0xFFEBF0FF),
                            width: 1.5,
                          ),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(services[index]['icon'], color: services[index]['color'], size: 32),
                            const SizedBox(height: 8),
                            Text(
                              services[index]['name'],
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                                color: Colors.black87,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showExperiencePicker() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.fromLTRB(20, 24, 20, 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'আপনার অভিজ্ঞতা নির্বাচন করুন',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              ...experienceLevels.map((exp) {
                bool isSelected = selectedExperience == exp;
                return ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                  title: Text(
                    exp,
                    style: TextStyle(
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                      color: Colors.black87,
                    ),
                  ),
                  trailing: isSelected ? const Icon(Icons.check_circle, color: Color(0xFF0066FF)) : null,
                  onTap: () {
                    setState(() => selectedExperience = exp);
                    Navigator.pop(context);
                  },
                );
              }).toList(),
            ],
          ),
        );
      },
    );
  }

  Widget _buildDivider() => const Divider(
        height: 1,
        indent: 50,
        endIndent: 16,
        color: Color(0xFFEBF0FF),
      );

  Widget _buildInputField({
    required String label,
    required String hint,
    required IconData icon,
    TextEditingController? controller,
    bool isPassword = false,
    bool isObscured = false,
    VoidCallback? onToggleVisibility,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: const Color(0xFFEBF0FF)),
            ),
            child: Icon(icon, color: const Color(0xFF0066FF), size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                TextField(
                  controller: controller,
                  obscureText: isObscured,
                  keyboardType: keyboardType,
                  style: const TextStyle(fontSize: 15, color: Colors.black),
                  decoration: InputDecoration(
                    hintText: hint,
                    hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 14),
                    border: InputBorder.none,
                    isDense: true,
                    contentPadding: const EdgeInsets.symmetric(vertical: 4),
                  ),
                ),
              ],
            ),
          ),
          if (isPassword)
            IconButton(
              icon: Icon(
                isObscured ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                color: Colors.grey.shade400,
                size: 18,
              ),
              onPressed: onToggleVisibility,
            ),
        ],
      ),
    );
  }

  Widget _buildDropdownField({
    required String label,
    required String hint,
    required IconData icon,
    VoidCallback? onTap,
    bool isSelected = false,
  }) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: const Color(0xFFEBF0FF)),
              ),
              child: Icon(icon, color: const Color(0xFF0066FF), size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    hint,
                    style: TextStyle(
                      color: isSelected ? Colors.black87 : Colors.grey.shade400,
                      fontSize: 15,
                    ),
                  ),
                ],
              ),
            ),
            Icon(Icons.keyboard_arrow_right, color: Colors.grey.shade400, size: 20),
          ],
        ),
      ),
    );
  }
}
