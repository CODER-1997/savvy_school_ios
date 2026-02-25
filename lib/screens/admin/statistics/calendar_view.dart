import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';

class CalendarScreen extends StatefulWidget {
  final List<dynamic> days;

  CalendarScreen({required this.days});

  @override
  _CalendarScreenState createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  late Map<DateTime, List<dynamic>> _events;
  DateTime _focusedDay = DateTime.now();

  @override
  void initState() {
    super.initState();
    _events = {};
    _populateEvents();
  }

  void _populateEvents() {
    for (var item in widget.days) {
      final dateValue = item['day'];
      DateTime rawDate = (dateValue is String) ? DateTime.parse(dateValue) : dateValue;
      final dayKey = DateTime.utc(rawDate.year, rawDate.month, rawDate.day);

      if (_events[dayKey] == null) _events[dayKey] = [];
      _events[dayKey]!.add(item);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        title: const Text('Davomat jurnali', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child:  TableCalendar(
              firstDay: DateTime.utc(2020, 1, 1),
              lastDay: DateTime.utc(2050, 12, 31),
              focusedDay: _focusedDay,
              headerStyle: const HeaderStyle(
                formatButtonVisible: false,
                titleCentered: true,
              ),
              // Standart markerlarni butkul o'chiramiz
              calendarStyle: const CalendarStyle(
                 outsideDaysVisible: false, // Boshqa oydagi kunlarni yashirish (toza ko'rinish uchun)
              ),
              eventLoader: (day) => _events[DateTime.utc(day.year, day.month, day.day)] ?? [],
              calendarBuilders: CalendarBuilders(
                // 1. ASOSIY QISM: Kelgan/Kelmagan kunlarni bo'yash
                prioritizedBuilder: (context, day, focusedDay) {
                  final dayKey = DateTime.utc(day.year, day.month, day.day);
                  final data = _events[dayKey];

                  if (data != null && data.isNotEmpty) {
                    final bool isAttended = data.first['isAttended'] == true || data.first['isAttended'] == 1;

                    return Center(
                      child: Container(
                        margin: const EdgeInsets.all(6.0),
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: isAttended ? const Color(0xFF34C759) : const Color(0xFFFF3B30),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 4,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Text(
                          '${day.day}',
                          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                        ),
                      ),
                    );
                  }
                  return null;
                },

                // 2. BUGUNGI KUN: Agar ma'lumot bo'lmasa, bugun qanday ko'rinsin?
                todayBuilder: (context, day, focusedDay) {
                  return Center(
                    child: Container(
                      margin: const EdgeInsets.all(6.0),
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.blueAccent, width: 2),
                      ),
                      child: Text(
                        '${day.day}',
                        style: const TextStyle(color: Colors.blueAccent, fontWeight: FontWeight.bold),
                      ),
                    ),
                  );
                },

                // 3. MARKERLARNI YO'QOTISH: MarkerBuilder bo'sh bo'lishi shart
                markerBuilder: (context, day, events) => const SizedBox(),
              ),
            )
          ),
          const SizedBox(height: 20),
         ],
      ),
    );
  }

  // Pastki qismdagi tushuntirish (Legend)


  Widget _legendItem(Color color, String text) {
    return Row(
      children: [
        Container(width: 12, height: 12, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
        const SizedBox(width: 6),
        Text(text, style: const TextStyle(fontSize: 14, color: Colors.grey)),
      ],
    );
  }
}