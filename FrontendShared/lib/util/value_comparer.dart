
class ValueComparer {
	static int compareStringPair(String a1, String a2, String b1, String b2) {
		int result = a1.compareTo(b1);
		return 0 != result ? result : a2.compareTo(b2);
	}

	static int compareStringsWithNumbers(String a, String b) {
		return _normalizeNumbers(a).compareTo(_normalizeNumbers(b));
	}

	// Poor man's natural number sort - prefix single digits by 0
	static String _normalizeNumbers(String str) =>
		str.replaceAllMapped(RegExp(r'(\s|^)([0-9])([a-z]|\s|$)'), (m) => '${m[1]}0${m[2]}${m[3]}');
}
