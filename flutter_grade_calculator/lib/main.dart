import 'package:flutter/material.dart';
import 'package:excel/excel.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:typed_data';
import 'dart:html' as html; // for web download

void main() => runApp(MyApp());

// Basic Calculator
class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Calculator & Grade Calculator',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: CalculatorScreen(),
    );
  }
}

class CalculatorScreen extends StatefulWidget {
  @override
  _CalculatorScreenState createState() => _CalculatorScreenState();
}

class _CalculatorScreenState extends State<CalculatorScreen> {
  // ---- Basic Calculator Variables ----
  String input = '';
  String result = '';
  String operation = '';
  double first = 0;

  final List<String> buttons = [
    '7','8','9','/',
    '4','5','6','*',
    '1','2','3','-',
    '0','.','=','+',
    'C'
  ];

  void buttonPressed(String value) {
    setState(() {
      if (value == 'C') {
        input = '';
        result = '';
        first = 0;
        operation = '';
      } else if (value == '+' || value == '-' || value == '*' || value == '/') {
        first = double.tryParse(input) ?? 0;
        input = '';
        operation = value;
      } else if (value == '=') {
        double second = double.tryParse(input) ?? 0;
        switch (operation) {
          case '+':
            result = (first + second).toString();
            break;
          case '-':
            result = (first - second).toString();
            break;
          case '*':
            result = (first * second).toString();
            break;
          case '/':
            result = (second != 0) ? (first / second).toString() : 'Error';
            break;
        }
        input = '';
      } else {
        input += value;
      }
    });
  }

  // ---- Grade Calculator Variables ----
  List<Map<String, dynamic>> students = [];

  String calculateGrade(double marks) {
    if (marks >= 90) return 'A';
    if (marks >= 80) return 'B';
    if (marks >= 70) return 'C';
    if (marks >= 60) return 'D';
    return 'F';
  }

  Future<void> pickExcelFile() async {
    final result = await FilePicker.platform.pickFiles(
      allowedExtensions: ['xlsx'],
      type: FileType.custom,
    );
    if (result != null && result.files.single.bytes != null) {
      final bytes = result.files.single.bytes!;
      final excel = Excel.decodeBytes(bytes);
      List<Map<String, dynamic>> temp = [];

      for (var table in excel.tables.keys) {
        for (var row in excel.tables[table]!.rows.skip(1)) {
          String name = row[0]?.value.toString() ?? '';
          String course = row[1]?.value.toString() ?? '';
          double marks = double.tryParse(row[2]?.value.toString() ?? '0') ?? 0;
          temp.add({'name': name, 'course': course, 'marks': marks});
        }
      }

      setState(() {
        students = temp;
      });
    }
  }

  void saveExcelFile() {
    var excel = Excel.createExcel();
    Sheet sheet = excel['Grades'];
    sheet.appendRow(['Name', 'Course', 'Grade']);
    for (var s in students) {
      sheet.appendRow([s['name'], s['course'], calculateGrade(s['marks'])]);
    }

    final bytes = excel.encode()!;
    final blob = html.Blob([bytes]);
    final url = html.Url.createObjectUrlFromBlob(blob);
    final anchor = html.AnchorElement(href: url)
      ..setAttribute("download", "grades.xlsx")
      ..click();
    html.Url.revokeObjectUrl(url);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Calculator & Grade Calculator')),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Column(
            children: [
              // --- Basic Calculator Section ---
              Container(
                alignment: Alignment.centerRight,
                padding: EdgeInsets.symmetric(vertical: 24, horizontal: 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(input, style: TextStyle(fontSize: 24)),
                    Text(result, style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
              GridView.builder(
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                itemCount: buttons.length,
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 4),
                itemBuilder: (context, index) {
                  final button = buttons[index];
                  return Padding(
                    padding: EdgeInsets.all(4),
                    child: ElevatedButton(
                      onPressed: () => buttonPressed(button),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      child: Text(button, style: TextStyle(fontSize: 24)),
                    ),
                  );
                },
              ),
              SizedBox(height: 24),

              // --- Grade Calculator Section ---
              Text('Upload Excel to get Grades', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton(
                    onPressed: pickExcelFile,
                    child: Text('Upload Excel'),
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.blueAccent),
                  ),
                  ElevatedButton(
                    onPressed: saveExcelFile,
                    child: Text('Download Grades'),
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                  ),
                ],
              ),
              SizedBox(height: 16),

              // Optional: preview table
              if (students.isNotEmpty)
                Column(
                  children: students.map((s) {
                    return Card(
                      color: Colors.blue[50],
                      child: ListTile(
                        title: Text('${s['name']} (${s['course']})'),
                        trailing: Text(calculateGrade(s['marks'])),
                      ),
                    );
                  }).toList(),
                ),
            ],
          ),
        ),
      ),
    );
  }
}