import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart' as intl;
import 'package:madrassa/constants/colors.dart';
import 'package:madrassa/constants/enums.dart';
import 'package:madrassa/model/groupe.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:madrassa/model/cours.dart';

import 'class_details.dart';
import 'groupe_details.dart';

class Timetable extends StatefulWidget {
  const Timetable({super.key});

  @override
  TimetableState createState() => TimetableState();
}

class TimetableState extends State<Timetable> {
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay = DateTime.now();
  List<Cours> courses = existingCours;

  void filterCourses() {
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
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          TableCalendar(
            firstDay: DateTime.utc(2024, 1, 1),
            lastDay: DateTime.utc(DateTime.now().year + 1, 12, 31),
            focusedDay: _focusedDay,
            selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
            onDaySelected: (selectedDay, focusedDay) {
              _selectedDay = selectedDay;
              _focusedDay = focusedDay;
              filterCourses();
            },
            calendarFormat: CalendarFormat.twoWeeks,
            calendarStyle: CalendarStyle(
              isTodayHighlighted: true,
              defaultTextStyle: const TextStyle(color: Colors.white),
              disabledTextStyle: const TextStyle(color: Colors.white),
              rowDecoration: BoxDecoration(color: secondaryColor),
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
              leftChevronIcon: const Icon(
                Icons.arrow_back_ios,
                size: 15,
                color: Colors.white,
              ),
              rightChevronIcon: const Icon(
                Icons.arrow_forward_ios,
                size: 15,
                color: Colors.white,
              ),
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
    // Define three lists for each section
    List<Map<String, dynamic>> currentGroups = [];
    List<Map<String, dynamic>> finishedGroups = [];
    List<Map<String, dynamic>> upcomingGroups = [];

    // Populate each section based on the schedule relative to the selected day and time
    for (final course in courses) {
      List<Group> currentCourseGroups = [];
      List<Group> finishedCourseGroups = [];
      List<Group> upcomingCourseGroups = [];

      for (final group in course.groups) {
        bool isCurrent = false;
        bool isFinished = false;

        // Check if the group is currently studying, has finished, or has yet to start
        for (final schedule in group.schedule) {
          final startTime = schedule.start;
          final endTime = schedule.end;
          if (_selectedDay!.isAfter(startTime) && _selectedDay!.isBefore(endTime)) {
            print("current");
            isCurrent = true;
            break;
          } else if (_selectedDay!.isAfter(endTime)) {
            isFinished = true;
          }
        }

        if (group.repeatedDaysOfWeek != null) {
          for (final schedule in group.repeatedDaysOfWeek!) {
            final startTime = schedule.start;
            final endTime = schedule.end;
            if (_selectedDay!.day==DateTime.now().day  &&
                DateTime.now().weekday==schedule.dayIndex  &&
                DateTime.now().isBefore(DateTime(DateTime.now().year,DateTime.now().month,DateTime.now().day,endTime.hour,endTime.minute))
                && DateTime.now().isAfter(DateTime(DateTime.now().year,DateTime.now().month,DateTime.now().day,startTime.hour,startTime.minute))) {
              isCurrent = true;
              break;
            } else if (
            (_selectedDay!.day < DateTime.now().day) || (_selectedDay!.day == DateTime.now().day && DateTime.now().weekday == schedule.dayIndex &&  DateTime.now().isAfter(DateTime(DateTime.now().year,DateTime.now().month,DateTime.now().day,endTime.hour,endTime.minute))
            )) {
              isFinished = true;
            }
          }
        }
        // Add the group to the appropriate list for this course
        if (isCurrent) {
          currentCourseGroups.add(group);
        } else if (isFinished) {
          finishedCourseGroups.add(group);
        } else {
          upcomingCourseGroups.add(group);
        }
      }

      // Add course with its categorized groups to respective lists if they have groups in the section
      if (currentCourseGroups.isNotEmpty) {
        currentGroups.add({'course': course, 'groups': currentCourseGroups});
      }
      if (finishedCourseGroups.isNotEmpty) {
        finishedGroups.add({'course': course, 'groups': finishedCourseGroups});
      }
      if (upcomingCourseGroups.isNotEmpty) {
        upcomingGroups.add({'course': course, 'groups': upcomingCourseGroups});
      }
    }

    // Build widgets for each section
    return ListView(
      children: [
        if (currentGroups.isNotEmpty) _buildGroupSection("En cours", currentGroups),
        if (finishedGroups.isNotEmpty) _buildGroupSection("Déjà terminé", finishedGroups),
        if (upcomingGroups.isNotEmpty) _buildGroupSection("Pas encore commencé", upcomingGroups),
      ],
    );
  }

// Helper method to build each section
  Widget _buildGroupSection(String title, List<Map<String, dynamic>> courseGroupData) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              title,
              style: const TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
            ),
          ),
          ...courseGroupData.map((data) {
            final course = data['course'] as Cours;
            final groups = data['groups'] as List<Group>;

            return _buildCourseTile(course, groups);
          }).toList(),
        ],
      ),
    );
  }

// Helper method to build a tile for each course and display only the relevant groups in each section
  Widget _buildCourseTile(Cours course, List<Group> groups) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => CoursDetailsPage(cours: course),
          ),
        );
      },
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: ExpansionTile(
          leading: Icon(
            FontAwesomeIcons.bookOpenReader,
            color: secondaryColor,
          ),
          title: Text(
            course.name,
            textDirection: TextDirection.rtl,
            textAlign: TextAlign.center,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 8.0,
                  mainAxisSpacing: 8.0,
                  childAspectRatio: 1.5,
                ),
                itemCount: groups.length,
                itemBuilder: (context, groupIndex) {
                  final group = groups[groupIndex];

                  // Format the schedules for each group
                  final events = group.schedule.map((schedule) {
                    return '${intl.DateFormat.MMMMEEEEd("fr").format(schedule.start)}\n${TimeOfDay(hour: schedule.start.hour, minute: schedule.start.minute).format(context)} - ${TimeOfDay(hour: schedule.end.hour, minute: schedule.end.minute).format(context)}';
                  }).join('\n');

                  // Prepare the repeated days information
                  String repeatedDays = "";
                  if (group.repeatedDaysOfWeek != null && group.repeatedDaysOfWeek!.isNotEmpty) {
                    if (group.repeatedDaysOfWeek!.length < 7) {
                      repeatedDays = group.repeatedDaysOfWeek!.map((day) => day.dayNameFr).join(', ');
                    } else {
                      repeatedDays = "Chaque jour";
                    }
                    repeatedDays += "\n${group.repeatedDaysOfWeek!.first.start.format(context)} - ${group.repeatedDaysOfWeek!.first.end.format(context)}";
                  }

                  return GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => GroupeDetails(group: group),
                        ),
                      );
                    },
                    child: Card(
                      color: Colors.white,
                      elevation: 2.0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.0),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Text(
                              group.name,
                              style: const TextStyle(fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 4.0),
                            Text(
                              'Salle: ${group.room?.name ?? 'salle non sélectionnée'}',
                              style: const TextStyle(color: Colors.black54),
                            ),
                            if (events.isNotEmpty)
                              Expanded(
                                child: Text(
                                  events,
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(color: Colors.black54),
                                ),
                              ),
                            if (repeatedDays.isNotEmpty)
                              Expanded(
                                child: Text(
                                  repeatedDays,
                                  style: const TextStyle(color: Colors.black54),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
