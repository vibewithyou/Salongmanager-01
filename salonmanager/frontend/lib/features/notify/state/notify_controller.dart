import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/notify_repository.dart';
import 'notify_state.dart';

final notifyRepositoryProvider = Provider((_)=>NotifyRepository());
final notifyControllerProvider = StateNotifierProvider<NotifyController, NotifyState>(
  (ref)=>NotifyController(ref.read(notifyRepositoryProvider))
);

class NotifyController extends StateNotifier<NotifyState> {
  final NotifyRepository _repo;
  NotifyController(this._repo): super(const NotifyState()){
    load();
  }

  Future<void> load() async {
    state = state.copyWith(loading:true);
    final p = await _repo.prefs();
    state = state.copyWith(loading:false, prefs: p);
  }

  void toggle(String event, String channel, bool enabled) {
    final next = [...state.prefs];
    final i = next.indexWhere((e)=>e['event']==event && e['channel']==channel);
    if (i>=0) next[i] = {'event':event,'channel':channel,'enabled':enabled};
    else next.add({'event':event,'channel':channel,'enabled':enabled});
    state = state.copyWith(prefs: next);
  }

  Future<void> save() async => _repo.updatePrefs(state.prefs);
}