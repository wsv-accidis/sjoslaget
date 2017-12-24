import 'dart:math' as Math show min;

class PagingSupport {
	static final PAGE_LIMIT = 20;

	int _numberOfResults = 0;
	int _pageNo = 0;
	Function _refreshView;

	bool get hasMultiplePages => numberOfResults > PAGE_LIMIT;

	bool get hasResults => numberOfResults > 0;

	int get numberOfPages => hasMultiplePages ? (numberOfResults / PAGE_LIMIT).ceil() : 1;

	int get numberOfResults => _numberOfResults;

	int get pageNo => 1 + _pageNo;

	int get pageOffsetStart => 1 + (PAGE_LIMIT * _pageNo);

	int get pageOffsetEnd => Math.min(pageOffsetStart + PAGE_LIMIT - 1, numberOfResults);

	set pageNo(int value) {
		if(value < 0)
			_pageNo = 0;
		else if(value > numberOfPages)
			_pageNo = numberOfPages - 1;
		else
			_pageNo = value - 1;

		if(null != _refreshView)
			_refreshView();
	}

	List<int> get pages => new List.generate(numberOfPages, (int i) => 1 + i);

	set refreshCallback(Function fun) => _refreshView = fun;

	List<E> apply<E>(Iterable<E> list) {
		_numberOfResults = list.length;

		// If the list changed so the current page no longer exists, go back to 0
		if(numberOfResults <= _pageNo * PAGE_LIMIT)
			_pageNo = 0;

		return list
			.skip(PAGE_LIMIT * _pageNo)
			.take(PAGE_LIMIT)
			.toList(growable: false);
	}
}
