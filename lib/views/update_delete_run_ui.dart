// ignore_for_file: sort_child_properties_last

import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_run_tracker_app/models/run.dart';
import 'package:flutter_run_tracker_app/services/supabase_services.dart';
import 'package:image_picker/image_picker.dart';

class UpdateDeleteRunUi extends StatefulWidget {
  final Run run; // ข้อมูลการวิ่งที่เลือกมาจากหน้ารายการ
  const UpdateDeleteRunUi({super.key, required this.run});

  @override
  State<UpdateDeleteRunUi> createState() => _UpdateDeleteRunUiState();
}

class _UpdateDeleteRunUiState extends State<UpdateDeleteRunUi> {
  // รูปใหม่ที่เลือก (ถ้าไม่เลือกก็ใช้รูปเดิม)
  Uint8List? imageByte;
  XFile? xFile;

  late final TextEditingController runWhereCtrl;
  late final TextEditingController runPersonCtrl;
  late final TextEditingController runDistanceCtrl;
  bool isBusy = false;

  @override
  void initState() {
    super.initState();
    // ใส่ข้อมูลเดิมลงในช่องกรอก
    runWhereCtrl = TextEditingController(text: widget.run.runWhere ?? '');
    runPersonCtrl = TextEditingController(text: widget.run.runPerson ?? '');
    runDistanceCtrl =
        TextEditingController(text: '${widget.run.runDistance ?? ''}');
  }

  @override
  void dispose() {
    runWhereCtrl.dispose();
    runPersonCtrl.dispose();
    runDistanceCtrl.dispose();
    super.dispose();
  }

  // เลือกรูปใหม่ (ถ่ายรูปหรือ Gallery)
  Future<void> pickImage(ImageSource source) async {
    final picked =
        await ImagePicker().pickImage(source: source, imageQuality: 80);
    if (picked != null) {
      final bytes = await picked.readAsBytes();
      setState(() {
        imageByte = bytes;
        xFile = picked;
      });
    }
  }

  void showImageSourceSheet() {
    showModalBottomSheet(
      context: context,
      builder: (sheetContext) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: Icon(Icons.camera_alt),
              title: Text('ถ่ายรูป'),
              onTap: () {
                Navigator.pop(sheetContext);
                pickImage(ImageSource.camera);
              },
            ),
            ListTile(
              leading: Icon(Icons.photo_library),
              title: Text('เลือกจาก Gallery'),
              onTap: () {
                Navigator.pop(sheetContext);
                pickImage(ImageSource.gallery);
              },
            ),
          ],
        ),
      ),
    );
  }

  void showMessage(String message, {bool error = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: error ? Colors.red : Colors.green,
        duration: Duration(seconds: error ? 4 : 2),
      ),
    );
  }

  // ชื่อไฟล์ใน Bucket ดึงจากส่วนท้ายของ URL
  String fileNameFromUrl(String url) =>
      Uri.decodeComponent(url.split('/').last.split('?').first);

  // บันทึกการแก้ไข
  Future<void> updateRun() async {
    if (runWhereCtrl.text.trim().isEmpty ||
        runPersonCtrl.text.trim().isEmpty ||
        int.tryParse(runDistanceCtrl.text.trim()) == null) {
      showMessage('กรุณาป้อนข้อมูลให้ครบ และระยะทางเป็นตัวเลขจำนวนเต็ม',
          error: true);
      return;
    }

    setState(() => isBusy = true);
    try {
      final service = SupabaseService();
      String imageUrl = widget.run.runimageURL ?? '';

      // ถ้าเลือกรูปใหม่ ให้อัปโหลดรูปใหม่ แล้วลบรูปเดิมออกจาก Bucket
      if (xFile != null) {
        final newUrl = await service.uploadFileToBucketRun(xFile!);
        if (imageUrl.isNotEmpty) {
          await service.deleteFileFromBucketRun(fileNameFromUrl(imageUrl));
        }
        imageUrl = newUrl;
      }

      final run = Run(
        runWhere: runWhereCtrl.text.trim(),
        runPerson: runPersonCtrl.text.trim(),
        runDistance: int.parse(runDistanceCtrl.text.trim()),
        runimageURL: imageUrl,
      );
      await service.updateDataToTableRun(run, widget.run.id!);

      if (!mounted) return;
      showMessage('แก้ไขข้อมูลเสร็จสิ้น');
      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;
      setState(() => isBusy = false);
      showMessage('แก้ไขข้อมูลไม่สำเร็จ: $e', error: true);
    }
  }

  // ลบข้อมูล (ถามยืนยันก่อน)
  Future<void> deleteRun() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text('ยืนยันการลบ'),
        content: Text('ต้องการลบข้อมูลการวิ่งนี้ใช่หรือไม่?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: Text('ไม่ลบ'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: Text('ลบ'),
          ),
        ],
      ),
    );
    if (confirm != true) return;

    setState(() => isBusy = true);
    try {
      final service = SupabaseService();
      final oldUrl = widget.run.runimageURL ?? '';
      if (oldUrl.isNotEmpty) {
        await service.deleteFileFromBucketRun(fileNameFromUrl(oldUrl));
      }
      await service.deleteDataFromTableRun(widget.run.id!);

      if (!mounted) return;
      showMessage('ลบข้อมูลเสร็จสิ้น');
      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;
      setState(() => isBusy = false);
      showMessage('ลบข้อมูลไม่สำเร็จ: $e', error: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size.width * 0.45;
    final oldUrl = widget.run.runimageURL ?? '';

    // รูปที่แสดง: รูปใหม่ที่เลือก > รูปเดิมจาก Supabase > ไอคอนกล้อง
    Widget picture;
    if (imageByte != null) {
      picture = Image.memory(imageByte!,
          width: size, height: size, fit: BoxFit.cover);
    } else if (oldUrl.isNotEmpty) {
      picture = Image.network(oldUrl,
          width: size,
          height: size,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stack) =>
              Icon(Icons.broken_image, size: size, color: Colors.grey));
    } else {
      picture = Icon(Icons.add_a_photo, size: size, color: Colors.grey);
    }

    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 2, 18, 84),
        title: Text(
          'Run Tracker (แก้ไข/ลบ)',
          style: TextStyle(color: Colors.white),
        ),
        centerTitle: true,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: Icon(Icons.arrow_back_ios_new, color: Colors.white),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.only(top: 65, left: 40, right: 40, bottom: 50),
          child: Center(
            child: Column(
              children: [
                InkWell(onTap: showImageSourceSheet, child: picture),
                SizedBox(height: 45),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text('วิ่งที่ไหน'),
                ),
                TextField(
                  controller: runWhereCtrl,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(6),
                    ),
                  ),
                ),
                SizedBox(height: 20),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text('วิ่งกับใคร'),
                ),
                TextField(
                  controller: runPersonCtrl,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(6),
                    ),
                  ),
                ),
                SizedBox(height: 20),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text('ระยะทาง (กม.)'),
                ),
                TextField(
                  controller: runDistanceCtrl,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(6),
                    ),
                  ),
                ),
                SizedBox(height: 30),
                ElevatedButton(
                  onPressed: isBusy ? null : updateRun,
                  child: Text(
                    'บันทึกการแก้ไข',
                    style: TextStyle(
                      fontSize: MediaQuery.of(context).size.height * 0.02,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color.fromARGB(255, 36, 145, 3),
                    fixedSize: Size(MediaQuery.of(context).size.width, 55),
                  ),
                ),
                SizedBox(height: 20),
                ElevatedButton(
                  onPressed: isBusy ? null : deleteRun,
                  child: Text(
                    'ลบข้อมูล',
                    style: TextStyle(
                      fontSize: MediaQuery.of(context).size.height * 0.02,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.redAccent,
                    fixedSize: Size(MediaQuery.of(context).size.width, 55),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
