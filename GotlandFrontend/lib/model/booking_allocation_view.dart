import 'booking_allocation.dart';
import 'cabin_class_detail.dart';

class BookingAllocationView {
	final CabinClassDetail cabinClassDetail;
	final int noOfPax;
	final String note;

	int get capacity => cabinClassDetail.capacity;

	int get no => cabinClassDetail.no;

	String get title => cabinClassDetail.title;

	BookingAllocationView(this.cabinClassDetail, this.noOfPax, this.note);

	BookingAllocationView.fromBookingAllocation(BookingAllocation alloc, List<CabinClassDetail> details) :
			this(_getDetail(alloc.cabinId, details), alloc.noOfPax, alloc.note);

	BookingAllocation toBookingAllocation() =>
		BookingAllocation(cabinClassDetail.id, noOfPax, note);

	static CabinClassDetail _getDetail(String id, List<CabinClassDetail> details) =>
		details.firstWhere((d) => d.id == id);
}
