class Song {
  final String id;
  final String title;
  final String artist;
  final String coverUrl;
  final String url;
  final int? audioId; // for local artwork via on_audio_query

  const Song({
    required this.id,
    required this.title,
    required this.artist,
    required this.coverUrl,
    required this.url,
    this.audioId,
  });
}


