import 'package:flutter/material.dart';
import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../worker_dashboard.dart';

class WorkerOTPScreen extends StatefulWidget {
  final String phoneNumber;
  final String verificationId;
  final String userName;
  final String password;
  final String serviceType;
  final String experience;
  final String district;
  final String districtEn;
  final String email;
  final String address;
  final int serviceCharge;

  const WorkerOTPScreen({
    super.key,
    required this.phoneNumber,
    required this.verificationId,
    required this.userName,
    required this.password,
    required this.serviceType,
    required this.experience,
    required this.district,
    required this.districtEn,
    required this.email,
    required this.address,
    required this.serviceCharge,
  });
  @override
  State<WorkerOTPScreen> createState() => _WorkerOTPScreenState();
}

class _WorkerOTPScreenState extends State<WorkerOTPScreen> {
  final List<TextEditingController> _controllers = List.generate(6, (index) => TextEditingController());
  final List<FocusNode> _focusNodes = List.generate(6, (index) => FocusNode());
  
  int _timerSeconds = 60;
  bool _isLoading = false;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) {
        setState(() {
          if (_timerSeconds > 0) {
            _timerSeconds--;
          } else {
            _timer?.cancel();
          }
        });
      }
    });
  }

  @override
  void dispose() {
    for (var controller in _controllers) {
      controller.dispose();
    }
    for (var node in _focusNodes) {
      node.dispose();
    }
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _verifyOTP() async {
    String otp = _controllers.map((e) => e.text).join();

    if (otp.length != 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("৬ সংখ্যার OTP দিন")),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      PhoneAuthCredential credential = PhoneAuthProvider.credential(
        verificationId: widget.verificationId,
        smsCode: otp,
      );


      UserCredential userCredential = await FirebaseAuth.instance.signInWithCredential(credential);


      if (widget.password.isNotEmpty) {
        try {
          AuthCredential emailAuth = EmailAuthProvider.credential(
            email: "${widget.phoneNumber}@hmfix.com",
            password: widget.password,
          );

          await userCredential.user!.linkWithCredential(emailAuth);
        } on FirebaseAuthException catch (e) {
          debugPrint("Link Error: ${e.code}");
        }
      }


      await FirebaseFirestore.instance
          .collection("workers")
          .doc(widget.phoneNumber)
          .set({
        "uid": userCredential.user!.uid,
        "name": widget.userName,
        "phone": widget.phoneNumber,
        "email": "${widget.phoneNumber}@hmfix.com",
        "role": "worker",

        "serviceType": widget.serviceType,
        "experience": widget.experience,
        "district": widget.district,
        "districtEn": widget.districtEn,

        "address": widget.address,
        "serviceCharge": widget.serviceCharge,

        "rating": 0.0,
        "pendingRequests": 0,
        "runningJobs": 0,
        "totalJobs": 0,
        "totalEarnings": 0,

        "serviceArea": "",
        "isOnline": true,
        "isAvailable": true,

        "isVerified": false,
        "createdAt": Timestamp.now(),
      }, SetOptions(merge: true));
      if (!mounted) return;
      setState(() => _isLoading = false);

      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const WorkerDashboard()),
        (route) => false,
      );
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString())),
      );
    }
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
              const SizedBox(height: 20),
              Center(
                child: Container(
                  height: width * 0.30,
                  width: width * 0.30,
                  decoration: BoxDecoration(
                    color: const Color(0xFFE8F0FE),
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: const Icon(Icons.verified_user_outlined, size: 60, color: Color(0xFF0066FF)),
                ),
              ),
              const SizedBox(height: 32),
              Text(
                'OTP ভেরিফিকেশন',
                style: TextStyle(fontSize: width * 0.06, fontWeight: FontWeight.bold, color: Color(0xFF1E1E1E)),
              ),
              const SizedBox(height: 12),
              RichText(
                textAlign: TextAlign.center,
                text: TextSpan(
                  style: const TextStyle(fontSize: 14, color: Colors.grey, height: 1.5),
                  children: [
                    const TextSpan(text: 'আমরা একটি কোড পাঠিয়েছি \n'),
                    TextSpan(
                      text: '+88 ${widget.phoneNumber}',
                      style: const TextStyle(color: Colors.black87, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 40),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: List.generate(6, (index) {
                  return Container(
                    width: width * 0.12,
                    height: width * 0.14,
                    decoration: BoxDecoration(
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.03),
                          blurRadius: 10,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: TextField(
                      controller: _controllers[index],
                      focusNode: _focusNodes[index],
                      keyboardType: TextInputType.number,
                      textAlign: TextAlign.center,
                      maxLength: 1,
                      style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFF0066FF)),
                      decoration: InputDecoration(
                        counterText: "",
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15),
                          borderSide: const BorderSide(color: Color(0xFFEBF0FF)),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15),
                          borderSide: const BorderSide(color: Color(0xFF0066FF), width: 2),
                        ),
                        fillColor: const Color(0xFFF8FAFF),
                        filled: true,
                      ),
                      onChanged: (value) {
                        if (value.isNotEmpty && index < 5) {
                          _focusNodes[index + 1].requestFocus();
                        } else if (value.isEmpty && index > 0) {
                          _focusNodes[index - 1].requestFocus();
                        }
                        if (value.isNotEmpty && index == 5) {
                          FocusScope.of(context).unfocus();
                        }
                      },
                    ),
                  );
                }),
              ),
              const SizedBox(height: 40),
              SizedBox(
                width: double.infinity,
                height: height * 0.07,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _verifyOTP,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0066FF),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                    elevation: 0,
                  ),
                  child: _isLoading
                      ? const SizedBox(height: 24, width: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                      : Text('ভেরিফাই এবং এগিয়ে যান', style: TextStyle(fontSize: width * 0.04, fontWeight: FontWeight.bold)),
                ),
              ),
              const SizedBox(height: 32),
              Column(
                children: [
                  const Text('কোড পাননি?', style: TextStyle(color: Colors.grey, fontSize: 14)),
                  const SizedBox(height: 8),
                  _timerSeconds > 0
                      ? Text('পুনরায় পাঠান (${_timerSeconds}s)', style: const TextStyle(color: Colors.black54, fontWeight: FontWeight.bold, fontSize: 14))
                      : TextButton(
                          onPressed: () {
                            setState(() { _timerSeconds = 60; _startTimer(); });
                          },
                          child: const Text(
                            'কোড পুনরায় পাঠান',
                            style: TextStyle(color: Color(0xFF0066FF), fontWeight: FontWeight.bold, fontSize: 15),
                          ),
                        ),
                ],
              ),
              const SizedBox(height: 40),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFFF0F6FF),
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.info_outline, color: Color(0xFF0066FF), size: 20),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'একজন প্রফেশনাল হিসেবে আপনার তথ্যগুলো সুরক্ষিত রাখা হবে।',
                        style: TextStyle(fontSize: 12, color: Colors.blue.shade900),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
