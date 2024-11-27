import 'package:flutter/material.dart';
import 'package:intl/intl.dart' as intl;
import 'package:madrassa/constants/enums.dart';
import 'package:madrassa/model/groupe.dart';
import 'package:madrassa/model/cours.dart';
import 'package:madrassa/constants/colors.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

class DailyProgram extends StatefulWidget {
  const DailyProgram({super.key});

  @override
  DailyProgramState createState() => DailyProgramState();
}

class DailyProgramState extends State<DailyProgram> {
  final DateTime _selectedDate = DateTime.now();
  DateTimeRange? _selectedTimeRange;
  List<Cours> courses = existingCours;

  // Filter courses by the selected date and time range
  List<Map<String, dynamic>> getFilteredCourses() {
    List<Map<String, dynamic>> filteredCourses = [];

    for (final course in courses) {
      List<Group> dailyGroups = [];

      for (final group in course.groups) {
        // Filter based on scheduled time for the selected day and time range
        for (final schedule in group.schedule) {
          if (isSameDay(_selectedDate, schedule.start) &&
              isWithinTimeRange(schedule.start, schedule.end)) {
            dailyGroups.add(group);
          }
        }

        if (group.repeatedDaysOfWeek != null && _selectedTimeRange!= null) {
          for (final schedule in group.repeatedDaysOfWeek!) {
            if (schedule.isWithinRange(_selectedTimeRange!)) {
                dailyGroups.add(group);
                break;
            }
          }
        }
      }

      if (dailyGroups.isNotEmpty) {
        filteredCourses.add({'course': course, 'groups': dailyGroups});
      }
    }

    return filteredCourses;
  }

  // Helper method to check if two dates are on the same day
  bool isSameDay(DateTime day1, DateTime day2) {
    return day1.year == day2.year &&
        day1.month == day2.month &&
        day1.day == day2.day;
  }

  // Helper method to check if the schedule is within the selected time range
  bool isWithinTimeRange(DateTime start, DateTime end) {
    if (_selectedTimeRange != null) {
      return start.isAfter(_selectedTimeRange!.start) &&
          end.isBefore(_selectedTimeRange!.end);
    }
    return true; // If no time range is selected, include all courses
  }

  // Method to generate the PDF program for printing
  Future<void> _generatePDF(BuildContext context) async {
    final pdf = pw.Document();
    final filteredCourses = getFilteredCourses();

    if (filteredCourses.isEmpty) {
      print("No courses found for the selected date and time range.");
      return;
    }

    final arabicFont = await PdfGoogleFonts.amiriRegular();

    final daysOfWeekInFrench = [
      'Lundi', 'Mardi', 'Mercredi', 'Jeudi', 'Vendredi', 'Samedi', 'Dimanche'
    ];

    pdf.addPage(
      pw.MultiPage(
        build: (pw.Context context) {
          return [
            pw.Text(
              'Programme pour ${intl.DateFormat.yMMMMd("fr").format(_selectedDate)}',
              style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold),
            ),
            pw.SizedBox(height: 16),

            // Iterate through each day of the week
            ...daysOfWeekInFrench.map((dayName) {
              final dayCourses = filteredCourses.where((courseData) {
                final groups = courseData['groups'] as List<Group>;

                return groups.any((group) {
                  return group.schedule.any((schedule) {
                    final dayOfWeek = intl.DateFormat.EEEE("fr").format(schedule.start);
                    return dayOfWeek.toLowerCase() == dayName.toLowerCase();
                  });
                });
              }).toList();

              if (dayCourses.isEmpty) return pw.Container();

              return pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text(
                    dayName,
                    style: pw.TextStyle(fontSize: 20, fontWeight: pw.FontWeight.bold),
                  ),
                  pw.SizedBox(height: 8),

                  // Table of courses for the day
                  pw.Table(
                    border: pw.TableBorder.all(width: 0.5, color: PdfColors.black),
                    children: [
                      // Table header
                      pw.TableRow(
                        decoration: const pw.BoxDecoration(color: PdfColors.grey300),
                        children: [
                          pw.Padding(
                            padding: const pw.EdgeInsets.all(4),
                            child: pw.Text('Cours', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                          ),
                          pw.Padding(
                            padding: const pw.EdgeInsets.all(4),
                            child: pw.Text('Groupe', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                          ),
                          pw.Padding(
                            padding: const pw.EdgeInsets.all(4),
                            child: pw.Text('Horaire', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                          ),
                        ],
                      ),

                      // Table rows for each course
                      ...dayCourses.expand((courseData) {
                        final course = courseData['course'] as Cours;
                        final groups = courseData['groups'] as List<Group>;

                        return groups.map((group) {
                          final scheduleDetails = group.schedule
                              .where((schedule) {
                            final dayOfWeek = intl.DateFormat.EEEE("fr").format(schedule.start);
                            return dayOfWeek.toLowerCase() == dayName.toLowerCase();
                          })
                              .map((schedule) =>
                          '${intl.DateFormat.Hm().format(schedule.start)} - ${intl.DateFormat.Hm().format(schedule.end)}')
                              .join(', ');

                          return pw.TableRow(
                            children: [
                              pw.Padding(
                                padding: const pw.EdgeInsets.all(4),
                                child: pw.Text(course.name, style: pw.TextStyle(font: arabicFont), textDirection: pw.TextDirection.rtl),
                              ),
                              pw.Padding(
                                padding: const pw.EdgeInsets.all(4),
                                child: pw.Text(group.name),
                              ),
                              pw.Padding(
                                padding: const pw.EdgeInsets.all(4),
                                child: pw.Text(scheduleDetails),
                              ),
                            ],
                          );
                        });
                      }),
                    ],
                  ),
                  pw.SizedBox(height: 16),
                ],
              );
            }).toList(),
          ];
        },
      ),
    );

    await Printing.layoutPdf(onLayout: (PdfPageFormat format) async => pdf.save());
  }


  // Method to show the DateTimeRange picker
  Future<void> _selectDateTimeRange(BuildContext context) async {
    final DateTimeRange? picked = await showDateRangePicker(
      context: context,
      initialDateRange: _selectedTimeRange ?? DateTimeRange(start: DateTime.now(), end: DateTime.now().add(const Duration(hours: 1))),
      firstDate: DateTime(2020),
      lastDate: DateTime(2101),
    );

    if (picked != null) {
      setState(() {
        _selectedTimeRange = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final filteredCourses = getFilteredCourses();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Daily Program'),
        backgroundColor: secondaryColor,
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            Row(
              children: [
                ElevatedButton(
                  onPressed: () => _selectDateTimeRange(context),
                  child: const Text('Select DateTime Range'),
                ),
                const SizedBox(width: 10),
                ElevatedButton(
                  onPressed:()=> _generatePDF(context),
                  child: const Text('Print Program'),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (_selectedTimeRange != null)
              Text('Selected Time Range: ${intl.DateFormat.yMd().format(_selectedTimeRange!.start)} - ${intl.DateFormat.yMd().format(_selectedTimeRange!.end)}'),
            const SizedBox(height: 16),
            filteredCourses.isEmpty
                ? const Text('No courses scheduled for this day')
                : Expanded(
              child: ListView.builder(
                itemCount: filteredCourses.length,
                itemBuilder: (context, index) {
                  final courseData = filteredCourses[index];
                  final course = courseData['course'] as Cours;
                  final groups = courseData['groups'] as List<Group>;

                  return Card(
                    elevation: 2.0,
                    margin: const EdgeInsets.symmetric(vertical: 8.0),
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            course.name,
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 8.0),
                          ...groups.map((group) {
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

                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  group.name,
                                  style: const TextStyle(fontWeight: FontWeight.bold),
                                ),
                                const SizedBox(height: 4.0),
                                if (events.isNotEmpty)
                                  Text(
                                    events,
                                    textAlign: TextAlign.center,
                                    style: const TextStyle(color: Colors.black54),
                                  ),
                                if (repeatedDays.isNotEmpty)
                                  Text(
                                    repeatedDays,
                                    style: const TextStyle(color: Colors.black54),
                                  ),
                              ],
                            );
                          }),
                        ],
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
