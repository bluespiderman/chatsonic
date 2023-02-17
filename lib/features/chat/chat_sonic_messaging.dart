import 'package:http/http.dart' as http;
import 'dart:convert';

class ChatSonicApi {
  String serverUrl =
      "https://api.writesonic.com/v2/business/content/chatsonic?engine=premium";
  String apiKey = "eda2f473-5ebd-4508-a0ed-7158ff86875b";

  ChatSonicApi({required this.enableGoogleResults, required this.enableMemory});

  final bool enableGoogleResults;
  final bool enableMemory;

  Future<ChatResponse> sendMessage(String text) async {
    final response = await http.post(
      Uri.parse(serverUrl),
      headers: <String, String>{
        'Accept': 'application/json',
        'Accept-Language': '*',
        'Content-Type': 'application/json; charset=UTF-8',
        'Access-Control-Allow-Origin': '*',
        'x-api-key': apiKey
      },
      body: jsonEncode(<String, String>{
        "enable_google_results": enableGoogleResults.toString(),
        "enable_memory": enableMemory.toString(),
        "input_text": text
      }),
    );
    var data = json.decode(utf8.decode(response.bodyBytes));
    var newMessage = ChatResponse(message: "", imgUrls: []);
    if (null == data["message"]) {
      newMessage = ChatResponse(message: "Sorry, Network error.", imgUrls: []);
    } else {
      String message = data["message"];
      newMessage = ChatResponse(message: message, imgUrls: []);
    }

    return newMessage;
  }
}

enum ChatMessageType { user, bot }

class History {
  History({required this.isSent, required this.text});

  final bool isSent;
  final String text;
}

class ChatMessage {
  ChatMessage({
    required this.text,
    required this.chatMessageType,
  });

  final String text;
  final ChatMessageType chatMessageType;
}

class ChatResponse {
  ChatResponse({required this.message, required this.imgUrls});
  final String message;
  final List<String> imgUrls;
}
