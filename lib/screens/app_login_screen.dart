import 'dart:convert';

import 'package:enhanzer_login_project/screens/user_details_screen.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

class AppLoginScreen extends StatefulWidget {
  const AppLoginScreen({super.key});

  @override
  State<AppLoginScreen> createState() => _AppLoginScreenState();
}

class _AppLoginScreenState extends State<AppLoginScreen> {

  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;

  Future<void> _login(context) async {
    final username = _usernameController.text;
    final password = _passwordController.text;

    if (username.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Username and Password cannot be empty")),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    final url = Uri.parse("https://api.ezuite.com/api/External_Api/Mobile_Api/Invoke");

    final body = jsonEncode({
      "API_Body": [{}],
      "Unique_Id": "",
      "Pw": password,
      "Api_Action": "GetUserData",
      "Company_Code": username
    });

    try {
      final response = await http.post(
        url,
        body: body,
        headers: {"Content-Type": "application/json"},
      );

      final responseData = jsonDecode(response.body);

      if (response.statusCode == 200) {
        if (responseData['Status_Code'] == 200) {
          await _saveToDatabase(responseData['Response_Body'][0]);
          Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => UserDetailsScreen()),
        );
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(responseData['Message'])),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Login failed: ${responseData['Message']}")),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error: ${response.statusCode}")),
        );
      }
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $error")),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _saveToDatabase(Map<String, dynamic> userData) async {
    final directory = await getApplicationDocumentsDirectory();
    final path = "${directory.path}/user_data.db";

    final database = await openDatabase(path, version: 1, onCreate: (db, version) {
      return db.execute(
        "CREATE TABLE user_data (id INTEGER PRIMARY KEY, user_code TEXT, user_display_name TEXT, email TEXT, employee_code TEXT, company_code TEXT)",
      );
    });

    await database.insert(
      "user_data",
      {
        "user_code": userData['User_Code'],
        "user_display_name": userData['User_Display_Name'],
        "email": userData['Email'],
        "employee_code": userData['User_Employee_Code'],
        "company_code": userData['Company_Code']
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  @override
  void initState() {
    _usernameController.text = 'info@enhanzer.com';
    _passwordController.text = 'Welcome#5';
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("login",style: TextStyle(fontSize: 25,fontWeight: FontWeight.w500,color: Colors.blue),),
        centerTitle: true,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Card(
            elevation: 8,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    "Welcome Back!",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.blueGrey,
                    ),
                  ),
                  SizedBox(height: 10),
                  Text(
                    "Login to continue",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey[600],
                    ),
                  ),
                  SizedBox(height: 20),
                  TextField(
                    controller: _usernameController,
                    decoration: InputDecoration(
                      labelText: "Username",
                      prefixIcon: Icon(Icons.person),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                  SizedBox(height: 16),
                  TextField(
                    controller: _passwordController,
                    decoration: InputDecoration(
                      labelText: "Password",
                      prefixIcon: Icon(Icons.lock),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    obscureText: true,
                  ),
                  SizedBox(height: 20),
                  _isLoading
                      ? Center(
                          child: CircularProgressIndicator(),
                        )
                      : ElevatedButton(
                          onPressed: () {
                            _login(context);
                          },
                          style: ElevatedButton.styleFrom(
                            padding: EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            backgroundColor: Colors.green,
                          ),
                          child: Text(
                            "Login",
                            style: TextStyle(fontSize: 18, color: Colors.white),
                          ),
                        ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}