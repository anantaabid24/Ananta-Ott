import 'package:dio/dio.dart';
import '../models/channel.dart';

class IptvService {
  final Dio _dio = Dio();
  String _playlistUrl = 'https://raw.githubusercontent.com/anantaabid24/Ananta-Ott/refs/heads/main/channels.m3u'; // CHANGE THIS!

  void setPlaylistUrl(String url) {
    _playlistUrl = url;
  }

  Future<List<Channel>> loadPlaylist() async {
    final response = await _dio.get(_playlistUrl);
    final String content = response.data.toString();

    List<Channel> channels = [];
    String currentGroup = "Live";

    final lines = content.split('\n');
    for (String line in lines) {
      if (line.startsWith('#EXTINF:')) {
        final nameMatch = RegExp(r'tvg-name="(.*?)"').firstMatch(line);
        final name = nameMatch?.group(1) ?? line.replaceAll('#EXTINF:', '');
        currentGroup = "Live";
        final groupMatch = RegExp(r'group-title="(.*?)"').firstMatch(line);
        if (groupMatch != null) currentGroup = groupMatch.group(1) ?? "Live";
      } else if (line.startsWith('http') && line.length > 10) {
        channels.add(Channel(
          id: DateTime.now().millisecondsSinceEpoch.toString() + channels.length.toString(),
          name: 'Channel ${channels.length + 1}',
          group: currentGroup,
          url: line,
          logo: '',
          tvgId: '',
        ));
      }
    }
    return channels;
  }

  // Demo fallback if your GitHub file is empty
  List<Channel> getFallbackChannels() {
    return [
      Channel(id: '1', name: 'CNN', group: 'News', url: 'https://example.com/cnn.m3u8', logo: '', tvgId: 'cnn'),
      Channel(id: '2', name: 'BBC', group: 'News', url: 'https://example.com/bbc.m3u8', logo: '', tvgId: 'bbc'),
      Channel(id: '3', name: 'Fox News', group: 'News', url: 'https://example.com/fox.m3u8', logo: '', tvgId: 'fox'),
    ];
  }
}
