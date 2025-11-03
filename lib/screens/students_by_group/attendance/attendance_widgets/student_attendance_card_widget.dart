import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../constants/custom_widgets/gradient_button.dart';
import '../../../../constants/utils.dart';
import '../../../../controllers/students/student_controller.dart';
class StudentAttendanceCardWidget extends StatelessWidget {
  final RxBool isStudentChoosen;
  final Map student;
  final StudentController studentController;
  final String groupId;
  final List selectedStudents;
  final int index;

  const StudentAttendanceCardWidget({
    super.key,
    required this.isStudentChoosen,
    required this.student,
    required this.studentController,
    required this.groupId,
    required this.selectedStudents,
    required this.index,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 1),
      padding: const EdgeInsets.all(8),
      decoration: const BoxDecoration(color: CupertinoColors.white),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _buildStudentInfo(),
          _buildAttendanceButtons(context),
        ],
      ),
    );
  }

  /// ✅ Left side: checkbox / number + student details
  Widget _buildStudentInfo() {
    return Row(
      children: [
        _buildCheckOrIndex(),
        const SizedBox(width: 8),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildNameAndPhone(),
            const SizedBox(height: 4),
            if (hasDebtFromPayment(student['payments'])) _buildDebtBadge(),
            if (student['isFreeOfcharge'] == false)
              _buildUnpaidMonthsBadge(),
          ],
        )
      ],
    );
  }

  /// ✅ Right side: attendance buttons
  Widget _buildAttendanceButtons(BuildContext context) {
    return Row(
      children: [
        _attendanceButton(
          label: "Bor",
          isPresent: true,
          onTap: () {
            if (checkStatus(student['studyDays'],
                studentController.selectedStudyDate.value) ==
                '2') {
              studentController.removeStudyDay(
                  student['id'], groupId, student['uniqueId'], );
            } else {
              studentController.setStudyDay(
                  student['id'], groupId, student['uniqueId'], '2');
            }
          }, color: Colors.green,
        ),
        const SizedBox(width: 4),
        _attendanceButton(
          label:
          checkStatus(student['studyDays'], studentController.selectedStudyDate.value) =='1'
              ?         "Kech":"Yo'q"
              ,
          isPresent: false,
          onTap: () {
            if (checkStatus(student['studyDays'],
                studentController.selectedStudyDate.value) ==
                '-1') {
              studentController.removeStudyDay(
                  student['id'], groupId, student['uniqueId'],   );
            } else {
              _showReasonDialog(context);
            }
          }, color:  checkStatus(student['studyDays'], studentController.selectedStudyDate.value) =='1'
            ?         Colors.orangeAccent:Colors.red,
        ),
      ],
    );
  }

  /// ✅ Checkbox or student number
  Widget _buildCheckOrIndex() {
    if (isStudentChoosen.value) {
      return Container(
        alignment: Alignment.center,
        width: 20,
        height: 20,
        decoration: BoxDecoration(
          color:
          selectedStudents.contains(student) ? Colors.green : Colors.white,
          border: Border.all(
            color: selectedStudents.contains(student)
                ? Colors.white
                : Colors.grey,
          ),
          borderRadius: BorderRadius.circular(4),
        ),
        child: const Icon(Icons.check, color: Colors.white, size: 12),
      );
    }

    if (student['isFreeOfcharge'] == true) {
      return Stack(
        alignment: Alignment.center,
        children: [
          Image.asset('assets/verified.png',
              width: 25, color: CupertinoColors.systemYellow),
          Text("${index + 1}",
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.w500)),
        ],
      );
    }

    return Container(
      width: 25,
      height: 25,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: hasDebt(student['payments']) ? Colors.blue : Colors.green,
      ),
      child: Text(
        "${index + 1}",
        style: const TextStyle(
            color: Colors.white, fontSize: 10, fontWeight: FontWeight.w500),
      ),
    );
  }

  /// ✅ Student name + phone check
  Widget _buildNameAndPhone() {
    return SizedBox(
      width: Get.width / 2.5,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "${student['surname'].toString().capitalizeFirst!} "
                "${student['name'].toString().capitalizeFirst!}",
            style: const TextStyle(fontWeight: FontWeight.w600),
            overflow: TextOverflow.ellipsis,
          ),
          if (student['phone'].toString().isEmpty)
            const Text("Phone number is empty",
                style: TextStyle(color: Colors.red)),
        ],
      ),
    );
  }

  /// ✅ Small red badge for debt
  Widget _buildDebtBadge() => Container(
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
    decoration: BoxDecoration(
        color: Colors.red, borderRadius: BorderRadius.circular(12)),
    child: const Text("To'lovda chalasi bor !",
        style: TextStyle(color: Colors.white, fontSize: 10)),
  );

  /// ✅ Badge for unpaid months
  Widget _buildUnpaidMonthsBadge() {
    final months = calculateUnpaidMonths(
        student['studyDays'], student['payments']).length;

    if (months == 0) return const SizedBox();

    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.red,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.red, width: 1),
      ),
      child: Text("$months oylik to'lov qolgan",
          style: const TextStyle(color: Colors.white, fontSize: 10)),
    );
  }

  /// ✅ Attendance button (Bor / Yo'q)
  Widget _attendanceButton({
    required String label,
    required bool isPresent,
    required VoidCallback onTap,
    required Color color,
    
  }) {
    final status = checkStatus(
        student['studyDays'], studentController.selectedStudyDate.value);

    final isActive = isPresent ? status == '2' : (status == '-1' || status =='1'); // highlight only when matches

    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
        decoration: BoxDecoration(
          color: (color)
              .withOpacity(isActive ? 1 : .3),
          borderRadius: BorderRadius.circular(4),
        ),
        child: Text(label,
            style: TextStyle(
                color: isActive
                    ? Colors.white
                    : (color),
                fontSize: 12,
                fontWeight: FontWeight.w900)),
      ),
    );
  }

  /// ✅ Reason dialog
  void _showReasonDialog(BuildContext context) {
    studentController.selectedAbsenseReason.value =='';

    showDialog(

      context: context,
      builder: (_) => Dialog(
        backgroundColor: Colors.white,
        shape:
        RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
        child: Container(
          padding: const EdgeInsets.all(16),
          width: Get.width - 64,
          height: Get.height / 5  ,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [


              Obx(() => Row(
                children: ["Kelmadi", "Kech keldi"].map((reason) {
                  final selected =
                      studentController.selectedAbsenseReason.value ==
                          reason;
                  return Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: InkWell(
                        onTap: () =>
                        studentController.selectedAbsenseReason.value =
                            reason,
                        child: Container(
                          alignment: Alignment.center,
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: selected ? Colors.red : Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.black),
                          ),
                          child: Text(reason,
                              style: TextStyle(
                                  color: selected ? Colors.white : Colors.black,
                              fontFamily: 'Nunito',
                                fontWeight: FontWeight.w700
                              ),

                          textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              )),
            Row(children: [
              Expanded(
                child: InkWell(
                  onTap: () {
                    if ( studentController.selectedAbsenseReason.value.isNotEmpty) {
                      if(studentController.selectedAbsenseReason.value =="Kelmadi"){
                        studentController.setStudyDay(student['id'], groupId,
                            student['uniqueId'],'-1');
                      }
                      else if  (studentController.selectedAbsenseReason.value =="Kech keldi"){
                        {
                          studentController.setStudyDay(student['id'], groupId,
                              student['uniqueId'], '1');
                        }
                      }
                
                    }
                    Get.back();
                  },
                  child: Obx(() => CustomButton(
                    color: Colors.green,
                    isLoading: studentController.isLoading.value,
                    text: 'Tasdiqlash',
                  )),
                ),
              ),
              SizedBox(width: 4,),
              Expanded(
                child: InkWell(
                  onTap: () {
                 
                    Get.back();
                  },
                  child: Obx(() => CustomButton(
                    color: Colors.red,
                    isLoading: studentController.isLoading.value,
                    text: 'Bekor qilish',
                  )),
                ),
              ),
            ],)
            ],
          ),
        ),
      ),
    );
  }
}
