import 'dart:async';

import 'package:angular2/core.dart';
import 'package:http/http.dart';
import 'package:http/browser_client.dart';

@Injectable()
class ClientFactory {
	Future<Client> createClient() async {
		return new BrowserClient();
	}
}

const OpaqueToken SJOSLAGET_API_ROOT = const OpaqueToken("sjoslagetApiRoot");
