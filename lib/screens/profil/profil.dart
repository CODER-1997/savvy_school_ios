import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:intl/intl.dart';
import '../../constants/custom_funcs/img_uploader.dart';

class Profil extends StatefulWidget {
  const Profil({super.key});

  @override
  _ProfilState createState() => _ProfilState();
}

class _ProfilState extends State<Profil> {
  final box = GetStorage();
  final ImageUploader uploader = ImageUploader();

  // Tanlangan oyni kuzatish (Default: Hozirgi oy)
  final RxString _selectedMonth = DateFormat('MMMM yyyy').format(DateTime.now()).obs;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: CupertinoColors.systemGroupedBackground,
      appBar: AppBar(
        backgroundColor: CupertinoColors.systemGroupedBackground,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          "Oylik Ma'lumotlari",
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black, fontSize: 18),
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
            return const Center(child: Text("Ma'lumot topilmadi"));
          }

          var documentData = snapshot.data!.data() as Map<String, dynamic>;
          var teacher = documentData['items'] ?? {};
          var imgUrl = teacher['imgUrl'];
          List history = List.from(teacher['salaryHistory'] ?? []);

          return Obx(() {
            // Tanlangan oy bo'yicha filterlash
            List monthlyDetails = history.where((item) => item['month'] == _selectedMonth.value).toList();

            num totalEarned = 0;
            num totalAdvance = 0;

            for (var item in monthlyDetails) {
              if (item['type'] == "Salary") totalEarned += item['amount'] ?? 0;
              if (item['type'] == "Advance") totalAdvance += item['amount'] ?? 0;
            }

            return SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 1. Profil Qismi
                  _buildHeader(teacher, imgUrl),
                  const SizedBox(height: 25),

                  // 2. Oy Tanlash
                  _buildMonthSelector(context),
                  const SizedBox(height: 20),

                  // 3. Statistika Kartalari
                  Row(
                    children: [
                      _statCard("Ishlangan haq", totalEarned, CupertinoColors.activeGreen),
                      const SizedBox(width: 12),
                      _statCard("Olingan Avans", totalAdvance, CupertinoColors.activeOrange),
                    ],
                  ),
                  const SizedBox(height: 30),

                  // 4. Batafsil Ro'yxat (Sababsiz, faqat turi va sanasi)
                  const Text(
                    "TO'LOVLAR TARIXI",
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: CupertinoColors.secondaryLabel, letterSpacing: 0.5),
                  ),
                  const SizedBox(height: 12),

                  if (monthlyDetails.isEmpty)
                    _buildEmptyState()
                  else
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: monthlyDetails.length,
                      itemBuilder: (context, index) {
                        return _buildTransactionItem(monthlyDetails[index]);
                      },
                    ),
                  const SizedBox(height: 50),
                ],
              ),
            );
          });
        },
      ),
    );
  }

  // --- UI METODLARI ---

  Widget _buildHeader(Map teacher, dynamic imgUrl) {
    return Row(
      children: [
        CircleAvatar(
          radius: 35,
          backgroundColor: Colors.white,
          backgroundImage: (imgUrl != null && imgUrl != "") ? NetworkImage(imgUrl) : null,
          child: (imgUrl == null || imgUrl == "") ? const Icon(CupertinoIcons.person, size: 30) : null,
        ),
        const SizedBox(width: 15),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("${teacher['name'] ?? ''} ${teacher['surname'] ?? ''}",
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            Text("Teacher ID: ${box.read('teacherId')}",
                style: const TextStyle(color: Colors.grey, fontSize: 13, fontWeight: FontWeight.w500)),
          ],
        ),
      ],
    );
  }

  Widget _buildMonthSelector(BuildContext context) {
    return CupertinoButton(
      padding: EdgeInsets.zero,
      onPressed: () => _showMonthPicker(context),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10, offset: const Offset(0, 4))],
        ),
        child: Row(
          children: [
            const Icon(CupertinoIcons.calendar, color: CupertinoColors.activeBlue, size: 22),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                _selectedMonth.value,
                style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 16),
              ),
            ),
            const Icon(CupertinoIcons.chevron_down, color: Colors.grey, size: 16),
          ],
        ),
      ),
    );
  }

  void _showMonthPicker(BuildContext context) {
    final List<String> months = [];
    DateTime now = DateTime.now();
    for (int i = 0; i < 12; i++) {
      months.add(DateFormat('MMMM yyyy').format(DateTime(now.year, now.month - i, 1)));
    }

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(10))),
            const SizedBox(height: 20),
            const Text("Kerakli oyni tanlang", style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                childAspectRatio: 2.2,
                mainAxisSpacing: 10,
                crossAxisSpacing: 10,
              ),
              itemCount: months.length,
              itemBuilder: (context, index) {
                bool isSelected = _selectedMonth.value == months[index];
                return GestureDetector(
                  onTap: () {
                    _selectedMonth.value = months[index];
                    Navigator.pop(context);
                  },
                  child: Container(
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: isSelected ? CupertinoColors.activeBlue : CupertinoColors.systemGrey6,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      months[index].split(' ')[0],
                      style: TextStyle(
                        color: isSelected ? Colors.white : Colors.black,
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                        fontSize: 13,
                      ),
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  Widget _statCard(String label, num amount, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: color.withOpacity(0.1)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: const TextStyle(fontSize: 11, color: Colors.grey, fontWeight: FontWeight.bold)),
            const SizedBox(height: 6),
            Text(
              NumberFormat('#,###').format(amount),
              style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: color),
            ),
            const Text("UZS", style: TextStyle(fontSize: 9, color: Colors.grey, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }

  Widget _buildTransactionItem(Map item) {
    bool isSalary = item['type'] == "Salary";
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: (isSalary ? Colors.green : Colors.orange).withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              isSalary ? CupertinoIcons.add_circled : CupertinoIcons.minus_circle,
              color: isSalary ? Colors.green : Colors.orange,
              size: 20,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Reason olib tashlandi, o'rniga turi chiqadi
                Text(isSalary ? "Ish haqi" : "Avans to'lovi",
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                const SizedBox(height: 2),
                Text(item['date'] ?? "", style: const TextStyle(color: Colors.grey, fontSize: 12)),
              ],
            ),
          ),
          Text(
            "${isSalary ? '+' : '-'}${NumberFormat('#,###').format(item['amount'])}",
            style: TextStyle(fontWeight: FontWeight.w800, color: isSalary ? Colors.green : Colors.orange, fontSize: 15),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(40),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20)),
      child: Column(
        children: [
          Icon(CupertinoIcons.tray, color: Colors.grey.shade300, size: 50),
          const SizedBox(height: 10),
          const Text("Ushbu oy uchun ma'lumot yo'q", style: TextStyle(color: Colors.grey, fontSize: 14)),
        ],
      ),
    );
  }
}