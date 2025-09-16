import '../models/salon_profile.dart';
import '../models/content_block.dart';

class SalonState {
  final bool loading;
  final SalonProfile? profile;
  final List<ContentBlock> blocks;

  const SalonState({this.loading=false, this.profile, this.blocks=const []});

  SalonState copyWith({bool? loading, SalonProfile? profile, List<ContentBlock>? blocks}) =>
    SalonState(loading: loading ?? this.loading, profile: profile ?? this.profile, blocks: blocks ?? this.blocks);
}