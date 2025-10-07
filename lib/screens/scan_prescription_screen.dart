import 'dart:convert';
import 'dart:io';
import 'package:camera/camera.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';

class FullScreenCameraScanner extends StatefulWidget {
  const FullScreenCameraScanner({super.key});

  @override
  State<FullScreenCameraScanner> createState() => _FullScreenCameraScannerState();
}

class _FullScreenCameraScannerState extends State<FullScreenCameraScanner> {
  CameraController? _controller;
  bool _isCameraReady = false;
  bool _isLoading = false;
  final dio = Dio();

  final String apiKey = "YOUR_GOOGLE_VISION_API_KEY";
  final String visionUrl = "https://vision.googleapis.com/v1/images:annotate";

  @override
  void initState() {
    super.initState();
    initCamera();
  }

  Future<void> initCamera() async {
    final cameras = await availableCameras();
    final backCamera = cameras.firstWhere(
          (c) => c.lensDirection == CameraLensDirection.back,
    );

    _controller = CameraController(backCamera, ResolutionPreset.medium);
    await _controller!.initialize();
    setState(() => _isCameraReady = true);
  }

  Future<void> captureAndScan(BuildContext context) async {
    if (_controller == null || !_controller!.value.isInitialized) return;

    try {
      setState(() => _isLoading = true);

      // Take picture
      final XFile picture = await _controller!.takePicture();
      final File imageFile = File(picture.path);

      // Convert to base64
      final bytes = await imageFile.readAsBytes();
      final base64Image = base64Encode(bytes);

      final requestBody = {
        "requests": [
          {
            "image": {"content": base64Image},
            "features": [
              {"type": "DOCUMENT_TEXT_DETECTION"}
            ]
          }
        ]
      };

      final response = await dio.post(
        "$visionUrl?key=$apiKey",
        data: requestBody,
      );

      final annotations = response.data["responses"][0]["fullTextAnnotation"];
      final text = annotations?["text"] ?? "";

      final lines = text.split("\n").map((e) => e.trim()).toList();
      final meds = lines.where((l) {
        final lower = l.toLowerCase();
        return lower.contains("mg") ||
            lower.contains("ml") ||
            lower.contains("tablet") ||
            lower.contains("cap") ||
            lower.contains("syrup");
      }).toList();

      if (mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ScanResultPage(
              imagePath: imageFile.path,
              fullText: text,
              medicines: meds,
            ),
          ),
        );
      }
    } catch (e) {
      debugPrint("Error: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Scan failed. Try again.")),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }


  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_isCameraReady) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          CameraPreview(_controller!),
          if (_isLoading)
            Container(
              color: Colors.black54,
              child: const Center(
                child: CircularProgressIndicator(color: Colors.teal),
              ),
            ),
          Positioned(
            bottom: 40,
            left: 0,
            right: 0,
            child: Center(
              child: GestureDetector(
                onTap:(){
    _isLoading ? null : captureAndScan(context);
    },
                child: Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 4),
                    color: _isLoading ? Colors.grey : Colors.white,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class ScanResultPage extends StatelessWidget {
  final String imagePath;
  final String fullText;
  final List<String> medicines;

  const ScanResultPage({
    super.key,
    required this.imagePath,
    required this.fullText,
    required this.medicines,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Scan Result"), backgroundColor: Colors.teal),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.file(File(imagePath), height: 220, fit: BoxFit.cover),
            ),
            const SizedBox(height: 16),
            if (medicines.isNotEmpty)
              Expanded(
                child: ListView(
                  children: [
                    const Text(
                      "Detected Medicines:",
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 8),
                    ...medicines.map((m) => ListTile(
                      leading: const Icon(Icons.medical_services_outlined,
                          color: Colors.teal),
                      title: Text(m),
                    )),
                  ],
                ),
              )
            else
              Expanded(
                child: SingleChildScrollView(child: Text(fullText)),
              ),
          ],
        ),
      ),
    );
  }
}
