import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'services/otp_screen.dart';
import 'package:flutter/services.dart';

class UserRegistrationScreen extends StatefulWidget {
  const UserRegistrationScreen({super.key});

  @override
  State<UserRegistrationScreen> createState() => _UserRegistrationScreenState();
}

class _UserRegistrationScreenState extends State<UserRegistrationScreen> {
  bool _isObscure = true;
  bool _isObscureConfirm = true;
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();

  @override
  void dispose() {
    _phoneController.dispose();
    _nameController.dispose();
    _emailController.dispose();
    _addressController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {

    final width = MediaQuery.of(context).size.width;
    final height = MediaQuery.of(context).size.height;

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
          padding: EdgeInsets.symmetric(
            horizontal: width * 0.06,
          ),
          child: Column(
            children: [
               Text(
                'নতুন অ্যাকাউন্ট তৈরি করুন',
                style: TextStyle(
                  fontSize: width * 0.065,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1E1E1E),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'অ্যাপ ব্যবহার শুরু করুন',
                style: TextStyle(
                  fontSize: width * 0.035,
                  color: Colors.grey,
                ),
              ),
              const SizedBox(height: 10),
              Center(
                child: Image.asset(
                  'image/register_hero.png',
                  height: height * 0.25,
                  fit: BoxFit.contain,
                ),
              ),
              SizedBox(height: height * 0.02),

              Container(
                decoration: BoxDecoration(
                  color: const Color(0xFFF8FAFF),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: const Color(0xFFEBF0FF)),
                ),
                child: Column(
                  children: [
                    _buildInputField(
                      controller: _nameController,
                      label: 'নাম',
                      hint: 'আপনার নাম দিন',
                      icon: Icons.person_outline,
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(
                          RegExp(r'[a-zA-Z\u0980-\u09FF ]'),
                        ),
                      ],
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
                      keyboardType: TextInputType.emailAddress,
                    ),
                    _buildDivider(),
                    _buildInputField(
                      controller: _addressController,
                      label: 'ঠিকানা',
                      hint: 'আপনার ঠিকানা দিন',
                      icon: Icons.location_on_outlined,
                    ),
                    _buildDivider(),
                    _buildInputField(
                      controller: _passwordController,
                      label: 'পাসওয়ার্ড',
                      hint: 'পাসওয়ার্ড দিন',
                      icon: Icons.lock_outline,
                      isPassword: true,
                      isObscured: _isObscure,
                      onToggleVisibility: () {
                        setState(() {
                          _isObscure = !_isObscure;
                        });
                      },
                    ),
                    _buildDivider(),
                    _buildInputField(
                      controller: _confirmPasswordController,
                      label: 'পাসওয়ার্ড পুনরায় দিন',
                      hint: 'পাসওয়ার্ড পুনরায় দিন',
                      icon: Icons.lock_outline,
                      isPassword: true,
                      isObscured: _isObscureConfirm,
                      onToggleVisibility: () {
                        setState(() {
                          _isObscureConfirm = !_isObscureConfirm;
                        });
                      },
                    ),
                  ],
                ),
              ),
              SizedBox(height: height * 0.03),
              
              SizedBox(
                width: double.infinity,
                height: height * 0.07,
                child: ElevatedButton(
                  // validation check
                  onPressed: () async {
                    String phone = _phoneController.text.trim();

                    String email = _emailController.text.trim();

                    String name = _nameController.text.trim();

                    if (name.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("নাম দিন")),
                      );
                      return;
                    }

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
                    if (_addressController.text.trim().isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("ঠিকানা দিন")),
                      );
                      return;
                    }
                    if (phone.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("অনুগ্রহ করে মোবাইল নাম্বার দিন")),
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

                    if (_passwordController.text.length < 8) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("পাসওয়ার্ড কমপক্ষে ৮ অক্ষরের হতে হবে")),
                      );
                      return;
                    }

                   // number checck before this number register
                    var userDoc = await FirebaseFirestore.instance
                        .collection('users')
                        .doc(phone)
                        .get();

                    if (userDoc.exists) {
                      if (!mounted) return;
                      showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: const Text("অ্যাকাউন্ট ইতিমধ্যে বিদ্যমান"),
                          content: const Text("আপনি আমাদের একজন রেজিস্টার্ড ইউজার। দয়া করে লগইন করুন।"),
                          actions: [
                            TextButton(
                              onPressed: () {
                                Navigator.pop(context);
                                Navigator.pop(context);
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
                            builder: (_) => OTPScreen(
                              phoneNumber: phone,
                              verificationId: verificationId,
                              userName: _nameController.text,
                              password: _passwordController.text,
                              role: "user",
                              email: _emailController.text.trim(),
                              address: _addressController.text.trim(),
                            )
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
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                  child: Text(
                    'রেজিস্টার করুন',
                    style: TextStyle(fontSize: width * 0.045, fontWeight: FontWeight.bold),
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
                    onTap: () {
                      Navigator.pop(context);
                    },
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
              SizedBox(height: height * 0.03),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDivider() {
    return const Divider(
      height: 1,
      indent: 50,
      endIndent: 16,
      color: Color(0xFFF0F4F8),
    );
  }

  Widget _buildInputField({
    required String label,
    required String hint,
    required IconData icon,
    TextEditingController? controller,
    List<TextInputFormatter>? inputFormatters,
    bool isPassword = false,
    bool isObscured = false,
    VoidCallback? onToggleVisibility,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xFFF5F9FF),
              borderRadius: BorderRadius.circular(10),
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
                  inputFormatters: inputFormatters,
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
}
