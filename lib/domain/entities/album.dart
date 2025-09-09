import 'song.dart';

class Album {
  final String id;
  final String name;
  final DateTime createdAt;
  final List<Song> songs;

  const Album({
    required this.id,
    required this.name,
    required this.createdAt,
    required this.songs,
  });

  Album copyWith({
    String? id,
    String? name,
    DateTime? createdAt,
    List<Song>? songs,
  }) {
    return Album(
      id: id ?? this.id,
      name: name ?? this.name,
      createdAt: createdAt ?? this.createdAt,
      songs: songs ?? this.songs,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'createdAt': createdAt.toIso8601String(),
      'songs': songs.map((song) => song.toJson()).toList(),
    };
  }

  factory Album.fromJson(Map<String, dynamic> json) {
    return Album(
      id: json['id'] as String,
      name: json['name'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      songs: (json['songs'] as List)
          .map((songJson) => Song.fromJson(songJson as Map<String, dynamic>))
          .toList(),
    );
  }
}
