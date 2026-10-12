import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:better_player/better_player.dart';
import 'package:dio/dio.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:intl/intl.dart';

import 'models/channel.dart';
import 'services/iptv_service.dart';

void main() => runApp(const IPTVApp());

class IPTVApp extends StatelessWidget {
  const IPTVApp({super.key});

  @override
  Widget build(BuildContext context) => MaterialApp(
        title: 'Live IPTV',
        debugShowCheckedModeBanner: false,
        theme: ThemeData.dark().copyWith(
          primaryColor: Colors.redAccent,
          scaffoldBackgroundColor: Colors.black,
          appBarTheme: const AppBarTheme(backgroundColor: Colors.black, elevation: 0),
        ),
        home: const MainScreen(),
      );
}

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});
  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  final IptvService _iptvService = IptvService();
  List<Channel> _allChannels = [];
  List<Channel> _displayedChannels = [];
  List<Channel> _favorites = [];

  String _currentCategory = "All";
  String _searchQuery = "";

  BetterPlayerController? _betterPlayerController;

  bool _isLoading = false;
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    _loadAllData();
  }

  Future<void> _loadAllData() async {
    setState(() => _isLoading = true);
    await _loadFavorites();
    await _loadChannels();
    if (_allChannels.isNotEmpty) _currentCategory = _allChannels.first.group;
    setState(() => _isLoading = false);
  }

  Future<void> _loadFavorites() async {
    final prefs = await SharedPreferences.getInstance();
    final List<String> favStrings = prefs.getStringList('favorites') ?? [];
    setState(() {
      _favorites = favStrings.map((e) => Channel.fromMap(json.decode(e))).toList();
    });
  }

  Future<void> _saveFavorites() async {
    final prefs = await SharedPreferences.getInstance();
    final List<String> favStrings = _favorites.map((c) => json.encode(c.toMap())).toList();
    await prefs.setStringList('favorites', favStrings);
  }

  Future<void> _loadChannels() async {
    try {
      final channels = await _iptvService.loadPlaylist();
      setState(() {
        _allChannels = channels;
        _displayedChannels = channels;
      });
    } catch (e) {
      // Fallback to demo if needed
      final fallbackChannels = _iptvService.getFallbackChannels();
      setState(() {
        _allChannels = fallbackChannels;
        _displayedChannels = fallbackChannels;
      });
    }
  }

  List<Channel> get _filteredAndCategorizedChannels {
    return _allChannels.where((channel) {
      final matchesSearch = channel.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          channel.group.toLowerCase().contains(_searchQuery.toLowerCase());
      final matchesCategory = _currentCategory == "All" || channel.group == _currentCategory;
      return matchesSearch && matchesCategory;
    }).toList();
  }

  void _playChannel(Channel channel) {
    _betterPlayerController?.pause();

    final dataSource = BetterPlayerDataSource(
      BetterPlayerDataSourceType.network,
      channel.url,
      headers: {'User-Agent': 'Mozilla/5.0 (Android)'},
      showControls: true,
      autoPlay: true,
      autoInitialize: true,
      autoDispose: false,
      controlsConfiguration: const BetterPlayerControlsConfiguration(
        enablePip: true,
        enablePlayPause: true,
        enableFullscreen: true,
        enableMute: true,
      ),
    );

    _betterPlayerController = BetterPlayerController(
      BetterPlayerConfiguration(
        aspectRatio: 16 / 9,
        autoPlay: true,
        autoInitialize: true,
        autoDispose: false,
        looping: false,
      ),
    );

    _betterPlayerController!.setupDataSource(dataSource);

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => Scaffold(
          backgroundColor: Colors.black,
          body: Stack(
            children: [
              BetterPlayer(controller: _betterPlayerController!),
              Positioned(
                top: 40,
                left: 16,
                child: IconButton(
                  icon: const Icon(Icons.arrow_back, color: Colors.white, size: 28),
                  onPressed: () {
                    _betterPlayerController?.pause();
                    Navigator.pop(context);
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _toggleFavorite(Channel channel) {
    setState(() {
      channel.favorite = !channel.favorite;
      if (channel.favorite) {
        if (!_favorites.any((f) => f.id == channel.id)) {
          _favorites.add(channel);
        }
      } else {
        _favorites.removeWhere((f) => f.id == channel.id);
      }
    });
    _saveFavorites();
  }

  Widget _buildChannelCard(Channel channel) {
    return GestureDetector(
      onTap: () => _playChannel(channel),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.grey[900],
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.4), blurRadius: 12, offset: const Offset(0, 4)),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                  child: CachedNetworkImage(
                    imageUrl: channel.logo.isNotEmpty ? channel.logo : '',
                    height: 168,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    placeholder: (_, __) => Container(height: 168, color: Colors.black87),
                    errorWidget: (_, __, ___) => Container(
                      height: 168,
                      color: Colors.black,
                      child: const Icon(Icons.tv, size: 90, color: Colors.white60),
                    ),
                  ),
                ),
                Positioned(
                  top: 12,
                  right: 12,
                  child: GestureDetector(
                    onTap: () => _toggleFavorite(channel),
                    child: Icon(
                      Icons.star_rounded,
                      color: channel.favorite ? Colors.amber : Colors.white70,
                      size: 32,
                    ),
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    channel.name,
                    style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w600, color: Colors.white),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 6),
                  Text(
                    channel.group,
                    style: TextStyle(fontSize: 13, color: Colors.grey[400]),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: const Text('Live IPTV', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 24)),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, size: 26),
            onPressed: _loadChannels,
          ),
        ],
      ),
      body: _isLoading && !_isInitialized
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(color: Colors.redAccent),
                  SizedBox(height: 20),
                  Text("Loading from GitHub...", style: TextStyle(fontSize: 16)),
                ],
              ),
            )
          : Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: 'Search channels...',
                      prefixIcon: const Icon(Icons.search),
                      filled: true,
                      fillColor: Colors.grey[900],
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
                    ),
                    onChanged: (value) {
                      setState(() {
                        _searchQuery = value;
                        _displayedChannels = _filteredAndCategorizedChannels;
                      });
                    },
                  ),
                ),
                _allChannels.isEmpty
                    ? const SizedBox.shrink()
                    : SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Row(
                          children: [
                            Chip(
                              label: const Text('All'),
                              backgroundColor: _currentCategory == "All" ? Colors.redAccent : Colors.grey[800],
                              onPressed: () {
                                setState(() {
                                  _currentCategory = "All";
                                  _displayedChannels = _filteredAndCategorizedChannels;
                                });
                              },
                            ),
                            const SizedBox(width: 8),
                            ..._allChannels.map((ch) => ch.group).toSet().map((cat) => Padding(
                                  padding: const EdgeInsets.only(right: 8),
                                  child: InkWell(
                                    onTap: () {
                                      setState(() {
                                        _currentCategory = cat;
                                        _displayedChannels = _filteredAndCategorizedChannels;
                                      });
                                    },
                                    child: Chip(
                                      label: Text(cat),
                                      backgroundColor: _currentCategory == cat ? Colors.redAccent : Colors.grey[800],
                                    ),
                                  ),
                                )),
                          ],
                        ),
                      ),
                Expanded(
                  child: GridView.builder(
                    padding: const EdgeInsets.all(12),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                      childAspectRatio: 0.78,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                    ),
                    itemCount: _filteredAndCategorizedChannels.length,
                    itemBuilder: (_, index) => _buildChannelCard(_filteredAndCategorizedChannels[index]),
                  ),
                ),
              ],
            ),
    );
  }
}
