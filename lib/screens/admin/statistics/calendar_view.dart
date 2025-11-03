import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';

class CalendarScreen extends StatefulWidget {
  final List days;
  const CalendarScreen({Key? key, required this.days}) : super(key: key);

  @override
  _CalendarScreenState createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  late Map<DateTime, List<Map<String, dynamic>>> events;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  @override
  void initState() {
    super.initState();
    events = {};
    _populateEvents();
  }

  DateTime _toKeyDate(dynamic raw) {
    DateTime dt;
    if (raw is DateTime) {
      dt = raw;
    } else if (raw != null &&
        raw.runtimeType.toString().contains('Timestamp')) {
      dt = (raw as dynamic).toDate() as DateTime;
    } else if (raw is int) {
      dt = DateTime.fromMillisecondsSinceEpoch(raw);
    } else if (raw is String) {
      dt = DateTime.parse(raw);
    } else {
      throw Exception('Unsupported day type: ${raw.runtimeType}');
    }
    return DateTime(dt.year, dt.month, dt.day);
  }

  void _populateEvents() {
    events.clear();
    for (final item in widget.days) {
      try {
        final key = _toKeyDate(item['day']);
        final normalized = Map<String, dynamic>.from(item as Map);
        if (events.containsKey(key)) {
          events[key]!.add(normalized);
        } else {
          events[key] = [normalized];
        }
      } catch (e) {
        debugPrint('Parse error: $e, item: $item');
      }
    }
  }

  /// Returns background color for attendance code
  Color _getAttendanceColor(String? code) {
    switch (code) {
      case '2':
        return Colors.green;
      case '1':
        return Colors.orange;
      case '-1':
        return Colors.red;
      default:
        return Colors.grey.shade300;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Davomat kalendari')),
      body: TableCalendar(
        firstDay: DateTime.utc(2020, 1, 1),
        lastDay: DateTime.utc(2050, 12, 31),
        focusedDay: _focusedDay,
        selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
        onDaySelected: (selected, focused) {
          setState(() {
            _selectedDay = selected;
            _focusedDay = focused;
          });
        },
        eventLoader: (day) {
          final key = DateTime(day.year, day.month, day.day);
          return events[key] ?? [];
        },
        calendarBuilders: CalendarBuilders(
          defaultBuilder: (context, day, focusedDay) {
            final key = DateTime(day.year, day.month, day.day);
            final dayEvents = events[key] ?? [];

            if (dayEvents.isNotEmpty) {
              final event = dayEvents.first;
              final attendance = event['attendance']?.toString();
              return Container(
                margin: const EdgeInsets.all(6),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: _getAttendanceColor(attendance),
                ),
                child: Text(
                  '${day.day}',
                  style: const TextStyle(
                      color: Colors.white, fontWeight: FontWeight.bold),
                ),
              );
            }

            return Container(
              margin: const EdgeInsets.all(6),
              alignment: Alignment.center,
              child: Text('${day.day}'),
            );
          },

          todayBuilder: (context, day, focusedDay) {
            final key = DateTime(day.year, day.month, day.day);
            final dayEvents = events[key] ?? [];
            if (dayEvents.isNotEmpty) {
              final event = dayEvents.first;
              final attendance = event['attendance']?.toString();
              return Container(
                margin: const EdgeInsets.all(6),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: _getAttendanceColor(attendance),
                  border: Border.all(color: Colors.blueAccent, width: 2),
                ),
                child: Text(
                  '${day.day}',
                  style: const TextStyle(
                      color: Colors.white, fontWeight: FontWeight.bold),
                ),
              );
            }
            return Container(
              margin: const EdgeInsets.all(6),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: Colors.blueAccent, width: 2),
              ),
              child: Text(
                '${day.day}',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            );
          },

          selectedBuilder: (context, day, focusedDay) {
            return Container(
              margin: const EdgeInsets.all(6),
              alignment: Alignment.center,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.orange,
              ),
              child: Text(
                '${day.day}',
                style: const TextStyle(
                    color: Colors.white, fontWeight: FontWeight.bold),
              ),
            );
          },

          // 🔴 This disables the under-dot completely
          markerBuilder: (context, day, events) => const SizedBox.shrink(),
        ),

      ),
    );
  }
}
