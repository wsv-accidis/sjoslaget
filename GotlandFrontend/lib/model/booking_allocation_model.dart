class BookingAllocationModel {
	static const String STATUS_NONE = 'none';
	static const String STATUS_FULLY_ALLOC = 'fully-alloc';
	static const String STATUS_PARTIALLY_ALLOC = 'partially-alloc';
	static const String STATUS_OVER_ALLOC = 'over-alloc';
	static const String STATUS_NOT_ALLOC = 'not-alloc';

	final int numberOfPax;
	final int allocatedPax;

	BookingAllocationModel(this.numberOfPax, this.allocatedPax);

	bool get hasPax => numberOfPax > 0;

	bool get isFullyAllocated => hasPax && numberOfPax == allocatedPax;

	bool get isPartiallyAllocated => hasPax && allocatedPax > 0 && numberOfPax > allocatedPax;

	bool get isOverAllocated => hasPax && numberOfPax < allocatedPax;

	bool get inUnallocated => hasPax && 0 == allocatedPax;

	String get status {
		if (isFullyAllocated)
			return STATUS_FULLY_ALLOC;
		if (isPartiallyAllocated)
			return STATUS_PARTIALLY_ALLOC;
		if (isOverAllocated)
			return STATUS_OVER_ALLOC;
		if (inUnallocated)
			return STATUS_NOT_ALLOC;

		return STATUS_NONE;
	}

	int get statusAsInt {
		if (isFullyAllocated)
			return 3;
		if (isPartiallyAllocated)
			return 2;
		if (isOverAllocated)
			return 1;
		if (inUnallocated)
			return 0;

		return -1;
	}
}
