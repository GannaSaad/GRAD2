import 'dart:io';
import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';
import 'models/prediction_response.dart';
import 'models/chat_response.dart';
import 'models/doctor_clinical_response.dart';

part 'web_services.g.dart';

@RestApi(baseUrl: "https://dentex-ai-40233588836.us-central1.run.app/")
abstract class WebServices {
  factory WebServices(Dio dio, {String? baseUrl}) = _WebServices;

  @POST("/chat")
  Future<ChatResponse> getShagyReply(@Body() Map<String, dynamic> body);

  @POST("/doctor/chat-with-image")
  @MultiPart()
  Future<DoctorClinicalResponse> doctorChatWithImage(
    @Part(name: "image") File image,
    @Part(name: "question") String? question,
  );

  @GET("/predict")
  Future<PredictionResponse> getNoShowPrediction(
    @Query("appointments") int appointments,
    @Query("cancellations") int cancellations,
  );
}
