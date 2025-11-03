import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';

import '../../../constants/custom_widgets/FormFieldDecorator.dart';
import '../../../constants/custom_widgets/gradient_button.dart';
import '../../../controllers/students/student_controller.dart';

class AddStudent extends StatelessWidget {

  final String groupName;
  final String groupId;

  AddStudent({required this.groupName, required this.groupId, });


  RxList grades = [
    "child",
    "5",
    "6",
    "7",
    "8",
    "9",
    "10",
    "11",
    "College",
    "Teacher",
    "Univer student",
    "Employed",
  ].obs;

  RxString selectedGrade = "".obs;


  StudentController studentController = Get.put(StudentController());
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: Icon(CupertinoIcons.person_add_solid,color: Colors.white,),
      onPressed:    () {
        studentController.selectedGroup.value = groupName;
        studentController.selectedGroupId.value =  groupId;
        studentController.isFreeOfCharge.value = false;
        Get.bottomSheet(
            isScrollControlled: true,

            enableDrag: true,
            backgroundColor: Colors.transparent,
            isDismissible: true,
            Container(
              height: Get.height*.8,
              decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(32),
                      topRight: Radius.circular(32))),
              padding: EdgeInsets.all(16),
              child: SingleChildScrollView(
                child:Obx(()=> Column(
                  mainAxisSize: MainAxisSize.max,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                height:4,
                                width: 40,
                                decoration: BoxDecoration(
                                    color: Colors.grey,
                                    borderRadius: BorderRadius.circular(12)
                                ),
                              )
                            ],),
                          Column(
                            children: [
                              Text("Talaba qo'shish"),
                              SizedBox(
                                height: 16,
                              ),
                              TextFormField(
                                  controller: studentController.name,
                                  keyboardType: TextInputType.text,
                                  decoration: buildInputDecoratione(
                                      'Ismi:'
                                          .tr
                                          .capitalizeFirst! ??
                                          ''),
                                  validator: (value) {
                                    if (value!.isEmpty) {
                                      return "Maydonlar bo'sh bo'lmasligi kerak";
                                    }
                                    return null;
                                  }),
                              SizedBox(
                                height: 16,
                              ),
                              TextFormField(
                                  controller: studentController.surname,
                                  keyboardType: TextInputType.text,
                                  decoration: buildInputDecoratione(
                                      'Familiyasi'
                                          .tr
                                          .capitalizeFirst! ??
                                          ''),
                                  validator: (value) {
                                    if (value!.isEmpty) {
                                      return "Maydonlar bo'sh bo'lmasligi kerak";
                                    }
                                    return null;
                                  }),
                              SizedBox(
                                height: 16,
                              ),
                              TextFormField(
                                controller: studentController.phone,
                                keyboardType: TextInputType.phone,
                                inputFormatters: [
                                  MaskTextInputFormatter(
                                      mask: '+998 ## ### ## ##',
                                      filter: {"#": RegExp(r'[0-9]')},
                                      type: MaskAutoCompletionType.lazy)
                                ],
                                decoration: buildInputDecoratione(
                                    '+998 ## ### ## ##'
                                        .tr
                                        .capitalizeFirst! ??
                                        ''),

                              ),
                              SizedBox(
                                height: 16,
                              ),
                              TextFormField(
                                controller: studentController.parentPhone,
                                keyboardType: TextInputType.phone,
                                inputFormatters: [
                                  MaskTextInputFormatter(
                                      mask: '+998 ## ### ## ##',
                                      filter: {"#": RegExp(r'[0-9]')},
                                      type: MaskAutoCompletionType.lazy)
                                ],
                                decoration: buildInputDecoratione(
                                    '+998 ## ### ## ##  (Parents phone)'
                                        .tr
                                        .capitalizeFirst! ??
                                        ''),

                              ),
                              SizedBox(
                                height: 16,
                              ),

                              Obx(()=>Container(child: SingleChildScrollView(
                                scrollDirection: Axis.horizontal,
                                child: Row(children: [
                                  for(int i = 0 ; i < grades.length ; i++)
                                    GestureDetector(
                                      onTap: (){
                                        selectedGrade.value = grades[i];
                                        studentController.grade.value = selectedGrade.value;
                                      },
                                      child: Container(

                                        padding: EdgeInsets.symmetric(horizontal: 16,vertical: 8),
                                        margin: EdgeInsets.symmetric(horizontal: 4),
                                        decoration: BoxDecoration(
                                            color: selectedGrade.value == grades[i] ? Colors.green:Colors.white,
                                            borderRadius: BorderRadius.circular(12),
                                            border: Border.all(
                                                color: selectedGrade.value == grades[i] ? Colors.white:Colors.black
                                            )
                                        ),
                                        child: Text(grades[i],style: TextStyle(
                                            color: selectedGrade.value == grades[i] ? Colors.white:Colors.black
                                        ),),
                                      ),
                                    )

                                ],),),)),

                              SizedBox(
                                height: 16,
                              ),
                              Row(
                                children: [
                                  Obx(
                                        () => Text(
                                        'Kelgan kuni:  ${studentController.paidDate.value}'),
                                  ),
                                  IconButton(
                                      onPressed: () {
                                        studentController.showDate(
                                            studentController.paidDate);
                                      },
                                      icon: Icon(Icons.calendar_month))
                                ],
                              ),



                              Row(
                                mainAxisAlignment:
                                MainAxisAlignment.start,
                                children: [
                                  Obx(() => InkWell(
                                    onTap: () {
                                      studentController
                                          .isFreeOfCharge.value =
                                      !studentController
                                          .isFreeOfCharge.value;
                                    },
                                    child: Container(
                                      padding: EdgeInsets.symmetric(
                                          horizontal: 18,
                                          vertical: 8),
                                      margin: EdgeInsets.all(8),
                                      decoration: BoxDecoration(
                                          color: studentController
                                              .isFreeOfCharge
                                              .value
                                              ? Colors.green
                                              : Colors.white,
                                          borderRadius:
                                          BorderRadius.circular(
                                              112),
                                          border: Border.all(
                                              color: Colors.green,
                                              width: 1)),
                                      child: Text(
                                        "To'lovdan ozod",
                                        style: TextStyle(
                                          color: studentController
                                              .isFreeOfCharge
                                              .value
                                              ? Colors.white
                                              : Colors.black,
                                        ),
                                      ),
                                    ),
                                  )),
                                ],
                              )

                            ],
                          ),


                        ],
                      ),
                    ),
                    Column(
                      children: [
                        GestureDetector(

                          onTap: () {

                             //
                             //
                             // showDialog(
                             //   context: context,
                             //   builder: (BuildContext context) {
                             //     return Dialog(
                             //       backgroundColor: Colors.white,
                             //       insetPadding: EdgeInsets.symmetric(horizontal: 16),
                             //       shape: RoundedRectangleBorder(
                             //           borderRadius: BorderRadius.circular(12.0)),
                             //
                             //       child: Container(
                             //         padding: EdgeInsets.all(16),
                             //         decoration: BoxDecoration(
                             //             color: Colors.white,
                             //             borderRadius: BorderRadius.circular(12)),
                             //         width: Get.width,
                             //         height: Get.height/3.5 ,
                             //         child:Container(
                             //           child: Column(
                             //             mainAxisAlignment: MainAxisAlignment.center,
                             //
                             //             children: [
                             //             Text("Barcha ma'lumotlar \nto\'g\'rimi ?",
                             //             style: TextStyle(
                             //               color: CupertinoColors.black,
                             //               fontSize: 28,
                             //               fontWeight: FontWeight.bold
                             //
                             //             ),
                             //               textAlign: TextAlign.center,
                             //             ),
                             //             SizedBox(height: 32,),
                             //             Row(
                             //               mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                             //               children: [
                             //
                             //               ElevatedButton(
                             //
                             //                   onPressed: (){},
                             //                   style: ElevatedButton.styleFrom(
                             //                     backgroundColor: Colors.greenAccent, // button color
                             //                     foregroundColor: Colors.white, // text color
                             //                     shape: RoundedRectangleBorder(
                             //                       borderRadius: BorderRadius.circular(32), // rounded corners
                             //                     ),
                             //                     padding:   EdgeInsets.symmetric(horizontal: Get.width/7, vertical: 14),
                             //                     elevation: 5, // shadow
                             //                   ),
                             //
                             //                   child: Text('Ha')),
                             //               ElevatedButton(
                             //                   style: ElevatedButton.styleFrom(
                             //                     backgroundColor: Colors.red, // button color
                             //                     foregroundColor: Colors.white, // text color
                             //                     shape: RoundedRectangleBorder(
                             //                       borderRadius: BorderRadius.circular(32), // rounded corners
                             //                     ),
                             //                     padding:   EdgeInsets.symmetric(horizontal: Get.width/7, vertical: 14),
                             //                     elevation: 5, // shadow
                             //                   ),
                             //
                             //                   onPressed: (){}, child: Text("Yo'q")),
                             //
                             //
                             //
                             //             ],)
                             //           ],),
                             //
                             //
                             //         ),
                             //       ),
                             //     );
                             //   },
                             // );










                            if (_formKey.currentState!.validate() &&
                                studentController
                                    .selectedGroupId.value.isNotEmpty) {
                              studentController.addNewStudent(  );
                            }





                          },






                          child: CustomButton(
                              isLoading:studentController.isLoading.value,
                              text: 'confirm'.tr.capitalizeFirst!),
                        ),
                        SizedBox(
                          height: 8,
                        ),
                        GestureDetector(
                            onTap: () {
                              Get.back();
                            },
                            child: CustomButton(
                              text: 'Cancel'.tr.capitalizeFirst!,
                              color: Colors.red,
                            ))
                      ],
                    )
                  ],
                )),
              ),
            ));


      },
    );
  }
}
