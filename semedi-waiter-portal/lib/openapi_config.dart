import 'package:openapi_generator_annotations/openapi_generator_annotations.dart';

@Openapi(
  additionalProperties: DioProperties(
    pubName: 'my_api_client',
    pubAuthor: 'Abdisamad Yusuf',
    serializationLibrary: DioSerializationLibrary.jsonSerializable,
  ),
  inputSpec: InputSpec(
    path: 'openapi_patched.json',
  ),
  generatorName: Generator.dio,
  runSourceGenOnOutput: false,
  outputDirectory: 'api_client',
  skipIfSpecIsUnchanged: true,
)
class ApiConfig {}
