class CruiseCabin {
	final int capacity;
	final int count;
	final String description;
	final String id;
	final String name;
	final int pricePerPax;

	CruiseCabin(this.id, this.name, this.description, this.capacity, this.count, this.pricePerPax);

	factory CruiseCabin.fromJson(Map<String, dynamic> json) =>
		new CruiseCabin(json['Id'], json['Name'], json['Description'], _toInt(json['Capacity']), _toInt(json['Count']), _toInt(json['PricePerPax']));
}

int _toInt(id) {
	if(id is int) return id;
	if(id is double) return id.toInt();
	return int.parse(id.toString());
}
