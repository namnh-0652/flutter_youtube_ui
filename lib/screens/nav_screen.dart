import 'package:better_player_plus/better_player_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_youtube_ui/data.dart';
import 'package:flutter_youtube_ui/screens/home_screen.dart';
import 'package:flutter_youtube_ui/screens/video_screen.dart';
import 'package:flutter_youtube_ui/ytlib/miniplayer.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

final selectedVideoProvider = StateProvider<Video?>((ref) => null);

final miniPlayerControllerProvider = StateProvider.autoDispose<MiniplayerController>(
  (ref) => MiniplayerController(),
);

final _screens = [
  HomeScreen(),
  const Scaffold(body: Center(child: Text('Explore'))),
  const Scaffold(body: Center(child: Text('Add'))),
  const Scaffold(body: Center(child: Text('Subscriptions'))),
  const Scaffold(body: Center(child: Text('Library'))),
];

class NavScreen extends HookConsumerWidget {
  NavScreen({super.key});

  static const double _playerMinHeight = 126.0;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedIndex = useState(0);
    final selectedVideo = ref.watch(selectedVideoProvider);
    final miniPlayerController = ref.watch(miniPlayerControllerProvider);

    return Scaffold(
      body: Stack(
        children: _screens
            .asMap()
            .map((i, screen) => MapEntry(
                  i,
                  Offstage(
                    offstage: selectedIndex.value != i,
                    child: screen,
                  ),
                ))
            .values
            .toList()
          ..add(
            Offstage(
              offstage: selectedVideo == null,
              child: HookConsumer(builder: (context, ref, _) {
                final videoController = useMemoized(() {
                  return BetterPlayerController(
                    betterPlayerDataSource: BetterPlayerDataSource.network(
                      selectedVideo?.videoUrl ?? '',
                    ),
                    BetterPlayerConfiguration(autoDispose: false, autoPlay: true),
                  )..setControlsEnabled(false);
                }, [selectedVideo]);
                useEffect(() {
                  return () => videoController.dispose(forceDispose: true);
                }, []);
                return Miniplayer(
                  controller: miniPlayerController,
                  minHeight: _playerMinHeight,
                  maxHeight: MediaQuery.of(context).size.height,
                  builder: (height, percentage) {
                    if (height <= _playerMinHeight + 200) {
                      return Material(
                        color: Colors.transparent,
                        child: Stack(
                          children: [
                            AspectRatio(
                              aspectRatio: 16 / 9,
                              child: SizedBox(
                                height: _playerMinHeight - 4,
                                child: BetterPlayer(controller: videoController),
                              ),
                            ),
                            Positioned(
                              right: 0,
                              child: IconButton(
                                iconSize: 24.0,
                                icon: const Icon(Icons.close),
                                onPressed: () {
                                  videoController.dispose(forceDispose: true);
                                  ref.read(selectedVideoProvider.notifier).state = null;
                                },
                              ),
                            ),
                          ],
                        ),
                      );
                    }
                    return VideoScreen(videoController: videoController);
                  },
                );
              }
              ),
            ),
          ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: selectedIndex.value,
        onTap: (i) => selectedIndex.value = i,
        selectedFontSize: 10.0,
        unselectedFontSize: 10.0,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.explore_outlined),
            activeIcon: Icon(Icons.explore),
            label: 'Explore',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.add_circle_outline),
            activeIcon: Icon(Icons.add_circle),
            label: 'Add',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.subscriptions_outlined),
            activeIcon: Icon(Icons.subscriptions),
            label: 'Subscriptions',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.video_library_outlined),
            activeIcon: Icon(Icons.video_library),
            label: 'Library',
          ),
        ],
      ),
    );
  }
}
