// Openapi Generator last run: : 2026-02-11T11:12:15.521992
import 'package:openapi_generator_annotations/openapi_generator_annotations.dart';

@Openapi(
  additionalProperties: DioProperties(
      pubName: 'my_api_client', // Name of generated package
      pubAuthor: 'Abdisamad Yusuf'),
  inputSpec: RemoteSpec(
    path: 'http://192.168.0.198:8000/api-spec.json', // Your spec URL
  ),
  generatorName: Generator.dio, // THIS IS KEY: Dio client for Flutter
  runSourceGenOnOutput: true, // Auto-runs json_serializable if needed
  outputDirectory: 'api_client', // Generated code goes here
  skipIfSpecIsUnchanged: true, // Useful for remote specs to ensure it update
)
class ApiConfig {}