Live TV Streaming App for Android & iOS
Ananta OTT is a beautiful, ad-free, glass-morphism style live TV streaming application built with Flutter. It supports M3U playlists, favorites, search, categories, and smooth playback.
✨ Features

Glassmorphic UI with beautiful backdrop blur
Live M3U Playlist Parser (channels.m3u)
Favorites with local storage
Search channels instantly
Category Filters (All, Sports, News, etc.)
Smooth Video Playback with VideoPlayer
Auto-hiding controls + gesture support
Fullscreen mode with system UI hiding
Wake Lock (screen stays on while playing)
Responsive & Modern UI

📱 Supported Platforms

Android (APK)
iOS (IPA)
Web (coming soon)

🛠 Tech Stack

Flutter 3.24.0+
Video Player (ExoPlayer on Android)
M3U Parser
Shared Preferences (favorites)
Wake Lock Plus
Material 3 Dark Theme with custom glass effect

🚀 Quick Start
Prerequisites

Flutter SDK (3.24.0 or higher)
Android Studio / VS Code
Android SDK (for building APK)

Step 1: Clone the repo
Bashgit clone https://github.com/YOUR_USERNAME/Ananta-Ott.git
cd Ananta-Ott
Step 2: Install dependencies
Bashflutter pub get
Step 3: Build Release APK
Bashflutter build apk --release
The APK will be available at:
textbuild/app/outputs/flutter-apk/app-release.apk
📂 Project Structure
textlib/
├── main.dart
├── models/channel.dart
└── screens/
    └── ananta_home_page.dart   (Main UI + Player)
📜 Code Overview
Key Files

models/channel.dart – Channel model
ananta_home_page.dart – Full app logic (player, favorites, search, fullscreen)
pubspec.yaml – Dependencies

🛠 Dependencies
YAMLdependencies:
  flutter:
    sdk: flutter
  video_player: ^2.9.2
  http: ^1.2.2
  shared_preferences: ^2.3.2
  wakelock_plus: ^1.3.2
  cupertino_icons: ^1.0.8
🔧 Setup

Update channels.m3u URL in main.dart
Replace the PTV stream URL if needed
Configure signing for release APK
(Optional) Add your own M3U playlist

🎥 How to Use

Open the app
Browse channels in categories
Search any channel
Add to favorites
Play any stream
Lock your phone — screen stays on (thanks to Wake Lock)
Tap screen to show/hide controls

📱 Screenshots
(Add screenshots here)
🤝 Contributing

Fork the repository
Create a feature branch (git checkout -b feature/amazing-feature)
Commit your changes (git commit -m 'Add amazing feature')
Push to the branch (git push origin feature/amazing-feature)
Open a Pull Request

📄 License
This project is licensed under the MIT License - see the LICENSE [blocked] file for details.
❤️ Support
If you love this app, please give it a ⭐ star on GitHub!

Done! Just copy the entire code above, save it as README.md in your root folder, and push to GitHub.
Would you like me to:

Add a screenshot gallery section?
Make it more minimal / elegant?
Add installation instructions for iOS?
Include changelog or faq?

Just tell me and I’ll update it instantly! 🔥
