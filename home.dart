import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:connectivity/connectivity.dart';
import 'package:to_do_app/constants/colors.dart';

void main() {
  runApp(Home());
}

class Home extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'User List',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blueGrey,
        scaffoldBackgroundColor: Colors.grey[300],
        textTheme: TextTheme(
          bodyText2: TextStyle(color: Colors.black),
        ),
      ),
      home: HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<dynamic> users = [];

  @override
  void initState() {
    super.initState();
    fetchUsers();
  }

  Future<void> fetchUsers() async {
    final String apiUrl = 'https://dummyapi.io/data/v1/user?limit=20';
    final String appId = '61dbf9b1d7efe0f95bc1e1a6';

    try {
      final response = await http.get(
        Uri.parse(apiUrl),
        headers: {'app-id': appId},
      );

      if (response.statusCode == 200) {
        setState(() {
          users = json.decode(response.body)['data'];
        });
      } else {
        throw Exception('Failed to load users');
      }
    } catch (e) {
      print(e);
    }
  }

  Future<void> checkInternetAndNavigate(BuildContext context, String userId) async {
    var connectivityResult = await Connectivity().checkConnectivity();
    if (connectivityResult == ConnectivityResult.none) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('No internet connection!'),
      ));
    } else {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => UserDetailsPage(userId: userId)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Center(child: Text('Users')),
      ),
      body: Container(
        padding: EdgeInsets.all(8.0),
        color: luGrey,
        child: ListView.builder(
          itemCount: users.length,
          itemBuilder: (context, index) {
            return Card(
              elevation: 2,
              child: ListTile(
                title: Text(
                  users[index]['firstName'] + ' ' + users[index]['lastName'],
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                trailing: CircleAvatar(
                  backgroundColor: Colors.grey,
                  child: Icon(Icons.person, color: Colors.white),
                ),
                onTap: () {
                  checkInternetAndNavigate(context, users[index]['id']);
                },
              ),
            );
          },
        ),
      ),
    );
  }
}

class UserDetailsPage extends StatefulWidget {
  final String userId;

  UserDetailsPage({required this.userId});

  @override
  _UserDetailsPageState createState() => _UserDetailsPageState();
}

class _UserDetailsPageState extends State<UserDetailsPage> {
  Map<String, dynamic> userDetails = {};

  @override
  void initState() {
    super.initState();
    fetchUserDetails();
  }

  Future<void> fetchUserDetails() async {
    final String apiUrl = 'https://dummyapi.io/data/v1/user/${widget.userId}';
    final String appId = '61dbf9b1d7efe0f95bc1e1a6';

    try {
      final response = await http.get(
        Uri.parse(apiUrl),
        headers: {'app-id': appId},
      );

      if (response.statusCode == 200) {
        setState(() {
          userDetails = json.decode(response.body);
        });
      } else {
        throw Exception('Failed to load user details');
      }
    } catch (e) {
      print(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('User Details'),
      ),
      body: Center(
        child: Container(
        padding: EdgeInsets.all(8.0),
        color: luBGColor,
        child: userDetails.isNotEmpty
            ? Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            CircleAvatar(
              backgroundColor: Colors.grey,
              child: Icon(Icons.person, color: Colors.white, size: 70,),
              radius: 40,
            ),
            SizedBox(height: 20),
            Text(
              'Name: ${userDetails['firstName']} ${userDetails['lastName']}',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 15),
            Text('Email: ${userDetails['email']}'),
          ],
        )
            : Center(
          child: CircularProgressIndicator(),
        ),
      ),
    )
    );
  }
}
