class Duty {
  final int id;
  final String description;
  final DateTime date;
  final String status;
  final String startTime;
  final String endTime;
  final String? rejectionReason;

  Duty({
    required this.id,
    required this.description,
    required this.date,
    required this.status,
    required this.startTime,
    required this.endTime,
    this.rejectionReason,
  });

  /// Creates a Duty instance from a JSON map.
  factory Duty.fromJson(Map<String, dynamic> json) {
    return Duty(
      id: json['id'] as int,
      description: json['description'] as String,
      date: DateTime.parse(json['date'] as String),
      status: json['status'] as String,
      startTime: json['startTime'] as String,
      endTime: json['endTime'] as String,
      rejectionReason: json['rejectionReason'] as String?,
    );
  }

  /// Converts a Duty instance to a JSON map.
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'description': description,
      'date': date.toIso8601String().split('T').first, // Formats as 'YYYY-MM-DD'
      'status': status,
      'startTime': startTime,
      'endTime': endTime,
      'rejectionReason': rejectionReason,
    };
  }

  @override
  String toString() {
    return 'Duty(id: $id, description: $description, date: $date, status: $status, startTime: $startTime, endTime: $endTime, rejectionReason: $rejectionReason)';
  }

  /// Creates a copy of the current Duty with optional new values.
  Duty copyWith({
    int? id,
    String? description,
    DateTime? date,
    String? status,
    String? startTime,
    String? endTime,
    String? rejectionReason,
  }) {
    return Duty(
      id: id ?? this.id,
      description: description ?? this.description,
      date: date ?? this.date,
      status: status ?? this.status,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      rejectionReason: rejectionReason ?? this.rejectionReason,
    );
  }
}