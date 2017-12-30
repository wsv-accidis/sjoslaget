import 'package:angular/angular.dart';
import 'package:frontend_shared/client.dart';

@Injectable()
class ClientFactory extends ClientFactoryBase {
	ClientFactory(@Inject(SJOSLAGET_API_ROOT) String apiRoot) : super(apiRoot);
}

const OpaqueToken SJOSLAGET_API_ROOT = const OpaqueToken('sjoslagetApiRoot');
