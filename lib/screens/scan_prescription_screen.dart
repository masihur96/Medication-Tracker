import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
class PrescriptionHome extends StatefulWidget {
  const PrescriptionHome({super.key});

  @override
  State<PrescriptionHome> createState() => _PrescriptionHomeState();
}

class _PrescriptionHomeState extends State<PrescriptionHome> {
  final picker = ImagePicker();
  final dio = Dio();
  File? _imageFile;
  bool _loading = false;
  String? extractedText;
  List<String> medicineLines = [];

  final String apiKey = "YOUR_GOOGLE_VISION_API_KEY";
  final String visionUrl =
      "https://vision.googleapis.com/v1/images:annotate";

  Future<void> pickImage() async {
    final picked = await picker.pickImage(source: ImageSource.gallery);
    if (picked != null) {
      setState(() => _imageFile = File(picked.path));
    }
  }

  Future<void> scanImage() async {
    if (_imageFile == null) return;
    setState(() {
      _loading = true;
      extractedText = null;
      medicineLines.clear();
    });

    try {
      final bytes = await _imageFile!.readAsBytes();
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
      final meds = lines.where((l) =>
      l.toLowerCase().contains("mg") ||
          l.toLowerCase().contains("ml") ||
          RegExp(r"\\d-\\d-\\d").hasMatch(l) ||
          l.toLowerCase().contains("tablet") ||
          l.toLowerCase().contains("cap")).toList();

      setState(() {
        extractedText = text;
        medicineLines = meds;
      });
    } catch (e) {
      debugPrint("Error: $e");
    } finally {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("AI Prescription Scanner")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            if (_imageFile != null)
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.file(_imageFile!, height: 220, fit: BoxFit.cover),
              ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.photo),
                    label: const Text("Pick Image"),
                    onPressed: pickImage,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.document_scanner_outlined),
                    label: const Text("Scan"),
                    onPressed: scanImage,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (_loading)
              CircularProgressIndicator(color: Colors.teal)
              // const SpinKitCircle(color: Colors.teal, size: 40)
            else if (medicineLines.isNotEmpty)
              Expanded(
                child: ListView(
                  children: [
                    Text(
                      "Extracted Medicines",

                    ),
                    const SizedBox(height: 8),
                    ...medicineLines.map(
                          (line) => Card(
                        elevation: 2,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                        child: ListTile(
                          leading: const Icon(Icons.medical_services_outlined,
                              color: Colors.teal),
                          title: Text(line),
                        ),
                      ),
                    ),
                  ],
                ),
              )
            else if (extractedText != null)
                Expanded(
                  child: SingleChildScrollView(
                    child: Text(extractedText ?? ""),
                  ),
                ),
          ],
        ),
      ),
      floatingActionButton: medicineLines.isNotEmpty
          ? FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) =>
                  EPrescriptionPage(medicines: medicineLines),
            ),
          );
        },
        label: const Text("Generate e-Prescription"),
        icon: const Icon(Icons.receipt_long_outlined),
      )
          : null,
    );
  }
}

class EPrescriptionPage extends StatelessWidget {
  final List<String> medicines;
  const EPrescriptionPage({super.key, required this.medicines});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("e-Prescription Preview")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Card(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          elevation: 3,
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Dr. John Doe",
                    // style: GoogleFonts.poppins(
                    //     fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                const Text("MBBS, MD (Medicine)"),
                const Divider(),
                const Text("Patient Name: ______________________"),
                const SizedBox(height: 12),
                Text("Prescription:",
                    // style: GoogleFonts.poppins(
                    //     fontSize: 18, fontWeight: FontWeight.w600)
                ),
                const SizedBox(height: 8),
                Expanded(
                  child: ListView.builder(
                    itemCount: medicines.length,
                    itemBuilder: (ctx, i) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 6),
                        child: Text("• ${medicines[i]}",
                            style: const TextStyle(fontSize: 16)),
                      );
                    },
                  ),
                ),
                const Divider(),
                const Align(
                  alignment: Alignment.bottomRight,
                  child: Text("Signature: ____________"),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}