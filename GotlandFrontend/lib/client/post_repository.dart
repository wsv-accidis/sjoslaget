import 'package:angular/angular.dart';
import 'package:frontend_shared/client/repository/post_repository_base.dart';

import 'client_factory.dart' show GOTLAND_API_ROOT;

@Injectable()
class PostRepository extends PostRepositoryBase {
  PostRepository(@Inject(GOTLAND_API_ROOT) String apiRoot) : super(apiRoot);
}
