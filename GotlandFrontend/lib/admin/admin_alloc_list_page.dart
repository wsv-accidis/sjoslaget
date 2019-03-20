import 'dart:math';

import 'package:angular/angular.dart';
import 'package:angular_components/angular_components.dart';
import 'package:angular_forms/angular_forms.dart';
import 'package:angular_router/angular_router.dart';
import 'package:collection/collection.dart';

import '../client/allocation_repository.dart';
import '../client/client_factory.dart';
import '../client/event_repository.dart';
import '../model/allocation_list_item.dart';
import '../model/cabin_class_detail.dart';
import '../widgets/components.dart';
import '../widgets/spinner_widget.dart';
import 'admin_routes.dart';

@Component(
	selector: 'admin-alloc-list-page',
	templateUrl: 'admin_alloc_list_page.html',
	styleUrls: ['../content/content_styles.css', 'admin_styles.css', 'admin_alloc_list_page.css'],
	directives: <dynamic>[coreDirectives, formDirectives, routerDirectives, gotlandMaterialDirectives, SpinnerWidget],
	providers: <dynamic>[materialProviders],
	exports: <dynamic>[AdminRoutes]
)
class AdminAllocListPage implements OnInit {
	final AllocationRepository _allocationRepository;
	final ClientFactory _clientFactory;
	final EventRepository _eventRepository;

	Map<String, List<AllocationListItem>> allocations;
	List<CabinClassDetail> cabinClasses;

	bool get isLoading => null == allocations;

	AdminAllocListPage(this._allocationRepository, this._clientFactory, this._eventRepository);

	@override
	Future<void> ngOnInit() async {
		await refresh();
	}

	int count(CabinClassDetail cabin) => cabin.no == 0 ? numberOfPax(cabin) : allocations.containsKey(cabin.id) ? min(cabin.count, allocations[cabin.id].length) : 0;

	bool exists(CabinClassDetail cabin) => allocations.containsKey(cabin.id);

	List<AllocationListItem> findAllocations(CabinClassDetail cabin) =>
		allocations.containsKey(cabin.id) ? allocations[cabin.id] : <AllocationListItem>[];

	bool isOvercapacity(CabinClassDetail cabin) => numberOfPax(cabin) > totalPax(cabin);

	int numberOfPax(CabinClassDetail cabin) => findAllocations(cabin).fold(0, (sum, alloc) => sum + alloc.numberOfPax);

	int total(CabinClassDetail cabin) => cabin.no == 0 ? cabin.capacity : cabin.count;

	int totalPax(CabinClassDetail cabin) => cabin.capacity * cabin.count;

	Future<void> refresh() async {
		try {
			final client = _clientFactory.getClient();
			cabinClasses = await _eventRepository.getCabinClassDetails(client);
			cabinClasses.sort(_classesComparator);

			final allocationList = await _allocationRepository.getList(client);
			allocationList.sort(_allocationComparator);
			allocations = _groupAllocations(allocationList);
		} catch (e) {
			print('Failed to load list of allocations: ${e.toString()}');
			// Just ignore this here, we will be stuck in the loading state until the user refreshes
		}
	}

	int _allocationComparator(AllocationListItem one, AllocationListItem two) {
		if(one.note != two.note) {
			return _normalizeNumbers(one.note).compareTo(_normalizeNumbers(two.note));
		} else {
			return one.teamName.compareTo(two.teamName);
		}
	}

	int _classesComparator(CabinClassDetail one, CabinClassDetail two) {
		if(one.no != two.no) {
			return one.no - two.no;
		} else {
			if(one.title != two.title) {
				return one.title.compareTo(two.title);
			} else {
				return one.count - two.count;
			}
		}
	}

	// Poor man's natural number sort - prefix single digits by 0
	String _normalizeNumbers(String str) =>
		str.replaceAllMapped(RegExp(r'(\s|^)([0-9])(\s|$)'), (m) => '${m[1]}0${m[2]}${m[3]}');

	Map<String, List<AllocationListItem>> _groupAllocations(List<AllocationListItem> items) =>
		groupBy(items, (i) => i.cabinId);
}
