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
  _DailyProgramState createState() => _DailyProgramState();
}

class _DailyProgramState extends State<DailyProgram> {
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
  Future<void> _generatePDF() async {
    final pdf = pw.Document();
    final filteredCourses = getFilteredCourses();

    if (filteredCourses.isEmpty) {
      print("No courses found for the selected date and time range.");
    }

    final arabicFont = await PdfGoogleFonts.amiriRegular();

    final daysOfWeekInFrench = [
      'Lundi', 'Mardi', 'Mercredi', 'Jeudi', 'Vendredi', 'Samedi', 'Dimanche'
    ];

    pdf.addPage(
      pw.Page(
        build: (pw.Context context) {
          return pw.Column(
            children: [
              pw.Text(
                'Program for ${intl.DateFormat.yMMMMd().format(_selectedDate)}',
                style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold),
              ),
              pw.SizedBox(height: 16),
              ...daysOfWeekInFrench.map((dayName) {
                final dayCourses = filteredCourses.where((courseData) {
                  final course = courseData['course'] as Cours;
                  final groups = courseData['groups'] as List<Group>;

                  return groups.any((group) {
                    return group.schedule.any((schedule) {
                      final dayOfWeek = intl.DateFormat.E().format(schedule.start);
                      return dayOfWeek == dayName.substring(0, 3);
                    });
                  });
                }).toList();

                if (dayCourses.isNotEmpty) {
                  return pw.Column(
                    children: [
                      pw.Text(
                        dayName,
                        style: pw.TextStyle(fontSize: 20, fontWeight: pw.FontWeight.bold),
                      ),
                      pw.Table(
                        border: pw.TableBorder.all(width: 1, color: PdfColors.black),
                        children: [
                          pw.TableRow(
                            children: [
                              pw.Text(
                                'Course',
                                style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold),
                              ),
                              pw.Text(
                                'Group',
                                style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold),
                              ),
                              pw.Text(
                                'Time',
                                style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold),
                              ),
                            ],
                          ),
                          ...List.generate(dayCourses.length, (index) {
                            final courseData = dayCourses[index];
                            final course = courseData['course'];
                            final groups = courseData['groups'];

                            return pw.TableRow(
                              children: List.generate(groups.length, (groupIndex) {
                                final group = groups[groupIndex];
                                return pw.Row(
                                  children: [
                                    pw.Text(course.name, style: const pw.TextStyle(fontSize: 10)),
                                    pw.Text(group.name, style: const pw.TextStyle(fontSize: 10)),
                                    pw.Text(
                                      group.schedule
                                          .where((schedule) =>
                                      intl.DateFormat.E().format(schedule.start) ==
                                          dayName.substring(0, 3))
                                          .map((schedule) {
                                        return '${intl.DateFormat.Hm().format(schedule.start)} - ${intl.DateFormat.Hm().format(schedule.end)}';
                                      }).join('\n'),
                                      style: const pw.TextStyle(fontSize: 10),
                                    ),
                                  ],
                                );
                              }),
                            );
                          }),
                        ],
                      ),
                      pw.SizedBox(height: 16),
                    ],
                  );
                } else {
                  return pw.Container();
                }
              }).toList(),
            ],
          );
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
                  onPressed: _generatePDF,
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
                            final scheduleDetails = group.schedule.map((schedule) {
                              return '${intl.DateFormat.jm().format(schedule.start)} - ${intl.DateFormat.jm().format(schedule.end)}';
                            }).join('\n');

                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Group: ${group.name}',
                                  style: const TextStyle(fontWeight: FontWeight.bold),
                                ),
                                const SizedBox(height: 4.0),
                                Text(
                                  'Time: $scheduleDetails',
                                  style: const TextStyle(color: Colors.black54),
                                ),
                              ],
                            );
                          }).toList(),
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
