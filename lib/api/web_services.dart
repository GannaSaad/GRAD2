import 'dart:io';
import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';
import 'models/prediction_response.dart';
import 'models/chat_response.dart';
import 'models/doctor_clinical_response.dart';
import 'models/doctor_chat_response.dart';

part 'web_services.g.dart';

@RestApi(baseUrl: "http://104.198.50.23:8001/")
abstract class WebServices {
  factory WebServices(Dio dio, {String? baseUrl}) = _WebServices;

  // Patient chatbot on port 8000
  @POST("http://104.198.50.23:8000/chat")
  Future<ChatResponse> getShagyReply(@Body() Map<String, dynamic> body);

  @POST("/doctor/chat-text")
  Future<DoctorChatResponse> getDoctorReply(@Body() Map<String, dynamic> body);

  @POST("/doctor/chat-with-image")
  @MultiPart()
  Future<DoctorChatResponse> doctorChatWithImage(
    @Part(name: "image") File image,
    @Part(name: "question") String? question,
  );

  // No-show prediction on separate API (port 8002)
  @POST("http://104.198.50.23:8002/predict")
  Future<PredictionResponse> getNoShowPrediction(
    @Body() Map<String, dynamic> body,
  );

  // Speech-to-text on separate API (port 8003)
  @POST("http://104.198.50.23:8003/api/voice-to-record")
  @MultiPart()
  Future<Map<String, dynamic>> voiceToRecord(
    @Part(name: "file") File audioFile,
  );
}
