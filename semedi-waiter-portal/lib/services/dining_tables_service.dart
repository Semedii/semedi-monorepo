import 'package:my_api_client/my_api_client.dart' show DefaultApi;

import '../models/dining_tables.dart';
import '../models/area_zone.dart';

class DiningTablesService {
  final DefaultApi _api;

  DiningTablesService(this._api);

  getDiningTables() async {
    final response = await _api.readMeApiAuthMeGet();
    print("response, ${response}");
  }

  getDiningTablesStream() {
    // return _supabase.from('dining_tables').stream(primaryKey: ['id']).map(
    //     (rows) => rows.map((json) => DiningTables.fromJson(json)).toList());
  }
}
