import 'package:angular_components/model/selection/selection_options.dart';

class Gender {
	static const String GENDER_FEMALE = 'f';
	static const String GENDER_MALE = 'm';
	static const String GENDER_OTHER = 'x';

	static SelectionOptions<String> getOptions() => SelectionOptions.fromList(<String>[GENDER_FEMALE, GENDER_MALE, GENDER_OTHER]);

	static String asString(String g) {
		switch (g) {
			case GENDER_FEMALE:
				return 'Kvinna';
			case GENDER_MALE:
				return 'Man';
			default:
				return 'Annat';
		}
	}
}
