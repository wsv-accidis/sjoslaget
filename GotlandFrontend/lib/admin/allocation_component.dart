import 'dart:async';

import 'package:angular/angular.dart';
import 'package:angular_components/angular_components.dart';
import 'package:angular_forms/angular_forms.dart';
import 'package:frontend_shared/util.dart';
import 'package:quiver/strings.dart' as str show isEmpty, isNotEmpty;

import '../client/allocation_repository.dart';
import '../client/client_factory.dart';
import '../client/event_repository.dart';
import '../model/booking_allocation_view.dart';
import '../model/cabin_class.dart';
import '../model/cabin_class_detail.dart';
import '../widgets/components.dart';

@Component(
	selector: 'allocation-component',
	templateUrl: 'allocation_component.html',
	styleUrls: ['../content/content_styles.css', 'admin_styles.css', 'allocation_component.css'],
	directives: <dynamic>[coreDirectives, formDirectives, gotlandMaterialDirectives, materialNumberInputDirectives]
)
class AllocationComponent {
	final AllocationRepository _allocationRepository;
	final ClientFactory _clientFactory;
	final EventRepository _eventRepository;
	final _onAllocationChange = StreamController<void>.broadcast();

	@Input()
	String bookingRef;

	@Input()
	set count(int value) {
		_noOfPaxInBooking = value;
		validate();
	}

	@Output()
	Stream get onAllocationChange => _onAllocationChange.stream;

	List<CabinClass> _cabinClasses;
	int _noOfPaxInBooking;

	AllocationComponent(this._allocationRepository, this._clientFactory, this._eventRepository);

	List<BookingAllocationView> allocations = <BookingAllocationView>[];
	SingleSelectionModel<CabinClassDetail> cabinClassDetails = SelectionModel<CabinClassDetail>.single();
	SelectionOptions<CabinClassDetail> cabinClassDetailsOptions;
	bool isSaving = false;
	String noOfPax;
	String note;
	String warningMessage;

	String get cabinClassDetailLabel =>
		null == cabinClassDetails.selectedValue ? 'Välj boende'
			: cabinClassDetailToString(cabinClassDetails.selectedValue);

	bool get hasAllocations => allocations.isNotEmpty;

	bool get hasSelectedDetail => null != cabinClassDetails.selectedValue;

	bool get hasPrice => price > 0;

	bool get hasWarningMessage => str.isNotEmpty(warningMessage);

	set noOfPaxInBooking(int value) {
		_noOfPaxInBooking = value;
		validate();
	}

	int get price => allocations.fold(0, (sum, a) => sum + a.price);

	String get priceFormatted => CurrencyFormatter.formatIntAsSEK(price);

	String cabinClassDetailToString(CabinClassDetail detail) => '${detail.no}. ${detail.title}, ${detail.capacity} bäddar';

	void allocate() {
		if (!hasSelectedDetail) {
			return;
		}

		final details = cabinClassDetails.selectedValue;
		final cabinClass = _cabinClasses.firstWhere((c) => c.no == details.no);
		final allocation = BookingAllocationView(cabinClass, details, int.parse(noOfPax), note);
		allocations.add(allocation);
		_clear();
		validate();
		_notifyChanged();
	}

	void delete(int idx) {
		allocations.removeAt(idx);
		validate();
		_notifyChanged();
	}

	Future<void> load() async {
		if (str.isEmpty(bookingRef)) {
			return;
		}

		try {
			final client = _clientFactory.getClient();
			_cabinClasses = await _eventRepository.getActiveCabinClasses(client);
			final cabinClassDetails = await _eventRepository.getCabinClassDetails(client);
			cabinClassDetailsOptions = SelectionOptions<CabinClassDetail>.fromList(cabinClassDetails);

			final allocation = await _allocationRepository.getAllocation(client, bookingRef);
			allocations = allocation.map((a) => BookingAllocationView.fromBookingAllocation(a, _cabinClasses, cabinClassDetails)).toList();
		} catch (e) {
			print('Failed to load allocation: ${e.toString()}');
			return;
		}

		cabinClassDetails.selectionChanges.listen(_onSelectionChanged);
		validate();
		_notifyChanged();
	}

	Future<void> save() async {
		if (str.isEmpty(bookingRef)) {
			return;
		}

		isSaving = true;
		try {
			final client = _clientFactory.getClient();
			final allocation = allocations.map((a) => a.toBookingAllocation()).toList(growable: false);
			await _allocationRepository.saveAllocation(client, bookingRef, allocation);
		} catch (e) {
			print('Failed to save allocation: ${e.toString()}');
			return;
		} finally {
			isSaving = false;
		}
	}

	void validate() {
		warningMessage = '';

		final allocatedCount = allocations.fold<int>(0, (sum, a) => sum + a.noOfPax);
		if (allocatedCount > _noOfPaxInBooking) {
			warningMessage = 'Fler bäddar är tilldelade än vad det finns deltagare i bokningen (behöver $_noOfPaxInBooking, tilldelat $allocatedCount).';
		} else if (allocatedCount < _noOfPaxInBooking) {
			warningMessage = 'Alla deltagare i bokningen har inte tilldelat boende (behöver $_noOfPaxInBooking, tilldelat $allocatedCount).';
		}
	}

	void _clear() {
		cabinClassDetails.clear();
		noOfPax = '';
		note = '';
	}

	void _notifyChanged() {
		_onAllocationChange.add(null);
	}

	void _onSelectionChanged(dynamic ignored) {
		if (null == cabinClassDetails.selectedValue || cabinClassDetails.selectedValue.no == 0) {
			noOfPax = '';
		} else {
			noOfPax = cabinClassDetails.selectedValue.capacity.toString();
		}
	}
}
