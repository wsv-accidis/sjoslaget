import 'booking_allocation.dart';
import 'cabin_class.dart';
import 'cabin_class_detail.dart';

class BookingAllocationView {
	final CabinClass cabinClass;
	final CabinClassDetail cabinClassDetail;
	final int noOfPax;
	final String note;

	int get capacity => cabinClassDetail.capacity;

	int get no => cabinClassDetail.no;

	int get price => noOfPax * cabinClass.pricePerPax.toInt();

	String get title => cabinClassDetail.title;

	BookingAllocationView(this.cabinClass, this.cabinClassDetail, this.noOfPax, this.note);

	factory BookingAllocationView.fromBookingAllocation(BookingAllocation alloc, List<CabinClass> classes, List<CabinClassDetail> details) {
		final cabinClassDetail = _getDetail(alloc.cabinId, details);
		final cabinClass = _getClass(cabinClassDetail.no, classes);
		return BookingAllocationView(cabinClass, cabinClassDetail, alloc.noOfPax, alloc.note);
	}

	static List<BookingAllocationView> fromListOfBookingAllocation(List<BookingAllocation> alloc, List<CabinClass> classes, List<CabinClassDetail> details) {
		final result = alloc.map((a) =>
			BookingAllocationView.fromBookingAllocation(a, classes, details))
			.toList();
		result.sort(_comparator);
		return result;
	}

	BookingAllocation toBookingAllocation() =>
		BookingAllocation(cabinClassDetail.id, noOfPax, note);

	static CabinClass _getClass(int no, List<CabinClass> classes) =>
		classes.firstWhere((c) => c.no == no);

	static CabinClassDetail _getDetail(String id, List<CabinClassDetail> details) =>
		details.firstWhere((d) => d.id == id);

	static int _comparator(BookingAllocationView one, BookingAllocationView two) {
		if(one.no != two.no) {
			return one.no - two.no;
		} else {
			return one.note.compareTo(two.note);
		}
	}
}
