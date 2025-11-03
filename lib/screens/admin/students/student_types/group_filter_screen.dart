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
import 'package:savvy_school_ios/screens/admin/students/student_types/total_payment_screen.dart';
import 'package:intl/intl.dart';

import '../../../../constants/custom_widgets/emptiness.dart';
import '../../../../constants/custom_widgets/gradient_button.dart';
import '../../../../constants/text_styles.dart';
import '../../../../constants/theme.dart';

class GroupFilterScreen extends StatefulWidget {
  final List students;

  final RxList paidStudents;

  final List groups;

  GroupFilterScreen(
      {required this.students,
      required this.groups,
      required this.paidStudents});

  @override
  State<GroupFilterScreen> createState() => _GroupFilterScreenState();
}

class _GroupFilterScreenState extends State<GroupFilterScreen>
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
  List<String> generateDateStrings(String startDate, String endDate) {
    DateTime start = DateFormat("dd-MM-yyyy").parse(startDate);
    DateTime end = DateFormat("dd-MM-yyyy").parse(endDate);

    List<String> dates = [];
    for (var d = start; !d.isAfter(end); d = d.add(const Duration(days: 1))) {
      dates.add(DateFormat("dd-MM-yyyy").format(d));
    }
    return dates;
  }

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
              // From date
              Expanded(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Obx(() => Text('Dan: ${from.value}')),
                    IconButton(
                      icon: const Icon(Icons.calendar_month),
                      onPressed: () {
                        studentController.showDate(from);
                      },
                    ),
                  ],
                ),
              ),

              // To date
              Expanded(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Obx(() => Text('Gacha: ${to.value}')), // changed text for clarity
                    IconButton(
                      icon: const Icon(Icons.calendar_month),
                      onPressed: () {
                        studentController.showDate(to);
                      },
                    ),
                  ],
                ),
              ),
            ],
          ) ,


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
                      paymentChecks.clear();
                       
                    List dates =   generateDateStrings(from.value,to.value);

 


                      for(var item in widget.paidStudents){
                        if(_selectedGroups.contains(item['items']['groupId'])){
                          var payments = item['items']['payments'];
                          for(var payment in payments){
                            if(dates.contains(payment['paidDate']) ){

                              paymentChecks.add({

                                'paidDate':payment['paidDate'],
                                'paidSum':payment['paidSum'],
                                 'name':item['items']['name'],
                                 'surname':item['items']['surname'],
                                 'group':item['items']['group'],

                              });

                              list.add(item);

                            }
                          }
                        }
                      }









                      widget.paidStudents.clear();
                      widget.paidStudents.addAll(list);

                      Navigator.pop(context);
                      isFiltered.value = true;
                      print(paymentChecks);
                      Get.to(PaymentScreen(payments: paymentChecks,));

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
          child: widget.groups.length != 0
              ? Stack(
            alignment: Alignment.bottomRight,
            children: [
              Container(
                height: Get.height,
                child: ListView.builder(
                  itemCount: widget.groups.length,
                  itemBuilder: (context, dynamic index) =>
                      GestureDetector(
                        onTap: (){
                          if(isGroupSelected.value){
                            if(_selectedGroups.contains(widget.groups[index]['group_id']) == false){
                              _selectedGroups.add(widget.groups[index]['group_id']);

                            }else {
                              _selectedGroups.removeWhere((el)=>el==widget.groups[index]['group_id']);
                            }
                            print(_selectedGroups);
                          }
                        },
                        onLongPress: () {
                          isGroupSelected.value = true;
                        },
                        child: Obx(()=>Container(
                          margin: EdgeInsets.only(bottom: 8),
                          decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12)),
                          child: ListTile(
                            subtitle: Row(
                              children: [
                                Container(
                                  padding: EdgeInsets.symmetric(horizontal: 18,vertical: 8),
                                  decoration: BoxDecoration(
                                      color:calculateTotalPayments(widget.groups[index]['group_id']) !="0"? greenColor:Colors.red,
                                      borderRadius: BorderRadius.circular(122)
                                  ),
                                  child: calculateTotalPayments(widget.groups[index]['group_id']) !="0"?Text('${calculateTotalPayments(widget.groups[index]['group_id'])}' +  " so'm",style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w900,
                                      fontSize: 12
                                  ),):Text("To'lovlar mavjud emas",style: TextStyle(color: Colors.white,fontSize: 8),),
                                ),
                                Expanded(child: Container())
                              ],
                            ),

                            trailing:isGroupSelected.value==false   ? Text(
                                "${getPaidStudentCountByGroup(widget.groups[index]['group_id'])}" +
                                    "/${getStudentCountByGroup(widget.groups[index]['group_id'])}"):(
                                _selectedGroups.contains(widget.groups[index]['group_id'])  == false? Icon(Icons.circle_outlined,):
                                Icon(Icons.check_circle_rounded,color: Colors.green,)
                            ),
                            title: Text(widget.groups[index]['group_name'],style: TextStyle(
                                fontSize: 14
                            ),),
                          ),
                        )),
                      ),
                ),
              ),
              Obx(()=>

                 isGroupSelected.value ? Padding(
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
                        isGroupSelected.value=false;

                      }



                    }),
              ):SizedBox())
            ],
          )
              : Emptiness(title: 'Our center has not any  student '),
        ));
  }
}
