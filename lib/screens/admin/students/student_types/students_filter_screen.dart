import 'package:savvy_school_ios/constants/utils.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:savvy_school_ios/constants/custom_widgets/student_card.dart';
import 'package:savvy_school_ios/controllers/students/student_controller.dart';
import 'package:savvy_school_ios/screens/admin/students/student_info.dart';
import 'package:grouped_list/grouped_list.dart';
import 'package:intl/intl.dart';

import '../../../../constants/custom_widgets/emptiness.dart';
import '../../../../constants/custom_widgets/gradient_button.dart';
import '../../../../constants/text_styles.dart';
import '../../../../constants/theme.dart';

class StudentFilterScreen extends StatefulWidget {
  final List students;

  final RxList paidStudents;

  final List groups;

  StudentFilterScreen(
      {required this.students,
      required this.groups,
      required this.paidStudents});

  @override
  State<StudentFilterScreen> createState() => _StudentFilterScreenState();
}

class _StudentFilterScreenState extends State<StudentFilterScreen>
 {
  String getPaidDate(List list) {
    String result = "";

    for (var item in list) {
      print("List $item");

      if (isDateInCurrentMonth(item['paidDate'])) {
        result = item['paidDate'];
        break;
      }
    }

    return result;
  }

  late TabController _tabController;

  StudentController studentController = Get.put(StudentController());

  RxString from = ''.obs;
  RxString to = ''.obs;

  RxList _students = [].obs;
  RxList _selectedGroups = [].obs;

  RxList paymentChecks = [].obs;

  RxBool isFiltered = false.obs;
  RxBool isGroupSelected = false.obs;

  
  _openBottomSheet() {
    
    showModalBottomSheet(
      context: context,
      isScrollControlled: true, // makes sheet taller
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                "Sanani tanlang",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Obx(
                    () => Text('Dan:  ${from.value}'),
                  ),
                  IconButton(
                      onPressed: () {
                        studentController.showDate(from);
                      },
                      icon: Icon(Icons.calendar_month)),
                  Expanded(child: Container()),
                  Obx(
                    () => Text('Dan:  ${to.value}'),
                  ),
                  IconButton(
                      onPressed: () {
                        studentController.showDate(to);
                      },
                      icon: Icon(Icons.calendar_month))
                ],
              ),

              // Bottom button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(111)),
                  ),
                  onPressed: () {
                    final format = DateFormat("dd-MM-yyyy");

                    DateTime d1 = format.parse(from.value);
                    DateTime d2 = format.parse(to.value);

                    if (d2.isBefore(d1)) {
                      Get.snackbar(
                        "Xatolik", // title
                        "Sanalar nomunosib tanlandi", // message
                        snackPosition: SnackPosition.TOP,
                        // TOP or BOTTOM
                        backgroundColor: Colors.red.withOpacity(0.8),
                        colorText: Colors.white,
                        borderRadius: 12,
                        margin: EdgeInsets.all(12),
                        duration: Duration(seconds: 2),
                        icon: Icon(Icons.error_outline, color: Colors.white),
                      );
                    } else if (d1.isBefore(d2)) {
                      _students.addAll(widget.paidStudents);
                      List list = [];



                      for(var item in widget.paidStudents){
                         var payments = item['items']['payments'];
                        for(var payment in payments){
                          if(format.parse(payment['paidDate']).isAfter( d1.subtract(const Duration(days: 1))) &&
                              format.parse( payment['paidDate']).isBefore(d2.add(const Duration(days: 1)))){
                            paymentChecks.add(payment);

                            list.add(item);

                          }
                        }
                      }








                      widget.paidStudents.clear();
                      widget.paidStudents.addAll(list);

                      Navigator.pop(context);
                      isFiltered.value = true;
                    }
                  },
                  child: const Text(
                    "Tasdiqlash",
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
  String calculateTotalPayments(String groupId) {
    int value = 0;
    final format = NumberFormat("#,###", "en_US");

    for (int i = 0; i < widget.paidStudents.length; i++) {
       if(widget.paidStudents[i]['items']['groupId'] == groupId){
         var paidMonths = widget.paidStudents[i]['items']['payments'];
         for (int j = 0; j < paidMonths.length; j++) {
           if (currentMonth(paidMonths[j]['paidDate'].toString()) ) {
             value += int.parse(paidMonths[j]['paidSum']);
             if (int.parse(paidMonths[j]['paidSum']) != 0) {}
           }
         }
       }
    }
    String formatted = format.format(value).replaceAll(",", " ");

    return formatted;
  }


  bool isDateInCurrentMonth(String dateString) {
    // Parse the input date string to a DateTime object
    DateTime inputDate =
        DateTime.parse(dateString.split('-').reversed.join('-'));

    // Get the current date
    DateTime currentDate = DateTime.now();

    // Return true if the year and month match, otherwise false
    return inputDate.year == currentDate.year &&
        inputDate.month == currentDate.month;
  }

  String getStudentCountByGroup(String groupId) {
    int val = 0;
    for (var item in widget.students) {
      if (item['items']['groupId'] == groupId) {
        val++;
      }
    }

    return "$val";
  }

  String getPaidStudentCountByGroup(String groupId) {
    int val = 0;
    for (var item in widget.paidStudents) {
      if (item['items']['groupId'] == groupId) {
        val++;
      }
    }

    return "$val";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Color(0xffe8e8e8),

        body: Padding(
          padding: const EdgeInsets.all(8.0),
          child:    Stack(
            alignment: Alignment.bottomRight,
            children: [
              Obx(()=>Expanded(
                child: widget.paidStudents.length != 0
                    ? GroupedListView(
                  sort: true,
                  elements: widget.paidStudents,
                  groupBy: (element) =>
                      getPaidDate(element['items']['payments']),
                  groupSeparatorBuilder: (String value) => Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      value,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  itemBuilder: (context, dynamic element) =>
                      GestureDetector(
                        onTap: () {
                          Get.to(StudentInfo(studentId: element.id));
                        },
                        child: StudentCard(
                          item: element['items'],
                          studentId: element.id,
                        ),
                      ),
                  floatingHeader: false,
                  // optional
                  order: GroupedListOrder.ASC, // optional
                )
                    : Emptiness(
                    title:
                    'Our center has not any free of charged student '),
              )),
              Obx(()=>Padding(
                padding: const EdgeInsets.all(8.0),
                child: FloatingActionButton(
                    backgroundColor: Colors.white,
                    child: isFiltered.value == false ? Icon(Icons.filter_list_alt):Icon(Icons.close),
                    onPressed: () {
                      if(isFiltered.value==false){

                        _openBottomSheet();

                      }
                      else {
                        isFiltered.value=false;
                        widget.paidStudents.clear();
                        for(var item in _students){
                          if(!widget.paidStudents.contains(item)){
                            widget.paidStudents.add(item);
                          }

                        }

                      }



                    }),
              ))
            ],
          ),
        ));
  }
}
