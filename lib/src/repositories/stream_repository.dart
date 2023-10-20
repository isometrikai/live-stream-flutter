import 'package:appscrip_live_stream_component/appscrip_live_stream_component.dart';
import 'package:http/http.dart' show Client;

class IsmLiveStreamRepository {
  IsmLiveStreamRepository(this.$client)
      : _apiWrapper = IsmLiveApiWrapper($client);

  final Client $client;
  final IsmLiveApiWrapper _apiWrapper;
}
