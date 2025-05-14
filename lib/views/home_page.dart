import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:test1/controllers/radio_controller.dart';
import 'package:test1/views/equalizer_widget.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final RadioController controller = Get.put(RadioController());
    const String radioUrl = 'https://live.radiodarbast.com/stream.mp3';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Radio Visualizer'),
        centerTitle: true,
        elevation: 0,
      ),
      backgroundColor: Colors.grey[100],
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Equalizer Visualizer with Card
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  children: [
                    const Text(
                      'Audio Visualizer',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 20),
                    SizedBox(
                      height: 150,
                      child: const EqualizerVisualizer(
                        height: 120,
                        barColor: Colors.blueAccent,
                        // spacing: 3.0,
                        // borderRadius: 8.0,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 40),

            // Play/Pause Button
            Obx(() {
              return ElevatedButton.icon(
                icon: Icon(
                  controller.isPlaying.value ? Icons.pause : Icons.play_arrow,
                  size: 28,
                ),
                label: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 20),
                  child: Text(
                    controller.isPlaying.value ? 'PAUSE' : 'PLAY',
                    style: const TextStyle(fontSize: 18),
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blueAccent,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 4,
                ),
                onPressed: () async {
                  try {
                    if (controller.isPlaying.value) {
                      await controller.pauseRadio();
                    } else {
                      await controller.playRadio(radioUrl);
                    }
                  } catch (e) {
                    Get.snackbar(
                      'Error',
                      'Failed to ${controller.isPlaying.value ? 'pause' : 'play'} radio',
                      snackPosition: SnackPosition.BOTTOM,
                      backgroundColor: Colors.red[400],
                      colorText: Colors.white,
                    );
                  }
                },
              );
            }),

            const SizedBox(height: 20),

            // Radio Info
            Obx(() {
              return AnimatedOpacity(
                opacity: controller.isPlaying.value ? 1.0 : 0.0,
                duration: const Duration(milliseconds: 300),
                child: const Column(
                  children: [
                    Text(
                      'Now Playing',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey,
                      ),
                    ),
                    SizedBox(height: 5),
                    Text(
                      'Radio Darbast',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}