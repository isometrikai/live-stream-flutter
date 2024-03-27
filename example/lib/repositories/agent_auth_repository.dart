import 'package:appscrip_live_stream_component/appscrip_live_stream_component.dart';
import 'package:appscrip_live_stream_component_example/models/agent_model.dart';
import 'package:appscrip_live_stream_component_example/utils/utility.dart';
import 'package:http/http.dart' show Client;

class AgetAuthRepository {
  AgetAuthRepository(this.$client) : _apiWrapper = IsmLiveApiWrapper($client);

  final Client $client;
  final IsmLiveApiWrapper _apiWrapper;
  Future<IsmLiveResponseModel> agentlogin({required AgentModel payload}) =>
      _apiWrapper.makeRequest(
        IsmLiveApis.agentLogin,
        baseUrl: IsmLiveApis.agentauthenticate,
        type: IsmLiveRequestType.patch,
        payload: payload.toMap(),
        headers: Utility.secretHeader(),
        showLoader: true,
        showDialog: true,
      );

  Future<IsmLiveResponseModel> agentSendOtp({required AgentModel payload}) =>
      _apiWrapper.makeRequest(
        IsmLiveApis.agentSendOtp,
        baseUrl: IsmLiveApis.agentauthenticate,
        type: IsmLiveRequestType.post,
        payload: payload.toMap().removeNullValues(),
        headers: Utility.secretHeader(),
        showLoader: true,
        showDialog: true,
      );
}
