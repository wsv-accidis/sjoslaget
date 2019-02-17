import 'package:angular/angular.dart';
import 'package:frontend_shared/client/repository/user_repository_base.dart';

import 'client_factory.dart' show GOTLAND_API_ROOT;

@Injectable()
class UserRepository extends UserRepositoryBase {
	UserRepository(@Inject(GOTLAND_API_ROOT) String apiRoot) : super(apiRoot);
}
