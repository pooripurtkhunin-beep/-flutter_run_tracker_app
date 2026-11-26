class Run {
  //สร้างตัวแปรให้ล้อกับ columm tablesของ supabase
  String? id;
  String? runWhere;
  String? runPerson;
  int? runDistance;
  String? runimageURL;

  //สร้าง Constructor ให้เรียกใช้งาน
  Run({
    this.id,
    this.runWhere,
    this.runPerson,
    this.runDistance,
    this.runimageURL,
  });
  // แปลงข้อมูลจาก Supabase เพื่อมาใช้ใน Flutter => From JSON
  factory Run.fromJson(Map<String, dynamic> json) {
    return Run(
      id: json['id']?.toString(), // รองรับทั้ง id แบบตัวเลขและข้อความ
      runWhere: json['run_Where'] as String?,
      runPerson: json['run_Person'] as String?,
      runDistance: json['run_Distance'] as int?,
      runimageURL: json['run_image_URL'] as String?,
    );
  }

// แปลงข้อมูลจาก Flutter เพื่อเข้าไปใน Supabase => To JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'run_Where': runWhere,
      'run_Person': runPerson,
      'run_Distance': runDistance,
      'run_image_URL': runimageURL,
    };
  }
}
