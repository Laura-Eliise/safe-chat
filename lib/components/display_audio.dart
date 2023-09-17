import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';

class DisplayAudio extends StatefulWidget {
  const DisplayAudio({super.key, required this.url});

  final String url;

  @override
  State<DisplayAudio> createState() => _DisplayAudioState();
}

class _DisplayAudioState extends State<DisplayAudio> {
  late AudioPlayer player;

  @override
  void dispose() {
    player.dispose();
    super.dispose();
  }

  @override
  void initState() {
    player = AudioPlayer();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Text(
          "Audio: ",
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
        ),
        IconButton(
          icon: const Icon(Icons.play_arrow),
          onPressed: () {
            player.play(UrlSource(widget.url));
          },
        ),
      ],
    );
  }
}
