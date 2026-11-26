//-----------ไฟล์นี้เป็นไฟล์ที่จะทำงานกับ Supabase (Database, storage)----------------
import 'package:flutter_run_tracker_app/models/run.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:image_picker/image_picker.dart';

class SupabaseService {
  //*** ก่อนจะทำงานใดๆ อย่าลืมสร้าง instance/object/ตัวแทน ของ Supabase เพื่อที่จะทำงานใดๆ ***
  final supabase = Supabase.instance.client;

  //1. เมธอดอัปโหลดรูปไปยัง Bucket: run_bk -----------------------------
  Future<String> uploadFileToBucketRun(XFile xFile) async {
    //คำสั่งเปลี่ยนชื่อไฟล์
    final newFileName =
        '${DateTime.now().millisecondsSinceEpoch}_${xFile.name}';

    //คำสั่งอัปโหลดไฟล์
    await supabase.storage.from('run_bk').uploadBinary(
          newFileName,
          await xFile.readAsBytes(),
          fileOptions: FileOptions(contentType: xFile.mimeType),
        );

    //ส่งกลับที่อยู่ที่ไฟล์บน Supabase ของไฟล์ที่อัปโหลดไปเพื่อเอาไปใช้งาน
    return supabase.storage.from('run_bk').getPublicUrl(newFileName);
  }

  //2. เมธอดเพิ่มข้อมูลไปยัง Table:run_tb --------------------------------
  Future<void> insertDataToTableRun(Run run) async {
    final data = run.toJson();
    // ถ้ายังไม่มี id ไม่ต้องส่งไป ให้ Database สร้างให้เอง
    if (data['id'] == null) data.remove('id');
    await supabase.from('Run_Tb').insert(data);
  }

  //3. เมธอดดึงข้อมูลทั้งหมดจาก Table:run_tb -----------------------------
  Future<List<Run>> getAllDataFromTableRun() async {
    final response = await supabase.from('Run_Tb').select('*');
    return response.map((e) => Run.fromJson(e)).toList();
  }

  //4. เมธอดลบรูปออกจาก Bucket: run_bk --------------------------------
  Future<void> deleteFileFromBucketRun(String fileName) async {
    await supabase.storage.from('run_bk').remove([fileName]);
  }

  //5. เมธอดแก้ไขข้อมูลใน Table:run_tb ----------------------------------
  Future<void> updateDataToTableRun(Run run, String id) async {
    final data = run.toJson();
    data.remove('id'); // ไม่แก้ไข id ของแถว ใช้ id ที่ส่งมาระบุแถวเท่านั้น
    await supabase.from('Run_Tb').update(data).eq('id', id);
  }

  //6. เมธอดลบข้อมูลออกจาก Table:run_tb --------------------------------
  Future<void> deleteDataFromTableRun(String id) async {
    await supabase.from('Run_Tb').delete().eq('id', id);
  }
}
