class CardItem {
  int? id;
  String name;
  String suit;
  String imageUrl;
  String? imageBytes;
  int? folderId;
  DateTime createdAt;

  CardItem({
    this.id,
    required this.name,
    required this.suit,
    required this.imageUrl,
    this.imageBytes,
    this.folderId,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() => {
    'id': id,
    'name': name,
    'suit': suit,
    'imageUrl': imageUrl,
    'imageBytes': imageBytes,
    'folderId': folderId,
    'createdAt': createdAt.toIso8601String(),
  };

  factory CardItem.fromMap(Map<String, dynamic> map) => CardItem(
    id: map['id'],
    name: map['name'],
    suit: map['suit'],
    imageUrl: map['imageUrl'],
    imageBytes: map['imageBytes'],
    folderId: map['folderId'],
    createdAt: DateTime.parse(map['createdAt']),
  );
}
