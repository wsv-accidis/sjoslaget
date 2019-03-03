import 'package:angular/angular.dart';
import 'package:frontend_shared/client/repository/payment_repository_base.dart';

import 'client_factory.dart' show GOTLAND_API_ROOT;

@Injectable()
class PaymentRepository extends PaymentRepositoryBase {
	PaymentRepository(@Inject(GOTLAND_API_ROOT) String apiRoot) : super(apiRoot);
}
