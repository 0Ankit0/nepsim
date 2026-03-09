// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'simulator_repository.dart';

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
    r'211d4fe6eace36061b34b20abe9b49b3cbad6915';
