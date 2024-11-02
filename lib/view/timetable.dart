import 'package:flutter/material.dart';
import 'package:intl/intl.dart' as intl;
import 'package:madrassa/constants/colors.dart';
import 'package:madrassa/constants/enums.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:madrassa/model/cours.dart';

class Timetable extends StatefulWidget {
  const Timetable({super.key});

  @override
  TimetableState createState() => TimetableState();
}

class TimetableState extends State<Timetable> {
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay = DateTime.now();
  List<Cours> courses = existingCours;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          TableCalendar(
            firstDay: DateTime.utc(2024, 1, 1),
            lastDay: DateTime.utc(DateTime.now().year+1, 12, 31),
            focusedDay: _focusedDay,
            selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
            onDaySelected: (selectedDay, focusedDay) {
              setState(() {
                _selectedDay = selectedDay;
                _focusedDay = focusedDay;
              });
            },
            calendarFormat: CalendarFormat.twoWeeks,
            calendarStyle: CalendarStyle(
              isTodayHighlighted: true,
                   defaultTextStyle: const TextStyle(color: Colors.white),
                   disabledTextStyle: const TextStyle(color: Colors.white),
                   rowDecoration:  BoxDecoration(color: secondaryColor),
              selectedDecoration: const BoxDecoration(
                color: Colors.blueAccent,
                shape: BoxShape.circle,
              ),
              todayDecoration: const BoxDecoration(
                color: Colors.lightBlue,
                shape: BoxShape.circle,
              ),
            ),
            currentDay: _selectedDay,
            weekendDays: const [5, 6],
            daysOfWeekHeight: 20,
            daysOfWeekStyle: DaysOfWeekStyle(
              decoration: BoxDecoration(
                color: secondaryColor,
              ),
              weekdayStyle: const TextStyle(color: Colors.white),
              dowTextFormatter: (date, locale) => intl.DateFormat.E("fr").format(date).replaceAll(".", ""),
            ),
            headerStyle: HeaderStyle(
              decoration: BoxDecoration(
                color: secondaryColor,
              ),
              formatButtonTextStyle: const TextStyle(color: Colors.white),
              titleTextStyle: const TextStyle(color: Colors.white),
              formatButtonDecoration: const BoxDecoration(
                border: Border.fromBorderSide(BorderSide(color: Colors.white)),
                borderRadius: BorderRadius.all(
                  Radius.circular(
                    12.0,
                  ),
                ),
              ),
              leftChevronIcon: const Icon(Icons.arrow_back_ios,size: 15,color: Colors.white,),
              rightChevronIcon: const Icon(Icons.arrow_forward_ios,size: 15,color: Colors.white,),
            ),
            locale: "fr",
          ),
          const SizedBox(height: 8.0),
          Expanded(
            child: _buildTimetable(),
          ),
        ],
      ),
    );
  }

  Widget _buildTimetable() {
    final filteredCourses = existingCours.where((course) {
      return course.groups.any((group) {
        // Check if any repeated day matches the selected day's weekday
        final repeatedDayMatch = group.repeatedDaysOfWeek?.any((day) {
              return day.dayIndex == _selectedDay!.weekday;
            }) ??
            false;

        // Check if any scheduled day matches the selected day's date
        final scheduleDayMatch = group.schedule.any((schedule) {
          return isSameDay(_selectedDay, schedule.start);
        });

        // Return true if either repeated day or schedule day matches
        return repeatedDayMatch || scheduleDayMatch;
      });
    }).toList();
    courses = filteredCourses;
    return ListView.builder(
      itemCount: courses.length,
      itemBuilder: (context, index) {
        final course = courses[index];

        return Padding(
          padding: const EdgeInsets.all(8.0),
          child: ExpansionTile(
            title: Text(
              course.name,
              textDirection: TextDirection.rtl,
              textAlign: TextAlign.left,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            children: course.groups.map((group) {
              final events = group.schedule.map((schedule) {
                return '${intl.DateFormat.MMMMEEEEd("fr").format(schedule.start)} ${schedule.start.hour}:${schedule.start.minute.toString().padLeft(2, '0')} - ${schedule.end.hour}:${schedule.end.minute.toString().padLeft(2, '0')}';
              }).join(', ');

              String repeatedDays = "";
              if (group.repeatedDaysOfWeek != null) {
                if (group.repeatedDaysOfWeek!.length < 7) {
                  repeatedDays = group.repeatedDaysOfWeek!.map((day) => day.dayNameFr).join(', ');
                } else {
                  repeatedDays = "Chaque jour";
                }
                repeatedDays += "\n${group.repeatedDaysOfWeek!.first.start.format(context)} - ${group.repeatedDaysOfWeek!.first.end.format(context)}";
              }

              return ListTile(
                title: Text(
                  group.name,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Room: ${group.room?.name ?? 'salle non selectionnée'}',
                      style: const TextStyle(color: Colors.black54),
                    ),
                    if (events.isNotEmpty)
                      Text(
                        'Le: $events',
                        style: const TextStyle(color: Colors.black54),
                      ),
                    if (repeatedDays.isNotEmpty)
                      Text(
                        repeatedDays,
                        style: const TextStyle(color: Colors.black54),
                      ),
                  ],
                ),
              );
            }).toList(),
          ),
        );
      },
    );
  }
}
