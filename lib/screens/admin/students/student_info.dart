import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';
import 'package:savvy_school_ios/screens/admin/students/student_payment_history.dart';
import 'package:savvy_school_ios/screens/admin/students/unpaid_months.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../constants/custom_widgets/FormFieldDecorator.dart';
import '../../../constants/custom_widgets/custom_dialog.dart';
import '../../../constants/custom_widgets/gradient_button.dart';
import '../../../constants/text_styles.dart';
import '../../../constants/theme.dart';
import '../../../constants/utils.dart';
import '../../../controllers/students/student_controller.dart';
import '../statistics/calendar_view.dart';

class StudentInfo extends StatelessWidget {
  final String studentId;
  final _formKey = GlobalKey<FormState>();

  StudentController studentController = Get.put(StudentController());

  StudentInfo({required this.studentId});




  void launchPhoneNumber(String phoneNumber) async {
    print(phoneNumber.toString() + "AAA");
    final Uri url = Uri(scheme: 'tel', path: phoneNumber);
    if (await canLaunchUrl(url)) {
      await launchUrl(url);
    } else if(phoneNumber == 'null') {
      Get.snackbar(
        'Error',           // Title
        'Wrong phone number',  // Message
        snackPosition: SnackPosition.TOP,  // Or SnackPosition.TOP
        backgroundColor: Colors.red.withOpacity(0.7),
        colorText: Colors.white,
      );

    }
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: homePagebg,
      appBar: AppBar(
        backgroundColor: dashBoardColor,
        leading: IconButton(
          onPressed: Get.back,
          icon: Icon(
            Icons.arrow_back,
            color: Colors.white,
          ),
        ),
        automaticallyImplyLeading: true,
        title: Text(
          "Talaba Profili",
          style: appBarStyle.copyWith(color: Colors.white),
        ),
      ),
      body: StreamBuilder<DocumentSnapshot>(
        stream: getDocumentStreamById('MarkazStudents', studentId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Text('Error: ${snapshot.error}');
          } else if (!snapshot.hasData || !snapshot.data!.exists) {
            return Text('Document not found');
          } else {
            // Access the document data
            Map<String, dynamic> data =
            snapshot.data!.data() as Map<String, dynamic>;
            studentController.isFreeOfCharge.value =
                data['items']['isFreeOfcharge'] ?? false;
            return Column(
              children: [
                Container(
                  color: Colors.white,
                  child: ListTile(
                    trailing: IconButton(
                      icon: const Icon(Icons.edit),
                      onPressed: () {
                        studentController.fetchGroups();
                        studentController.selectedGroupId.value = data['items']['groupId'];

                        studentController.setValues(
                          data['items']['name'],
                          data['items']['surname'],
                          data['items']['phone'],
                          data['items']['parentPhone'] ?? '',
                        );

                        showModalBottomSheet(
                          context: context,
                          isScrollControlled: true, // ⬅️ allows full height & keyboard push
                          backgroundColor: Colors.transparent,
                          builder: (ctx) {
                            return Padding(
                              padding: EdgeInsets.only(
                                bottom: MediaQuery.of(ctx).viewInsets.bottom,
                              ),
                              child: Container(
                                height: Get.height * 0.8,
                                width: double.infinity,
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius:
                                  const BorderRadius.vertical(top: Radius.circular(12)),
                                ),
                                child: Form(
                                  key: _formKey,
                                  child: SingleChildScrollView(
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Column(
                                          children: [
                                            const Text("Edit student info"),
                                            const SizedBox(height: 16),

                                            // ✅ all your fields remain unchanged
                                            SizedBox(
                                              child: TextFormField(
                                                decoration: buildInputDecoratione('Ismi'),
                                                controller: studentController.nameEdit,
                                                keyboardType: TextInputType.text,
                                                validator: (value) {
                                                  if (value!.isEmpty) {
                                                    return "Maydonlar bo'sh bo'lmasligi kerak";
                                                  }
                                                  return null;
                                                },
                                              ),
                                            ),
                                            const SizedBox(height: 16),

                                            SizedBox(
                                              child: TextFormField(
                                                controller: studentController.surnameEdit,
                                                keyboardType: TextInputType.text,
                                                validator: (value) {
                                                  if (value!.isEmpty) {
                                                    return "Maydonlar bo'sh bo'lmasligi kerak";
                                                  }
                                                  return null;
                                                },
                                                decoration: buildInputDecoratione(
                                                  'familiyasi'.tr.capitalizeFirst! ?? '',
                                                ),
                                              ),
                                            ),
                                            const SizedBox(height: 16),

                                            SizedBox(
                                              child: TextFormField(
                                                keyboardType: TextInputType.phone,
                                                inputFormatters: [
                                                  MaskTextInputFormatter(
                                                    mask: '+998 ## ### ## ##',
                                                    filter: {"#": RegExp(r'[0-9]')},
                                                    type: MaskAutoCompletionType.lazy,
                                                  )
                                                ],
                                                controller: studentController.phoneEdit,
                                                decoration: buildInputDecoratione(
                                                  'Phone'.tr.capitalizeFirst! ?? '',
                                                ),
                                              ),
                                            ),
                                            const SizedBox(height: 16),

                                            SizedBox(
                                              child: TextFormField(
                                                keyboardType: TextInputType.phone,
                                                inputFormatters: [
                                                  MaskTextInputFormatter(
                                                    mask: '+998 ## ### ## ##',
                                                    filter: {"#": RegExp(r'[0-9]')},
                                                    type: MaskAutoCompletionType.lazy,
                                                  )
                                                ],
                                                controller: studentController.parentPhoneEdit,
                                                decoration: buildInputDecoratione(
                                                  'Parents phone'.tr.capitalizeFirst! ?? '',
                                                ),
                                              ),
                                            ),
                                            const SizedBox(height: 16),

                                            Row(
                                              children: [
                                                Obx(() => Text(
                                                    'Started date:  ${studentController.paidDate.value}')),
                                                IconButton(
                                                  onPressed: () => studentController.showDate(
                                                      studentController.paidDate),
                                                  icon: const Icon(Icons.calendar_month),
                                                )
                                              ],
                                            ),
                                            const SizedBox(height: 16),

                                            Row(
                                              mainAxisAlignment: MainAxisAlignment.start,
                                              children: [
                                                Text('Choose Group', style: appBarStyle),
                                              ],
                                            ),
                                            const SizedBox(height: 16),

                                            Obx(
                                                  () => Container(
                                                alignment: Alignment.topLeft,
                                                child: SingleChildScrollView(
                                                  scrollDirection: Axis.horizontal,
                                                  child: Row(
                                                    children: [
                                                      for (int i = 0;
                                                      i <
                                                          studentController.MarkazGroups.length;
                                                      i++)
                                                        GestureDetector(
                                                          onTap: () {
                                                            studentController.selectedGroup.value =
                                                            studentController.MarkazGroups[i]
                                                            ['group_name'];
                                                            studentController.selectedGroupId.value =
                                                            studentController.MarkazGroups[i]
                                                            ['group_id'];
                                                          },
                                                          child: Container(
                                                            padding: const EdgeInsets.symmetric(
                                                                horizontal: 18, vertical: 8),
                                                            margin: const EdgeInsets.all(8),
                                                            decoration: studentController
                                                                .selectedGroupId.value !=
                                                                studentController.MarkazGroups[i]
                                                                ['group_id']
                                                                ? BoxDecoration(
                                                              borderRadius:
                                                              BorderRadius.circular(112),
                                                              border: Border.all(
                                                                  color: Colors.black,
                                                                  width: 1),
                                                            )
                                                                : BoxDecoration(
                                                              color: Colors.green,
                                                              borderRadius:
                                                              BorderRadius.circular(112),
                                                              border: Border.all(
                                                                  color: Colors.green,
                                                                  width: 1),
                                                            ),
                                                            child: Text(
                                                              "${studentController.MarkazGroups[i]['group_name']}",
                                                              style: TextStyle(
                                                                color: studentController
                                                                    .selectedGroupId
                                                                    .value !=
                                                                    studentController
                                                                        .MarkazGroups[i]
                                                                    ['group_id']
                                                                    ? Colors.black
                                                                    : CupertinoColors.white,
                                                              ),
                                                            ),
                                                          ),
                                                        )
                                                    ],
                                                  ),
                                                ),
                                              ),
                                            ),

                                            Row(
                                              mainAxisAlignment: MainAxisAlignment.start,
                                              children: [
                                                Obx(
                                                      () => InkWell(
                                                    onTap: () {
                                                      studentController.isFreeOfCharge.value =
                                                      !studentController.isFreeOfCharge.value;
                                                    },
                                                    child: Container(
                                                      padding: const EdgeInsets.symmetric(
                                                          horizontal: 18, vertical: 8),
                                                      margin: const EdgeInsets.all(8),
                                                      decoration: BoxDecoration(
                                                        color:
                                                        studentController.isFreeOfCharge.value
                                                            ? Colors.green
                                                            : Colors.white,
                                                        borderRadius: BorderRadius.circular(112),
                                                        border: Border.all(
                                                            color: Colors.green, width: 1),
                                                      ),
                                                      child: Text(
                                                        "is free of charge",
                                                        style: TextStyle(
                                                          color: studentController
                                                              .isFreeOfCharge.value
                                                              ? Colors.white
                                                              : Colors.black,
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),

                                        InkWell(
                                          onTap: () {
                                            if (_formKey.currentState!.validate()) {
                                              studentController.editStudent(studentId);
                                              Navigator.pop(ctx);
                                            }
                                          },
                                          child: Obx(() => CustomButton(
                                            isLoading: studentController.isLoading.value,
                                            text: "Edit".tr.capitalizeFirst!,
                                          )),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            );
                          },
                        );
                      },
                    ),

                      contentPadding: EdgeInsets.all(8),
                    leading: Image.asset(
                      'assets/student_avatar.png',
                      width: 64,
                    ),
                    subtitle: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text("Id: ${data['items']['uniqueId']}"),
                        SizedBox(width: 6,),

                        data['items']['grade'].toString().isNotEmpty ?    Container(
                          padding: EdgeInsets.symmetric(horizontal: 6,vertical: 4),
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12),
                              color: Colors.orange.withOpacity(.5),
                              border: Border.all(
                                  color: Colors.orange,
                                  width: 1.5
                              )
                          ),
                          child: Text('${data['items']['grade'] == null
                              ?"student":data['items']['grade']}',style: TextStyle(color: Colors.deepOrange,fontSize: 10,fontWeight: FontWeight.w700),),
                        ):SizedBox()

                      ],
                    ),


                    title: Row(
                      children: [
                        Text(
                          "${data['items']['name']}".capitalizeFirst! +
                              " " +
                              "${data['items']['surname']}".capitalizeFirst!,
                          style: TextStyle(
                              color: Colors.black, fontWeight: FontWeight.w700,fontSize:12),
                        ),

                      ],
                    ),
                  ),
                ),
                SizedBox(
                  height: 2,
                ),
                InkWell(
                  onTap: () {
                    if (data['items']['isFreeOfcharge'] == false) {
                      Get.to(AdminStudentPaymentHistory(
                        uniqueId: '${data['items']['uniqueId']}',
                        id: studentId,
                        name: data['items']['name'],
                        surname: data['items']['surname'], paidMonths: data['items']['payments'],
                      ));
                    }
                  },
                  child: Container(
                    color: Colors.white,
                    child: ListTile(
                      contentPadding: EdgeInsets.all(8),
                      leading: Image.asset(
                        'assets/gold_bill.png',
                        width: 64,
                      ),
                      title: Text(
                        data['items']['isFreeOfcharge'] == false
                            ? "To'ovlar tarixi".capitalizeFirst!
                            : "To'lovdan ozod",
                        style: TextStyle(
                            color: Colors.black, fontWeight: FontWeight.w700),
                      ),
                    ),
                  ),
                ),
                SizedBox(
                  height: 2,
                ),
                calculateUnpaidMonths(data['items']['studyDays'],
                    data['items']['payments'])
                    .length !=
                    0
                    ? InkWell(
                  onTap: () {
                    Get.to(UnpaidMonths(
                      months: calculateUnpaidMonths(
                          data['items']['studyDays'],
                          data['items']['payments']),
                      studentPhone: data['items']['phone'],
                      studentName: data['items']['name'], studentSurname: data['items']['surname'],
                    ));
                  },
                  child: Container(
                    color: Colors.white,
                    child: ListTile(
                      contentPadding: EdgeInsets.all(8),
                      leading: Image.asset(
                        'assets/debt.png',
                        width: 64,
                      ),
                      title: Row(
                        children: [
                          Text(
                            "Qarzdor oylar".capitalizeFirst!,
                            style: TextStyle(
                                color: Colors.black,
                                fontWeight: FontWeight.w700),
                          ),
                          Container(
                            margin: EdgeInsets.only(left: 12),
                            alignment: Alignment.center,
                            width: 33,
                            height: 33,
                            child: Text(
                              "${calculateUnpaidMonths(data['items']['studyDays'], data['items']['payments']).length}",
                              style: TextStyle(color: Colors.white),
                            ),
                            decoration: BoxDecoration(
                                color: Colors.red,
                                borderRadius: BorderRadius.circular(121)),
                          )
                        ],
                      ),
                    ),
                  ),
                )
                    : SizedBox(),
                calculateUnpaidMonths(data['items']['studyDays'],
                    data['items']['payments'])
                    .length !=
                    0
                    ? SizedBox(
                  height: 2,
                )
                    : SizedBox(),
                InkWell(
                  onTap: () {
                    var list = [];

                    for (int i = 0;
                  i < data['items']['studyDays'].length;  i++) {

                        list.add({
                          'attendance': data['items']['studyDays'][i] ['attendance'],
                          'day': DateFormat('dd-MM-yyyy')  .parse(data['items']['studyDays'][i]['studyDay'])
                        });

                    }
                    Get.to(CalendarScreen(
                      days: list,
                    ));
                  },
                  child: Container(
                    color: Colors.white,
                    child: ListTile(
                      contentPadding: EdgeInsets.all(8),
                      leading: Image.asset(
                        'assets/calendar.png',
                        width: 64,
                      ),
                      title: Text(
                        "Davomat kalendari".capitalizeFirst!,
                        style: TextStyle(
                            color: Colors.black, fontWeight: FontWeight.w700),
                      ),
                    ),
                  ),
                ),
                SizedBox(
                  height: 2,
                ),
                data['items']['phone'].toString().isNotEmpty   ?

                GestureDetector(
                  onTap: (){
                    launchPhoneNumber(data['items']['phone'].toString());
                  },
                  child: Container(
                    color:Colors.white,
                    child: ListTile(
                      contentPadding: EdgeInsets.all(8),
                      leading: Icon(
                        Icons.phone,
                        color: Colors.blue,
                      ),
                      title: Text('Student phone'),
                      subtitle: Text(
                        "${data['items']['phone']}".capitalizeFirst!,
                        style: TextStyle(
                            color: Colors.green, fontWeight: FontWeight.w700),
                      ),
                    ),
                  ),
                ):SizedBox(),

                SizedBox(
                  height: 2,
                ),
                data['items']['parentPhone'].toString().isNotEmpty &&   data['items']['parentPhone'].toString().length > 8 ?
                GestureDetector(
                  onTap: (){
                    launchPhoneNumber(data['items']['parentPhone'].toString());
                  },
                  child: Container(
                    color:Colors.white,
                    child: ListTile(
                      contentPadding: EdgeInsets.all(8),
                      leading: Icon(
                        Icons.phone,
                        color: Colors.blue,
                      ),
                      title: Text('Parent phone'),
                      subtitle: Text(
                        "${data['items']['parentPhone']}".capitalizeFirst!,
                        style: TextStyle(
                            color: Colors.green, fontWeight: FontWeight.w700),
                      ),
                    ),
                  ),
                ):SizedBox(),
                SizedBox(height:  data['items']['parentPhone'].toString().isNotEmpty &&   data['items']['parentPhone'].toString().length > 8 ? 2:0,),
                InkWell(
                  onTap: () {
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return Stack(
                          alignment: Alignment.center,
                          children: [
                            CustomAlertDialog(
                              title: "Delete Student",
                              description:
                              "Are you sure you want to delete this student?",
                              onConfirm: () async {
                                // Perform delete action here
                                studentController.deleteStudent(studentId);

                                Get.back();
                              },
                              img: 'assets/delete.png',
                            ),
                            Obx(() => studentController.isLoading.value
                                ? Container(
                              child: CircularProgressIndicator(
                                color: Colors.red,
                              ),
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(12),
                                  color: Colors.white),
                              padding: EdgeInsets.all(32),
                            )
                                : SizedBox())
                          ],
                        );
                      },
                    );
                  },
                  child: Container(
                    color: Colors.white,
                    child: ListTile(
                      contentPadding: EdgeInsets.all(8),
                      leading: Icon(
                        Icons.delete,
                        color: Colors.red,
                      ),
                      title: Text(
                        "Delete student".capitalizeFirst!,
                        style: TextStyle(
                            color: Colors.red, fontWeight: FontWeight.w700),
                      ),
                    ),
                  ),
                )
              ],
            );
          }
        },
      ),
    );
  }
}

Stream<DocumentSnapshot> getDocumentStreamById(
    String collection, String documentId) {
  DocumentReference documentRef =
  FirebaseFirestore.instance.collection(collection).doc(documentId);
  return documentRef.snapshots();
}
