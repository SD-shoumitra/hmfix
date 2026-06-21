import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'login.dart';
import 'home_screen.dart';
import 'worker_dashboard.dart';

class Wrapper extends StatelessWidget {
  const Wrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, authSnapshot) {

        if (authSnapshot.connectionState ==
            ConnectionState.waiting) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }

        if (!authSnapshot.hasData) {
          return const LoginScreen();
        }

        final user = authSnapshot.data!;

        String phone = "";

        if (user.email != null &&
            user.email!.contains('@hmfix.com')) {

          phone = user.email!.split('@')[0];

        } else {

          phone =
              user.phoneNumber?.replaceAll('+88', '') ?? "";
        }

        return FutureBuilder<DocumentSnapshot>(
          future: FirebaseFirestore.instance
              .collection('workers')
              .doc(phone)
              .get(
            const GetOptions(
              source: Source.serverAndCache,
            ),
          ),
          builder: (context, workerSnapshot) {

            if (workerSnapshot.connectionState ==
                ConnectionState.waiting) {
              return const Scaffold(
                body: Center(
                  child: CircularProgressIndicator(),
                ),
              );
            }

            if (workerSnapshot.hasData &&
                workerSnapshot.data!.exists) {

              return const WorkerDashboard();
            }

            return const HomeScreen();
          },
        );
      },
    );
  }
}