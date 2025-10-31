import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get_storage/get_storage.dart';
import 'package:savvy_school_ios/screens/admin/groups/groups.dart';
 import 'package:savvy_school_ios/screens/admin/statistics/statistics.dart';
import 'package:savvy_school_ios/screens/admin/students/students.dart';
import 'package:savvy_school_ios/screens/admin/teachers/teachers.dart';
 import '../../constants/theme.dart';

class AdminHomeScreen extends StatelessWidget {
  static RxInt currentIndex = 0.obs;
   GetStorage box = GetStorage();

  @override
  Widget build(BuildContext context) {
    return Obx(() => Scaffold(
          backgroundColor: homePagebg,
          body:   Container(
              height: Get.height,
              // padding: EdgeInsets.only(left: 16,right: 16,top: 16),
              child: box.read('isLogged') == 'Linguista9' || box.read('isLogged') == 'testuser' ? [
                AdminGroups(),
                AdminStudents(),
                Teachers(),
              //  MonthlyStatistics(),
                Statistics(),
              ].obs[currentIndex.value]: [
                AdminGroups(),
                AdminStudents(),

              ].obs[currentIndex.value],
            ),

          bottomNavigationBar:box.read('isLogged') == 'Linguista9' || box.read('isLogged') == 'testuser'  ? BottomNavigationBar(

            backgroundColor: Colors.white,
            selectedItemColor: Colors.blueAccent,
            unselectedItemColor: Colors.black,
            currentIndex: currentIndex.value,
            onTap: (int index) {
              currentIndex.value = index;
            },
            items: [
              BottomNavigationBarItem(
                icon: Image.asset(
                  'assets/icons/ic_main.png',
                  width: 24,
                  height: 24,
                ),
                label: 'Groups'.tr.capitalizeFirst,
              ),

              BottomNavigationBarItem(
                icon:Image.asset(
                  'assets/icons/ic_students.png',
                  width: 24,
                  height: 24,
                ),
                label: 'Students'.tr.capitalizeFirst,
              ),
              BottomNavigationBarItem(
                icon:Image.asset(
                  'assets/icons/ic_student.png',
                  width: 24,
                  height: 24,
                ),
                label: 'Teachers'.tr.capitalizeFirst,
              ),
              // BottomNavigationBarItem(
              //   icon: FaIcon(size: 18, FontAwesomeIcons.triangleExclamation),
              //   label: 'Debtors'.tr.capitalizeFirst,
              // ),
              BottomNavigationBarItem(
                icon: Image.asset(
                  'assets/icons/ic_statistics.png',
                  width: 24,
                  height: 24,
                ),
                label: 'Statistics'.tr.capitalizeFirst,
              ),
              // BottomNavigationBarItem(
              //   icon: Icon(Icons.groups),
              //   label: 'Groups'.tr.capitalizeFirst,
              // ),
            ],
          ):BottomNavigationBar(

            backgroundColor: Colors.white,
            selectedItemColor: Colors.blueAccent,
            unselectedItemColor: Colors.black,
            currentIndex: currentIndex.value,
            onTap: (int index) {
              currentIndex.value = index;
            },
            items: [
              BottomNavigationBarItem(
                icon: FaIcon(size: 18, FontAwesomeIcons.rocket),
                label: 'Groups'.tr.capitalizeFirst,
              ),

              BottomNavigationBarItem(
                icon: FaIcon(size: 18, FontAwesomeIcons.peopleGroup),
                label: 'Students'.tr.capitalizeFirst,
              ),


              // BottomNavigationBarItem(
              //   icon: Icon(Icons.groups),
              //   label: 'Groups'.tr.capitalizeFirst,
              // ),
            ],
          ),
        ));
  }
}
