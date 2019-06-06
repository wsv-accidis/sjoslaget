import 'package:http/http.dart' show Client;

abstract class ClientProvider {
	Client getClient();
}
