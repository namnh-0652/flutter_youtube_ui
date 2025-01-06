import 'package:better_player_plus/better_player_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_youtube_ui/data.dart';
import 'package:flutter_youtube_ui/screens/nav_screen.dart';
import 'package:flutter_youtube_ui/widgets/widgets.dart';
import 'package:flutter_youtube_ui/ytlib/miniplayer.dart';

class VideoScreen extends StatefulWidget {
  const VideoScreen({super.key, required this.videoController});
  final BetterPlayerController videoController;
  @override
  _VideoScreenState createState() => _VideoScreenState();
}

class _VideoScreenState extends State<VideoScreen> {
  ScrollController? _scrollController;
  final _ignoreScrolling = ValueNotifier<bool>(false);

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
  }

  @override
  void dispose() {
    _scrollController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        color: Theme.of(context).scaffoldBackgroundColor,
        child: Listener(
          onPointerMove: (event) {
            _ignoreScrolling.value = event.delta.dy > 0 && _scrollController!.position.pixels == 0;
          },
          child: ValueListenableBuilder(
            valueListenable: _ignoreScrolling,
            builder: (context, value, child) {
              return Consumer(
                builder: (context, ref, _) {
                  final selectedVideo = ref.watch(selectedVideoProvider);
                  return SafeArea(
                    child: Column(
                      children: [
                        Stack(
                          children: [
                            AspectRatio(
                              aspectRatio: 16 / 9,
                              child: BetterPlayer(controller: widget.videoController),
                            ),
                            IconButton(
                              iconSize: 30.0,
                              icon: const Icon(Icons.keyboard_arrow_down),
                              onPressed: () => ref
                                  .read(miniPlayerControllerProvider)
                                  .animateToHeight(state: PanelState.MIN),
                            ),
                          ],
                        ),
                        Expanded(
                          child: SingleChildScrollView(
                            physics: _ignoreScrolling.value
                                ? const NeverScrollableScrollPhysics()
                                : const AlwaysScrollableScrollPhysics(),
                            controller: _scrollController,
                            child: Column(
                              children: [
                                VideoInfo(video: selectedVideo!),
                                ListView.builder(
                                  shrinkWrap: true,
                                  physics: const NeverScrollableScrollPhysics(),
                                  itemCount: suggestedVideos.length,
                                  itemBuilder: (context, index) {
                                    final video = suggestedVideos[index];
                                    return VideoCard(
                                      video: video,
                                      hasPadding: true,
                                      onTap: () => _scrollController!.animateTo(
                                        0,
                                        duration: const Duration(milliseconds: 200),
                                        curve: Curves.easeIn,
                                      ),
                                    );
                                  },
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              );
            },
          ),
        ),
      ),
    );
  }
}
