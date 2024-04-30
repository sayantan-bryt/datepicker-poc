import 'dart:math';

import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';

/// Flutter code sample for [showDatePicker].

void main() => runApp(const DatePickerApp());

class DatePickerApp extends StatelessWidget {
  const DatePickerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(useMaterial3: true),
      restorationScopeId: 'app',
      home: const DatePickerExample(),
    );
  }
}

class DatePickerExample extends StatefulWidget {
  const DatePickerExample({super.key});

  @override
  State<DatePickerExample> createState() => _DatePickerExampleState();
}

enum EventType {
  holiday, other
}

class Event {
  final String name;
  final DateTime date;
  final EventType type;
  const Event({
    required this.name,
    required this.date,
    required this.type
  });
}

class _DatePickerExampleState extends State<DatePickerExample> {
  late DateTime _today, _lastDay, _focusedDay, _selectedDay;
  late final List<DateTime> _schoolWhitelist;
  late final List<Event> events;
  List<Event> _eventsToShow = [];

  DateTime onlyDay(DateTime dt) => DateTime.utc(dt.year, dt.month, dt.day);

  @override
  void initState() {
    // TODO: implement initState
    _today = _focusedDay = _selectedDay = onlyDay(DateTime.now());
    _lastDay = onlyDay(_today.add(const Duration(days: 100)));
    _schoolWhitelist = List<DateTime>.generate(
        20, (i) => onlyDay(_today.add(Duration(days: i * 2))));
    events = List.generate(10, (index) {
      final days = _schoolWhitelist;
      final which = Random().nextInt(days.length);
      final day = days[which];
      final typeC = Random().nextInt(EventType.values.length);
      final type = EventType.values[typeC];
      return Event(name: 'event $day', type: type, date: day);
    });
    setState(() {});
    super.initState();
  }

  bool _isDayEnabled(DateTime day) => _schoolWhitelist.contains(day);

  List<Event> _getEventsForDay(DateTime day) =>
      events.where((event) => event.date == day).toList();

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: Column(
          children: [
            Center(
              child: OutlinedButton(
                onPressed: () async {
                  await showDatePicker(
                  context: context,
                  initialDate: _today,
                  firstDate: _today,
                  lastDate: _lastDay,
                  selectableDayPredicate: _isDayEnabled);
                },
                child: const Text('Open Date Picker'),
              ),
            ),
            TableCalendar(
              // calendarFormat: CalendarFormat.month,
              focusedDay: _focusedDay,
              firstDay: _today,
              lastDay: _lastDay,
              availableCalendarFormats: const {CalendarFormat.month: 'month',},
              enabledDayPredicate: _isDayEnabled, // requires tz aware utc dt
              selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
              onDaySelected: (selectedDay, focusedDay) {
                if(isSameDay(selectedDay, _selectedDay)) return;
                setState(() {
                  _focusedDay = selectedDay;
                  _selectedDay = selectedDay;
                  _eventsToShow = _getEventsForDay(selectedDay);
                });
              },
              calendarBuilders: CalendarBuilders(
                  singleMarkerBuilder: (context, day, Event event) {
                return Container(
                  width: 6,
                  height: 6,
                  margin: const EdgeInsets.symmetric(horizontal: 3),
                  decoration: BoxDecoration(
                    color: event.type == EventType.holiday
                        ? Colors.red
                        : Colors.blue,
                    shape: BoxShape.circle,
                  ),
                );
              }),
              eventLoader: _getEventsForDay,
              // daysOfWeekStyle: const DaysOfWeekStyle(
              //   // ... other styles
              //     weekdayStyle: TextStyle(fontSize: 16.0, color: Colors.black),
              //     weekendStyle: TextStyle(fontSize: 16.0, color: Colors.red)
              // ),
              // calendarStyle: const CalendarStyle(
              //   markersMaxCount: 2,
              //   markersAlignment: Alignment.bottomCenter,
              //   defaultTextStyle: TextStyle(fontSize: 8, color: Colors.black),
              // ),
              // headerStyle: const HeaderStyle(
              //   formatButtonVisible: false,
              // ),
            ),
            ..._eventsToShow.map(
                (e) => Text("Name: ${e.name} Type: ${e.type}")),
          ],
        ),
      ),
    );
  }
}
