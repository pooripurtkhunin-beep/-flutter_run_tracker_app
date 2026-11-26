// ignore_for_file: sort_child_properties_last

import 'package:flutter/material.dart';
import 'package:flutter_run_tracker_app/models/run.dart';
import 'package:flutter_run_tracker_app/services/supabase_services.dart';
import 'package:flutter_run_tracker_app/views/add_run_ui.dart';
import 'package:flutter_run_tracker_app/views/update_delete_run_ui.dart';

class ShowAllRunUi extends StatefulWidget {
  const ShowAllRunUi({super.key});

  @override
  State<ShowAllRunUi> createState() => _ShowAllRunUiState();
}

class _ShowAllRunUiState extends State<ShowAllRunUi> {
  // เก็บผลการดึงข้อมูลจาก Table เพื่อให้รีเฟรชได้เมื่อกลับมาจากหน้าอื่น
  late Future<List<Run>> runList;

  @override
  void initState() {
    super.initState();
    runList = SupabaseService().getAllDataFromTableRun();
  }

  void reload() {
    setState(() {
      runList = SupabaseService().getAllDataFromTableRun();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // เป็นส่วนของ แทบ bar ด้านบน
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 1, 23, 113),
        title: Text(
          'Run Tracker',
          style: TextStyle(
            color: Colors.white,
          ),
        ),
        centerTitle: true,
      ),
      //ส่วนของ floating button ด้านล่าง
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          //เปิด Addrun แบบย้อนกลับได้ แล้วโหลดรายการใหม่เมื่อกลับมา
          await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const AddRunUI(),
            ),
          );
          reload();
        },
        child: Icon(
          Icons.add,
          color: Colors.white,
        ),
        backgroundColor: const Color.fromARGB(255, 1, 23, 113),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      //ส่วน body
      body: FutureBuilder<List<Run>>(
        future: runList,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: EdgeInsets.all(20),
                child: Text('โหลดข้อมูลไม่สำเร็จ: ${snapshot.error}'),
              ),
            );
          }
          final runs = snapshot.data ?? [];
          if (runs.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset(
                    'assets/images/logo.png',
                    width: MediaQuery.of(context).size.width * 0.35,
                    height: MediaQuery.of(context).size.width * 0.35,
                    fit: BoxFit.contain,
                  ),
                  SizedBox(
                    height: 16,
                  ),
                  Text(
                    'วิ่งกันเถอะ',
                    style: TextStyle(
                      fontSize: MediaQuery.of(context).size.height * 0.025,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            );
          }
          return ListView.builder(
            padding: EdgeInsets.only(bottom: 90),
            itemCount: runs.length,
            itemBuilder: (context, index) {
              final run = runs[index];
              final hasImage =
                  run.runimageURL != null && run.runimageURL!.isNotEmpty;
              return ListTile(
                leading: hasImage
                    ? Image.network(
                        run.runimageURL!,
                        width: 50,
                        height: 50,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stack) =>
                            Icon(Icons.broken_image, size: 50),
                      )
                    : Icon(Icons.directions_run, size: 50),
                title: Text(run.runWhere ?? ''),
                subtitle: Text(
                    'วิ่งกับ ${run.runPerson ?? ''} • ${run.runDistance ?? 0} กม.'),
                trailing: Icon(Icons.chevron_right),
                // กดเพื่อเปิดหน้าแก้ไข/ลบ แล้วโหลดรายการใหม่เมื่อกลับมา
                onTap: () async {
                  await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => UpdateDeleteRunUi(run: run),
                    ),
                  );
                  reload();
                },
              );
            },
          );
        },
      ),
    );
  }
}
