import 'package:flutter/material.dart';

// Abstract Calculator
abstract class Calculator {
  double add(double a, double b);
  double subtract(double a, double b);
  double multiply(double a, double b);
  double divide(double a, double b);
}

// Student model
class Student {
  String name;
  String course;
  double marks;

  Student({required this.name, required this.course, required this.marks});
}

// Grade Calculator
class GradeCalculator extends Calculator {
  List<Student> students = [];

  @override
  double add(double a, double b) => a + b;
  @override
  double subtract(double a, double b) => a - b;
  @override
  double multiply(double a, double b) => a * b;
  @override
  double divide(double a, double b) => a / b;

  double averageMarks() =>
      students.isEmpty ? 0.0 : students.map((s) => s.marks).reduce((a, b) => a + b) / students.length;

  void addStudent(Student s) => students.add(s);
}

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  final GradeCalculator calculator = GradeCalculator();

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Grade Calculator',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        scaffoldBackgroundColor: Colors.white,
      ),
      home: GradeCalculatorScreen(calculator: calculator),
    );
  }
}

class GradeCalculatorScreen extends StatefulWidget {
  final GradeCalculator calculator;

  GradeCalculatorScreen({required this.calculator});

  @override
  _GradeCalculatorScreenState createState() => _GradeCalculatorScreenState();
}

class _GradeCalculatorScreenState extends State<GradeCalculatorScreen> {
  final nameController = TextEditingController();
  final courseController = TextEditingController();
  final marksController = TextEditingController();

  void addStudent() {
    String name = nameController.text;
    String course = courseController.text;
    double? marks = double.tryParse(marksController.text);

    if (name.isEmpty || course.isEmpty || marks == null) return;

    setState(() {
      widget.calculator.addStudent(Student(name: name, course: course, marks: marks));
      nameController.clear();
      courseController.clear();
      marksController.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Grade Calculator')),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            // Input fields
            TextField(
              controller: nameController,
              decoration: InputDecoration(labelText: 'Student Name', border: OutlineInputBorder()),
            ),
            SizedBox(height: 8),
            TextField(
              controller: courseController,
              decoration: InputDecoration(labelText: 'Course', border: OutlineInputBorder()),
            ),
            SizedBox(height: 8),
            TextField(
              controller: marksController,
              decoration: InputDecoration(labelText: 'Marks', border: OutlineInputBorder()),
              keyboardType: TextInputType.number,
            ),
            SizedBox(height: 12),
            // Add button
            ElevatedButton(
              onPressed: addStudent,
              child: Text('Add Student'),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.blueAccent),
            ),
            SizedBox(height: 20),
            // List of students
            Expanded(
              child: ListView.builder(
                itemCount: widget.calculator.students.length,
                itemBuilder: (context, index) {
                  final s = widget.calculator.students[index];
                  return Card(
                    color: Colors.blue[50],
                    child: ListTile(
                      title: Text('${s.name} (${s.course})'),
                      trailing: Text('${s.marks}'),
                    ),
                  );
                },
              ),
            ),
            // Average
            Text(
              'Average Marks: ${widget.calculator.averageMarks().toStringAsFixed(1)}',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }
}