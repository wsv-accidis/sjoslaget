import 'package:angular_components/model/selection/selection_options.dart';

class Food {
	static const String FOOD_MEAT = 'm';
	static const String FOOD_VEG = 'v';

	static SelectionOptions<String> getOptions() => SelectionOptions.fromList(<String>[FOOD_MEAT, FOOD_VEG]);

	static String asString(String g) {
		switch (g) {
			case FOOD_MEAT:
				return 'Kött';
			case FOOD_VEG:
				return 'Vegansk';
			default:
				return '-';
		}
	}
}
