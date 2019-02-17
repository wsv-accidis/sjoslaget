class ClientUtil {
	static Map<String, String> createJsonHeaders() {
		final headers = <String, String>{};
		headers['content-type'] = 'application/json';
		return headers;
	}
}
