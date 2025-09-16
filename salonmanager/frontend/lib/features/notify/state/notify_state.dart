class NotifyState {
  final bool loading;
  final List<Map<String,dynamic>> prefs; // {event,channel,enabled}
  const NotifyState({this.loading=false, this.prefs=const []});
  NotifyState copyWith({bool? loading, List<Map<String,dynamic>>? prefs})
    => NotifyState(loading: loading??this.loading, prefs: prefs??this.prefs);
}