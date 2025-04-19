import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mylocallance/screens/Freelancer/chatlist_screen.dart';
import 'package:mylocallance/screens/Freelancer/chatroom.dart';
import 'package:mylocallance/screens/Freelancer/dashboard.dart';
import 'package:mylocallance/screens/Freelancer/job_details_screen.dart';
import 'package:mylocallance/screens/Freelancer/notifications.dart';
import 'package:mylocallance/screens/Freelancer/payment_screen.dart';
import 'package:mylocallance/screens/Freelancer/profile_screen.dart';
import 'package:mylocallance/screens/Freelancer/review_screen.dart';
import 'package:mylocallance/screens/home_screen/home.dart';
import 'package:mylocallance/screens/job_recruiter/home_screen.dart';
import 'package:mylocallance/screens/job_recruiter/job_details_screen.dart' as recruiter;
import 'screens/job_recruiter/login_screen.dart';
import 'firebase_options.dart';
// import 'screens/splash_screen.dart';
// 

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
         
  );
  
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(360, 800), // Base design size
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) {
        return MaterialApp(
          title: 'MyLocalLance',
          debugShowCheckedModeBanner: false,
          theme: ThemeData(
            colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
            useMaterial3: true,
          ),
          home: const recruiter.JobDetailsScreen(),
        );
      },
    );
  }
}

class MyHomePage extends StatefulWidget {
  final String title; 

  const MyHomePage({super.key, required this.title});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title), 
      ),
      body: Center(
        child: Column(),
      ), 
    );
  }
}
