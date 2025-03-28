enum PhotoType {
  all,     // フィルタリング用
  normal,  // 通常写真
  overlay, // オーバーレイ写真
  transparentPng, // 透過PNG
}

class PhotoMetadata {
  final DateTime createdAt;
  final PhotoType type;
  final List<Map<String, dynamic>>? overlayInfo;
  
  PhotoMetadata({
    required this.createdAt,
    required this.type,
    this.overlayInfo,
  });
  
  Map<String, dynamic> toJson() {
    return {
      'createdAt': createdAt.toIso8601String(),
      'type': type.toString(),
      'overlayInfo': overlayInfo,
    };
  }
  
  factory PhotoMetadata.fromJson(Map<String, dynamic> json) {
    return PhotoMetadata(
      createdAt: DateTime.parse(json['createdAt']),
      type: PhotoType.values.firstWhere(
        (e) => e.toString() == json['type'],
        orElse: () => PhotoType.normal,
      ),
      overlayInfo: json['overlayInfo'] != null
          ? List<Map<String, dynamic>>.from(json['overlayInfo'])
          : null,
    );
  }
}

class Photo {
  final String id;
  final String path;
  final PhotoMetadata metadata;
  
  Photo({
    required this.id,
    required this.path,
    required this.metadata,
  });
}
