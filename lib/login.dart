import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'user_regi.dart';
import 'worker_regi.dart';
import 'home_screen.dart';
import 'worker_profile.dart';
import 'worker_dashboard.dart';
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool isUserSelected = true;
  bool _isObscure = true;
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _phoneController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    if (_phoneController.text.isEmpty || _passwordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('অনুগ্রহ করে মোবাইল নাম্বার এবং পাসওয়ার্ড দিন')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // Firebase Auth
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: "${_phoneController.text}@hmfix.com",
        password: _passwordController.text,
      );

      // log in er smy database theke check
      String collectionName = isUserSelected ? "users" : "workers";

      DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection(collectionName)
          .doc(_phoneController.text)
          .get();

      if (!userDoc.exists) {
        await FirebaseAuth.instance.signOut();

        setState(() => _isLoading = false);

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("নির্বাচিত ক্যাটাগরিতে কোনো অ্যাকাউন্ট পাওয়া যায়নি"),
          ),
        );
        return;
      }

      String roleInDb = userDoc['role'];
      String selectedRole = isUserSelected ? "user" : "worker";

      if (roleInDb != selectedRole) {
        await FirebaseAuth.instance.signOut();

        setState(() => _isLoading = false);

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'আপনি ভুল ক্যাটাগরি (${isUserSelected ? "ইউজার" : "ওয়ার্কার"}) নির্বাচন করেছেন',
            ),
          ),
        );
        return;
      }


      setState(() => _isLoading = false);

      if (isUserSelected) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => const HomeScreen()),
              (route) => false,
        );
      } else {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => const WorkerDashboard()),
              (route) => false,
        );
      }

    } on FirebaseAuthException catch (e) {
      setState(() => _isLoading = false);
      debugPrint("Auth Error: ${e.code}"); // for debug
      
      String errorMessage = "লগইন ব্যর্থ হয়েছে";
      if (e.code == 'user-not-found' || e.code == 'invalid-credential') {
        errorMessage = "মোবাইল নাম্বার অথবা পাসওয়ার্ড সঠিক নয়";
      } else if (e.code == 'wrong-password') {
        errorMessage = "পাসওয়ার্ড সঠিক নয়";
      } else if (e.code == 'invalid-email') {
        errorMessage = "ভুল মোবাইল নাম্বার ফরম্যাট";
      } else if (e.code == 'too-many-requests') {
        errorMessage = "অতিরিক্ত চেষ্টার কারণে অ্যাকাউন্ট সাময়িকভাবে বন্ধ করা হয়েছে। পরে চেষ্টা করুন।";
      }
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(errorMessage)),
      );
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("লগইন ত্রুটি: ${e.toString()}")),
      );
    }
  }



  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final height = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F9FF),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(
            horizontal: width * 0.06,
          ),
          child: Column(
            children: [
              SizedBox(height: height * 0.05),
              Center(
                child: Container(
                  height: width * 0.30,
                  width: width * 0.30,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.blue.withOpacity(0.08),
                        blurRadius: 25,
                        spreadRadius: 2,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: ClipOval(
                    child: Image.asset(
                      'image/logo_page.png',
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 30),
              Text(
                'স্বাগতম!',
                style: TextStyle(
                  fontSize: width * 0.07,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1E1E1E),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'আপনার অ্যাকাউন্ট লগইন করুন',
                style: TextStyle(
                  fontSize: width * 0.035,
                  color: Colors.grey,
                ),
              ),
              const SizedBox(height: 30),

              // User/Worker Toggle
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFE3E8FF)),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () => setState(() => isUserSelected = true),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          decoration: BoxDecoration(
                            color: isUserSelected ? const Color(0xFF0066FF) : Colors.white,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.person,
                                size: 20,
                                color: isUserSelected ? Colors.white : const Color(0xFF0066FF),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'ইউজার',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: isUserSelected ? Colors.white : const Color(0xFF0066FF),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: GestureDetector(
                        onTap: () => setState(() => isUserSelected = false),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          decoration: BoxDecoration(
                            color: !isUserSelected ? const Color(0xFF0066FF) : Colors.white,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.engineering,
                                size: 20,
                                color: !isUserSelected ? Colors.white : Colors.grey,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'ওয়ার্কার',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: !isUserSelected ? Colors.white : Colors.grey,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Inputs Card
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.03),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    TextField(
                      controller: _phoneController,
                      keyboardType: TextInputType.phone,
                      decoration: const InputDecoration(
                        labelText: 'মোবাইল নাম্বার',
                        hintText: '01XXXXXXXXX',
                        prefixIcon: Icon(Icons.phone_outlined, color: Colors.black87),
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(vertical: 16, horizontal: 16),
                      ),
                    ),
                    const Divider(height: 1, indent: 16, endIndent: 16),
                    TextField(
                      controller: _passwordController,
                      obscureText: _isObscure,
                      decoration: InputDecoration(
                        labelText: 'পাসওয়ার্ড',
                        hintText: 'পাসওয়ার্ড দিন',
                        prefixIcon: const Icon(Icons.lock_outline, color: Colors.black87),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _isObscure ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                            color: Colors.grey,
                          ),
                          onPressed: () => setState(() => _isObscure = !_isObscure),
                        ),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () {},
                  child: const Text(
                    'পাসওয়ার্ড ভুলে গেছেন?',
                    style: TextStyle(color: Color(0xFF0066FF), fontSize: 13),
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Login Button
              SizedBox(
                width: double.infinity,
                height: height * 0.07,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _handleLogin,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0066FF),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          height: 24,
                          width: 24,
                          child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                        )
                      : Text(
                          'লগইন করুন',
                          style: TextStyle(fontSize: width * 0.045, fontWeight: FontWeight.bold),
                        ),
                ),
              ),

              const SizedBox(height: 40),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('অ্যাকাউন্ট নেই? ', style: TextStyle(color: Colors.black87)),
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => isUserSelected
                              ? const UserRegistrationScreen()
                              : const WorkerRegistrationScreen(),
                        ),
                      );
                    },
                    child: const Text(
                      'রেজিস্টার করুন',
                      style: TextStyle(
                        color: Color(0xFF0066FF),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
