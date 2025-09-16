import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/salon_repository.dart';
import 'salon_state.dart';

final salonRepositoryProvider = Provider<SalonRepository>((ref) => SalonRepository());

final salonControllerProvider = StateNotifierProvider<SalonController, SalonState>((ref) {
  final repo = ref.watch(salonRepositoryProvider);
  return SalonController(repo);
});

class SalonController extends StateNotifier<SalonState> {
  final SalonRepository _repo;
  SalonController(this._repo): super(const SalonState()){
    refresh();
  }

  Future<void> refresh() async {
    state = state.copyWith(loading: true);
    try {
      final profile = await _repo.fetchProfile();
      final blocks  = await _repo.fetchBlocks();
      state = state.copyWith(profile: profile, blocks: blocks);
    } finally {
      state = state.copyWith(loading: false);
    }
  }
}