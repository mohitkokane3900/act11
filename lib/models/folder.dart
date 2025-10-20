class Folder {
  int? id;
  String name;
  String? previewImage;
  DateTime createdAt;

  Folder({
    this.id,
    required this.name,
    this.previewImage,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() => {
    'id': id,
    'name': name,
    'previewImage': previewImage,
    'createdAt': createdAt.toIso8601String(),
  };

  factory Folder.fromMap(Map<String, dynamic> map) => Folder(
    id: map['id'],
    name: map['name'],
    previewImage: map['previewImage'],
    createdAt: DateTime.parse(map['createdAt']),
  );
}
