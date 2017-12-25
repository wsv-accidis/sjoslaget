import 'package:decimal/decimal.dart';

class ValueComparer {
	static int compareStringPair(String a1, String a2, String b1, String b2) {
		int result = a1.compareTo(b1);
		return 0 != result ? result : a2.compareTo(b2);
	}
}
