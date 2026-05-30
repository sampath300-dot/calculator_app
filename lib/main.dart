import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

void main() {
  runApp(CalculatorApp());
}

class CalculatorApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: CalculatorScreen(),
    );
  }
}

class CalculatorScreen extends StatefulWidget {
  @override
  _CalculatorScreenState createState() => _CalculatorScreenState();
}

class _CalculatorScreenState extends State<CalculatorScreen> {
  String display = "";
  File? backgroundImage;
  final ImagePicker picker = ImagePicker();

  Future<void> pickImage() async {
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        backgroundImage = File(image.path);
      });
    }
  }

  void buttonPressed(String value) {
    setState(() {
      if (value == "C") {
        display = "";
      } else if (value == "⌫") {
        if (display.isNotEmpty) {
          display = display.substring(0, display.length - 1);
        }
      } else if (value == "=") {
        try {
          display = calculate(display);
        } catch (e) {
          display = "Error";
        }
      } else {
        display += value;
      }
    });
  }

  String calculate(String input) {
    try {
      input = input.trim();
      input = input
          .replaceAll("×", "*")
          .replaceAll("÷", "/")
          .replaceAll("%", "/100");

      List<String> tokens = [];
      String current = "";

      for (int i = 0; i < input.length; i++) {
        String ch = input[i];

        if ((ch == "-" || ch == "+") &&
            (i == 0 || "+-*/".contains(input[i - 1]))) {
          current += ch;
        } else if ("+-*/".contains(ch)) {
          if (current.isNotEmpty) tokens.add(current);
          tokens.add(ch);
          current = "";
        } else {
          current += ch;
        }
      }
      if (current.isNotEmpty) tokens.add(current);

      double result = _parseExpression(tokens, 0).$1;

      if (result == result.truncateToDouble()) {
        return result.toInt().toString();
      }
      return result.toString();
    } catch (e) {
      return "Error";
    }
  }

  (double, int) _parseExpression(List<String> tokens, int i) {
    var (left, idx) = _parseTerm(tokens, i);

    while (idx < tokens.length &&
        (tokens[idx] == "+" || tokens[idx] == "-")) {
      String op = tokens[idx];
      var (right, newIdx) = _parseTerm(tokens, idx + 1);
      left = op == "+" ? left + right : left - right;
      idx = newIdx;
    }
    return (left, idx);
  }

  (double, int) _parseTerm(List<String> tokens, int i) {
    var (left, idx) = _parseFactor(tokens, i);

    while (idx < tokens.length &&
        (tokens[idx] == "*" || tokens[idx] == "/")) {
      String op = tokens[idx];
      var (right, newIdx) = _parseFactor(tokens, idx + 1);
      left = op == "*" ? left * right : left / right;
      idx = newIdx;
    }
    return (left, idx);
  }

  (double, int) _parseFactor(List<String> tokens, int i) {
    if (i >= tokens.length) throw Exception("Unexpected end");
    return (double.parse(tokens[i]), i + 1);
  }

  Widget calcButton(String text, Color color, Color textColor) {
    return Expanded(
      child: Padding(
        padding: EdgeInsets.all(8),
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: color,
            padding: EdgeInsets.all(24),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
          ),
          onPressed: () => buttonPressed(text),
          child: Text(
            text,
            style: TextStyle(
              fontSize: 28,
              color: textColor,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text("My Calculator"),
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            onPressed: pickImage,
            icon: Icon(Icons.image),
          ),
          IconButton(
            onPressed: () {
              setState(() {
                backgroundImage = null;
              });
            },
            icon: Icon(Icons.refresh),
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          image: backgroundImage != null
              ? DecorationImage(
                  image: FileImage(backgroundImage!),
                  fit: BoxFit.cover,
                )
              : null,
        ),
        child: Container(
          color: Colors.black.withOpacity(0.4),
          child: SafeArea(
            child: Column(
              children: [
                Expanded(
                  child: Container(
                    alignment: Alignment.bottomRight,
                    padding: EdgeInsets.all(25),
                    child: Text(
                      display,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 48,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                Row(
                  children: [
                    calcButton("C", Colors.redAccent, Colors.white),
                    calcButton("⌫", Colors.orange, Colors.white),
                    calcButton("%", Colors.orange, Colors.white),
                    calcButton("÷", Colors.orange, Colors.white),
                  ],
                ),
                Row(
                  children: [
                    calcButton("7", Color(0xff1E1E1E), Colors.white),
                    calcButton("8", Color(0xff1E1E1E), Colors.white),
                    calcButton("9", Color(0xff1E1E1E), Colors.white),
                    calcButton("×", Colors.orange, Colors.white),
                  ],
                ),
                Row(
                  children: [
                    calcButton("4", Color(0xff1E1E1E), Colors.white),
                    calcButton("5", Color(0xff1E1E1E), Colors.white),
                    calcButton("6", Color(0xff1E1E1E), Colors.white),
                    calcButton("-", Colors.orange, Colors.white),
                  ],
                ),
                Row(
                  children: [
                    calcButton("1", Color(0xff1E1E1E), Colors.white),
                    calcButton("2", Color(0xff1E1E1E), Colors.white),
                    calcButton("3", Color(0xff1E1E1E), Colors.white),
                    calcButton("+", Colors.orange, Colors.white),
                  ],
                ),
                Row(
                  children: [
                    calcButton("0", Color(0xff1E1E1E), Colors.white),
                    calcButton(".", Color(0xff1E1E1E), Colors.white),
                    calcButton("=", Colors.green, Colors.white),
                  ],
                ),
                SizedBox(height: 10),
              ],
            ),
          ),
        ),
      ),
    );
  }
}