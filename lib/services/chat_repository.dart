// Method to create a new notice

import 'dart:developer';

import 'package:med_track/models/chat_model.dart';
import 'package:med_track/providers/data_provider.dart';


class ChatRepository {

  final DataProvider _dataProvider = DataProvider();
  Future<ChatBootModel?> createChat({
    required String text,

  }) async {


    ChatBootModel? chatBootModel;


    // Prepare data for POST request
    dynamic data={
      "model": "mistral-large-latest",
      "messages": [
        {
          "role": "user",
          "content": text
        }
      ]
    };


    // Request header
    dynamic header = {"Authorization": "Bearer oTHYtzUNkwfdKh1eympxYigEaLc99G3Q"};

    try {
      // Perform the POST request
      var response = await _dataProvider.fetchData(
        "POST",
        "https://api.mistral.ai/v1/chat/completions",
        data: data,
        header: header,
      );
      log("Create Notice status Code: ${response!.statusCode}");

      if (response.statusCode == 200) {
        var data = response.data;
        chatBootModel = ChatBootModel.fromJson(data);

        print("Successfully Created: ${chatBootModel.choices.first.message!.content}");

      } else {
        print("Failed to create notice: ${response.statusMessage}");

      }
    } catch (exception, stackTrace) {
      // Log exception and capture it using Sentry for error monitoring

      print("Exception: $exception");
      return data;
    }



    return chatBootModel;
}

}