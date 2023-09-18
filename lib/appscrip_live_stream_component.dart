import 'package:appscrip_live_stream_component/appscrip_live_stream_component_platform_interface.dart';

export 'src/controllers/controllers.dart';
export 'src/data/data.dart';
export 'src/models/models.dart';
export 'src/repositories/repositories.dart';
export 'src/res/res.dart';
export 'src/utils/utils.dart';
export 'src/view_models/view_models.dart';
export 'src/views/views.dart';
export 'src/widgets/widgets.dart';

class AppscripLiveStreamComponent {
  Future<String?> getPlatformVersion() =>
      AppscripLiveStreamComponentPlatform.instance.getPlatformVersion();
}
