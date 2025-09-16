import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/search_repository.dart';
import 'search_state.dart';

final searchRepositoryProvider = Provider<SearchRepository>((_) => SearchRepository());
final searchControllerProvider = StateNotifierProvider<SearchController, SearchState>((ref) => SearchController(ref.read(searchRepositoryProvider)));

class SearchController extends StateNotifier<SearchState> {
  final SearchRepository _repo;
  SearchController(this._repo): super(const SearchState());

  Future<void> refresh() async {
    state = state.copyWith(loading: true, hits: [], nextPage: 1);
    await loadMore();
  }

  Future<void> loadMore() async {
    if (state.nextPage == null) return;
    final res = await _repo.searchSalons(
      q: state.query,
      lat: state.lat, 
      lng: state.lng, 
      radiusKm: state.radiusKm,
      serviceId: state.serviceId, 
      openNow: state.openNow,
      page: state.nextPage!, 
      perPage: 20, 
      sort: (state.lat != null && state.lng != null) ? 'distance' : 'name'
    );
    state = state.copyWith(
      loading: false,
      hits: [...state.hits, ...res.hits],
      nextPage: res.nextPage,
    );
  }

  void setQuery(String q) { 
    state = state.copyWith(query: q); 
  }
  
  void setLocation(double lat, double lng) { 
    state = state.copyWith(lat: lat, lng: lng); 
  }
  
  void setRadius(double km) { 
    state = state.copyWith(radiusKm: km); 
  }
  
  void setOpenNow(bool v) { 
    state = state.copyWith(openNow: v); 
  }
  
  void setService(int? id) { 
    state = state.copyWith(serviceId: id); 
  }
}