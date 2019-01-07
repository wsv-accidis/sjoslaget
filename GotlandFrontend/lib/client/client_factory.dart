import 'package:angular/angular.dart';
import 'package:frontend_shared/client.dart';

@Injectable()
class ClientFactory extends ClientFactoryBase {
	ClientFactory(@Inject(GOTLAND_API_ROOT) String apiRoot) : super(apiRoot);
}

const OpaqueToken GOTLAND_API_ROOT = OpaqueToken<String>('gotlandApiRoot');
