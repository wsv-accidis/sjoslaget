import 'dart:async';
import 'dart:convert';

import 'package:angular/angular.dart';
import 'package:frontend_shared/client.dart';
import 'package:frontend_shared/client/repository/user_repository_base.dart';
import 'package:http/http.dart';

import '../model/json_field.dart';
import 'client_factory.dart' show SJOSLAGET_API_ROOT;

@Injectable()
class UserRepository extends UserRepositoryBase {
	UserRepository(@Inject(SJOSLAGET_API_ROOT) String apiRoot) : super(apiRoot);
}
