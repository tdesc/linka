library linka.globals;
import 'dart:async';
import 'package:http/http.dart' as http;

import 'package:camera/camera.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:googleapis/translate/v2.dart' as api;
import 'package:googleapis/translate/v2.dart' show TranslateTextRequest, TranslationsListResponse;
import 'package:googleapis_auth/auth_io.dart';

FirebaseUser user;
double gridSize = 1;
List<CameraDescription> cameras;
String language = "ru-RU";
List<String> ttsLanguages;
FlutterTts flutterTts;

void init() async
{
  flutterTts = FlutterTts();
  ttsLanguages = List.from(await flutterTts.getLanguages);
  print("tts languages available $ttsLanguages");

  await flutterTts.setVolume(1.0);
  var result = await flutterTts.isLanguageAvailable(language);
  print("language $result");

  await flutterTts.setLanguage(language);

  getAvailableCameras();
  user = await FirebaseAuth.instance.signInAnonymously();
  print("loggedIn as ${user.toString()}");
}

void getAvailableCameras () async {
  try {
    cameras = await availableCameras();
  } on CameraException catch (e) {
    logError(e.code, e.description);
  }
}

void logError(String code, String message) =>
  print('Error: $code\nError Message: $message');

Future<void> addItem(String downloadURL, List<String> labels) async {
  await Firestore.instance.collection('items').add(<String, dynamic> {
    'downloadURL': downloadURL,
    'labels': labels
  });
}

// const _SCOPES = const [StorageApi.DevstorageReadOnlyScope];
final apiKey = 'AIzaSyB1dhK2fO-yaQizCDV0ka9o4W7HsS6NVBw';

Future<String> translate(String text ) async {

  final client = clientViaApiKey(apiKey);  
  return translateCall(text, client);

}

Future<String> translateCall(String text, http.Client httpClient) async {
    
  String input = text;
  String output = "Я не знаю это слово";

  var request = TranslateTextRequest.fromJson({
    "q": [input],
    "target": "ru",
    "source": "en",
    "format": "text"
  });

  try {
    
    var googleApi = api.TranslateApi(httpClient);
    TranslationsListResponse result = await googleApi.translations.translate(request);
 
    print(result.translations.first.translatedText);
    output = result.translations.first.translatedText;
    
  } catch (error) {
    print(error.toString());
  }
  return output;
}


// final Uri googleTranslateUri = Uri.https('translation.googleapis.com', '/language/translate/v2');

// Future<String> translateCall(String text, http.Client httpClient) async {
    
//   String input = "Hello";

//   var request = TranslateTextRequest.fromJson({
//     "q": [input],
//     "target": "ru",
//     "source": "en",
//     "format": "text"
//   });

//   try {
//     var response = await http.post(googleTranslateUri,
//       headers: { HttpHeaders.authorizationHeader: apiKey }, 
//       body: request.toString());
//       print(response.body);

//   } catch (error) {
//     print(error.toString());
//   }
//   return "Привет";
// }

Future<void> speak(String text) async {

  String translated = await translate(text);
  flutterTts.speak(translated);
}