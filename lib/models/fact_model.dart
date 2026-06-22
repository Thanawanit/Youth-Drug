class Fact {
  final String id;
  final String title;
  final String message;
  final String category; // e.g. '💡 รู้ไหม', '🛡 การป้องกัน', '⚠ ข้อควรระวัง', '📚 ความรู้เพิ่มเติม'
  final bool isFavorite;

  const Fact({
    required this.id,
    required this.title,
    required this.message,
    required this.category,
    this.isFavorite = false,
  });

  Fact copyWith({
    bool? isFavorite,
  }) {
    return Fact(
      id: id,
      title: title,
      message: message,
      category: category,
      isFavorite: isFavorite ?? this.isFavorite,
    );
  }
}
