class Channel {
  final String id;
  final String name;
  final String group;
  final String url;
  final String logo;
  final String tvgId;
  final bool favorite;

  Channel({
    required this.id,
    required this.name,
    required this.group,
    required this.url,
    required this.logo,
    required this.tvgId,
    this.favorite = false,
  });

  factory Channel.fromMap(Map<String, dynamic> map) {
    return Channel(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      group: map['group'] ?? 'Live',
      url: map['url'] ?? '',
      logo: map['logo'] ?? '',
      tvgId: map['tvg_id'] ?? '',
    );
  }

  Map<String, dynamic> toMap() => {
        'id': id,
        'name': name,
        'group': group,
        'url': url,
        'logo': logo,
        'tvg_id': tvgId,
        'favorite': favorite,
      };
}
