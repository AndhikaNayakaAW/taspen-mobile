// lib/model/user.dart

class User {
  final String nik;
  final String nama;
  final String jabatan;
  final String ba;
  final String orgeh;
  final String unitKerja;
  final String kodeJabatan;
  final String perty;
  String username;

  User({
    required this.nik,
    required this.nama,
    required this.jabatan,
    required this.ba,
    required this.orgeh,
    required this.unitKerja,
    required this.kodeJabatan,
    required this.perty,
    required this.username,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      nik: json['NIK'] as String,
      nama: json['NAMA'] as String,
      jabatan: json['JABATAN'] as String,
      ba: json['BA'] as String,
      orgeh: json['ORGEH'] as String,
      unitKerja: json['UNITKERJA'] as String,
      kodeJabatan: json['KODEJABATAN'] as String,
      perty: json['PERTY'] as String,
      username: json['USERNAME'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'NIK': nik,
      'NAMA': nama,
      'JABATAN': jabatan,
      'BA': ba,
      'ORGEH': orgeh,
      'UNITKERJA': unitKerja,
      'KODEJABATAN': kodeJabatan,
      'PERTY': perty,
      'USERNAME': username,
    };
  }
}
