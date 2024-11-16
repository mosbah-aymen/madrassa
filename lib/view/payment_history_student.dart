import 'package:flutter/material.dart';
import 'package:intl/intl.dart' as intl;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:madrassa/model/payment.dart';
import 'package:madrassa/model/student.dart';

class PaymentHistoryStudent extends StatefulWidget {
  final Student student;

  const PaymentHistoryStudent({super.key, required this.student});

  @override
  PaymentHistoryStudentState createState() => PaymentHistoryStudentState();
}

class PaymentHistoryStudentState extends State<PaymentHistoryStudent> {
  DateTimeRange? dateRange;
  List<Payment> payments = [];

  @override
  void initState() {
    super.initState();
    // Initialize date range to the last month
    DateTime now = DateTime.now();
    dateRange = DateTimeRange(
      start: DateTime(now.year, now.month - 1, now.day),
      end: now,
    );
    fetchPayments();
  }

  Future<void> fetchPayments() async {
    // Fetch payments from Firestore and filter by date range
    QuerySnapshot snapshot = await FirebaseFirestore.instance
        .collection('payments')
        .where('student.id', isEqualTo: widget.student.id)
        .get();

    List<Payment> fetchedPayments = snapshot.docs.map((doc) {
      return Payment.fromMap(doc.data() as Map<String, dynamic>, doc.id);
    }).toList();

    // Filter payments based on the date range
    payments = fetchedPayments.where((payment) {
      return payment.date.isAfter(dateRange!.start) && payment.date.isBefore(dateRange!.end);
    }).toList();

    setState(() {});
  }

  Future<void> pickDateRange() async {
    DateTimeRange? newDateRange = await showDateRangePicker(
      context: context,
      initialDateRange: dateRange,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );

    if (newDateRange == null) return;

    setState(() {
      dateRange = newDateRange;
      fetchPayments();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Historique des paiements"),
        actions: [
          IconButton(
            icon: const Icon(Icons.date_range),
            onPressed: pickDateRange,
          ),
        ],
      ),
      body: Column(
        children: [
          if (dateRange != null) ...[
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                'Du ${intl.DateFormat.yMMMd('fr').format(dateRange!.start)} au ${intl.DateFormat.yMMMd('fr').format(dateRange!.end)}',
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
          ],
          Expanded(
            child: payments.isEmpty
                ? const Center(child: Text("Aucun paiement trouvé dans cette période."))
                : ListView.builder(
              itemCount: payments.length,
              itemBuilder: (context, index) {
                Payment payment = payments[index];
                return Card(
                  color: Colors.blue.shade50,
                  margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: Colors.blue,
                      child: Text(
                        intl.DateFormat.d('fr').format(payment.date),
                        style: const TextStyle(color: Colors.white),
                      ),
                    ),
                    title: Text(
                      "Montant: ${payment.amount} DZD",
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("Session: ${payment.sessionNumber}"),
                        Text("Date: ${intl.DateFormat.yMMMMd('fr').format(payment.date)}"),
                        Text("${payment.groupe.cours?.name}",textDirection: TextDirection.rtl,),
                        Text(payment.groupe.name),
                      ],
                    ),
                    trailing: const Icon(Icons.arrow_forward_ios),
                    onTap: () {
                      // Handle on tap if needed
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
