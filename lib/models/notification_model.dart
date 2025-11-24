class NotificationModel {
  final String id;
  final String userId;
  final String title;
  final String message;
  final String type; // maintenance, alert, warning, info
  final bool isRead;
  final DateTime createdAt;
  final String? vehicleId;
  final String? maintenanceId;
  final Map<String, dynamic>? data;

  NotificationModel({
    required this.id,
    required this.userId,
    required this.title,
    required this.message,
    required this.type,
    this.isRead = false,
    required this.createdAt,
    this.vehicleId,
    this.maintenanceId,
    this.data,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'title': title,
      'message': message,
      'type': type,
      'isRead': isRead,
      'createdAt': createdAt.toIso8601String(),
      'vehicleId': vehicleId,
      'maintenanceId': maintenanceId,
      'data': data,
    };
  }

  factory NotificationModel.fromMap(Map<String, dynamic> map) {
    return NotificationModel(
      id: map['id'] ?? '',
      userId: map['userId'] ?? '',
      title: map['title'] ?? '',
      message: map['message'] ?? '',
      type: map['type'] ?? 'info',
      isRead: map['isRead'] ?? false,
      createdAt: map['createdAt'] != null
          ? DateTime.parse(map['createdAt'])
          : DateTime.now(),
      vehicleId: map['vehicleId'],
      maintenanceId: map['maintenanceId'],
      data: map['data'] != null
          ? Map<String, dynamic>.from(map['data'])
          : null,
    );
  }

  NotificationModel copyWith({
    String? id,
    String? userId,
    String? title,
    String? message,
    String? type,
    bool? isRead,
    DateTime? createdAt,
    String? vehicleId,
    String? maintenanceId,
    Map<String, dynamic>? data,
  }) {
    return NotificationModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      title: title ?? this.title,
      message: message ?? this.message,
      type: type ?? this.type,
      isRead: isRead ?? this.isRead,
      createdAt: createdAt ?? this.createdAt,
      vehicleId: vehicleId ?? this.vehicleId,
      maintenanceId: maintenanceId ?? this.maintenanceId,
      data: data ?? this.data,
    );
  }
}

