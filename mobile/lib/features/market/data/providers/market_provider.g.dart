// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'market_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(marketRepository)
final marketRepositoryProvider = MarketRepositoryProvider._();

final class MarketRepositoryProvider
    extends
        $FunctionalProvider<
          MarketRepository,
          MarketRepository,
          MarketRepository
        >
    with $Provider<MarketRepository> {
  MarketRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'marketRepositoryProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$marketRepositoryHash();

  @$internal
  @override
  $ProviderElement<MarketRepository> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  MarketRepository create(Ref ref) {
    return marketRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(MarketRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<MarketRepository>(value),
    );
  }
}

String _$marketRepositoryHash() => r'45e605a62946657e427be4d2e88a383e3906bc20';

@ProviderFor(symbols)
final symbolsProvider = SymbolsProvider._();

final class SymbolsProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<String>>,
          List<String>,
          FutureOr<List<String>>
        >
    with $FutureModifier<List<String>>, $FutureProvider<List<String>> {
  SymbolsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'symbolsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$symbolsHash();

  @$internal
  @override
  $FutureProviderElement<List<String>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<String>> create(Ref ref) {
    return symbols(ref);
  }
}

String _$symbolsHash() => r'3f4e14047e0cca256be65798e8d5a1c77774c717';

@ProviderFor(quote)
final quoteProvider = QuoteFamily._();

final class QuoteProvider
    extends
        $FunctionalProvider<
          AsyncValue<LatestQuoteResponse>,
          LatestQuoteResponse,
          FutureOr<LatestQuoteResponse>
        >
    with
        $FutureModifier<LatestQuoteResponse>,
        $FutureProvider<LatestQuoteResponse> {
  QuoteProvider._({
    required QuoteFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'quoteProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$quoteHash();

  @override
  String toString() {
    return r'quoteProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<LatestQuoteResponse> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<LatestQuoteResponse> create(Ref ref) {
    final argument = this.argument as String;
    return quote(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is QuoteProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$quoteHash() => r'da394057a899bd496a61f83ef09dc12a909957ff';

final class QuoteFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<LatestQuoteResponse>, String> {
  QuoteFamily._()
    : super(
        retry: null,
        name: r'quoteProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  QuoteProvider call(String symbol) =>
      QuoteProvider._(argument: symbol, from: this);

  @override
  String toString() => r'quoteProvider';
}

@ProviderFor(history)
final historyProvider = HistoryFamily._();

final class HistoryProvider
    extends
        $FunctionalProvider<
          AsyncValue<HistoricDataResponse>,
          HistoricDataResponse,
          FutureOr<HistoricDataResponse>
        >
    with
        $FutureModifier<HistoricDataResponse>,
        $FutureProvider<HistoricDataResponse> {
  HistoryProvider._({
    required HistoryFamily super.from,
    required (String, {String? startDate, String? endDate, int limit})
    super.argument,
  }) : super(
         retry: null,
         name: r'historyProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$historyHash();

  @override
  String toString() {
    return r'historyProvider'
        ''
        '$argument';
  }

  @$internal
  @override
  $FutureProviderElement<HistoricDataResponse> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<HistoricDataResponse> create(Ref ref) {
    final argument =
        this.argument
            as (String, {String? startDate, String? endDate, int limit});
    return history(
      ref,
      argument.$1,
      startDate: argument.startDate,
      endDate: argument.endDate,
      limit: argument.limit,
    );
  }

  @override
  bool operator ==(Object other) {
    return other is HistoryProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$historyHash() => r'e2cbcba03ce93cace682bf1b44753a16f61fc526';

final class HistoryFamily extends $Family
    with
        $FunctionalFamilyOverride<
          FutureOr<HistoricDataResponse>,
          (String, {String? startDate, String? endDate, int limit})
        > {
  HistoryFamily._()
    : super(
        retry: null,
        name: r'historyProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  HistoryProvider call(
    String symbol, {
    String? startDate,
    String? endDate,
    int limit = 365,
  }) => HistoryProvider._(
    argument: (symbol, startDate: startDate, endDate: endDate, limit: limit),
    from: this,
  );

  @override
  String toString() => r'historyProvider';
}

@ProviderFor(indicators)
final indicatorsProvider = IndicatorsFamily._();

final class IndicatorsProvider
    extends
        $FunctionalProvider<
          AsyncValue<IndicatorsResponse>,
          IndicatorsResponse,
          FutureOr<IndicatorsResponse>
        >
    with
        $FutureModifier<IndicatorsResponse>,
        $FutureProvider<IndicatorsResponse> {
  IndicatorsProvider._({
    required IndicatorsFamily super.from,
    required (String, {String? startDate, String? endDate, int limit})
    super.argument,
  }) : super(
         retry: null,
         name: r'indicatorsProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$indicatorsHash();

  @override
  String toString() {
    return r'indicatorsProvider'
        ''
        '$argument';
  }

  @$internal
  @override
  $FutureProviderElement<IndicatorsResponse> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<IndicatorsResponse> create(Ref ref) {
    final argument =
        this.argument
            as (String, {String? startDate, String? endDate, int limit});
    return indicators(
      ref,
      argument.$1,
      startDate: argument.startDate,
      endDate: argument.endDate,
      limit: argument.limit,
    );
  }

  @override
  bool operator ==(Object other) {
    return other is IndicatorsProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$indicatorsHash() => r'f892a33ede01695ade28bac4b9829e498a85f639';

final class IndicatorsFamily extends $Family
    with
        $FunctionalFamilyOverride<
          FutureOr<IndicatorsResponse>,
          (String, {String? startDate, String? endDate, int limit})
        > {
  IndicatorsFamily._()
    : super(
        retry: null,
        name: r'indicatorsProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  IndicatorsProvider call(
    String symbol, {
    String? startDate,
    String? endDate,
    int limit = 365,
  }) => IndicatorsProvider._(
    argument: (symbol, startDate: startDate, endDate: endDate, limit: limit),
    from: this,
  );

  @override
  String toString() => r'indicatorsProvider';
}

@ProviderFor(latestIndicators)
final latestIndicatorsProvider = LatestIndicatorsFamily._();

final class LatestIndicatorsProvider
    extends
        $FunctionalProvider<
          AsyncValue<IndicatorRow>,
          IndicatorRow,
          FutureOr<IndicatorRow>
        >
    with $FutureModifier<IndicatorRow>, $FutureProvider<IndicatorRow> {
  LatestIndicatorsProvider._({
    required LatestIndicatorsFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'latestIndicatorsProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$latestIndicatorsHash();

  @override
  String toString() {
    return r'latestIndicatorsProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<IndicatorRow> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<IndicatorRow> create(Ref ref) {
    final argument = this.argument as String;
    return latestIndicators(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is LatestIndicatorsProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$latestIndicatorsHash() => r'a628b97f4c145d975905b6861322755f8e54db8a';

final class LatestIndicatorsFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<IndicatorRow>, String> {
  LatestIndicatorsFamily._()
    : super(
        retry: null,
        name: r'latestIndicatorsProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  LatestIndicatorsProvider call(String symbol) =>
      LatestIndicatorsProvider._(argument: symbol, from: this);

  @override
  String toString() => r'latestIndicatorsProvider';
}

@ProviderFor(indices)
final indicesProvider = IndicesFamily._();

final class IndicesProvider
    extends
        $FunctionalProvider<
          AsyncValue<IndicesResponse>,
          IndicesResponse,
          FutureOr<IndicesResponse>
        >
    with $FutureModifier<IndicesResponse>, $FutureProvider<IndicesResponse> {
  IndicesProvider._({
    required IndicesFamily super.from,
    required ({
      String? indexName,
      String? startDate,
      String? endDate,
      int limit,
    })
    super.argument,
  }) : super(
         retry: null,
         name: r'indicesProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$indicesHash();

  @override
  String toString() {
    return r'indicesProvider'
        ''
        '$argument';
  }

  @$internal
  @override
  $FutureProviderElement<IndicesResponse> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<IndicesResponse> create(Ref ref) {
    final argument =
        this.argument
            as ({
              String? indexName,
              String? startDate,
              String? endDate,
              int limit,
            });
    return indices(
      ref,
      indexName: argument.indexName,
      startDate: argument.startDate,
      endDate: argument.endDate,
      limit: argument.limit,
    );
  }

  @override
  bool operator ==(Object other) {
    return other is IndicesProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$indicesHash() => r'94119042d4314523cb8a18105a1693d652f30bf9';

final class IndicesFamily extends $Family
    with
        $FunctionalFamilyOverride<
          FutureOr<IndicesResponse>,
          ({String? indexName, String? startDate, String? endDate, int limit})
        > {
  IndicesFamily._()
    : super(
        retry: null,
        name: r'indicesProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  IndicesProvider call({
    String? indexName,
    String? startDate,
    String? endDate,
    int limit = 365,
  }) => IndicesProvider._(
    argument: (
      indexName: indexName,
      startDate: startDate,
      endDate: endDate,
      limit: limit,
    ),
    from: this,
  );

  @override
  String toString() => r'indicesProvider';
}

@ProviderFor(latestIndices)
final latestIndicesProvider = LatestIndicesFamily._();

final class LatestIndicesProvider
    extends
        $FunctionalProvider<
          AsyncValue<LatestIndicesResponse>,
          LatestIndicesResponse,
          FutureOr<LatestIndicesResponse>
        >
    with
        $FutureModifier<LatestIndicesResponse>,
        $FutureProvider<LatestIndicesResponse> {
  LatestIndicesProvider._({
    required LatestIndicesFamily super.from,
    required String? super.argument,
  }) : super(
         retry: null,
         name: r'latestIndicesProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$latestIndicesHash();

  @override
  String toString() {
    return r'latestIndicesProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<LatestIndicesResponse> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<LatestIndicesResponse> create(Ref ref) {
    final argument = this.argument as String?;
    return latestIndices(ref, indexName: argument);
  }

  @override
  bool operator ==(Object other) {
    return other is LatestIndicesProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$latestIndicesHash() => r'acf16dda4e58681fcb4f635cb4a0b2ca7cb25e08';

final class LatestIndicesFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<LatestIndicesResponse>, String?> {
  LatestIndicesFamily._()
    : super(
        retry: null,
        name: r'latestIndicesProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  LatestIndicesProvider call({String? indexName}) =>
      LatestIndicesProvider._(argument: indexName, from: this);

  @override
  String toString() => r'latestIndicesProvider';
}

@ProviderFor(StockSearchQuery)
final stockSearchQueryProvider = StockSearchQueryProvider._();

final class StockSearchQueryProvider
    extends $NotifierProvider<StockSearchQuery, String> {
  StockSearchQueryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'stockSearchQueryProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$stockSearchQueryHash();

  @$internal
  @override
  StockSearchQuery create() => StockSearchQuery();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(String value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<String>(value),
    );
  }
}

String _$stockSearchQueryHash() => r'6e9e90df292c8693d18ebf8e6cf8126d2638322a';

abstract class _$StockSearchQuery extends $Notifier<String> {
  String build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<String, String>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<String, String>,
              String,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}

@ProviderFor(filteredStockList)
final filteredStockListProvider = FilteredStockListProvider._();

final class FilteredStockListProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<String>>,
          List<String>,
          FutureOr<List<String>>
        >
    with $FutureModifier<List<String>>, $FutureProvider<List<String>> {
  FilteredStockListProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'filteredStockListProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$filteredStockListHash();

  @$internal
  @override
  $FutureProviderElement<List<String>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<String>> create(Ref ref) {
    return filteredStockList(ref);
  }
}

String _$filteredStockListHash() => r'9f21a9181d928e4b09baa20cdf2a2e09df803b02';
