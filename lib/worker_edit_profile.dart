import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class WorkerEditProfileScreen extends StatefulWidget {
  const WorkerEditProfileScreen({super.key});

  @override
  State<WorkerEditProfileScreen> createState() =>
      _WorkerEditProfileScreenState();
}

class _WorkerEditProfileScreenState
    extends State<WorkerEditProfileScreen> {

  final _nameController = TextEditingController();
  final _serviceController = TextEditingController();
  final _experienceController = TextEditingController();
  final _areaController = TextEditingController();

  bool _isLoading = false;

  String? workerPhone;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final user = FirebaseAuth.instance.currentUser;


    if (user != null && user.email != null) {
    workerPhone = user.email!.split('@')[0];

    final doc = await FirebaseFirestore.instance
        .collection('workers')
        .doc(workerPhone)
        .get();

    if (doc.exists) {
    final data = doc.data()!;

    _nameController.text = data['name'] ?? '';
    _serviceController.text = data['serviceType'] ?? '';
    _experienceController.text = data['experience'] ?? '';
    _areaController.text = data['serviceArea'] ?? '';

    setState(() {});
    }
    }


  }

  Future<void> _saveProfile() async {
    if (workerPhone == null) return;


    setState(() {
    _isLoading = true;
    });

    await FirebaseFirestore.instance
        .collection('workers')
        .doc(workerPhone)
        .update({
    'name': _nameController.text.trim(),
    'serviceType': _serviceController.text.trim(),
    'experience': _experienceController.text.trim(),
    'serviceArea': _areaController.text.trim(),
    });

    setState(() {
    _isLoading = false;
    });

    if (mounted) {
    ScaffoldMessenger.of(context).showSnackBar(
    const SnackBar(
    content: Text('প্রোফাইল আপডেট হয়েছে'),
    ),
    );

    Navigator.pop(context);
    }


  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("প্রোফাইল এডিট"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [


          TextField(
          controller: _nameController,
          decoration: const InputDecoration(
            labelText: "নাম",
          ),
        ),

        const SizedBox(height: 15),

        TextField(
          controller: _serviceController,
          decoration: const InputDecoration(
            labelText: "পেশা",
          ),
        ),

        const SizedBox(height: 15),

        TextField(
          controller: _experienceController,
          decoration: const InputDecoration(
            labelText: "অভিজ্ঞতা",
          ),
        ),

        const SizedBox(height: 15),

        TextField(
          controller: _areaController,
          decoration: const InputDecoration(
            labelText: "সার্ভিস এরিয়া",
          ),
        ),

        const SizedBox(height: 30),

        SizedBox(
          width: double.infinity,
          height: 55,
          child: ElevatedButton(
            onPressed: _isLoading ? null : _saveProfile,
            child: _isLoading
                ? const CircularProgressIndicator()
                : const Text("সেভ করুন"),
          ),
        ),
        ],
      ),
    ),
    );


  }
}
