import 'package:intl/intl.dart';

String generateUniqueId() {
  int timestamp = DateTime.now().millisecondsSinceEpoch;
  return '$timestamp';
}

bool isToday(String dateStr) {
  // Define the date format
  final DateFormat dateFormat = DateFormat('dd-MM-yyyy');

  // Parse the date string into a DateTime object
  DateTime inputDate = dateFormat.parse(dateStr);

  // Get today's date
  DateTime today = DateTime.now();

  // Compare the input date with today's date
  return inputDate.year == today.year &&
      inputDate.month == today.month &&
      inputDate.day == today.day;
}

String convertDate(String inputDate) {
  // Parse the input date string
  DateTime parsedDate = DateFormat('dd-MM-yyyy').parse(inputDate);

  // Format the parsed date to the desired output format
  String formattedDate = DateFormat('dd MMMM yyyy').format(parsedDate);

  return formattedDate;
}

String formatDate(String date) {
  List<String> parts = date.split('-');
  return '${parts[2]}-${parts[1]}-${parts[0]}';
}

bool currentMonth(String inputDate) {
  DateTime givenDate = DateTime.parse(formatDate(inputDate));

  // Get the current date
  DateTime currentDate = DateTime.now();

  // Check if the month and year of the given date are the same as the current date
  bool isSameMonthAndYear = (givenDate.month == currentDate.month) &&
      (givenDate.year == currentDate.year);
  return isSameMonthAndYear;
}

bool hasDebt(List paidMonths) {
  var currentMonthPaid = false;
  var debtStatus = false;

  DateTime now = DateTime.now();
  bool isTodayGreaterThan10 = now.day >= 1;

  for (int j = 0; j < paidMonths.length; j++) {
    if (currentMonth(paidMonths[j]['paidDate'].toString()) == true) {
      currentMonthPaid = true;
      break;
    }
  }

  if (isTodayGreaterThan10) {
    if (currentMonthPaid) {
      debtStatus = false;
    } else {
      debtStatus = true;
    }
  }

  return debtStatus;
}

bool hasDebtFromMonth(List paidMonths,String month) {
  var currentMonthPaid = false;
  var debtStatus = false;

  for (int j = 0; j < paidMonths.length; j++) {
    if (convertDateToMonthYear(paidMonths[j]['paidDate'].toString()) == month ) {
      currentMonthPaid = true;
      break;
    }
  }

    if (currentMonthPaid) {
      debtStatus = false;
    } else {
      debtStatus = true;
    }


  return debtStatus;
}

bool hasDebtFromPayment(List paidMonths) {
  var debtStatus = false;

  for (int j = 0; j < paidMonths.length; j++) {
    if (currentMonth(paidMonths[j]['paidDate'].toString()) == true &&
        paidMonths[j]['paymentCommentary'].toString().contains('chala')) {
      debtStatus = true;
      break;
    }
  }

  return debtStatus;
}

String checkStatus(List studyDays, String day) {
  String status = 'notChecked';
  int index = 0;
  // Parse the date string into a DateTime object
  bool isChecked = false;
  for (int i = 0; i < studyDays.length; i++) {
    if (studyDays[i]['studyDay'] == day.toString()) {
      isChecked = true;
      index = i;
      break;
    }
  }

  if (isChecked == false) {
    return status = "notChecked";
  } else {
    if (studyDays[index]['studyDay']  == day.toString() &&
        studyDays[index]['isAttended'] == true &&
        studyDays[index]['hasReason']['commentary'] == "" &&
        studyDays[index]['hasReason']['hasReason'] == false) {
      status = 'true';
    } else {
      status = 'false';
    }
  }
  return status;
}

String getGroupNameById(List list, String groupId) {
  print(list);
  var groupName = "";
  for (int i = 0; i < list.length; i++) {
    if (list[i]['group_id'] == groupId) {
      groupName = list[i]['group_name'];
      break;
    }
  }
  print("NAME ${groupName}");
  return groupName;
}

bool hasReason(List studyDays, String day) {
  bool hasReason = false;
  for (int i = 0; i < studyDays.length; i++) {
    if (studyDays[i]['studyDay'] == day &&
        studyDays[i]['hasReason']['hasReason'] == true &&
        studyDays[i]['isAttended'] == false) {
      hasReason = true;
      break;
    }
  }
  return hasReason;
}

String getReason(List list,String day) {
  var result = "";
  var holat = false;
  var index = 0;
  for (int i = 0; i < list.length; i++) {
    if (list[i]['studyDay'] == day) {
      holat = true;
      index = i;
      break;
    }
  }

  if (holat) {
    result = list[index]['hasReason']['commentary'];
  }

  return result;
}

String formatNumber(num number) {
  NumberFormat formatter = NumberFormat.decimalPattern('en');
  String formattedNumber = formatter.format(number).replaceAll(',', ' ');
  return formattedNumber;
}
String convertDateToMonthYear(String d){
  // The input date string
  String inputDate = "$d";

  // Define the format of the input date string
  DateFormat inputFormat = DateFormat("dd-MM-yyyy");

  // Parse the input date string to a DateTime object
  DateTime date = inputFormat.parse(inputDate);

  // Define the desired output format
  DateFormat outputFormat = DateFormat("MMMM, yyyy");

  // Format the DateTime object to the desired output format
  String formattedDate = outputFormat.format(date);

  return formattedDate; // Output: August, 2024
}

bool isCurrentMonth(String monthYear) {
  // Get the current date
  DateTime now = DateTime.now();

  // Get the current month and year as strings
  String currentMonth = DateFormat('MMMM').format(now); // Full month name
  String currentYear = now.year.toString();

  // Split the input string to extract month and year
  List<String> parts = monthYear.split(',').map((part) => part.trim()).toList();
  String inputMonth = parts[0]; // Month part
  String inputYear = parts[1];  // Year part

  // Check if both month and year match the current month and year
  return inputMonth == currentMonth && inputYear == currentYear;
}

List calculateUnpaidMonths(List studyDays,List payments){

  var studyMonths = [];
  var paidMonths = [];
  var shouldPay=[];

  for(int i = 0;i < studyDays.length;i++){
    if(!studyMonths.contains(convertDateToMonthYear(studyDays[i]['studyDay']))){
      studyMonths.add(convertDateToMonthYear(studyDays[i]['studyDay']));
    }
  }
  for(int i = 0;i < payments.length;i++){
    if(!paidMonths.contains(convertDateToMonthYear(payments[i]['paidDate']))){
      paidMonths.add(convertDateToMonthYear(payments[i]['paidDate']));
    }
  }
  for(int i = 0;i< studyMonths.length;i++){
    var month = studyMonths[i];
    if(!paidMonths.contains(month)){
      shouldPay.add(month);
    }

  }




  return shouldPay;

}

List<String> generateMonthsList() {
  List<String> months = [];
  DateTime now = DateTime.now();
  DateTime start = DateTime(2025, 2);

  while (start.isBefore(DateTime(now.year, now.month + 1))) {
    String monthName = '${_monthName(start.month)}, ${start.year}';
    months.add(monthName);
    start = DateTime(start.year, start.month + 1);
  }

  return months;
}






String _monthName(int month) {
  switch (month) {
    case 1:
      return 'January';
    case 2:
      return 'February';
    case 3:
      return 'March';
    case 4:
      return 'April';
    case 5:
      return 'May';
    case 6:
      return 'June';
    case 7:
      return 'July';
    case 8:
      return 'August';
    case 9:
      return 'September';
    case 10:
      return 'October';
    case 11:
      return 'November';
    case 12:
      return 'December';
    default:
      return '';
  }
}

String getCurrentMonthInUzbek() {
  List<String> monthsUzbek = [
    'Yanvar', 'Fevral', 'Mart', 'Aprel', 'May', 'Iyun',
    'Iyul', 'Avgust', 'Sentyabr', 'Oktyabr', 'Noyabr', 'Dekabr'
  ];

  DateTime now = DateTime.now();
  int monthIndex = now.month; // Get current month index (1 to 12)
  return monthsUzbek[monthIndex - 1]; // Subtract 1 since list is 0-indexed
}
List<String> generateMonths() {
  List<String> months = [];
  DateTime now = DateTime.now();

  // Add 6 months before the current month, current month, and 6 months after
  for (int i = -3; i <= 6; i++) {
    // Set a fixed day (e.g., 10nd of each month)
    DateTime date = DateTime(now.year, now.month + i, 10);
    String formattedDate = DateFormat('dd-MM-yyyy').format(date);  // Format as DD-MM-YYYY
    months.add(formattedDate);
  }

  return months;
}
List<String> getFormattedMonthsOfCurrentYear() {
  List<String> months = [];

  // Get the current year
  DateTime now = DateTime.now();
  int currentYear = now.year;

  // Generate the list of months with the 22nd day for the current year
  for (int month = 1; month <= 12; month++) {
    DateTime date = DateTime(currentYear, month, 22);
    String formattedDate = DateFormat('dd-MM-yyyy').format(date);  // Format as 22-MM-yyyy
    months.add(formattedDate);
  }

  return months;
}
