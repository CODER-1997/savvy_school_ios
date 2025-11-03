import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get_storage/get_storage.dart';
import 'package:permission_handler/permission_handler.dart';
 import '../../../constants/custom_widgets/FormFieldDecorator.dart';
import '../../../constants/custom_widgets/gradient_button.dart';
import '../../../constants/text_styles.dart';
import '../../../constants/utils.dart';
import '../../../controllers/students/student_controller.dart';
 import '../../../services/sms_service.dart';
import '../../admin/students/student_info.dart';
import 'attendance_widgets/student_attendance_card_widget.dart';

class Attendance extends StatelessWidget {
  final String groupId;
  final String groupName;

  Attendance({
    required this.groupId,
    required this.groupName,
  });

  GetStorage box = GetStorage();

  RxList students = [].obs;
  RxList selectedStudents = [].obs;
  static RxBool messageLoader = false.obs;
  RxBool messageLoader2 = false.obs;
  RxBool messageLoader3 = false.obs;
  TextEditingController customMessage = TextEditingController();
  RxBool isStudentChoosen = false.obs;
  StudentController studentController = Get.put(StudentController());
  final _formKey = GlobalKey<FormState>();
  RxList studentList = [].obs;
  SMSService _smsService = SMSService();

  RxList list = [].obs;
  RxList attendedStudents = [].obs;
  RxList unattendedStudents = [].obs;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xffe8e8e8),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Container(
            //   width: Get.width-32,
            //   padding: const EdgeInsets.symmetric(horizontal: 32,vertical: 8),
            //   decoration: BoxDecoration(
            //     color: Colors.white,
            //     borderRadius: BorderRadius.circular(4)
            //   ),
            //   child: Text(widget.lessonType.capitalizeFirst! + " Lesson",style: appBarStyle,),
            // ),
            // Form(
            //   key: _formKey,
            //   child: TextField(
            //     decoration: InputDecoration(
            //       labelText: 'Search Items',
            //       border: OutlineInputBorder(),
            //     ),
            //     onChanged: (value) {
            //       setState(() {
            //         _searchText = value.toLowerCase();
            //       });
            //     },
            //   ),
            // ),
            // SizedBox(height: 20),
            StreamBuilder(
                stream: FirebaseFirestore.instance
                    .collection('MarkazStudents')
                    .where('items.isDeleted', isEqualTo: false)
                    .where('items.groupId', isEqualTo: groupId)
                    .snapshots(),
                builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator());
                  }
                  if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  }
                  if (snapshot.hasData) {
                    var list = snapshot.data!.docs;

                    students.clear();
                    for (int i = 0; i < list.length; i++) {


                      students.add({
                        'name': list[i]['items']['name'],
                        'id': list[i].id,
                        'surname': list[i]['items']['surname'],
                        'payments': list[i]['items']['payments'],
                        'studyDays': list[i]['items']['studyDays'],
                        'uniqueId': list[i]['items']['uniqueId'],
                        'phone': list[i]['items']['phone'],
                        'isFreeOfcharge': list[i]['items']['isFreeOfcharge'],
                      });
                    }
                    students.sort((a, b) => a['surname'].compareTo(b['surname']));



                    return students.length != 0
                        ? Obx(() => Column(
                              children: [
                                isStudentChoosen.value
                                    ? Container(
                                        padding: EdgeInsets.all(16),
                                        width: Get.width,
                                        decoration:
                                            BoxDecoration(color: Colors.green),
                                        child: Row(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.center,
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text(
                                              '${selectedStudents.length} student(s) selected',
                                              style: TextStyle(
                                                  color: Colors.white),
                                            ),
                                            Row(
                                              children: [
                                                SizedBox(
                                                  height: 22,
                                                  child: IconButton(
                                                      padding: EdgeInsets.zero,
                                                      onPressed: () {
                                                        isStudentChoosen.value =
                                                            false;
                                                        selectedStudents
                                                            .clear();
                                                      },
                                                      icon: Icon(
                                                        Icons.close,
                                                        color: Colors.white,
                                                      )),
                                                ),
                                                SizedBox(
                                                  height: 22,
                                                  child: IconButton(
                                                      padding: EdgeInsets.zero,
                                                      onPressed: () {
                                                        if (selectedStudents
                                                                .length ==
                                                            students.length) {
                                                          selectedStudents
                                                              .clear();
                                                        } else {
                                                          selectedStudents
                                                              .clear();
                                                          selectedStudents
                                                              .addAll(students);
                                                        }
                                                      },
                                                      icon: Icon(
                                                        Icons.select_all,
                                                        color: Colors.white,
                                                      )),
                                                )
                                              ],
                                            )
                                          ],
                                        ),
                                      )
                                    : SizedBox(),
                                for (int i = 0; i < students.length; i++)
                                  Container(
                                    key: ValueKey(students[i]['id']),
                                    child: GestureDetector(
                                      onLongPress: () {
                                        isStudentChoosen.value = true;
                                      },
                                      onTap: () {
                                        if (
                                            isStudentChoosen.value == false) {
                                          Get.to(StudentInfo(
                                            studentId: students[i]['id'],
                                          ));
                                        }
                                        if (isStudentChoosen.value == true) {
                                          print('Working....');
                                          if (selectedStudents
                                              .contains(students[i])) {
                                            selectedStudents.removeWhere(
                                                (el) => el == students[i]);
                                          } else {
                                            selectedStudents.add(students[i]);
                                          }
                                        }
                                      },
                                      child: StudentAttendanceCardWidget(isStudentChoosen: isStudentChoosen, student: students[i], studentController: studentController, groupId: groupId, selectedStudents: selectedStudents, index: i,)
                                    ),
                                  )
                              ],
                            ))
                        : Container(
                            alignment: Alignment.center,
                            height: Get.height * .8,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Image.asset(
                                  'assets/empty.png',
                                  width: 150,
                                ),
                                Text(
                                  'This group has not any students ',
                                  style: TextStyle(
                                      color: Colors.black, fontSize: 16),
                                ),
                                SizedBox(
                                  height: 16,
                                ),
                              ],
                            ),
                          );
                  }
                  // If no data available

                  else {
                    return Text('No data'); // No data available
                  }
                }),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        height: 66,
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            children: [
              Expanded(
                  child: InkWell(
                onTap: () async {
                  if (selectedStudents.isEmpty) {
                    Get.snackbar(
                      'Xatolik', // Title
                      'Talabalar tanlanmagan', // Message
                      snackPosition: SnackPosition.TOP,
                      // Position of the snackbar
                      backgroundColor: Colors.red,
                      colorText: Colors.white,
                      borderRadius: 8,
                      margin: EdgeInsets.all(10),
                    );
                  } else {
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return Dialog(
                          backgroundColor: Colors.white,
                          insetPadding: EdgeInsets.symmetric(horizontal: 16),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12.0)),
                          //this right here
                          child: Container(
                            padding: EdgeInsets.all(16),
                            decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(12)),
                            width: Get.width,
                            height: 180,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    SizedBox(
                                      height: 16,
                                    ),
                                    Text(
                                      'Rostdanham yuborilsinmi ?',
                                      style: appBarStyle.copyWith(),
                                      textAlign: TextAlign.center,
                                    ),
                                    SizedBox(
                                      height: 16,
                                    ),
                                  ],
                                ),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceEvenly,
                                  children: [
                                    TextButton(
                                      onPressed: () async {
                                        Get.back();
                                        messageLoader.value = true;
    for (int i = 0;  i < selectedStudents.length;  i++) {


     if (checkStatus(   selectedStudents[i]  ['studyDays'],   studentController  .selectedStudyDate   .value) ==
                                              '2') {
                                            if (await Permission
                                                    .sms.isGranted &&
                                                selectedStudents[i]['phone']
                                                    .toString()
                                                    .isNotEmpty) {
                                              _smsService.sendSMS(
                                                  selectedStudents[i]['phone'],
                                                  "Assalomu Aleykum ,"
                                                  "\nFarzandingiz ${selectedStudents[i]['surname'].toString().capitalizeFirst}  ${selectedStudents[i]['name'].toString().capitalizeFirst!}  bugungi  darsga keldi. "
                                                   );
                                            }
                                          }

    else if (checkStatus( selectedStudents[i] ['studyDays'], studentController .selectedStudyDate .value) == '-1') {
         if (await Permission .sms.isGranted &&selectedStudents[i]['phone'].toString()  .isNotEmpty) {


                  _smsService.sendSMS(  selectedStudents[i]['phone'],

                                                  "Assalomu Aleykum ,"
                                                  "\nFarzandingiz ${selectedStudents[i]['surname'].toString().capitalizeFirst!}  ${selectedStudents[i]['name'].toString().capitalizeFirst!}  bugungi   darsga kelmadi. "
                                                   );
                                            }
                                          }
    else if (checkStatus( selectedStudents[i] ['studyDays'], studentController .selectedStudyDate .value) == '1') {
         if (await Permission .sms.isGranted &&selectedStudents[i]['phone'].toString()  .isNotEmpty) {


                  _smsService.sendSMS(  selectedStudents[i]['phone'],

                                                  "Assalomu Aleykum ,"
                                                  "\nFarzandingiz ${selectedStudents[i]['surname'].toString().capitalizeFirst!}  ${selectedStudents[i]['name'].toString().capitalizeFirst!} bugungi darsga kech keldi. "
                                                   );
                                            }
                                          }






    else {
                                            print('Sms yuborilmadi');
                                          }
                                          await Future.delayed(
                                              Duration(seconds: 1));
                                        }

                                        messageLoader.value = false;
                                        selectedStudents.clear();
                                        isStudentChoosen.value = false;

                                        Get.snackbar(
                                          'Xabar', // Title
                                          'Xabar yuborildi',
                                          // Message
                                          snackPosition: SnackPosition.BOTTOM,
                                          // Position of the snackbar
                                          backgroundColor: Colors.green,
                                          colorText: Colors.white,
                                          borderRadius: 8,
                                          margin: EdgeInsets.all(10),
                                        );
                                      },
                                      child: Text(
                                        'Tasdiqlash'.tr.capitalizeFirst!,
                                        style: appBarStyle.copyWith(
                                            color: Colors.green),
                                      ),
                                    ),
                                    TextButton(
                                        onPressed: Get.back,
                                        child: Text(
                                          'Bekor',
                                          style: appBarStyle.copyWith(
                                              color: Colors.red),
                                        )),
                                  ],
                                )
                              ],
                            ),
                          ),
                        );
                      },
                    );
                  }
                },
                child: Obx(() => CustomButton(
                      color: Colors.green,
                      text: messageLoader.value
                          ? "Sending ..."
                          : 'Davomat'.tr.capitalizeFirst!,
                    )),
              )),
              box.read('isLogged') == 'Savvy' || box.read('isLogged') == '1105'
                  ? Expanded(
                      child: InkWell(
                      onTap: () async {
                        if (selectedStudents.isEmpty) {
                          Get.snackbar(
                            'Xatolik', // Title
                            'Talabalar tanlanmagan', // Message
                            snackPosition: SnackPosition.TOP,
                            // Position of the snackbar
                            backgroundColor: Colors.red,
                            colorText: Colors.white,
                            borderRadius: 8,
                            margin: EdgeInsets.all(10),
                          );
                        } else {
                          showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return Dialog(
                                backgroundColor: Colors.white,
                                insetPadding:
                                    EdgeInsets.symmetric(horizontal: 16),
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12.0)),
                                //this right here
                                child: Container(
                                  padding: EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(12)),
                                  width: Get.width,
                                  height: 180,
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                        children: [
                                          SizedBox(
                                            height: 16,
                                          ),
                                          Text(
                                            'Rostdanham yuborilsinmi ?',
                                            style: appBarStyle.copyWith(),
                                            textAlign: TextAlign.center,
                                          ),
                                          SizedBox(
                                            height: 16,
                                          ),
                                        ],
                                      ),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceEvenly,
                                        children: [
                                          TextButton(
                                            onPressed: () async {
                                              Get.back();
                                              messageLoader2.value = true;

                                              for (int i = 0;
                                                  i < selectedStudents.length;
                                                  i++) {
                                                if (selectedStudents[i][
                                                            'isFreeOfcharge'] ==
                                                        false &&
                                                    hasDebtFromMonth(
                                                        selectedStudents[i]
                                                            ['payments'],
                                                        convertDateToMonthYear(
                                                            studentController
                                                                .selectedStudyDate
                                                                .value))) {
                                                  if (await Permission
                                                          .sms.isGranted &&
                                                      selectedStudents[i]
                                                              ['phone']
                                                          .toString()
                                                          .isNotEmpty) {
                                                    _smsService.sendSMS(
                                                        selectedStudents[i]
                                                            ['phone'],
                                                        "Hurmatli ota-ona, "
                                                        "\nFarzandingiz ${selectedStudents[i]['surname'].toString().capitalizeFirst} ${selectedStudents[i]['name'].toString().capitalizeFirst!}ning ${getCurrentMonthInUzbek()} oylari uchun to'lovi oyning 5-sanasiga qadar to'lanishi kerak.");

                                                    _smsService.sendSMS(
                                                        selectedStudents[i]
                                                            ['phone'],
                                                        " Iltimos, to'lovni belgilangan muddatda amalga oshirishingizni so'raymiz.\nHurmat bilan Savvy School");
                                                  }
                                                }
                                              }

                                              messageLoader2.value = false;
                                              selectedStudents.clear();
                                              isStudentChoosen.value = false;

                                              Get.snackbar(
                                                'Message', // Title
                                                'Your message has been sent',
                                                // Message
                                                snackPosition:
                                                    SnackPosition.BOTTOM,
                                                // Position of the snackbar
                                                backgroundColor: Colors.green,
                                                colorText: Colors.white,
                                                borderRadius: 8,
                                                margin: EdgeInsets.all(10),
                                              );
                                            },
                                            child: Text(
                                              'Tasdiqlash'.tr.capitalizeFirst!,
                                              style: appBarStyle.copyWith(
                                                  color: Colors.green),
                                            ),
                                          ),
                                          TextButton(
                                              onPressed: Get.back,
                                              child: Text(
                                                'Bekor',
                                                style: appBarStyle.copyWith(
                                                    color: Colors.red),
                                              )),
                                        ],
                                      )
                                    ],
                                  ),
                                ),
                              );
                            },
                          );
                        }
                      },
                      child: Obx(() => Container(
                            margin: EdgeInsets.only(left: 4),
                            child: CustomButton(
                              color: Colors.red,
                              text: messageLoader2.value
                                  ? "Sending..."
                                  : 'Payment',
                            ),
                          )),
                    ))
                  : SizedBox(),
              box.read('isLogged') == 'Savvy'
                  ? Expanded(
                      child: InkWell(
                      onTap: () async {
                        if (selectedStudents.isEmpty) {
                          Get.snackbar(
                            'Error', // Title
                            'Students are not selected', // Message
                            snackPosition: SnackPosition.TOP,
                            // Position of the snackbar
                            backgroundColor: Colors.red,
                            colorText: Colors.white,
                            borderRadius: 8,
                            margin: EdgeInsets.all(10),
                          );
                        } else {
                          showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return Dialog(
                                backgroundColor: Colors.white,
                                insetPadding:
                                    EdgeInsets.symmetric(horizontal: 16),
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12.0)),
                                //this right here
                                child: Form(
                                  key: _formKey,
                                  child: Container(
                                    padding: EdgeInsets.all(16),
                                    decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius:
                                            BorderRadius.circular(12)),
                                    width: Get.width,
                                    height: Get.height / 2.5,
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Column(
                                          children: [
                                            SizedBox(
                                              height: 16,
                                            ),
                                            TextFormField(
                                              maxLines: 5,
                                              controller: customMessage,
                                              maxLength: 80,
                                              keyboardType: TextInputType.text,
                                              decoration: buildInputDecoratione(
                                                  'Your message here'
                                                          .tr
                                                          .capitalizeFirst! ??
                                                      ''),
                                            ),
                                            SizedBox(
                                              height: 16,
                                            ),
                                          ],
                                        ),
                                        InkWell(
                                          onTap: () async {
                                            messageLoader3.value = true;
                                            if (customMessage.text.isNotEmpty) {
                                              for (int i = 0;
                                                  i < selectedStudents.length;
                                                  i++) {
                                                if (await Permission
                                                        .sms.isGranted &&
                                                    selectedStudents[i]['phone']
                                                        .toString()
                                                        .isNotEmpty) {
                                                  _smsService.sendSMS(
                                                      selectedStudents[i]
                                                          ['phone'],
                                                      customMessage.text +
                                                          "");
                                                }

                                                await Future.delayed(
                                                    Duration(seconds: 1));
                                              }
                                              messageLoader3.value = false;
                                              customMessage.clear();
                                              selectedStudents.clear();
                                              isStudentChoosen.value = false;

                                              Get.back();

                                              Get.snackbar(
                                                'Xabar', // Title
                                                'Xabar yuborildi',
                                                // Message
                                                snackPosition:
                                                    SnackPosition.BOTTOM,
                                                // Position of the snackbar
                                                backgroundColor: Colors.blue,
                                                colorText: Colors.white,
                                                borderRadius: 8,
                                                margin: EdgeInsets.all(10),
                                              );
                                            } else {
                                              Get.back();
                                            }
                                          },
                                          child: Obx(() => CustomButton(
                                              isLoading: studentController
                                                  .isLoading.value,
                                              text: messageLoader3.value
                                                  ? "Sending. . ."
                                                  : "Send"
                                                      .tr
                                                      .capitalizeFirst!)),
                                        )
                                      ],
                                    ),
                                  ),
                                ),
                              );
                            },
                          );
                        }
                      },
                      child: Container(
                        margin: EdgeInsets.only(left: 4),
                        child: CustomButton(
                          color: Colors.blue,
                          text: 'Ogohlantirish',
                        ),
                      ),
                    ))
                  : SizedBox(),
            ],
          ),
        ),
      ),
    );
  }
}
