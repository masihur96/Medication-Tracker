import 'dart:async';
import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:record/record.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:developer' as developer;
import 'dart:io';

class RecorderService {
  final AudioRecorder _recorder = AudioRecorder();

  Future<String> startRecording(String fileName) async {
    try {
      final hasPermission = await _recorder.hasPermission();
      if (!hasPermission) {
        throw Exception("Microphone permission not granted");
      }
      final dir = await getApplicationDocumentsDirectory();
      final filePath = '${dir.path}/$fileName.m4a';
      await Directory(dir.path).create(recursive: true);
      const config = RecordConfig(
        encoder: AudioEncoder.aacLc,
        bitRate: 128000,
        sampleRate: 44100,
      );
      await _recorder.start(config, path: filePath);
      return filePath;
    } catch (e) {
      throw Exception("Failed to start recording: $e");
    }
  }

  Future<String?> stopRecording() async {
    try {
      if (await _recorder.isRecording()) {
        final filePath = await _recorder.stop();
        return filePath;
      }
      return null;
    } catch (e) {
      throw Exception("Failed to stop recording: $e");
    } finally {
      await _recorder.dispose();
    }
  }

  Future<bool> isRecording() async {
    try {
      return await _recorder.isRecording();
    } catch (e) {
      throw Exception("Failed to check recording status: $e");
    }
  }

  Future<void> cancelRecording() async {
    try {
      if (await _recorder.isRecording()) {
        await _recorder.cancel();
      }
    } catch (e) {
      throw Exception("Failed to cancel recording: $e");
    } finally {
      await _recorder.dispose();
    }
  }

  Future<void> dispose() async {
    try {
      await _recorder.dispose();
    } catch (e) {
      throw Exception("Failed to dispose recorder: $e");
    }
  }
}