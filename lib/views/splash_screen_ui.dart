import 'package:flutter/material.dart';
import 'package:flutter_run_tracker_app/views/show_all_run_ui.dart';

class SplashScreenUi extends StatefulWidget {
  const SplashScreenUi({super.key});

  @override
  State<SplashScreenUi> createState() => _SplashScreenUiState();
}

class _SplashScreenUiState extends State<SplashScreenUi> {
  @override
  void initState() {
    super.initState();
    //เรียกใช้งานฟังก์ชันเมื่อเปิดหน้าจอ 3วิ แล้วเปิดไป Addrunแบบไม่ย้อนกลับ
    Future.delayed(const Duration(seconds: 3), () {
      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const ShowAllRunUi()),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 1, 23, 113),
      body: Stack(
        children: [
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset(
                  'assets/images/logo.png',
                  width: MediaQuery.of(context).size.width * 0.5,
                  height: MediaQuery.of(context).size.width * 0.5,
                  fit: BoxFit.cover,
                ),
                Text(
                  'RUN TRACKER',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: MediaQuery.of(context).size.width * 0.035,
                    fontStyle: FontStyle.italic,
                  ),
                ),
                SizedBox(
                  height: 25,
                ),
                CircularProgressIndicator(
                  color: Colors.white,
                ),
              ],
            ),
          ),
          //ชั้นที่สอง
          Center(
            child: Column(mainAxisAlignment: MainAxisAlignment.end, children: [
              Text('Created by NinniN SAU TEAM',
                  style: TextStyle(
                    color: Colors.grey[600],
                  )),
              SizedBox(
                height: 50.0,
              ),
            ]),
          ),
        ],
      ),
    );
  }
}
