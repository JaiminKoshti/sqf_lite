class Note {
  final int? id;
  final String title;
  final String description;
  final String? name;
  final String imagePath;

  const Note(
      {this.id,
      required this.title,
      required this.description,
      this.name,
      required this.imagePath});

  factory Note.fromJson(Map<String, dynamic> json) => Note(
      name: json['name'],
      imagePath: json['imagePath'],
      id: json['id'],
      title: json['title'],
      description: json['description']);

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'description': description,
        'name': name,
        'imagePath': imagePath,
      };
}
