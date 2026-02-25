import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:intl/intl.dart';
import '../../constants/custom_funcs/img_uploader.dart';

class Profil extends StatefulWidget {
  @override
  _ProfilState createState() => _ProfilState();
}

class _ProfilState extends State<Profil> {
  final box = GetStorage();
  final ImageUploader uploader = ImageUploader();

  // Animation state for the tap effect
  RxDouble _cardScale = 1.0.obs;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: CupertinoColors.systemGroupedBackground,
      appBar: AppBar(
        backgroundColor: CupertinoColors.systemGroupedBackground,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          "Profile",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: CupertinoColors.black,
            fontSize: 20,
            letterSpacing: -0.5,
          ),
        ),
      ),
      body: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance
            .collection('AkhmedovTeachers')
            .doc(box.read('teacherDocId'))
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CupertinoActivityIndicator());
          }
          if (!snapshot.hasData || !snapshot.data!.exists) {
            return const Center(child: Text("Data not found"));
          }

          var documentData = snapshot.data!.data() as Map<String, dynamic>;
          var teacher = documentData['items'];
          var imgUrl = teacher['imgUrl'];
          var balance = teacher['balance'] ?? 0;

          return SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            child: Column(
              children: [
                const SizedBox(height: 10),

                // --- PROFILE IMAGE SECTION ---
                Center(
                  child: Column(
                    children: [
                      Stack(
                        alignment: Alignment.bottomRight,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(4),
                            decoration: const BoxDecoration(
                              color: CupertinoColors.white,
                              shape: BoxShape.circle,
                            ),
                            child: CircleAvatar(
                              radius: 70, // Bigger Profile Image
                              backgroundColor: CupertinoColors.systemGrey5,
                              backgroundImage: (imgUrl != null && imgUrl.toString().isNotEmpty)
                                  ? NetworkImage(imgUrl)
                                  : null,
                              child: (imgUrl == null || imgUrl.toString().isEmpty)
                                  ? Text(
                                teacher['name'][0].toUpperCase(),
                                style: const TextStyle(
                                    fontSize: 45,
                                    fontWeight: FontWeight.bold,
                                    color: CupertinoColors.activeBlue),
                              )
                                  : null,
                            ),
                          ),
                          Positioned(
                            right: 8,
                            bottom: 8,
                            child: Obx(() => uploader.isUploading.value
                                ? const CupertinoActivityIndicator(radius: 12)
                                : CupertinoButton(
                              padding: EdgeInsets.zero,
                              borderRadius: BorderRadius.circular(30),
                              color: CupertinoColors.activeBlue,
                              child: const Icon(
                                CupertinoIcons.camera_fill,
                                color: CupertinoColors.white,
                                size: 22,
                              ),
                              onPressed: () async {
                                await uploader.uploadTeacherImage(box.read('teacherDocId'));
                              },
                            )),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        "${teacher['name']} ${teacher['surname']}",
                        style: const TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            letterSpacing: -0.8),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        "Teacher ID: ${box.read('teacherId')}",
                        style: const TextStyle(
                            fontSize: 16,
                            color: CupertinoColors.secondaryLabel,
                            fontWeight: FontWeight.w500),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 35),

                // --- CURRENT BALANCE CARD WITH TAP SCALE EFFECT ---
                const Align(
                  alignment: Alignment.centerLeft,
                  child: Padding(
                    padding: EdgeInsets.only(left: 4, bottom: 10),
                    child: Text("FINANCE", style: TextStyle(fontSize: 13, color: CupertinoColors.secondaryLabel, fontWeight: FontWeight.w600, letterSpacing: 0.5)),
                  ),
                ),

                GestureDetector(
                  onTapDown: (_) => _cardScale.value = 0.95, // Shrink on tap
                  onTapUp: (_) => _cardScale.value = 1.0,    // Return to normal
                  onTapCancel: () => _cardScale.value = 1.0,
                  child: Obx(() => AnimatedScale(
                    scale: _cardScale.value,
                    duration: const Duration(milliseconds: 150),
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF007AFF), Color(0xFF5AC8FA)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(28),
                        boxShadow: [
                          BoxShadow(
                            color: CupertinoColors.activeBlue.withOpacity(0.3),
                            blurRadius: 20,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                "Current Balance".toUpperCase(),
                                style: TextStyle(
                                  color: CupertinoColors.white.withOpacity(0.8),
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 1.2,
                                ),
                              ),
                              const Icon(CupertinoIcons.sparkles, color: CupertinoColors.white, size: 20),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Text(
                            "${NumberFormat('#,###').format(int.parse(balance.toString()))} UZS",
                            style: const TextStyle(
                              color: CupertinoColors.white,
                              fontSize: 34,
                              fontWeight: FontWeight.bold,
                              letterSpacing: -1,
                            ),
                          ),
                        ],
                      ),
                    ),
                  )),
                ),

                const SizedBox(height: 30),

                // --- ACCOUNT SETTINGS SECTION ---
                const Align(
                  alignment: Alignment.centerLeft,
                  child: Padding(
                    padding: EdgeInsets.only(left: 4, bottom: 10),
                    child: Text("ACCOUNT SETTINGS", style: TextStyle(fontSize: 13, color: CupertinoColors.secondaryLabel, fontWeight: FontWeight.w600, letterSpacing: 0.5)),
                  ),
                ),
                Container(
                  decoration: BoxDecoration(
                    color: CupertinoColors.white,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Column(
                    children: [
                      _buildProfileItem(
                        icon: CupertinoIcons.person_alt_circle_fill,
                        title: "Personal Information",
                        onTap: () {},
                      ),
                      const Divider(height: 1, indent: 60, color: CupertinoColors.systemGrey6),
                      _buildProfileItem(
                        icon: CupertinoIcons.settings_solid,
                        title: "App Settings",
                        onTap: () {},
                      ),
                      const Divider(height: 1, indent: 60, color: CupertinoColors.systemGrey6),
                      _buildProfileItem(
                        icon: CupertinoIcons.power,
                        title: "Sign Out",
                        color: CupertinoColors.systemRed,
                        onTap: () {},
                        isLast: true,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 40),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildProfileItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    Color color = CupertinoColors.activeBlue,
    bool isLast = false
  }) {
    return CupertinoButton(
      padding: EdgeInsets.zero,
      onPressed: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: color, size: 22),
            ),
            const SizedBox(width: 15),
            Text(
              title,
              style: const TextStyle(fontSize: 17, color: CupertinoColors.black, fontWeight: FontWeight.w500),
            ),
            const Spacer(),
            const Icon(CupertinoIcons.chevron_right, color: CupertinoColors.systemGrey3, size: 16),
          ],
        ),
      ),
    );
  }
}