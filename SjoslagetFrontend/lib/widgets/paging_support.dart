import 'dart:math' as math show min;

class PagingSupport {
	int _numberOfResults = 0;
	int _pageNo = 0;
	final int _pageLimit;
	Function _refreshView;

	PagingSupport(this._pageLimit);

	bool get hasMultiplePages => numberOfResults > _pageLimit;

	bool get hasResults => numberOfResults > 0;

	int get numberOfPages => hasMultiplePages ? (numberOfResults / _pageLimit).ceil() : 1;

	int get numberOfResults => _numberOfResults;

	int get pageNo => 1 + _pageNo;

	int get pageOffsetStart => 1 + (_pageLimit * _pageNo);

	int get pageOffsetEnd => math.min(pageOffsetStart + _pageLimit - 1, numberOfResults);

	set pageNo(int value) {
		if (value < 0)
			_pageNo = 0;
		else if (value > numberOfPages)
			_pageNo = numberOfPages - 1;
		else
			_pageNo = value - 1;

		if (null != _refreshView)
			_refreshView();
	}

	List<int> get pages => List.generate(numberOfPages, (int i) => 1 + i);

	set refreshCallback(Function fun) => _refreshView = fun;

	List<E> apply<E>(Iterable<E> list) {
		_numberOfResults = list.length;

		// If the list changed so the current page no longer exists, go back to 0
		if (numberOfResults <= _pageNo * _pageLimit)
			_pageNo = 0;

		return list
			.skip(_pageLimit * _pageNo)
			.take(_pageLimit)
			.toList(growable: false);
	}
}
