class CruiseCabin {
	static const ID = 'Id';
	static const NAME = 'Name';
	static const DESCRIPTION = 'Description';
	static const CAPACITY = 'Capacity';
	static const COUNT = 'Count';
	static const PRICE_PER_PAX = 'PricePerPax';

	final int capacity;
	final int count;
	final String description;
	final String id;
	final String name;
	final int pricePerPax;

	int get pricePerCabin => pricePerPax * capacity;

	CruiseCabin(this.id, this.name, this.description, this.capacity, this.count, this.pricePerPax);

	factory CruiseCabin.fromJson(Map<String, dynamic> json) =>
		new CruiseCabin(json[ID], json[NAME], json[DESCRIPTION], _toInt(json[CAPACITY]), _toInt(json[COUNT]), _toInt(json[PRICE_PER_PAX]));

	static int _toInt(id) {
		if (id is int)
			return id;
		if (id is double)
			return id.toInt();

		return int.parse(id.toString());
	}
}
