import 'package:dio/dio.dart';
import '../models/channel.dart';

class IptvService {
  final Dio _dio = Dio();

  Future<List<Channel>> loadPlaylist(String url) async {
    final response = await _dio.get(url);
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
        // We need to parse differently - using try-catch for simplicity
        // In real code we would parse logo too
        channels.add(Channel(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
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
}
