
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:savvy_school_ios/screens/admin/teachers/teacherInfo.dart';
 import '../../../constants/custom_funcs/snackbar.dart';
import '../../../constants/custom_widgets/FormFieldDecorator.dart';
import '../../../constants/custom_widgets/custom_dialog.dart';
import '../../../constants/custom_widgets/gradient_button.dart';
import '../../../constants/text_styles.dart';
import '../../../constants/theme.dart';
import '../../../controllers/admin/teachers_controller.dart';
 import '../../../controllers/students/student_controller.dart';

class Teachers extends StatefulWidget {
  @override
  State<Teachers> createState() => _TeachersState();
}

class _TeachersState extends State<Teachers> {
  final _formKey = GlobalKey<FormState>();

  TeachersController teachersController = Get.put(TeachersController());
  StudentController studentController = Get.put(StudentController());

  String _searchText = '';

  RxList scores = [

    "6.5",
    "7",
    "7.5",
    "8",
    "8.5",
    "9",
    "B2",
    "C1",
    "C2",
    "No certificate",

  ].obs;
  RxList experience = [

    "without experience",
    "less than 6 month",
    "6 month + ",
    "1 year",
    "2 year",
    "3 year",
    "4 year",
    "5 year",
    "5 year + ",
    "10 year + ",


  ].obs;

  bool shouldImproveScore(String ?  score){
      if(score == '6.5' || score == 'No certificate' || score == '7' || score == '7.5' || score == null){
        return true ;
      }
      return false;
  }







  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Color(0xffe8e8e8),
        appBar: AppBar(
          backgroundColor: dashBoardColor,
          toolbarHeight: 64,
          actions: [
            Padding(
              padding: const EdgeInsets.only(
                right: 16,
              ),
              child: TextButton.icon(
                style: ButtonStyle(

                ),
                  onPressed: () {
                    studentController.fetchGroups();
                    teachersController.teacherGroups.clear();
                    teachersController.teacherGroupIds.clear();
                    teachersController.TeacherSurname.clear();
                    teachersController.TeacherName.clear();
                    teachersController.teacherExperience.value='';
                    teachersController.teacherScore.value='';

                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return Dialog(
                          backgroundColor: Colors.white,
                          insetPadding: EdgeInsets.symmetric(horizontal: 0),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(0)),
                          //this right here
                          child: Form(
                            key: _formKey,
                            child: Container(
                              padding: EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(12)),
                              width: Get.width,
                              height: Get.height  ,
                              child: SingleChildScrollView(
                                child: Column(
                                  mainAxisAlignment:
                                  MainAxisAlignment.spaceBetween,
                                  children: [
                                    Column(
                                      crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          mainAxisAlignment:
                                          MainAxisAlignment.center,
                                          children: [
                                            Expanded(
                                              child: Row(
                                                mainAxisAlignment:
                                                MainAxisAlignment
                                                    .spaceBetween,
                                                children: [
                                                  SizedBox(),
                                                  Text(
                                                    "Add Teacher",
                                                    style: appBarStyle.copyWith(
                                                        fontSize: 14),
                                                  ),
                                                  IconButton(
                                                      onPressed: Get.back,
                                                      icon: Icon(
                                                        Icons.close,
                                                        color:
                                                        CupertinoColors.black,
                                                      ))
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                        SizedBox(
                                          height: 16,
                                        ),
                                        TextFormField(
                                            controller:
                                            teachersController.TeacherName,
                                            keyboardType: TextInputType.text,
                                            decoration: buildInputDecoratione(
                                                'Teacher name'),
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
                                            controller:
                                            teachersController.TeacherSurname,
                                            keyboardType: TextInputType.text,
                                            decoration: buildInputDecoratione(
                                                'Teacher surname'),
                                            validator: (value) {
                                              if (value!.isEmpty) {
                                                return "Maydonlar bo'sh bo'lmasligi kerak";
                                              }
                                              return null;
                                            }),
                                        SizedBox(
                                          height: 16,
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: Text(
                                            'Append group(s)',
                                            style:
                                            appBarStyle.copyWith(fontSize: 12,fontWeight: FontWeight.w600,color: Colors.grey),
                                          ),
                                        ),
                                        Obx(() => Container(
                                           alignment: Alignment.topLeft,
                                          child: SingleChildScrollView(
                                            scrollDirection: Axis.horizontal,
                                            child: Row(
                                              children: [
                                                for (int i = 0;
                                                i <
                                                    studentController
                                                        .MarkazGroups
                                                        .length;
                                                i++)
                                                  GestureDetector(
                                                    onTap: () {
                                
                                                      if (teachersController.teacherGroupIds.contains(studentController.MarkazGroups[i]['group_id'])) {
                                                        teachersController .teacherGroupIds.remove(studentController.MarkazGroups[i]['group_id']);
                                                        teachersController.teacherGroups.removeWhere((el)=> el['group_id']== studentController.MarkazGroups[i]['group_id']);
                                                        print('Teacher groups ${ teachersController.teacherGroups}');
                                                      } else {
                                                        teachersController.teacherGroups.add(studentController.MarkazGroups[i]);
                                                        teachersController.teacherGroupIds.add(studentController.MarkazGroups[i]['group_id']);
                                                        print('Teacher groups ${ teachersController.teacherGroups}');
                                
                                                      }
                                
                                                    },
                                                    child: Container(
                                                      padding: EdgeInsets
                                                          .symmetric(
                                                          horizontal: 18,
                                                          vertical: 8),
                                                      margin:
                                                      EdgeInsets.all(2),
                                                      decoration: !teachersController
                                                          .teacherGroupIds
                                                          .contains(studentController
                                                          .MarkazGroups[i][
                                                      'group_id'])
                                                          ? BoxDecoration(
                                                          borderRadius:
                                                          BorderRadius.circular(
                                                              112),
                                                          border: Border.all(
                                                              color: Colors
                                                                  .black,
                                                              width: 1))
                                                          : BoxDecoration(
                                                          color: Colors
                                                              .green,
                                                          borderRadius:
                                                          BorderRadius.circular(112),
                                                          border: Border.all(color: Colors.green, width: 1)),
                                                      child: Text(
                                                        "${studentController.MarkazGroups[i]['group_name']}",
                                                        style: TextStyle(
                                                            color: !teachersController
                                                                .teacherGroupIds
                                                                .contains(
                                                                studentController.MarkazGroups[i]
                                                                [
                                                                'group_id'])
                                                                ? Colors.black
                                                                : CupertinoColors
                                                                .white),
                                                      ),
                                                    ),
                                                  )
                                              ],
                                            ),
                                          ),
                                        )),
                                        Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: Text(
                                            'Teacher personal score',
                                            style:
                                            appBarStyle.copyWith(fontSize: 12,fontWeight: FontWeight.w600,color: Colors.grey),
                                          ),
                                        ),
                                
                                        Obx(()=>Container(child: SingleChildScrollView(
                                          scrollDirection: Axis.horizontal,
                                          child: Row(children: [
                                            for(int i = 0 ; i < scores.length ; i++)
                                              GestureDetector(
                                                onTap: (){
                                                  teachersController.teacherScore.value = scores[i];
                                
                                                },
                                                child: Container(
                                
                                                  padding: EdgeInsets.symmetric(horizontal: 16,vertical: 8),
                                                  margin: EdgeInsets.symmetric(horizontal: 4),
                                                  decoration: BoxDecoration(
                                                      color:    teachersController.teacherScore.value == scores[i] ? Colors.green:Colors.white,
                                                      borderRadius: BorderRadius.circular(12),
                                                      border: Border.all(
                                                          color:    teachersController.teacherScore.value == scores[i] ? Colors.white:Colors.black
                                                      )
                                                  ),
                                                  child: Text(scores[i],style: TextStyle(
                                                      color:    teachersController.teacherScore.value == scores[i] ? Colors.white:Colors.black
                                                  ),),
                                                ),
                                              )
                                
                                          ],),),)),
                                        Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: Text(
                                            'Teacher personal experience',
                                            style:
                                            appBarStyle.copyWith(fontSize: 12,fontWeight: FontWeight.w600,color: Colors.grey),
                                          ),
                                        ),
                                
                                        Obx(()=>Container(child: SingleChildScrollView(
                                          scrollDirection: Axis.horizontal,
                                          child: Row(children: [
                                            for(int i = 0 ; i < experience.length ; i++)
                                              GestureDetector(
                                                onTap: (){
                                                  teachersController.teacherExperience.value = experience[i];
                                
                                                },
                                                child: Container(
                                
                                                  padding: EdgeInsets.symmetric(horizontal: 16,vertical: 8),
                                                  margin: EdgeInsets.symmetric(horizontal: 4),
                                                  decoration: BoxDecoration(
                                                      color:    teachersController.teacherExperience.value == experience[i] ? Colors.green:Colors.white,
                                                      borderRadius: BorderRadius.circular(12),
                                                      border: Border.all(
                                                          color:    teachersController.teacherExperience.value == experience[i] ? Colors.white:Colors.black
                                                      )
                                                  ),
                                                  child: Text(experience[i],style: TextStyle(
                                                      color:    teachersController.teacherExperience.value == experience[i] ? Colors.white:Colors.black
                                                  ),),
                                                ),
                                              )
                                
                                          ],),),)),
                                      ],
                                    ),
                                    SizedBox(height: Get.height/3.3,),
                                    InkWell(
                                      onTap: () {
                                        if (_formKey.currentState!.validate()) {
                                          teachersController.addNewTeacher();
                                        }
                                      },
                                      child: Obx(() => CustomButton(
                                          isLoading:
                                          teachersController.isLoading.value,
                                          text: "Add")),
                                    )
                                  ],
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    );
                  },
                  icon: Icon(Icons.add,color: Colors.white,),

                  label: Text("Add Teacher",style: TextStyle(color: Colors.white),)),
            ),

          ],
        ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('MarkazTeachers')
            //.where('items.isDeleted', isEqualTo: false)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CupertinoActivityIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return _emptyTeachersView();
          }

          final teachers = snapshot.data!.docs;

          return ListView.builder(
            padding: const EdgeInsets.all(8),
            itemCount: teachers.length,
            itemBuilder: (context, index) {
              final teacher = teachers[index]['items'];
              return Card(
                  color: Colors.white,
                  margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  elevation: 1,
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    onTap: () => Get.to(Teacherinfo(documentId: teachers[index].id)),
                    leading: teacher  != null &&
                        teacher ['imgUrl'] != null &&
                        teacher ['imgUrl'].toString().isNotEmpty
                        ? CircleAvatar(
                      radius: 25,
                      backgroundImage: NetworkImage(teacher ['imgUrl']),
                    )
                        : CircleAvatar(
                      radius: 25,
                      backgroundColor: Colors.blue.shade50,
                      child: Text(
                        teacher['name'][0].toUpperCase(),
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.blue,
                        ),
                      ),
                    ),
                    title: Text(
                      "${teacher['name']} ${teacher['surname']}",
                      style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
                    ),
                    subtitle: Text(
                      "Groups: ${teacher['groups'].length}",
                      style: const TextStyle(color: Colors.grey, fontSize: 13),
                    ),
                    trailing: Wrap(
                      spacing: 4,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit, color: Colors.blueAccent),
                          onPressed: () {
                            teachersController.teacherGroupsEdit.clear();
                            teachersController.teacherGroupIdsEdit.clear();
                            studentController.fetchGroups();

                            teachersController
                                .setValues(teacher['name'], teacher['surname']);
                            teachersController.teacherGroupIdsEdit
                                .addAll(teacher['groupIds']);
                            teachersController.teacherGroupsEdit
                                .addAll(teacher['groups']);

                            _showEditTeacherSheet(context, teachers[index].id.toString());
                          },
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
                          onPressed: () {
                            if (GetStorage().read('isLogged') == 'Savvy') {
                              showDialog(
                                context: context,
                                builder: (_) => CustomAlertDialog(
                                  title: "Delete Teacher",
                                  description:
                                  "Are you sure you want to delete this teacher?",
                                  onConfirm: () =>
                                      teachersController.deleteTeacher(teachers[index].id),
                                  img: 'assets/delete.png',
                                ),
                              );
                            } else {
                              showCustomSnackBar(context,
                                  title: 'Error', message: 'Only admin can delete');
                            }
                          },
                        ),
                      ],
                    ),
                  )

              );
            },
          );
        },
      ),
    );
  }

  Widget _emptyTeachersView() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 60),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset('assets/empty.png', width: 180),
            const SizedBox(height: 16),
            const Text(
              'No teachers found',
              style: TextStyle(fontSize: 20, color: Colors.black54),
            ),
          ],
        ),
      ),
    );
  }

  void _showAddTeacherSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) {
        return DraggableScrollableSheet(
          expand: false,
          initialChildSize: 0.9, // initial height (90% of screen)
          minChildSize: 0.5,     // minimum height
          maxChildSize: 0.95,    // maximum height
          builder: (_, controller) {
            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
                top: 20,
              ),
              child: Form(
                key: _formKey,
                child: SingleChildScrollView(
                  controller: controller,
                  padding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Center(
                        child: Text(
                          "Add Teacher",
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: teachersController.TeacherName,
                        decoration: buildInputDecoratione('Teacher name'),
                        validator: (v) =>
                        v!.isEmpty ? "Field cannot be empty" : null,
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: teachersController.TeacherSurname,
                        decoration: buildInputDecoratione('Teacher surname'),
                        validator: (v) =>
                        v!.isEmpty ? "Field cannot be empty" : null,
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'Assign Groups',
                        style:
                        TextStyle(fontWeight: FontWeight.w500, fontSize: 14),
                      ),
                      const SizedBox(height: 8),
                      Obx(() => Container(
                        height: Get.height/2,
                        child: SingleChildScrollView(
                          scrollDirection: Axis.vertical,
                          child: Wrap(
                            direction: Axis.vertical,

                            children: _buildGroupSelector(
                              studentController.MarkazGroups,
                              teachersController.teacherGroupIds,
                              teachersController.teacherGroups,
                            ),
                          ),
                        ),
                      )),
                      const SizedBox(height: 24),
                      Center(
                        child: InkWell(
                          onTap: () {
                            if (_formKey.currentState!.validate()) {
                              teachersController.addNewTeacher();
                              Get.back();
                            }
                          },
                          child: Obx(() => CustomButton(
                              isLoading:
                              teachersController.isLoading.value,
                              text: "Add Teacher")),
                        ),
                      ),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  void _showEditTeacherSheet(BuildContext context, String teacherId) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) {
        return DraggableScrollableSheet(
          expand: false,
          initialChildSize: 0.95, // almost full screen
          minChildSize: 0.5,
          maxChildSize: 1.0, // full height
          builder: (_, controller) {
            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
                top: 20,
              ),
              child: Form(
                key: _formKey,
                child: SingleChildScrollView(
                  controller: controller,
                  padding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Center(
                        child: Text(
                          "Edit Teacher",
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: teachersController.TeacherNameEdit,
                        decoration: buildInputDecoratione('Teacher name'),
                        validator: (v) =>
                        v!.isEmpty ? "Field cannot be empty" : null,
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: teachersController.TeacherSurnameEdit,
                        decoration: buildInputDecoratione('Teacher surname'),
                        validator: (v) =>
                        v!.isEmpty ? "Field cannot be empty" : null,
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'Edit Groups',
                        style:
                        TextStyle(fontWeight: FontWeight.w500, fontSize: 14),
                      ),
                      const SizedBox(height: 8),
                      // Groups - vertically wrapped
                      Obx(() => Container(
                        constraints:
                        BoxConstraints(maxHeight: Get.height / 2),
                        child: SingleChildScrollView(
                          child: Wrap(
                            direction: Axis.vertical,
                            spacing: 8,
                            runSpacing: 8,
                            children: _buildGroupSelector(
                              studentController.MarkazGroups,
                              teachersController.teacherGroupIdsEdit,
                              teachersController.teacherGroupsEdit,
                            ),
                          ),
                        ),
                      )),
                      const SizedBox(height: 24),
                      Center(
                        child: InkWell(
                          onTap: () {
                            if (_formKey.currentState!.validate()) {
                              teachersController.editTeacher(teacherId);
                              Get.back();
                            }
                          },
                          child: Obx(() => CustomButton(
                              isLoading: teachersController.isLoading.value,
                              text: "Save Changes")),
                        ),
                      ),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  List<Widget> _buildGroupSelector(List groups, RxList selectedIds, RxList selectedGroups) {
    return   groups.map((g) {
      final isSelected = selectedIds.contains(g['group_id']);
      return GestureDetector(
        onTap: () {
          if (isSelected) {
            selectedIds.remove(g['group_id']);
            selectedGroups.removeWhere(
                    (el) => el['group_id'] == g['group_id']);
          } else {
            selectedIds.add(g['group_id']);
            selectedGroups.add(g);
          }
        },
        child: Container(
          padding:
          const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          margin: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: isSelected ? Colors.green : Colors.white,
            borderRadius: BorderRadius.circular(50),
            border: Border.all(
                color: isSelected ? Colors.green : Colors.black),
          ),
          child: Text(
            g['group_name'],
            style: TextStyle(
                color: isSelected ? Colors.white : Colors.black,fontSize: 16),
          ),
        ),
      );
    }).toList();

  }
}
