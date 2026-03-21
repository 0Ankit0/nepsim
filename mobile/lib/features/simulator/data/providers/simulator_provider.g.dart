// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'simulator_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(simulatorRepository)
final simulatorRepositoryProvider = SimulatorRepositoryProvider._();

final class SimulatorRepositoryProvider
    extends
        $FunctionalProvider<
          SimulatorRepository,
          SimulatorRepository,
          SimulatorRepository
        >
    with $Provider<SimulatorRepository> {
  SimulatorRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'simulatorRepositoryProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$simulatorRepositoryHash();

  @$internal
  @override
  $ProviderElement<SimulatorRepository> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  SimulatorRepository create(Ref ref) {
    return simulatorRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(SimulatorRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<SimulatorRepository>(value),
    );
  }
}

String _$simulatorRepositoryHash() =>
    r'863914acfa4dcfcbfe4ef59abee4e612f03fe1bc';

@ProviderFor(simulations)
final simulationsProvider = SimulationsProvider._();

final class SimulationsProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<SimulationSummary>>,
          List<SimulationSummary>,
          FutureOr<List<SimulationSummary>>
        >
    with
        $FutureModifier<List<SimulationSummary>>,
        $FutureProvider<List<SimulationSummary>> {
  SimulationsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'simulationsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$simulationsHash();

  @$internal
  @override
  $FutureProviderElement<List<SimulationSummary>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<SimulationSummary>> create(Ref ref) {
    return simulations(ref);
  }
}

String _$simulationsHash() => r'08a3c55e7248f07ab9eb1e6a3efa34cc595fcd23';

@ProviderFor(simulation)
final simulationProvider = SimulationFamily._();

final class SimulationProvider
    extends
        $FunctionalProvider<
          AsyncValue<SimulationResponse>,
          SimulationResponse,
          FutureOr<SimulationResponse>
        >
    with
        $FutureModifier<SimulationResponse>,
        $FutureProvider<SimulationResponse> {
  SimulationProvider._({
    required SimulationFamily super.from,
    required int super.argument,
  }) : super(
         retry: null,
         name: r'simulationProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$simulationHash();

  @override
  String toString() {
    return r'simulationProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<SimulationResponse> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<SimulationResponse> create(Ref ref) {
    final argument = this.argument as int;
    return simulation(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is SimulationProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$simulationHash() => r'fd7b65f236b9f9303a024f642f212ed52c1d65ed';

final class SimulationFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<SimulationResponse>, int> {
  SimulationFamily._()
    : super(
        retry: null,
        name: r'simulationProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  SimulationProvider call(int id) =>
      SimulationProvider._(argument: id, from: this);

  @override
  String toString() => r'simulationProvider';
}

@ProviderFor(analysis)
final analysisProvider = AnalysisFamily._();

final class AnalysisProvider
    extends
        $FunctionalProvider<
          AsyncValue<AIAnalysisResponse>,
          AIAnalysisResponse,
          FutureOr<AIAnalysisResponse>
        >
    with
        $FutureModifier<AIAnalysisResponse>,
        $FutureProvider<AIAnalysisResponse> {
  AnalysisProvider._({
    required AnalysisFamily super.from,
    required int super.argument,
  }) : super(
         retry: null,
         name: r'analysisProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$analysisHash();

  @override
  String toString() {
    return r'analysisProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<AIAnalysisResponse> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<AIAnalysisResponse> create(Ref ref) {
    final argument = this.argument as int;
    return analysis(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is AnalysisProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$analysisHash() => r'cda496cdc542a81ad940694fe4c350beefa088c8';

final class AnalysisFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<AIAnalysisResponse>, int> {
  AnalysisFamily._()
    : super(
        retry: null,
        name: r'analysisProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  AnalysisProvider call(int id) => AnalysisProvider._(argument: id, from: this);

  @override
  String toString() => r'analysisProvider';
}
