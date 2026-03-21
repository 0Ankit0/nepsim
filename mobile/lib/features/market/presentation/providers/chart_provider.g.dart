// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'chart_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(ChartDrawings)
final chartDrawingsProvider = ChartDrawingsFamily._();

final class ChartDrawingsProvider
    extends $AsyncNotifierProvider<ChartDrawings, List<dynamic>> {
  ChartDrawingsProvider._({
    required ChartDrawingsFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'chartDrawingsProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$chartDrawingsHash();

  @override
  String toString() {
    return r'chartDrawingsProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  ChartDrawings create() => ChartDrawings();

  @override
  bool operator ==(Object other) {
    return other is ChartDrawingsProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$chartDrawingsHash() => r'af94eed3d9ca8287088c108c18785ce12643e269';

final class ChartDrawingsFamily extends $Family
    with
        $ClassFamilyOverride<
          ChartDrawings,
          AsyncValue<List<dynamic>>,
          List<dynamic>,
          FutureOr<List<dynamic>>,
          String
        > {
  ChartDrawingsFamily._()
    : super(
        retry: null,
        name: r'chartDrawingsProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  ChartDrawingsProvider call(String symbol) =>
      ChartDrawingsProvider._(argument: symbol, from: this);

  @override
  String toString() => r'chartDrawingsProvider';
}

abstract class _$ChartDrawings extends $AsyncNotifier<List<dynamic>> {
  late final _$args = ref.$arg as String;
  String get symbol => _$args;

  FutureOr<List<dynamic>> build(String symbol);
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<AsyncValue<List<dynamic>>, List<dynamic>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<List<dynamic>>, List<dynamic>>,
              AsyncValue<List<dynamic>>,
              Object?,
              Object?
            >;
    element.handleCreate(ref, () => build(_$args));
  }
}
