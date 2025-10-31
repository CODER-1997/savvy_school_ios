// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:flutter/cupertino.dart';
// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:get/get_core/src/get_main.dart';
// import 'package:get_storage/get_storage.dart';
// import 'package:savvy_school_ios/constants/custom_widgets/emptiness.dart';
// import 'package:savvy_school_ios/controllers/exams/exams_controller.dart';
// import 'package:savvy_school_ios/screens/students_by_group/additional_funcs/add_exams.dart';
// import 'package:savvy_school_ios/screens/students_by_group/students_by_group_cefr.dart';
// import 'package:savvy_school_ios/screens/students_by_group/students_by_group_exams.dart';
// import '../../../constants/custom_widgets/FormFieldDecorator.dart';
// import '../../../constants/custom_widgets/gradient_button.dart';
//
// class Exams extends StatelessWidget {
//   final String group;
//   final String groupId;
//
//   Exams({required this.group, required this.groupId});
//
//   final _formKey = GlobalKey<FormState>();
//
//    GetStorage box = GetStorage();
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       extendBody: true,
//       backgroundColor: Color(0xffe8e8e8),
//       body: Padding(
//         padding: const EdgeInsets.all(8.0),
//         child: StreamBuilder(
//             stream: FirebaseFirestore.instance
//                 .collection('LinguistaExams')
//                 .where('items.group', isEqualTo: group)
//                 .snapshots(),
//             builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
//               if (snapshot.connectionState == ConnectionState.waiting) {
//                 return Center(child: CircularProgressIndicator());
//               }
//               if (snapshot.hasError) {
//                 return Center(child: Text('Xatolik: ${snapshot.error}'));
//               }
//               if (snapshot.hasData) {
//                 var exams = snapshot.data!.docs;
//
//                 return exams.isNotEmpty
//                     ?
//
//                 ListView.builder(
//                   itemCount: exams.length,
//                   itemBuilder: (context, index) {
//                     var exam  = exams[index];
//                     return   GestureDetector(
//                       onTap: () {
//                         if (exam['items']['isCefr']== true) {
//                           Get.to(Cefr(
//                             groupId: groupId,
//                             groupName: group,
//                             examTitle: exam['items']['name'],
//                             examCount: exam['items']['questionNums'],
//                             examDate: exam['items']['date'],
//                           ));
//                         } else {
//                           Get.to(ExamResults(
//                             groupId: groupId,
//                             groupName: group,
//                             examTitle: exam['items']['name'],
//                             examCount: exam['items']['questionNums'],
//                             examDate: exam['items']['date'],
//                           ));
//                         }
//                       },
//                       child: Container(
//                         decoration: BoxDecoration(
//                             color: Colors.white,
//                             borderRadius: BorderRadius.circular(12)),
//                         margin: EdgeInsets.all(4),
//                         child: ListTile(
//                           trailing: Row(
//                             mainAxisSize: MainAxisSize.min,
//                             children: [
//                               InkWell(
//                                   onTap: () {
//                                     showDialog(
//                                       context: context,
//                                       builder: (BuildContext context) {
//                                         examController.setValues(
//                                           exam['items']['name'],
//                                           exam['items']['questionNums'],
//                                         );
//
//                                         return Dialog(
//                                           backgroundColor: Colors.white,
//                                           insetPadding:
//                                           EdgeInsets.symmetric(
//                                               horizontal: 16),
//
//                                           shape: RoundedRectangleBorder(
//                                               borderRadius:
//                                               BorderRadius.circular(
//                                                   12.0)),
//                                           //this right here
//                                           child: Form(
//                                             key: _formKey,
//                                             child: Container(
//                                               padding:
//                                               EdgeInsets.all(16),
//                                               decoration: BoxDecoration(
//                                                   color: Colors.white,
//                                                   borderRadius:
//                                                   BorderRadius
//                                                       .circular(
//                                                       12)),
//                                               width: Get.width,
//                                               height: exam['items']['isCefr']== true ? Get.height/3.8: Get.height / 2.2,
//                                               child: Column(
//                                                 mainAxisAlignment:
//                                                 MainAxisAlignment
//                                                     .spaceBetween,
//                                                 children: [
//                                                   Column(
//                                                     children: [
//                                                       Text(
//                                                           "Tahrirlash"),
//                                                       SizedBox(
//                                                         height: 16,
//                                                       ),
//                                                       SizedBox(
//                                                         child:
//                                                         TextFormField(
//                                                             decoration:
//                                                             buildInputDecoratione(
//                                                                 ''),
//                                                             controller:
//                                                             examController
//                                                                 .examEdit,
//                                                             keyboardType:
//                                                             TextInputType
//                                                                 .text,
//                                                             validator:
//                                                                 (value) {
//                                                               if (value!
//                                                                   .isEmpty) {
//                                                                 return "Maydonlar bo'sh bo'lmasligi kerak";
//                                                               }
//                                                               return null;
//                                                             }),
//                                                       ),
//                                                       SizedBox(
//                                                         height: 16,
//                                                       ),
//                                                       exam['items']['isCefr']  ==true ? SizedBox():  TextFormField(
//                                                           decoration:
//                                                           buildInputDecoratione(
//                                                               ''),
//                                                           controller:
//                                                           examController
//                                                               .examQuestionCountEdit,
//                                                           keyboardType:
//                                                           TextInputType
//                                                               .number,
//                                                           validator:
//                                                               (value) {
//                                                             if (value!
//                                                                 .isEmpty) {
//                                                               return "Maydonlar bo'sh bo'lmasligi kerak";
//                                                             }
//                                                             return null;
//                                                           }),
//                                                       SizedBox(
//                                                         height: 16,
//                                                       ),
//                                                     ],
//                                                   ),
//                                                   InkWell(
//                                                     onTap: () {
//                                                       if (_formKey
//                                                           .currentState!
//                                                           .validate()) {
//                                                         examController
//                                                             .editExam(exam
//                                                             .id
//                                                             .toString());
//                                                       }
//                                                     },
//                                                     child: Obx(() => CustomButton(
//                                                         isLoading:
//                                                         examController
//                                                             .isLoading
//                                                             .value,
//                                                         text:
//                                                         "Tahrirlash")),
//                                                   )
//                                                 ],
//                                               ),
//                                             ),
//                                           ),
//                                         );
//                                       },
//                                     );
//                                   },
//                                   child: Icon(Icons.edit)),
//                               IconButton(
//                                   onPressed: () {
//                                     Get.defaultDialog(
//                                       title: "O'chirish",
//                                       middleText:
//                                       "Rostdanham o'chirilsinmi ?",
//                                       textCancel: "Yoq",
//                                       textConfirm: "Ha",
//                                       confirmTextColor: Colors.white,
//                                       onConfirm: () {
//                                         examController
//                                             .deleteExam(exam.id);
//                                       },
//                                       onCancel: () {
//                                       },
//                                     );
//                                   },
//                                   icon: Icon(
//                                     Icons.delete,
//                                     color: Colors.red,
//                                   ))
//                             ],
//                           ),
//                           title: Text('${exam['items']['name']}'),
//                         ),
//                       ),
//                     );
//                   },
//                 )
//
//
//                     : Emptiness(title: 'Hali imtihonlar yo\'q');
//               }
//               // If no data available
//
//               else {
//                 return Text('Malumot mavjud emas'); // No data available
//               }
//             }),
//       ),
//       floatingActionButtonLocation:
//       FloatingActionButtonLocation.miniCenterFloat,
//       floatingActionButton: AddExams(group: group),
//     );
//   }
// }
