import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart'; // Required for initializing locales
import 'package:madrassa/constants/colors.dart';
import 'package:madrassa/model/teacher.dart';

class TeacherDetails extends StatelessWidget {
  final Teacher teacher;

  const TeacherDetails({super.key, required this.teacher});

  @override
  Widget build(BuildContext context) {
    // Initialize the date formatting for French locale
    initializeDateFormatting('fr', null);

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Détails d'enseignant",
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Center(
              child: CircleAvatar(
                radius: 50,
                backgroundImage: AssetImage("assets/images/profile.png"),
              ),
            ),
            const SizedBox(height: 24),
            Center(
              child: Text(
                teacher.name,
                style: TextStyle(
                  color: primaryColor,
                  fontWeight: FontWeight.bold,
                  fontSize: 24,
                ),
              ),
            ),
            const SizedBox(height: 8),
            Center(
              child: Text(
                teacher.email,
                style: TextStyle(color: secondaryColor, fontSize: 16),
              ),
            ),
            const SizedBox(height: 24),
            Divider(color: primaryColor),
            const SizedBox(height: 16),
            _buildDetailTile(
              icon: Icons.phone,
              title: 'Téléphone',
              value: teacher.phone,
            ),
            _buildDetailTile(
              icon: Icons.book,
              title: 'Sujet',
              value: teacher.subject.toString().split('.').last,
            ),
            _buildDetailTile(
              icon: Icons.school,
              title: 'Niveau',
              value: teacher.level.toString().split('.').last,
            ),
            _buildDetailTile(
              icon: Icons.person,
              title: 'Sexe',
              value: teacher.sex.name,
            ),
            _buildDetailTile(
              icon: Icons.calendar_today,
              title: 'Créé le',
              value: DateFormat.yMMMMEEEEd("fr").format(teacher.createdAt),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailTile({
    required IconData icon,
    required String title,
    required String value,
  }) {
    return ListTile(
      leading: Icon(icon, color: primaryColor),
      title: Text(
        title,
        style: TextStyle(
          color: secondaryColor,
          fontWeight: FontWeight.bold,
          fontSize: 14,
        ),
      ),
      subtitle: Text(
        value,
        style: TextStyle(
          color: primaryColor,
          fontSize: 16,
        ),
      ),
      contentPadding: const EdgeInsets.symmetric(vertical: 4.0),
    );
  }
}
