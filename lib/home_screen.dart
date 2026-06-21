import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'login.dart';
import 'user_profile.dart';
import 'user_electric.dart';
import 'user_booking_status.dart';
import 'user_emergency.dart';
import 'user_customer_helpline.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  String _getBanglaDate() {
    final now = DateTime.now();
    final dayNames = ['সোমবার', 'মঙ্গলবার', 'বুধবার', 'বৃহস্পতিবার', 'শুক্রবার', 'শনিবার', 'রবিবার'];
    final monthNames = [
      'জানুয়ারি', 'ফেব্রুয়ারি', 'মার্চ', 'এপ্রিল', 'মে', 'জুন',
      'জুলাই', 'আগস্ট', 'সেপ্টেম্বর', 'অক্টোবর', 'নভেম্বর', 'ডিসেম্বর'
    ];

    String dayName = dayNames[now.weekday - 1];
    String monthName = monthNames[now.month - 1];
    
    // digit convert to Bangla
    String day = now.day.toString().replaceAll('0', '০').replaceAll('1', '১').replaceAll('2', '২').replaceAll('3', '৩').replaceAll('4', '৪').replaceAll('5', '৫').replaceAll('6', '৬').replaceAll('7', '৭').replaceAll('8', '৮').replaceAll('9', '৯');
    String year = now.year.toString().replaceAll('0', '০').replaceAll('1', '১').replaceAll('2', '২').replaceAll('3', '৩').replaceAll('4', '৪').replaceAll('5', '৫').replaceAll('6', '৬').replaceAll('7', '৭').replaceAll('8', '৮').replaceAll('9', '৯');

    return '$dayName, $day $monthName $year';
  }

  @override
  Widget build(BuildContext context) {
    const Color bgColor = Colors.white;
    bool isTablet = MediaQuery.of(context).size.width > 600;

    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        final currentUser = snapshot.data;

        return Scaffold(
          backgroundColor: const Color(0xFFF3F7FF),
          appBar: AppBar(
            toolbarHeight: 95,
            backgroundColor: bgColor,
            elevation: 0,
            surfaceTintColor: Colors.transparent,
            automaticallyImplyLeading: false, 
            centerTitle: false,
            title: Padding(
              padding: const EdgeInsets.only(top: 25.0, left: 4.0),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Image.asset(
                    'image/logo.png',
                    height: 40,
                    fit: BoxFit.contain,
                  ),
                  const SizedBox(width: 10),
                  const Text(
                    'হোমফিক্স',
                    style: TextStyle(
                      color: Color(0xFF0066FF),
                      fontWeight: FontWeight.bold,
                      fontSize: 24,
                    ),
                  ),
                ],
              ),
            ),
            actions: [
              Padding(
                padding: const EdgeInsets.only(top: 25.0, right: 16.0), // প্রোফাইল আইকন নিচে নামানো হলো
                child: GestureDetector(
                  onTap: () {
                    if (currentUser != null) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const UserProfileScreen()),
                      );
                    } else {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const LoginScreen()),
                      );
                    }
                  },
                  child: CircleAvatar(
                    radius: 20,
                    backgroundColor: const Color(0xFFF0F4FF),
                    child: Icon(
                      currentUser != null ? Icons.person : Icons.login,
                      color: const Color(0xFF0066FF),
                      size: 24,
                    ),
                  ),
                ),
              ),
            ],
          ),
          body: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 12),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Row(
                    children: [
                      const Icon(Icons.calendar_today, color: Color(0xFF0066FF), size: 18),
                      const SizedBox(width: 8),
                      Text(
                        _getBanglaDate(),
                        style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black87),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Container(
                    height: 180,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(28),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withAlpha(38), 
                          blurRadius: 20,
                          spreadRadius: 1,
                          offset: const Offset(0, 10),
                        )
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(28),
                      child: Stack(
                        children: [
                          Positioned(
                            right: 0,
                            top: 0,
                            bottom: 0,
                            child: Image.asset(
                              'image/banner.png',
                              fit: BoxFit.cover,
                              alignment: Alignment.centerRight,
                            ),
                          ),
                          Container(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.centerLeft,
                                end: Alignment.centerRight,
                                colors: [
                                  const Color(0xFFE3F2FD).withAlpha(242), 
                                  const Color(0xFFE3F2FD).withAlpha(0), 
                                ],
                                stops: const [0.4, 0.8],
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(24.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(20),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withAlpha(12), 
                                        blurRadius: 5,
                                      )
                                    ]
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: const [
                                      Icon(Icons.bolt, color: Colors.amber, size: 16),
                                      SizedBox(width: 4),
                                      Text(
                                        'দ্রুত ও নির্ভরযোগ্য সেবা',
                                        style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 16),
                                const Text(
                                  'আপনার প্রয়োজনীয়\nসেবা এখন হাতের মুঠোয়',
                                  style: TextStyle(
                                    fontSize: 22,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF0D47A1),
                                    height: 1.2,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 30),

                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: GridView.count(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisCount: 3,
                    mainAxisSpacing: 20,
                    crossAxisSpacing: 15,
                    childAspectRatio: 0.9,
                    children: [

                      _buildServiceItem(
                        context,
                        Icons.electric_bolt,
                        'ইলেকট্রিশিয়ান',
                        Colors.orange,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const UserElectricScreen(
                                serviceType: 'ইলেকট্রিশিয়ান',
                                pageTitle: 'ইলেকট্রিশিয়ান',
                              ),
                            ),
                          );
                        },
                      ),

                      _buildServiceItem(
                        context,
                        Icons.plumbing,
                        'প্লাম্বার',
                        Colors.blue,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const UserElectricScreen(
                                serviceType: 'প্লাম্বার',
                                pageTitle: 'প্লাম্বার',
                              ),
                            ),
                          );
                        },
                      ),

                      _buildServiceItem(
                        context,
                        Icons.ac_unit,
                        'এসি সার্ভিস',
                        Colors.cyan,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const UserElectricScreen(
                                serviceType: 'এসি সার্ভিস',
                                pageTitle: 'এসি সার্ভিস',
                              ),
                            ),
                          );
                        },
                      ),

                      _buildServiceItem(
                        context,
                        Icons.restaurant,
                        'বাবুর্চি',
                        Colors.amber,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const UserElectricScreen(
                                serviceType: 'বাবুর্চি',
                                pageTitle: 'বাবুর্চি',
                              ),
                            ),
                          );
                        },
                      ),

                      _buildServiceItem(
                        context,
                        Icons.kebab_dining,
                        'কসাই',
                        Colors.red,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const UserElectricScreen(
                                serviceType: 'কসাই',
                                pageTitle: 'কসাই',
                              ),
                            ),
                          );
                        },
                      ),

                      _buildServiceItem(
                        context,
                        Icons.cleaning_services,
                        'ক্লিনার',
                        Colors.orangeAccent,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const UserElectricScreen(
                                serviceType: 'ক্লিনার',
                                pageTitle: 'ক্লিনার',
                              ),
                            ),
                          );
                        },
                      ),

                    ],
                  ),
                ),
                const SizedBox(height: 25),

                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: _buildActionCards(context, currentUser, isTablet),
                ),
                const SizedBox(height: 40),
              ],
            ),
          ),
          bottomNavigationBar: BottomAppBar(
            height: 70,
            color: Colors.white,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildNavItem(context, Icons.home, 'হোম', true, onTap: () {}),
                _buildNavItem(
                  context,
                  Icons.calendar_month,
                  'বুকিং',
                  false,
                  onTap: () {
                    if (currentUser != null) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const UserBookingStatusScreen()),
                      );
                    } else {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const LoginScreen()),
                      );
                    }
                  },
                ),
                _buildNavItem(
                  context,
                  Icons.person_outline,
                  'প্রোফাইল',
                  false,
                  onTap: () {
                    if (currentUser != null) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const UserProfileScreen()),
                      );
                    } else {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const LoginScreen()),
                      );
                    }
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildServiceItem(BuildContext context, IconData icon, String label, Color color, {VoidCallback? onTap}) {
    return InkWell(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            height: 60,
            width: 60,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withAlpha(10), 
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Icon(icon, color: color, size: 30),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.black87),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildActionCards(BuildContext context, User? currentUser, bool isTablet) {
    return Row(
      children: [
        Expanded(
          child: _actionCard(
            "জরুরি সেবা",
            "৩০-৬০ মিনিটের মধ্যে",
            const Color(0xFFFFEBEE),
            Icons.emergency,
            Colors.red,
            isTablet,
            onTap: () {
              if (currentUser != null) {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const UserEmergencyScreen()),
                );
              } else {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const LoginScreen()),
                );
              }
            },
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _actionCard(
            "কাস্টমার হেল্পলাইন",
            "যেকোনো সমস্যায় কল করুন",
            const Color(0xFFE8F5E9),
            Icons.support_agent,
            Colors.green,
            isTablet,
            onTap: () {
              if (currentUser != null) {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const UserCustomerHelplineScreen()),
                );
              } else {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const LoginScreen()),
                );
              }
            },
          ),
        ),
      ],
    );
  }

  Widget _actionCard(String title, String subtitle, Color bgColor, IconData icon, Color iconColor, bool isTablet, {VoidCallback? onTap}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(24),
      child: Container(
        padding: EdgeInsets.all(isTablet ? 20 : 16),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(24),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
              child: Icon(icon, color: iconColor, size: isTablet ? 24 : 20),
            ),
            const SizedBox(height: 12),
            Text(
              title,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: isTablet ? 16 : 14,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: TextStyle(
                fontSize: isTablet ? 12 : 10,
                color: Colors.grey.shade700,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNavItem(BuildContext context, IconData icon, String label, bool isActive, {VoidCallback? onTap}) {
    return InkWell(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: isActive ? const Color(0xFF0066FF) : Colors.grey.shade400, size: 26),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
              color: isActive ? const Color(0xFF0066FF) : Colors.grey.shade400,
            ),
          ),
        ],
      ),
    );
  }
}
