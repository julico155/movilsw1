import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class PaymentPage extends StatefulWidget {
  final String mobile;

  PaymentPage({required this.mobile});

  @override
  _PaymentPageState createState() => _PaymentPageState();
}

class _PaymentPageState extends State<PaymentPage> {
  late Future<List<Payment>> payments;

  @override
  void initState() {
    super.initState();
    payments = fetchPayments();
  }

  Future<List<Payment>> fetchPayments() async {
    final mobileNumber = widget.mobile;
    final response = await http.get(Uri.parse(
        'http://ec2-18-226-181-124.us-east-2.compute.amazonaws.com:3000/api/feesdetails?mobile=$mobileNumber')); // Reemplaza con la URL correcta y el móvil correspondiente

    if (response.statusCode == 200) {
      List jsonResponse = json.decode(response.body);
      return jsonResponse.map((data) => Payment.fromJson(data)).toList();
    } else {
      throw Exception('Failed to load payments');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Estado de Pagos'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: FutureBuilder<List<Payment>>(
          future: payments,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return Center(child: Text('No hay pagos disponibles.'));
            } else {
              return ListView.builder(
                itemCount: snapshot.data!.length,
                itemBuilder: (context, index) {
                  return buildPaymentCard(snapshot.data![index]);
                },
              );
            }
          },
        ),
      ),
    );
  }

  Widget buildPaymentCard(Payment payment) {
    return Card(
      elevation: 4,
      margin: EdgeInsets.symmetric(vertical: 10),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      child: ListTile(
        leading: Icon(
          payment.status == PaymentStatus.paid
              ? Icons.check_circle
              : payment.status == PaymentStatus.pending
                  ? Icons.hourglass_empty
                  : Icons.cancel,
          color: payment.status == PaymentStatus.paid
              ? Colors.green
              : payment.status == PaymentStatus.pending
                  ? Colors.orange
                  : Colors.red,
        ),
        title: Text(
          '${payment.productId} - \$${payment.amount.toStringAsFixed(2)}',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 5),
            Text(
                'Estudiante: ${payment.studentName}'), // Mostrar el nombre del estudiante
            Text('Fecha: ${payment.date}'),
            SizedBox(height: 10),
            Text(
              payment.status == PaymentStatus.paid
                  ? 'Estado: Pagado'
                  : payment.status == PaymentStatus.pending
                      ? 'Estado: Pendiente'
                      : 'Estado: Deuda',
              style: TextStyle(
                color: payment.status == PaymentStatus.paid
                    ? Colors.green
                    : payment.status == PaymentStatus.pending
                        ? Colors.orange
                        : Colors.red,
              ),
            ),
          ],
        ),
        trailing: Icon(Icons.arrow_forward, color: Colors.blue),
      ),
    );
  }
}

enum PaymentStatus { paid, pending, debt }

class Payment {
  final int id;
  final String feesLineId;
  final String invoiceId;
  final double amount;
  final String date;
  final String productId;
  final String studentId;
  final String studentName; // Añadir el nombre del estudiante
  final double feesFactor;
  final PaymentStatus status;

  Payment({
    required this.id,
    required this.feesLineId,
    required this.invoiceId,
    required this.amount,
    required this.date,
    required this.productId,
    required this.studentId,
    required this.studentName, // Añadir el nombre del estudiante
    required this.feesFactor,
    required this.status,
  });

  factory Payment.fromJson(Map<String, dynamic> json) {
    return Payment(
      id: json['id'],
      feesLineId: json['fees_line_id'][1],
      invoiceId:
          json['invoice_id'] != false ? json['invoice_id'][1] : 'No Invoice',
      amount:
          (json['amount'] as num).toDouble(), // Conversión correcta a double
      date: json['date'],
      productId: json['product_id'][1],
      studentId: json['student_id'][0].toString(),
      studentName: json['student_id'][1], // Añadir el nombre del estudiante
      feesFactor: (json['fees_factor'] as num)
          .toDouble(), // Conversión correcta a double
      status: json['state'] == 'invoice'
          ? PaymentStatus.paid
          : PaymentStatus.pending,
    );
  }
}
