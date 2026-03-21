// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'simulator_models.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$PortfolioHolding {

 String get symbol; int get quantity; double get average_buy_price; double? get current_price; double? get current_value; double? get unrealised_pnl; double? get unrealised_pnl_pct;
/// Create a copy of PortfolioHolding
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PortfolioHoldingCopyWith<PortfolioHolding> get copyWith => _$PortfolioHoldingCopyWithImpl<PortfolioHolding>(this as PortfolioHolding, _$identity);

  /// Serializes this PortfolioHolding to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PortfolioHolding&&(identical(other.symbol, symbol) || other.symbol == symbol)&&(identical(other.quantity, quantity) || other.quantity == quantity)&&(identical(other.average_buy_price, average_buy_price) || other.average_buy_price == average_buy_price)&&(identical(other.current_price, current_price) || other.current_price == current_price)&&(identical(other.current_value, current_value) || other.current_value == current_value)&&(identical(other.unrealised_pnl, unrealised_pnl) || other.unrealised_pnl == unrealised_pnl)&&(identical(other.unrealised_pnl_pct, unrealised_pnl_pct) || other.unrealised_pnl_pct == unrealised_pnl_pct));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,symbol,quantity,average_buy_price,current_price,current_value,unrealised_pnl,unrealised_pnl_pct);

@override
String toString() {
  return 'PortfolioHolding(symbol: $symbol, quantity: $quantity, average_buy_price: $average_buy_price, current_price: $current_price, current_value: $current_value, unrealised_pnl: $unrealised_pnl, unrealised_pnl_pct: $unrealised_pnl_pct)';
}


}

/// @nodoc
abstract mixin class $PortfolioHoldingCopyWith<$Res>  {
  factory $PortfolioHoldingCopyWith(PortfolioHolding value, $Res Function(PortfolioHolding) _then) = _$PortfolioHoldingCopyWithImpl;
@useResult
$Res call({
 String symbol, int quantity, double average_buy_price, double? current_price, double? current_value, double? unrealised_pnl, double? unrealised_pnl_pct
});




}
/// @nodoc
class _$PortfolioHoldingCopyWithImpl<$Res>
    implements $PortfolioHoldingCopyWith<$Res> {
  _$PortfolioHoldingCopyWithImpl(this._self, this._then);

  final PortfolioHolding _self;
  final $Res Function(PortfolioHolding) _then;

/// Create a copy of PortfolioHolding
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? symbol = null,Object? quantity = null,Object? average_buy_price = null,Object? current_price = freezed,Object? current_value = freezed,Object? unrealised_pnl = freezed,Object? unrealised_pnl_pct = freezed,}) {
  return _then(_self.copyWith(
symbol: null == symbol ? _self.symbol : symbol // ignore: cast_nullable_to_non_nullable
as String,quantity: null == quantity ? _self.quantity : quantity // ignore: cast_nullable_to_non_nullable
as int,average_buy_price: null == average_buy_price ? _self.average_buy_price : average_buy_price // ignore: cast_nullable_to_non_nullable
as double,current_price: freezed == current_price ? _self.current_price : current_price // ignore: cast_nullable_to_non_nullable
as double?,current_value: freezed == current_value ? _self.current_value : current_value // ignore: cast_nullable_to_non_nullable
as double?,unrealised_pnl: freezed == unrealised_pnl ? _self.unrealised_pnl : unrealised_pnl // ignore: cast_nullable_to_non_nullable
as double?,unrealised_pnl_pct: freezed == unrealised_pnl_pct ? _self.unrealised_pnl_pct : unrealised_pnl_pct // ignore: cast_nullable_to_non_nullable
as double?,
  ));
}

}


/// Adds pattern-matching-related methods to [PortfolioHolding].
extension PortfolioHoldingPatterns on PortfolioHolding {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _PortfolioHolding value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _PortfolioHolding() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _PortfolioHolding value)  $default,){
final _that = this;
switch (_that) {
case _PortfolioHolding():
return $default(_that);}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _PortfolioHolding value)?  $default,){
final _that = this;
switch (_that) {
case _PortfolioHolding() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String symbol,  int quantity,  double average_buy_price,  double? current_price,  double? current_value,  double? unrealised_pnl,  double? unrealised_pnl_pct)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _PortfolioHolding() when $default != null:
return $default(_that.symbol,_that.quantity,_that.average_buy_price,_that.current_price,_that.current_value,_that.unrealised_pnl,_that.unrealised_pnl_pct);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String symbol,  int quantity,  double average_buy_price,  double? current_price,  double? current_value,  double? unrealised_pnl,  double? unrealised_pnl_pct)  $default,) {final _that = this;
switch (_that) {
case _PortfolioHolding():
return $default(_that.symbol,_that.quantity,_that.average_buy_price,_that.current_price,_that.current_value,_that.unrealised_pnl,_that.unrealised_pnl_pct);}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String symbol,  int quantity,  double average_buy_price,  double? current_price,  double? current_value,  double? unrealised_pnl,  double? unrealised_pnl_pct)?  $default,) {final _that = this;
switch (_that) {
case _PortfolioHolding() when $default != null:
return $default(_that.symbol,_that.quantity,_that.average_buy_price,_that.current_price,_that.current_value,_that.unrealised_pnl,_that.unrealised_pnl_pct);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _PortfolioHolding implements PortfolioHolding {
  const _PortfolioHolding({required this.symbol, required this.quantity, required this.average_buy_price, this.current_price, this.current_value, this.unrealised_pnl, this.unrealised_pnl_pct});
  factory _PortfolioHolding.fromJson(Map<String, dynamic> json) => _$PortfolioHoldingFromJson(json);

@override final  String symbol;
@override final  int quantity;
@override final  double average_buy_price;
@override final  double? current_price;
@override final  double? current_value;
@override final  double? unrealised_pnl;
@override final  double? unrealised_pnl_pct;

/// Create a copy of PortfolioHolding
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$PortfolioHoldingCopyWith<_PortfolioHolding> get copyWith => __$PortfolioHoldingCopyWithImpl<_PortfolioHolding>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$PortfolioHoldingToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _PortfolioHolding&&(identical(other.symbol, symbol) || other.symbol == symbol)&&(identical(other.quantity, quantity) || other.quantity == quantity)&&(identical(other.average_buy_price, average_buy_price) || other.average_buy_price == average_buy_price)&&(identical(other.current_price, current_price) || other.current_price == current_price)&&(identical(other.current_value, current_value) || other.current_value == current_value)&&(identical(other.unrealised_pnl, unrealised_pnl) || other.unrealised_pnl == unrealised_pnl)&&(identical(other.unrealised_pnl_pct, unrealised_pnl_pct) || other.unrealised_pnl_pct == unrealised_pnl_pct));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,symbol,quantity,average_buy_price,current_price,current_value,unrealised_pnl,unrealised_pnl_pct);

@override
String toString() {
  return 'PortfolioHolding(symbol: $symbol, quantity: $quantity, average_buy_price: $average_buy_price, current_price: $current_price, current_value: $current_value, unrealised_pnl: $unrealised_pnl, unrealised_pnl_pct: $unrealised_pnl_pct)';
}


}

/// @nodoc
abstract mixin class _$PortfolioHoldingCopyWith<$Res> implements $PortfolioHoldingCopyWith<$Res> {
  factory _$PortfolioHoldingCopyWith(_PortfolioHolding value, $Res Function(_PortfolioHolding) _then) = __$PortfolioHoldingCopyWithImpl;
@override @useResult
$Res call({
 String symbol, int quantity, double average_buy_price, double? current_price, double? current_value, double? unrealised_pnl, double? unrealised_pnl_pct
});




}
/// @nodoc
class __$PortfolioHoldingCopyWithImpl<$Res>
    implements _$PortfolioHoldingCopyWith<$Res> {
  __$PortfolioHoldingCopyWithImpl(this._self, this._then);

  final _PortfolioHolding _self;
  final $Res Function(_PortfolioHolding) _then;

/// Create a copy of PortfolioHolding
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? symbol = null,Object? quantity = null,Object? average_buy_price = null,Object? current_price = freezed,Object? current_value = freezed,Object? unrealised_pnl = freezed,Object? unrealised_pnl_pct = freezed,}) {
  return _then(_PortfolioHolding(
symbol: null == symbol ? _self.symbol : symbol // ignore: cast_nullable_to_non_nullable
as String,quantity: null == quantity ? _self.quantity : quantity // ignore: cast_nullable_to_non_nullable
as int,average_buy_price: null == average_buy_price ? _self.average_buy_price : average_buy_price // ignore: cast_nullable_to_non_nullable
as double,current_price: freezed == current_price ? _self.current_price : current_price // ignore: cast_nullable_to_non_nullable
as double?,current_value: freezed == current_value ? _self.current_value : current_value // ignore: cast_nullable_to_non_nullable
as double?,unrealised_pnl: freezed == unrealised_pnl ? _self.unrealised_pnl : unrealised_pnl // ignore: cast_nullable_to_non_nullable
as double?,unrealised_pnl_pct: freezed == unrealised_pnl_pct ? _self.unrealised_pnl_pct : unrealised_pnl_pct // ignore: cast_nullable_to_non_nullable
as double?,
  ));
}


}


/// @nodoc
mixin _$SimulationResponse {

 int get id; int get user_id; String? get name; double get initial_capital; double get cash_balance; String get status; String get period_start; String get period_end; String get current_sim_date; String get started_at; String? get ended_at; double? get portfolio_value; double? get total_value; double? get total_pnl; double? get total_pnl_pct; List<PortfolioHolding>? get holdings;
/// Create a copy of SimulationResponse
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SimulationResponseCopyWith<SimulationResponse> get copyWith => _$SimulationResponseCopyWithImpl<SimulationResponse>(this as SimulationResponse, _$identity);

  /// Serializes this SimulationResponse to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SimulationResponse&&(identical(other.id, id) || other.id == id)&&(identical(other.user_id, user_id) || other.user_id == user_id)&&(identical(other.name, name) || other.name == name)&&(identical(other.initial_capital, initial_capital) || other.initial_capital == initial_capital)&&(identical(other.cash_balance, cash_balance) || other.cash_balance == cash_balance)&&(identical(other.status, status) || other.status == status)&&(identical(other.period_start, period_start) || other.period_start == period_start)&&(identical(other.period_end, period_end) || other.period_end == period_end)&&(identical(other.current_sim_date, current_sim_date) || other.current_sim_date == current_sim_date)&&(identical(other.started_at, started_at) || other.started_at == started_at)&&(identical(other.ended_at, ended_at) || other.ended_at == ended_at)&&(identical(other.portfolio_value, portfolio_value) || other.portfolio_value == portfolio_value)&&(identical(other.total_value, total_value) || other.total_value == total_value)&&(identical(other.total_pnl, total_pnl) || other.total_pnl == total_pnl)&&(identical(other.total_pnl_pct, total_pnl_pct) || other.total_pnl_pct == total_pnl_pct)&&const DeepCollectionEquality().equals(other.holdings, holdings));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,user_id,name,initial_capital,cash_balance,status,period_start,period_end,current_sim_date,started_at,ended_at,portfolio_value,total_value,total_pnl,total_pnl_pct,const DeepCollectionEquality().hash(holdings));

@override
String toString() {
  return 'SimulationResponse(id: $id, user_id: $user_id, name: $name, initial_capital: $initial_capital, cash_balance: $cash_balance, status: $status, period_start: $period_start, period_end: $period_end, current_sim_date: $current_sim_date, started_at: $started_at, ended_at: $ended_at, portfolio_value: $portfolio_value, total_value: $total_value, total_pnl: $total_pnl, total_pnl_pct: $total_pnl_pct, holdings: $holdings)';
}


}

/// @nodoc
abstract mixin class $SimulationResponseCopyWith<$Res>  {
  factory $SimulationResponseCopyWith(SimulationResponse value, $Res Function(SimulationResponse) _then) = _$SimulationResponseCopyWithImpl;
@useResult
$Res call({
 int id, int user_id, String? name, double initial_capital, double cash_balance, String status, String period_start, String period_end, String current_sim_date, String started_at, String? ended_at, double? portfolio_value, double? total_value, double? total_pnl, double? total_pnl_pct, List<PortfolioHolding>? holdings
});




}
/// @nodoc
class _$SimulationResponseCopyWithImpl<$Res>
    implements $SimulationResponseCopyWith<$Res> {
  _$SimulationResponseCopyWithImpl(this._self, this._then);

  final SimulationResponse _self;
  final $Res Function(SimulationResponse) _then;

/// Create a copy of SimulationResponse
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? user_id = null,Object? name = freezed,Object? initial_capital = null,Object? cash_balance = null,Object? status = null,Object? period_start = null,Object? period_end = null,Object? current_sim_date = null,Object? started_at = null,Object? ended_at = freezed,Object? portfolio_value = freezed,Object? total_value = freezed,Object? total_pnl = freezed,Object? total_pnl_pct = freezed,Object? holdings = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,user_id: null == user_id ? _self.user_id : user_id // ignore: cast_nullable_to_non_nullable
as int,name: freezed == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String?,initial_capital: null == initial_capital ? _self.initial_capital : initial_capital // ignore: cast_nullable_to_non_nullable
as double,cash_balance: null == cash_balance ? _self.cash_balance : cash_balance // ignore: cast_nullable_to_non_nullable
as double,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String,period_start: null == period_start ? _self.period_start : period_start // ignore: cast_nullable_to_non_nullable
as String,period_end: null == period_end ? _self.period_end : period_end // ignore: cast_nullable_to_non_nullable
as String,current_sim_date: null == current_sim_date ? _self.current_sim_date : current_sim_date // ignore: cast_nullable_to_non_nullable
as String,started_at: null == started_at ? _self.started_at : started_at // ignore: cast_nullable_to_non_nullable
as String,ended_at: freezed == ended_at ? _self.ended_at : ended_at // ignore: cast_nullable_to_non_nullable
as String?,portfolio_value: freezed == portfolio_value ? _self.portfolio_value : portfolio_value // ignore: cast_nullable_to_non_nullable
as double?,total_value: freezed == total_value ? _self.total_value : total_value // ignore: cast_nullable_to_non_nullable
as double?,total_pnl: freezed == total_pnl ? _self.total_pnl : total_pnl // ignore: cast_nullable_to_non_nullable
as double?,total_pnl_pct: freezed == total_pnl_pct ? _self.total_pnl_pct : total_pnl_pct // ignore: cast_nullable_to_non_nullable
as double?,holdings: freezed == holdings ? _self.holdings : holdings // ignore: cast_nullable_to_non_nullable
as List<PortfolioHolding>?,
  ));
}

}


/// Adds pattern-matching-related methods to [SimulationResponse].
extension SimulationResponsePatterns on SimulationResponse {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _SimulationResponse value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _SimulationResponse() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _SimulationResponse value)  $default,){
final _that = this;
switch (_that) {
case _SimulationResponse():
return $default(_that);}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _SimulationResponse value)?  $default,){
final _that = this;
switch (_that) {
case _SimulationResponse() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int id,  int user_id,  String? name,  double initial_capital,  double cash_balance,  String status,  String period_start,  String period_end,  String current_sim_date,  String started_at,  String? ended_at,  double? portfolio_value,  double? total_value,  double? total_pnl,  double? total_pnl_pct,  List<PortfolioHolding>? holdings)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _SimulationResponse() when $default != null:
return $default(_that.id,_that.user_id,_that.name,_that.initial_capital,_that.cash_balance,_that.status,_that.period_start,_that.period_end,_that.current_sim_date,_that.started_at,_that.ended_at,_that.portfolio_value,_that.total_value,_that.total_pnl,_that.total_pnl_pct,_that.holdings);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int id,  int user_id,  String? name,  double initial_capital,  double cash_balance,  String status,  String period_start,  String period_end,  String current_sim_date,  String started_at,  String? ended_at,  double? portfolio_value,  double? total_value,  double? total_pnl,  double? total_pnl_pct,  List<PortfolioHolding>? holdings)  $default,) {final _that = this;
switch (_that) {
case _SimulationResponse():
return $default(_that.id,_that.user_id,_that.name,_that.initial_capital,_that.cash_balance,_that.status,_that.period_start,_that.period_end,_that.current_sim_date,_that.started_at,_that.ended_at,_that.portfolio_value,_that.total_value,_that.total_pnl,_that.total_pnl_pct,_that.holdings);}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int id,  int user_id,  String? name,  double initial_capital,  double cash_balance,  String status,  String period_start,  String period_end,  String current_sim_date,  String started_at,  String? ended_at,  double? portfolio_value,  double? total_value,  double? total_pnl,  double? total_pnl_pct,  List<PortfolioHolding>? holdings)?  $default,) {final _that = this;
switch (_that) {
case _SimulationResponse() when $default != null:
return $default(_that.id,_that.user_id,_that.name,_that.initial_capital,_that.cash_balance,_that.status,_that.period_start,_that.period_end,_that.current_sim_date,_that.started_at,_that.ended_at,_that.portfolio_value,_that.total_value,_that.total_pnl,_that.total_pnl_pct,_that.holdings);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _SimulationResponse implements SimulationResponse {
  const _SimulationResponse({required this.id, required this.user_id, this.name, required this.initial_capital, required this.cash_balance, required this.status, required this.period_start, required this.period_end, required this.current_sim_date, required this.started_at, this.ended_at, this.portfolio_value, this.total_value, this.total_pnl, this.total_pnl_pct, final  List<PortfolioHolding>? holdings}): _holdings = holdings;
  factory _SimulationResponse.fromJson(Map<String, dynamic> json) => _$SimulationResponseFromJson(json);

@override final  int id;
@override final  int user_id;
@override final  String? name;
@override final  double initial_capital;
@override final  double cash_balance;
@override final  String status;
@override final  String period_start;
@override final  String period_end;
@override final  String current_sim_date;
@override final  String started_at;
@override final  String? ended_at;
@override final  double? portfolio_value;
@override final  double? total_value;
@override final  double? total_pnl;
@override final  double? total_pnl_pct;
 final  List<PortfolioHolding>? _holdings;
@override List<PortfolioHolding>? get holdings {
  final value = _holdings;
  if (value == null) return null;
  if (_holdings is EqualUnmodifiableListView) return _holdings;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(value);
}


/// Create a copy of SimulationResponse
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$SimulationResponseCopyWith<_SimulationResponse> get copyWith => __$SimulationResponseCopyWithImpl<_SimulationResponse>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$SimulationResponseToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _SimulationResponse&&(identical(other.id, id) || other.id == id)&&(identical(other.user_id, user_id) || other.user_id == user_id)&&(identical(other.name, name) || other.name == name)&&(identical(other.initial_capital, initial_capital) || other.initial_capital == initial_capital)&&(identical(other.cash_balance, cash_balance) || other.cash_balance == cash_balance)&&(identical(other.status, status) || other.status == status)&&(identical(other.period_start, period_start) || other.period_start == period_start)&&(identical(other.period_end, period_end) || other.period_end == period_end)&&(identical(other.current_sim_date, current_sim_date) || other.current_sim_date == current_sim_date)&&(identical(other.started_at, started_at) || other.started_at == started_at)&&(identical(other.ended_at, ended_at) || other.ended_at == ended_at)&&(identical(other.portfolio_value, portfolio_value) || other.portfolio_value == portfolio_value)&&(identical(other.total_value, total_value) || other.total_value == total_value)&&(identical(other.total_pnl, total_pnl) || other.total_pnl == total_pnl)&&(identical(other.total_pnl_pct, total_pnl_pct) || other.total_pnl_pct == total_pnl_pct)&&const DeepCollectionEquality().equals(other._holdings, _holdings));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,user_id,name,initial_capital,cash_balance,status,period_start,period_end,current_sim_date,started_at,ended_at,portfolio_value,total_value,total_pnl,total_pnl_pct,const DeepCollectionEquality().hash(_holdings));

@override
String toString() {
  return 'SimulationResponse(id: $id, user_id: $user_id, name: $name, initial_capital: $initial_capital, cash_balance: $cash_balance, status: $status, period_start: $period_start, period_end: $period_end, current_sim_date: $current_sim_date, started_at: $started_at, ended_at: $ended_at, portfolio_value: $portfolio_value, total_value: $total_value, total_pnl: $total_pnl, total_pnl_pct: $total_pnl_pct, holdings: $holdings)';
}


}

/// @nodoc
abstract mixin class _$SimulationResponseCopyWith<$Res> implements $SimulationResponseCopyWith<$Res> {
  factory _$SimulationResponseCopyWith(_SimulationResponse value, $Res Function(_SimulationResponse) _then) = __$SimulationResponseCopyWithImpl;
@override @useResult
$Res call({
 int id, int user_id, String? name, double initial_capital, double cash_balance, String status, String period_start, String period_end, String current_sim_date, String started_at, String? ended_at, double? portfolio_value, double? total_value, double? total_pnl, double? total_pnl_pct, List<PortfolioHolding>? holdings
});




}
/// @nodoc
class __$SimulationResponseCopyWithImpl<$Res>
    implements _$SimulationResponseCopyWith<$Res> {
  __$SimulationResponseCopyWithImpl(this._self, this._then);

  final _SimulationResponse _self;
  final $Res Function(_SimulationResponse) _then;

/// Create a copy of SimulationResponse
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? user_id = null,Object? name = freezed,Object? initial_capital = null,Object? cash_balance = null,Object? status = null,Object? period_start = null,Object? period_end = null,Object? current_sim_date = null,Object? started_at = null,Object? ended_at = freezed,Object? portfolio_value = freezed,Object? total_value = freezed,Object? total_pnl = freezed,Object? total_pnl_pct = freezed,Object? holdings = freezed,}) {
  return _then(_SimulationResponse(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,user_id: null == user_id ? _self.user_id : user_id // ignore: cast_nullable_to_non_nullable
as int,name: freezed == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String?,initial_capital: null == initial_capital ? _self.initial_capital : initial_capital // ignore: cast_nullable_to_non_nullable
as double,cash_balance: null == cash_balance ? _self.cash_balance : cash_balance // ignore: cast_nullable_to_non_nullable
as double,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String,period_start: null == period_start ? _self.period_start : period_start // ignore: cast_nullable_to_non_nullable
as String,period_end: null == period_end ? _self.period_end : period_end // ignore: cast_nullable_to_non_nullable
as String,current_sim_date: null == current_sim_date ? _self.current_sim_date : current_sim_date // ignore: cast_nullable_to_non_nullable
as String,started_at: null == started_at ? _self.started_at : started_at // ignore: cast_nullable_to_non_nullable
as String,ended_at: freezed == ended_at ? _self.ended_at : ended_at // ignore: cast_nullable_to_non_nullable
as String?,portfolio_value: freezed == portfolio_value ? _self.portfolio_value : portfolio_value // ignore: cast_nullable_to_non_nullable
as double?,total_value: freezed == total_value ? _self.total_value : total_value // ignore: cast_nullable_to_non_nullable
as double?,total_pnl: freezed == total_pnl ? _self.total_pnl : total_pnl // ignore: cast_nullable_to_non_nullable
as double?,total_pnl_pct: freezed == total_pnl_pct ? _self.total_pnl_pct : total_pnl_pct // ignore: cast_nullable_to_non_nullable
as double?,holdings: freezed == holdings ? _self._holdings : holdings // ignore: cast_nullable_to_non_nullable
as List<PortfolioHolding>?,
  ));
}


}


/// @nodoc
mixin _$SimulationSummary {

 int get id; String? get name; String get status; double get initial_capital; String get started_at; String? get ended_at; double? get total_pnl; double? get total_pnl_pct; int? get total_trades;
/// Create a copy of SimulationSummary
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SimulationSummaryCopyWith<SimulationSummary> get copyWith => _$SimulationSummaryCopyWithImpl<SimulationSummary>(this as SimulationSummary, _$identity);

  /// Serializes this SimulationSummary to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SimulationSummary&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.status, status) || other.status == status)&&(identical(other.initial_capital, initial_capital) || other.initial_capital == initial_capital)&&(identical(other.started_at, started_at) || other.started_at == started_at)&&(identical(other.ended_at, ended_at) || other.ended_at == ended_at)&&(identical(other.total_pnl, total_pnl) || other.total_pnl == total_pnl)&&(identical(other.total_pnl_pct, total_pnl_pct) || other.total_pnl_pct == total_pnl_pct)&&(identical(other.total_trades, total_trades) || other.total_trades == total_trades));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,name,status,initial_capital,started_at,ended_at,total_pnl,total_pnl_pct,total_trades);

@override
String toString() {
  return 'SimulationSummary(id: $id, name: $name, status: $status, initial_capital: $initial_capital, started_at: $started_at, ended_at: $ended_at, total_pnl: $total_pnl, total_pnl_pct: $total_pnl_pct, total_trades: $total_trades)';
}


}

/// @nodoc
abstract mixin class $SimulationSummaryCopyWith<$Res>  {
  factory $SimulationSummaryCopyWith(SimulationSummary value, $Res Function(SimulationSummary) _then) = _$SimulationSummaryCopyWithImpl;
@useResult
$Res call({
 int id, String? name, String status, double initial_capital, String started_at, String? ended_at, double? total_pnl, double? total_pnl_pct, int? total_trades
});




}
/// @nodoc
class _$SimulationSummaryCopyWithImpl<$Res>
    implements $SimulationSummaryCopyWith<$Res> {
  _$SimulationSummaryCopyWithImpl(this._self, this._then);

  final SimulationSummary _self;
  final $Res Function(SimulationSummary) _then;

/// Create a copy of SimulationSummary
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? name = freezed,Object? status = null,Object? initial_capital = null,Object? started_at = null,Object? ended_at = freezed,Object? total_pnl = freezed,Object? total_pnl_pct = freezed,Object? total_trades = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,name: freezed == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String?,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String,initial_capital: null == initial_capital ? _self.initial_capital : initial_capital // ignore: cast_nullable_to_non_nullable
as double,started_at: null == started_at ? _self.started_at : started_at // ignore: cast_nullable_to_non_nullable
as String,ended_at: freezed == ended_at ? _self.ended_at : ended_at // ignore: cast_nullable_to_non_nullable
as String?,total_pnl: freezed == total_pnl ? _self.total_pnl : total_pnl // ignore: cast_nullable_to_non_nullable
as double?,total_pnl_pct: freezed == total_pnl_pct ? _self.total_pnl_pct : total_pnl_pct // ignore: cast_nullable_to_non_nullable
as double?,total_trades: freezed == total_trades ? _self.total_trades : total_trades // ignore: cast_nullable_to_non_nullable
as int?,
  ));
}

}


/// Adds pattern-matching-related methods to [SimulationSummary].
extension SimulationSummaryPatterns on SimulationSummary {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _SimulationSummary value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _SimulationSummary() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _SimulationSummary value)  $default,){
final _that = this;
switch (_that) {
case _SimulationSummary():
return $default(_that);}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _SimulationSummary value)?  $default,){
final _that = this;
switch (_that) {
case _SimulationSummary() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int id,  String? name,  String status,  double initial_capital,  String started_at,  String? ended_at,  double? total_pnl,  double? total_pnl_pct,  int? total_trades)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _SimulationSummary() when $default != null:
return $default(_that.id,_that.name,_that.status,_that.initial_capital,_that.started_at,_that.ended_at,_that.total_pnl,_that.total_pnl_pct,_that.total_trades);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int id,  String? name,  String status,  double initial_capital,  String started_at,  String? ended_at,  double? total_pnl,  double? total_pnl_pct,  int? total_trades)  $default,) {final _that = this;
switch (_that) {
case _SimulationSummary():
return $default(_that.id,_that.name,_that.status,_that.initial_capital,_that.started_at,_that.ended_at,_that.total_pnl,_that.total_pnl_pct,_that.total_trades);}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int id,  String? name,  String status,  double initial_capital,  String started_at,  String? ended_at,  double? total_pnl,  double? total_pnl_pct,  int? total_trades)?  $default,) {final _that = this;
switch (_that) {
case _SimulationSummary() when $default != null:
return $default(_that.id,_that.name,_that.status,_that.initial_capital,_that.started_at,_that.ended_at,_that.total_pnl,_that.total_pnl_pct,_that.total_trades);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _SimulationSummary implements SimulationSummary {
  const _SimulationSummary({required this.id, this.name, required this.status, required this.initial_capital, required this.started_at, this.ended_at, this.total_pnl, this.total_pnl_pct, this.total_trades});
  factory _SimulationSummary.fromJson(Map<String, dynamic> json) => _$SimulationSummaryFromJson(json);

@override final  int id;
@override final  String? name;
@override final  String status;
@override final  double initial_capital;
@override final  String started_at;
@override final  String? ended_at;
@override final  double? total_pnl;
@override final  double? total_pnl_pct;
@override final  int? total_trades;

/// Create a copy of SimulationSummary
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$SimulationSummaryCopyWith<_SimulationSummary> get copyWith => __$SimulationSummaryCopyWithImpl<_SimulationSummary>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$SimulationSummaryToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _SimulationSummary&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.status, status) || other.status == status)&&(identical(other.initial_capital, initial_capital) || other.initial_capital == initial_capital)&&(identical(other.started_at, started_at) || other.started_at == started_at)&&(identical(other.ended_at, ended_at) || other.ended_at == ended_at)&&(identical(other.total_pnl, total_pnl) || other.total_pnl == total_pnl)&&(identical(other.total_pnl_pct, total_pnl_pct) || other.total_pnl_pct == total_pnl_pct)&&(identical(other.total_trades, total_trades) || other.total_trades == total_trades));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,name,status,initial_capital,started_at,ended_at,total_pnl,total_pnl_pct,total_trades);

@override
String toString() {
  return 'SimulationSummary(id: $id, name: $name, status: $status, initial_capital: $initial_capital, started_at: $started_at, ended_at: $ended_at, total_pnl: $total_pnl, total_pnl_pct: $total_pnl_pct, total_trades: $total_trades)';
}


}

/// @nodoc
abstract mixin class _$SimulationSummaryCopyWith<$Res> implements $SimulationSummaryCopyWith<$Res> {
  factory _$SimulationSummaryCopyWith(_SimulationSummary value, $Res Function(_SimulationSummary) _then) = __$SimulationSummaryCopyWithImpl;
@override @useResult
$Res call({
 int id, String? name, String status, double initial_capital, String started_at, String? ended_at, double? total_pnl, double? total_pnl_pct, int? total_trades
});




}
/// @nodoc
class __$SimulationSummaryCopyWithImpl<$Res>
    implements _$SimulationSummaryCopyWith<$Res> {
  __$SimulationSummaryCopyWithImpl(this._self, this._then);

  final _SimulationSummary _self;
  final $Res Function(_SimulationSummary) _then;

/// Create a copy of SimulationSummary
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? name = freezed,Object? status = null,Object? initial_capital = null,Object? started_at = null,Object? ended_at = freezed,Object? total_pnl = freezed,Object? total_pnl_pct = freezed,Object? total_trades = freezed,}) {
  return _then(_SimulationSummary(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,name: freezed == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String?,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String,initial_capital: null == initial_capital ? _self.initial_capital : initial_capital // ignore: cast_nullable_to_non_nullable
as double,started_at: null == started_at ? _self.started_at : started_at // ignore: cast_nullable_to_non_nullable
as String,ended_at: freezed == ended_at ? _self.ended_at : ended_at // ignore: cast_nullable_to_non_nullable
as String?,total_pnl: freezed == total_pnl ? _self.total_pnl : total_pnl // ignore: cast_nullable_to_non_nullable
as double?,total_pnl_pct: freezed == total_pnl_pct ? _self.total_pnl_pct : total_pnl_pct // ignore: cast_nullable_to_non_nullable
as double?,total_trades: freezed == total_trades ? _self.total_trades : total_trades // ignore: cast_nullable_to_non_nullable
as int?,
  ));
}


}


/// @nodoc
mixin _$TradeRequest {

 String get symbol; String get side; int get quantity;
/// Create a copy of TradeRequest
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$TradeRequestCopyWith<TradeRequest> get copyWith => _$TradeRequestCopyWithImpl<TradeRequest>(this as TradeRequest, _$identity);

  /// Serializes this TradeRequest to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is TradeRequest&&(identical(other.symbol, symbol) || other.symbol == symbol)&&(identical(other.side, side) || other.side == side)&&(identical(other.quantity, quantity) || other.quantity == quantity));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,symbol,side,quantity);

@override
String toString() {
  return 'TradeRequest(symbol: $symbol, side: $side, quantity: $quantity)';
}


}

/// @nodoc
abstract mixin class $TradeRequestCopyWith<$Res>  {
  factory $TradeRequestCopyWith(TradeRequest value, $Res Function(TradeRequest) _then) = _$TradeRequestCopyWithImpl;
@useResult
$Res call({
 String symbol, String side, int quantity
});




}
/// @nodoc
class _$TradeRequestCopyWithImpl<$Res>
    implements $TradeRequestCopyWith<$Res> {
  _$TradeRequestCopyWithImpl(this._self, this._then);

  final TradeRequest _self;
  final $Res Function(TradeRequest) _then;

/// Create a copy of TradeRequest
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? symbol = null,Object? side = null,Object? quantity = null,}) {
  return _then(_self.copyWith(
symbol: null == symbol ? _self.symbol : symbol // ignore: cast_nullable_to_non_nullable
as String,side: null == side ? _self.side : side // ignore: cast_nullable_to_non_nullable
as String,quantity: null == quantity ? _self.quantity : quantity // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [TradeRequest].
extension TradeRequestPatterns on TradeRequest {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _TradeRequest value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _TradeRequest() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _TradeRequest value)  $default,){
final _that = this;
switch (_that) {
case _TradeRequest():
return $default(_that);}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _TradeRequest value)?  $default,){
final _that = this;
switch (_that) {
case _TradeRequest() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String symbol,  String side,  int quantity)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _TradeRequest() when $default != null:
return $default(_that.symbol,_that.side,_that.quantity);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String symbol,  String side,  int quantity)  $default,) {final _that = this;
switch (_that) {
case _TradeRequest():
return $default(_that.symbol,_that.side,_that.quantity);}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String symbol,  String side,  int quantity)?  $default,) {final _that = this;
switch (_that) {
case _TradeRequest() when $default != null:
return $default(_that.symbol,_that.side,_that.quantity);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _TradeRequest implements TradeRequest {
  const _TradeRequest({required this.symbol, required this.side, required this.quantity});
  factory _TradeRequest.fromJson(Map<String, dynamic> json) => _$TradeRequestFromJson(json);

@override final  String symbol;
@override final  String side;
@override final  int quantity;

/// Create a copy of TradeRequest
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$TradeRequestCopyWith<_TradeRequest> get copyWith => __$TradeRequestCopyWithImpl<_TradeRequest>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$TradeRequestToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _TradeRequest&&(identical(other.symbol, symbol) || other.symbol == symbol)&&(identical(other.side, side) || other.side == side)&&(identical(other.quantity, quantity) || other.quantity == quantity));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,symbol,side,quantity);

@override
String toString() {
  return 'TradeRequest(symbol: $symbol, side: $side, quantity: $quantity)';
}


}

/// @nodoc
abstract mixin class _$TradeRequestCopyWith<$Res> implements $TradeRequestCopyWith<$Res> {
  factory _$TradeRequestCopyWith(_TradeRequest value, $Res Function(_TradeRequest) _then) = __$TradeRequestCopyWithImpl;
@override @useResult
$Res call({
 String symbol, String side, int quantity
});




}
/// @nodoc
class __$TradeRequestCopyWithImpl<$Res>
    implements _$TradeRequestCopyWith<$Res> {
  __$TradeRequestCopyWithImpl(this._self, this._then);

  final _TradeRequest _self;
  final $Res Function(_TradeRequest) _then;

/// Create a copy of TradeRequest
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? symbol = null,Object? side = null,Object? quantity = null,}) {
  return _then(_TradeRequest(
symbol: null == symbol ? _self.symbol : symbol // ignore: cast_nullable_to_non_nullable
as String,side: null == side ? _self.side : side // ignore: cast_nullable_to_non_nullable
as String,quantity: null == quantity ? _self.quantity : quantity // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}


/// @nodoc
mixin _$TradeResponse {

 int get id; int get simulation_id; String get symbol; String get side; int get quantity; double get executed_price; double get sebon_commission; double get broker_commission; double get dp_charge; double get total_cost; String get sim_date; String get status; String? get rejection_reason; double? get realised_pnl; String get created_at; double? get new_cash_balance; String? get message;
/// Create a copy of TradeResponse
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$TradeResponseCopyWith<TradeResponse> get copyWith => _$TradeResponseCopyWithImpl<TradeResponse>(this as TradeResponse, _$identity);

  /// Serializes this TradeResponse to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is TradeResponse&&(identical(other.id, id) || other.id == id)&&(identical(other.simulation_id, simulation_id) || other.simulation_id == simulation_id)&&(identical(other.symbol, symbol) || other.symbol == symbol)&&(identical(other.side, side) || other.side == side)&&(identical(other.quantity, quantity) || other.quantity == quantity)&&(identical(other.executed_price, executed_price) || other.executed_price == executed_price)&&(identical(other.sebon_commission, sebon_commission) || other.sebon_commission == sebon_commission)&&(identical(other.broker_commission, broker_commission) || other.broker_commission == broker_commission)&&(identical(other.dp_charge, dp_charge) || other.dp_charge == dp_charge)&&(identical(other.total_cost, total_cost) || other.total_cost == total_cost)&&(identical(other.sim_date, sim_date) || other.sim_date == sim_date)&&(identical(other.status, status) || other.status == status)&&(identical(other.rejection_reason, rejection_reason) || other.rejection_reason == rejection_reason)&&(identical(other.realised_pnl, realised_pnl) || other.realised_pnl == realised_pnl)&&(identical(other.created_at, created_at) || other.created_at == created_at)&&(identical(other.new_cash_balance, new_cash_balance) || other.new_cash_balance == new_cash_balance)&&(identical(other.message, message) || other.message == message));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,simulation_id,symbol,side,quantity,executed_price,sebon_commission,broker_commission,dp_charge,total_cost,sim_date,status,rejection_reason,realised_pnl,created_at,new_cash_balance,message);

@override
String toString() {
  return 'TradeResponse(id: $id, simulation_id: $simulation_id, symbol: $symbol, side: $side, quantity: $quantity, executed_price: $executed_price, sebon_commission: $sebon_commission, broker_commission: $broker_commission, dp_charge: $dp_charge, total_cost: $total_cost, sim_date: $sim_date, status: $status, rejection_reason: $rejection_reason, realised_pnl: $realised_pnl, created_at: $created_at, new_cash_balance: $new_cash_balance, message: $message)';
}


}

/// @nodoc
abstract mixin class $TradeResponseCopyWith<$Res>  {
  factory $TradeResponseCopyWith(TradeResponse value, $Res Function(TradeResponse) _then) = _$TradeResponseCopyWithImpl;
@useResult
$Res call({
 int id, int simulation_id, String symbol, String side, int quantity, double executed_price, double sebon_commission, double broker_commission, double dp_charge, double total_cost, String sim_date, String status, String? rejection_reason, double? realised_pnl, String created_at, double? new_cash_balance, String? message
});




}
/// @nodoc
class _$TradeResponseCopyWithImpl<$Res>
    implements $TradeResponseCopyWith<$Res> {
  _$TradeResponseCopyWithImpl(this._self, this._then);

  final TradeResponse _self;
  final $Res Function(TradeResponse) _then;

/// Create a copy of TradeResponse
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? simulation_id = null,Object? symbol = null,Object? side = null,Object? quantity = null,Object? executed_price = null,Object? sebon_commission = null,Object? broker_commission = null,Object? dp_charge = null,Object? total_cost = null,Object? sim_date = null,Object? status = null,Object? rejection_reason = freezed,Object? realised_pnl = freezed,Object? created_at = null,Object? new_cash_balance = freezed,Object? message = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,simulation_id: null == simulation_id ? _self.simulation_id : simulation_id // ignore: cast_nullable_to_non_nullable
as int,symbol: null == symbol ? _self.symbol : symbol // ignore: cast_nullable_to_non_nullable
as String,side: null == side ? _self.side : side // ignore: cast_nullable_to_non_nullable
as String,quantity: null == quantity ? _self.quantity : quantity // ignore: cast_nullable_to_non_nullable
as int,executed_price: null == executed_price ? _self.executed_price : executed_price // ignore: cast_nullable_to_non_nullable
as double,sebon_commission: null == sebon_commission ? _self.sebon_commission : sebon_commission // ignore: cast_nullable_to_non_nullable
as double,broker_commission: null == broker_commission ? _self.broker_commission : broker_commission // ignore: cast_nullable_to_non_nullable
as double,dp_charge: null == dp_charge ? _self.dp_charge : dp_charge // ignore: cast_nullable_to_non_nullable
as double,total_cost: null == total_cost ? _self.total_cost : total_cost // ignore: cast_nullable_to_non_nullable
as double,sim_date: null == sim_date ? _self.sim_date : sim_date // ignore: cast_nullable_to_non_nullable
as String,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String,rejection_reason: freezed == rejection_reason ? _self.rejection_reason : rejection_reason // ignore: cast_nullable_to_non_nullable
as String?,realised_pnl: freezed == realised_pnl ? _self.realised_pnl : realised_pnl // ignore: cast_nullable_to_non_nullable
as double?,created_at: null == created_at ? _self.created_at : created_at // ignore: cast_nullable_to_non_nullable
as String,new_cash_balance: freezed == new_cash_balance ? _self.new_cash_balance : new_cash_balance // ignore: cast_nullable_to_non_nullable
as double?,message: freezed == message ? _self.message : message // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [TradeResponse].
extension TradeResponsePatterns on TradeResponse {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _TradeResponse value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _TradeResponse() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _TradeResponse value)  $default,){
final _that = this;
switch (_that) {
case _TradeResponse():
return $default(_that);}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _TradeResponse value)?  $default,){
final _that = this;
switch (_that) {
case _TradeResponse() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int id,  int simulation_id,  String symbol,  String side,  int quantity,  double executed_price,  double sebon_commission,  double broker_commission,  double dp_charge,  double total_cost,  String sim_date,  String status,  String? rejection_reason,  double? realised_pnl,  String created_at,  double? new_cash_balance,  String? message)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _TradeResponse() when $default != null:
return $default(_that.id,_that.simulation_id,_that.symbol,_that.side,_that.quantity,_that.executed_price,_that.sebon_commission,_that.broker_commission,_that.dp_charge,_that.total_cost,_that.sim_date,_that.status,_that.rejection_reason,_that.realised_pnl,_that.created_at,_that.new_cash_balance,_that.message);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int id,  int simulation_id,  String symbol,  String side,  int quantity,  double executed_price,  double sebon_commission,  double broker_commission,  double dp_charge,  double total_cost,  String sim_date,  String status,  String? rejection_reason,  double? realised_pnl,  String created_at,  double? new_cash_balance,  String? message)  $default,) {final _that = this;
switch (_that) {
case _TradeResponse():
return $default(_that.id,_that.simulation_id,_that.symbol,_that.side,_that.quantity,_that.executed_price,_that.sebon_commission,_that.broker_commission,_that.dp_charge,_that.total_cost,_that.sim_date,_that.status,_that.rejection_reason,_that.realised_pnl,_that.created_at,_that.new_cash_balance,_that.message);}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int id,  int simulation_id,  String symbol,  String side,  int quantity,  double executed_price,  double sebon_commission,  double broker_commission,  double dp_charge,  double total_cost,  String sim_date,  String status,  String? rejection_reason,  double? realised_pnl,  String created_at,  double? new_cash_balance,  String? message)?  $default,) {final _that = this;
switch (_that) {
case _TradeResponse() when $default != null:
return $default(_that.id,_that.simulation_id,_that.symbol,_that.side,_that.quantity,_that.executed_price,_that.sebon_commission,_that.broker_commission,_that.dp_charge,_that.total_cost,_that.sim_date,_that.status,_that.rejection_reason,_that.realised_pnl,_that.created_at,_that.new_cash_balance,_that.message);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _TradeResponse implements TradeResponse {
  const _TradeResponse({required this.id, required this.simulation_id, required this.symbol, required this.side, required this.quantity, required this.executed_price, required this.sebon_commission, required this.broker_commission, required this.dp_charge, required this.total_cost, required this.sim_date, required this.status, this.rejection_reason, this.realised_pnl, required this.created_at, this.new_cash_balance, this.message});
  factory _TradeResponse.fromJson(Map<String, dynamic> json) => _$TradeResponseFromJson(json);

@override final  int id;
@override final  int simulation_id;
@override final  String symbol;
@override final  String side;
@override final  int quantity;
@override final  double executed_price;
@override final  double sebon_commission;
@override final  double broker_commission;
@override final  double dp_charge;
@override final  double total_cost;
@override final  String sim_date;
@override final  String status;
@override final  String? rejection_reason;
@override final  double? realised_pnl;
@override final  String created_at;
@override final  double? new_cash_balance;
@override final  String? message;

/// Create a copy of TradeResponse
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$TradeResponseCopyWith<_TradeResponse> get copyWith => __$TradeResponseCopyWithImpl<_TradeResponse>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$TradeResponseToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _TradeResponse&&(identical(other.id, id) || other.id == id)&&(identical(other.simulation_id, simulation_id) || other.simulation_id == simulation_id)&&(identical(other.symbol, symbol) || other.symbol == symbol)&&(identical(other.side, side) || other.side == side)&&(identical(other.quantity, quantity) || other.quantity == quantity)&&(identical(other.executed_price, executed_price) || other.executed_price == executed_price)&&(identical(other.sebon_commission, sebon_commission) || other.sebon_commission == sebon_commission)&&(identical(other.broker_commission, broker_commission) || other.broker_commission == broker_commission)&&(identical(other.dp_charge, dp_charge) || other.dp_charge == dp_charge)&&(identical(other.total_cost, total_cost) || other.total_cost == total_cost)&&(identical(other.sim_date, sim_date) || other.sim_date == sim_date)&&(identical(other.status, status) || other.status == status)&&(identical(other.rejection_reason, rejection_reason) || other.rejection_reason == rejection_reason)&&(identical(other.realised_pnl, realised_pnl) || other.realised_pnl == realised_pnl)&&(identical(other.created_at, created_at) || other.created_at == created_at)&&(identical(other.new_cash_balance, new_cash_balance) || other.new_cash_balance == new_cash_balance)&&(identical(other.message, message) || other.message == message));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,simulation_id,symbol,side,quantity,executed_price,sebon_commission,broker_commission,dp_charge,total_cost,sim_date,status,rejection_reason,realised_pnl,created_at,new_cash_balance,message);

@override
String toString() {
  return 'TradeResponse(id: $id, simulation_id: $simulation_id, symbol: $symbol, side: $side, quantity: $quantity, executed_price: $executed_price, sebon_commission: $sebon_commission, broker_commission: $broker_commission, dp_charge: $dp_charge, total_cost: $total_cost, sim_date: $sim_date, status: $status, rejection_reason: $rejection_reason, realised_pnl: $realised_pnl, created_at: $created_at, new_cash_balance: $new_cash_balance, message: $message)';
}


}

/// @nodoc
abstract mixin class _$TradeResponseCopyWith<$Res> implements $TradeResponseCopyWith<$Res> {
  factory _$TradeResponseCopyWith(_TradeResponse value, $Res Function(_TradeResponse) _then) = __$TradeResponseCopyWithImpl;
@override @useResult
$Res call({
 int id, int simulation_id, String symbol, String side, int quantity, double executed_price, double sebon_commission, double broker_commission, double dp_charge, double total_cost, String sim_date, String status, String? rejection_reason, double? realised_pnl, String created_at, double? new_cash_balance, String? message
});




}
/// @nodoc
class __$TradeResponseCopyWithImpl<$Res>
    implements _$TradeResponseCopyWith<$Res> {
  __$TradeResponseCopyWithImpl(this._self, this._then);

  final _TradeResponse _self;
  final $Res Function(_TradeResponse) _then;

/// Create a copy of TradeResponse
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? simulation_id = null,Object? symbol = null,Object? side = null,Object? quantity = null,Object? executed_price = null,Object? sebon_commission = null,Object? broker_commission = null,Object? dp_charge = null,Object? total_cost = null,Object? sim_date = null,Object? status = null,Object? rejection_reason = freezed,Object? realised_pnl = freezed,Object? created_at = null,Object? new_cash_balance = freezed,Object? message = freezed,}) {
  return _then(_TradeResponse(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,simulation_id: null == simulation_id ? _self.simulation_id : simulation_id // ignore: cast_nullable_to_non_nullable
as int,symbol: null == symbol ? _self.symbol : symbol // ignore: cast_nullable_to_non_nullable
as String,side: null == side ? _self.side : side // ignore: cast_nullable_to_non_nullable
as String,quantity: null == quantity ? _self.quantity : quantity // ignore: cast_nullable_to_non_nullable
as int,executed_price: null == executed_price ? _self.executed_price : executed_price // ignore: cast_nullable_to_non_nullable
as double,sebon_commission: null == sebon_commission ? _self.sebon_commission : sebon_commission // ignore: cast_nullable_to_non_nullable
as double,broker_commission: null == broker_commission ? _self.broker_commission : broker_commission // ignore: cast_nullable_to_non_nullable
as double,dp_charge: null == dp_charge ? _self.dp_charge : dp_charge // ignore: cast_nullable_to_non_nullable
as double,total_cost: null == total_cost ? _self.total_cost : total_cost // ignore: cast_nullable_to_non_nullable
as double,sim_date: null == sim_date ? _self.sim_date : sim_date // ignore: cast_nullable_to_non_nullable
as String,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String,rejection_reason: freezed == rejection_reason ? _self.rejection_reason : rejection_reason // ignore: cast_nullable_to_non_nullable
as String?,realised_pnl: freezed == realised_pnl ? _self.realised_pnl : realised_pnl // ignore: cast_nullable_to_non_nullable
as double?,created_at: null == created_at ? _self.created_at : created_at // ignore: cast_nullable_to_non_nullable
as String,new_cash_balance: freezed == new_cash_balance ? _self.new_cash_balance : new_cash_balance // ignore: cast_nullable_to_non_nullable
as double?,message: freezed == message ? _self.message : message // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}


/// @nodoc
mixin _$EndSimulationResponse {

 int get simulation_id; String get status; String get message; String? get analysis_task_id;
/// Create a copy of EndSimulationResponse
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$EndSimulationResponseCopyWith<EndSimulationResponse> get copyWith => _$EndSimulationResponseCopyWithImpl<EndSimulationResponse>(this as EndSimulationResponse, _$identity);

  /// Serializes this EndSimulationResponse to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is EndSimulationResponse&&(identical(other.simulation_id, simulation_id) || other.simulation_id == simulation_id)&&(identical(other.status, status) || other.status == status)&&(identical(other.message, message) || other.message == message)&&(identical(other.analysis_task_id, analysis_task_id) || other.analysis_task_id == analysis_task_id));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,simulation_id,status,message,analysis_task_id);

@override
String toString() {
  return 'EndSimulationResponse(simulation_id: $simulation_id, status: $status, message: $message, analysis_task_id: $analysis_task_id)';
}


}

/// @nodoc
abstract mixin class $EndSimulationResponseCopyWith<$Res>  {
  factory $EndSimulationResponseCopyWith(EndSimulationResponse value, $Res Function(EndSimulationResponse) _then) = _$EndSimulationResponseCopyWithImpl;
@useResult
$Res call({
 int simulation_id, String status, String message, String? analysis_task_id
});




}
/// @nodoc
class _$EndSimulationResponseCopyWithImpl<$Res>
    implements $EndSimulationResponseCopyWith<$Res> {
  _$EndSimulationResponseCopyWithImpl(this._self, this._then);

  final EndSimulationResponse _self;
  final $Res Function(EndSimulationResponse) _then;

/// Create a copy of EndSimulationResponse
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? simulation_id = null,Object? status = null,Object? message = null,Object? analysis_task_id = freezed,}) {
  return _then(_self.copyWith(
simulation_id: null == simulation_id ? _self.simulation_id : simulation_id // ignore: cast_nullable_to_non_nullable
as int,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String,message: null == message ? _self.message : message // ignore: cast_nullable_to_non_nullable
as String,analysis_task_id: freezed == analysis_task_id ? _self.analysis_task_id : analysis_task_id // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [EndSimulationResponse].
extension EndSimulationResponsePatterns on EndSimulationResponse {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _EndSimulationResponse value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _EndSimulationResponse() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _EndSimulationResponse value)  $default,){
final _that = this;
switch (_that) {
case _EndSimulationResponse():
return $default(_that);}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _EndSimulationResponse value)?  $default,){
final _that = this;
switch (_that) {
case _EndSimulationResponse() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int simulation_id,  String status,  String message,  String? analysis_task_id)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _EndSimulationResponse() when $default != null:
return $default(_that.simulation_id,_that.status,_that.message,_that.analysis_task_id);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int simulation_id,  String status,  String message,  String? analysis_task_id)  $default,) {final _that = this;
switch (_that) {
case _EndSimulationResponse():
return $default(_that.simulation_id,_that.status,_that.message,_that.analysis_task_id);}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int simulation_id,  String status,  String message,  String? analysis_task_id)?  $default,) {final _that = this;
switch (_that) {
case _EndSimulationResponse() when $default != null:
return $default(_that.simulation_id,_that.status,_that.message,_that.analysis_task_id);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _EndSimulationResponse implements EndSimulationResponse {
  const _EndSimulationResponse({required this.simulation_id, required this.status, required this.message, this.analysis_task_id});
  factory _EndSimulationResponse.fromJson(Map<String, dynamic> json) => _$EndSimulationResponseFromJson(json);

@override final  int simulation_id;
@override final  String status;
@override final  String message;
@override final  String? analysis_task_id;

/// Create a copy of EndSimulationResponse
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$EndSimulationResponseCopyWith<_EndSimulationResponse> get copyWith => __$EndSimulationResponseCopyWithImpl<_EndSimulationResponse>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$EndSimulationResponseToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _EndSimulationResponse&&(identical(other.simulation_id, simulation_id) || other.simulation_id == simulation_id)&&(identical(other.status, status) || other.status == status)&&(identical(other.message, message) || other.message == message)&&(identical(other.analysis_task_id, analysis_task_id) || other.analysis_task_id == analysis_task_id));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,simulation_id,status,message,analysis_task_id);

@override
String toString() {
  return 'EndSimulationResponse(simulation_id: $simulation_id, status: $status, message: $message, analysis_task_id: $analysis_task_id)';
}


}

/// @nodoc
abstract mixin class _$EndSimulationResponseCopyWith<$Res> implements $EndSimulationResponseCopyWith<$Res> {
  factory _$EndSimulationResponseCopyWith(_EndSimulationResponse value, $Res Function(_EndSimulationResponse) _then) = __$EndSimulationResponseCopyWithImpl;
@override @useResult
$Res call({
 int simulation_id, String status, String message, String? analysis_task_id
});




}
/// @nodoc
class __$EndSimulationResponseCopyWithImpl<$Res>
    implements _$EndSimulationResponseCopyWith<$Res> {
  __$EndSimulationResponseCopyWithImpl(this._self, this._then);

  final _EndSimulationResponse _self;
  final $Res Function(_EndSimulationResponse) _then;

/// Create a copy of EndSimulationResponse
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? simulation_id = null,Object? status = null,Object? message = null,Object? analysis_task_id = freezed,}) {
  return _then(_EndSimulationResponse(
simulation_id: null == simulation_id ? _self.simulation_id : simulation_id // ignore: cast_nullable_to_non_nullable
as int,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String,message: null == message ? _self.message : message // ignore: cast_nullable_to_non_nullable
as String,analysis_task_id: freezed == analysis_task_id ? _self.analysis_task_id : analysis_task_id // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}


/// @nodoc
mixin _$AnalysisSection {

 String get title; String get detail; List<int>? get trade_ids; double? get impact_pct;
/// Create a copy of AnalysisSection
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AnalysisSectionCopyWith<AnalysisSection> get copyWith => _$AnalysisSectionCopyWithImpl<AnalysisSection>(this as AnalysisSection, _$identity);

  /// Serializes this AnalysisSection to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AnalysisSection&&(identical(other.title, title) || other.title == title)&&(identical(other.detail, detail) || other.detail == detail)&&const DeepCollectionEquality().equals(other.trade_ids, trade_ids)&&(identical(other.impact_pct, impact_pct) || other.impact_pct == impact_pct));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,title,detail,const DeepCollectionEquality().hash(trade_ids),impact_pct);

@override
String toString() {
  return 'AnalysisSection(title: $title, detail: $detail, trade_ids: $trade_ids, impact_pct: $impact_pct)';
}


}

/// @nodoc
abstract mixin class $AnalysisSectionCopyWith<$Res>  {
  factory $AnalysisSectionCopyWith(AnalysisSection value, $Res Function(AnalysisSection) _then) = _$AnalysisSectionCopyWithImpl;
@useResult
$Res call({
 String title, String detail, List<int>? trade_ids, double? impact_pct
});




}
/// @nodoc
class _$AnalysisSectionCopyWithImpl<$Res>
    implements $AnalysisSectionCopyWith<$Res> {
  _$AnalysisSectionCopyWithImpl(this._self, this._then);

  final AnalysisSection _self;
  final $Res Function(AnalysisSection) _then;

/// Create a copy of AnalysisSection
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? title = null,Object? detail = null,Object? trade_ids = freezed,Object? impact_pct = freezed,}) {
  return _then(_self.copyWith(
title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,detail: null == detail ? _self.detail : detail // ignore: cast_nullable_to_non_nullable
as String,trade_ids: freezed == trade_ids ? _self.trade_ids : trade_ids // ignore: cast_nullable_to_non_nullable
as List<int>?,impact_pct: freezed == impact_pct ? _self.impact_pct : impact_pct // ignore: cast_nullable_to_non_nullable
as double?,
  ));
}

}


/// Adds pattern-matching-related methods to [AnalysisSection].
extension AnalysisSectionPatterns on AnalysisSection {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _AnalysisSection value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _AnalysisSection() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _AnalysisSection value)  $default,){
final _that = this;
switch (_that) {
case _AnalysisSection():
return $default(_that);}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _AnalysisSection value)?  $default,){
final _that = this;
switch (_that) {
case _AnalysisSection() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String title,  String detail,  List<int>? trade_ids,  double? impact_pct)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _AnalysisSection() when $default != null:
return $default(_that.title,_that.detail,_that.trade_ids,_that.impact_pct);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String title,  String detail,  List<int>? trade_ids,  double? impact_pct)  $default,) {final _that = this;
switch (_that) {
case _AnalysisSection():
return $default(_that.title,_that.detail,_that.trade_ids,_that.impact_pct);}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String title,  String detail,  List<int>? trade_ids,  double? impact_pct)?  $default,) {final _that = this;
switch (_that) {
case _AnalysisSection() when $default != null:
return $default(_that.title,_that.detail,_that.trade_ids,_that.impact_pct);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _AnalysisSection implements AnalysisSection {
  const _AnalysisSection({required this.title, required this.detail, final  List<int>? trade_ids, this.impact_pct}): _trade_ids = trade_ids;
  factory _AnalysisSection.fromJson(Map<String, dynamic> json) => _$AnalysisSectionFromJson(json);

@override final  String title;
@override final  String detail;
 final  List<int>? _trade_ids;
@override List<int>? get trade_ids {
  final value = _trade_ids;
  if (value == null) return null;
  if (_trade_ids is EqualUnmodifiableListView) return _trade_ids;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(value);
}

@override final  double? impact_pct;

/// Create a copy of AnalysisSection
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$AnalysisSectionCopyWith<_AnalysisSection> get copyWith => __$AnalysisSectionCopyWithImpl<_AnalysisSection>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$AnalysisSectionToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _AnalysisSection&&(identical(other.title, title) || other.title == title)&&(identical(other.detail, detail) || other.detail == detail)&&const DeepCollectionEquality().equals(other._trade_ids, _trade_ids)&&(identical(other.impact_pct, impact_pct) || other.impact_pct == impact_pct));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,title,detail,const DeepCollectionEquality().hash(_trade_ids),impact_pct);

@override
String toString() {
  return 'AnalysisSection(title: $title, detail: $detail, trade_ids: $trade_ids, impact_pct: $impact_pct)';
}


}

/// @nodoc
abstract mixin class _$AnalysisSectionCopyWith<$Res> implements $AnalysisSectionCopyWith<$Res> {
  factory _$AnalysisSectionCopyWith(_AnalysisSection value, $Res Function(_AnalysisSection) _then) = __$AnalysisSectionCopyWithImpl;
@override @useResult
$Res call({
 String title, String detail, List<int>? trade_ids, double? impact_pct
});




}
/// @nodoc
class __$AnalysisSectionCopyWithImpl<$Res>
    implements _$AnalysisSectionCopyWith<$Res> {
  __$AnalysisSectionCopyWithImpl(this._self, this._then);

  final _AnalysisSection _self;
  final $Res Function(_AnalysisSection) _then;

/// Create a copy of AnalysisSection
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? title = null,Object? detail = null,Object? trade_ids = freezed,Object? impact_pct = freezed,}) {
  return _then(_AnalysisSection(
title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,detail: null == detail ? _self.detail : detail // ignore: cast_nullable_to_non_nullable
as String,trade_ids: freezed == trade_ids ? _self._trade_ids : trade_ids // ignore: cast_nullable_to_non_nullable
as List<int>?,impact_pct: freezed == impact_pct ? _self.impact_pct : impact_pct // ignore: cast_nullable_to_non_nullable
as double?,
  ));
}


}


/// @nodoc
mixin _$TradeCommentary {

 int get trade_id; String get symbol; String get side; String get sim_date; String get commentary; double? get quality_score;
/// Create a copy of TradeCommentary
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$TradeCommentaryCopyWith<TradeCommentary> get copyWith => _$TradeCommentaryCopyWithImpl<TradeCommentary>(this as TradeCommentary, _$identity);

  /// Serializes this TradeCommentary to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is TradeCommentary&&(identical(other.trade_id, trade_id) || other.trade_id == trade_id)&&(identical(other.symbol, symbol) || other.symbol == symbol)&&(identical(other.side, side) || other.side == side)&&(identical(other.sim_date, sim_date) || other.sim_date == sim_date)&&(identical(other.commentary, commentary) || other.commentary == commentary)&&(identical(other.quality_score, quality_score) || other.quality_score == quality_score));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,trade_id,symbol,side,sim_date,commentary,quality_score);

@override
String toString() {
  return 'TradeCommentary(trade_id: $trade_id, symbol: $symbol, side: $side, sim_date: $sim_date, commentary: $commentary, quality_score: $quality_score)';
}


}

/// @nodoc
abstract mixin class $TradeCommentaryCopyWith<$Res>  {
  factory $TradeCommentaryCopyWith(TradeCommentary value, $Res Function(TradeCommentary) _then) = _$TradeCommentaryCopyWithImpl;
@useResult
$Res call({
 int trade_id, String symbol, String side, String sim_date, String commentary, double? quality_score
});




}
/// @nodoc
class _$TradeCommentaryCopyWithImpl<$Res>
    implements $TradeCommentaryCopyWith<$Res> {
  _$TradeCommentaryCopyWithImpl(this._self, this._then);

  final TradeCommentary _self;
  final $Res Function(TradeCommentary) _then;

/// Create a copy of TradeCommentary
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? trade_id = null,Object? symbol = null,Object? side = null,Object? sim_date = null,Object? commentary = null,Object? quality_score = freezed,}) {
  return _then(_self.copyWith(
trade_id: null == trade_id ? _self.trade_id : trade_id // ignore: cast_nullable_to_non_nullable
as int,symbol: null == symbol ? _self.symbol : symbol // ignore: cast_nullable_to_non_nullable
as String,side: null == side ? _self.side : side // ignore: cast_nullable_to_non_nullable
as String,sim_date: null == sim_date ? _self.sim_date : sim_date // ignore: cast_nullable_to_non_nullable
as String,commentary: null == commentary ? _self.commentary : commentary // ignore: cast_nullable_to_non_nullable
as String,quality_score: freezed == quality_score ? _self.quality_score : quality_score // ignore: cast_nullable_to_non_nullable
as double?,
  ));
}

}


/// Adds pattern-matching-related methods to [TradeCommentary].
extension TradeCommentaryPatterns on TradeCommentary {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _TradeCommentary value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _TradeCommentary() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _TradeCommentary value)  $default,){
final _that = this;
switch (_that) {
case _TradeCommentary():
return $default(_that);}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _TradeCommentary value)?  $default,){
final _that = this;
switch (_that) {
case _TradeCommentary() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int trade_id,  String symbol,  String side,  String sim_date,  String commentary,  double? quality_score)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _TradeCommentary() when $default != null:
return $default(_that.trade_id,_that.symbol,_that.side,_that.sim_date,_that.commentary,_that.quality_score);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int trade_id,  String symbol,  String side,  String sim_date,  String commentary,  double? quality_score)  $default,) {final _that = this;
switch (_that) {
case _TradeCommentary():
return $default(_that.trade_id,_that.symbol,_that.side,_that.sim_date,_that.commentary,_that.quality_score);}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int trade_id,  String symbol,  String side,  String sim_date,  String commentary,  double? quality_score)?  $default,) {final _that = this;
switch (_that) {
case _TradeCommentary() when $default != null:
return $default(_that.trade_id,_that.symbol,_that.side,_that.sim_date,_that.commentary,_that.quality_score);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _TradeCommentary implements TradeCommentary {
  const _TradeCommentary({required this.trade_id, required this.symbol, required this.side, required this.sim_date, required this.commentary, this.quality_score});
  factory _TradeCommentary.fromJson(Map<String, dynamic> json) => _$TradeCommentaryFromJson(json);

@override final  int trade_id;
@override final  String symbol;
@override final  String side;
@override final  String sim_date;
@override final  String commentary;
@override final  double? quality_score;

/// Create a copy of TradeCommentary
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$TradeCommentaryCopyWith<_TradeCommentary> get copyWith => __$TradeCommentaryCopyWithImpl<_TradeCommentary>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$TradeCommentaryToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _TradeCommentary&&(identical(other.trade_id, trade_id) || other.trade_id == trade_id)&&(identical(other.symbol, symbol) || other.symbol == symbol)&&(identical(other.side, side) || other.side == side)&&(identical(other.sim_date, sim_date) || other.sim_date == sim_date)&&(identical(other.commentary, commentary) || other.commentary == commentary)&&(identical(other.quality_score, quality_score) || other.quality_score == quality_score));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,trade_id,symbol,side,sim_date,commentary,quality_score);

@override
String toString() {
  return 'TradeCommentary(trade_id: $trade_id, symbol: $symbol, side: $side, sim_date: $sim_date, commentary: $commentary, quality_score: $quality_score)';
}


}

/// @nodoc
abstract mixin class _$TradeCommentaryCopyWith<$Res> implements $TradeCommentaryCopyWith<$Res> {
  factory _$TradeCommentaryCopyWith(_TradeCommentary value, $Res Function(_TradeCommentary) _then) = __$TradeCommentaryCopyWithImpl;
@override @useResult
$Res call({
 int trade_id, String symbol, String side, String sim_date, String commentary, double? quality_score
});




}
/// @nodoc
class __$TradeCommentaryCopyWithImpl<$Res>
    implements _$TradeCommentaryCopyWith<$Res> {
  __$TradeCommentaryCopyWithImpl(this._self, this._then);

  final _TradeCommentary _self;
  final $Res Function(_TradeCommentary) _then;

/// Create a copy of TradeCommentary
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? trade_id = null,Object? symbol = null,Object? side = null,Object? sim_date = null,Object? commentary = null,Object? quality_score = freezed,}) {
  return _then(_TradeCommentary(
trade_id: null == trade_id ? _self.trade_id : trade_id // ignore: cast_nullable_to_non_nullable
as int,symbol: null == symbol ? _self.symbol : symbol // ignore: cast_nullable_to_non_nullable
as String,side: null == side ? _self.side : side // ignore: cast_nullable_to_non_nullable
as String,sim_date: null == sim_date ? _self.sim_date : sim_date // ignore: cast_nullable_to_non_nullable
as String,commentary: null == commentary ? _self.commentary : commentary // ignore: cast_nullable_to_non_nullable
as String,quality_score: freezed == quality_score ? _self.quality_score : quality_score // ignore: cast_nullable_to_non_nullable
as double?,
  ));
}


}


/// @nodoc
mixin _$AIAnalysisResponse {

 int get id; int get simulation_id; String get status;// Metrics
 double? get total_pnl; double? get total_pnl_pct; double? get win_rate; double? get sharpe_ratio; double? get max_drawdown; int? get total_trades; int? get winning_trades; int? get losing_trades; double? get best_trade_pnl; double? get worst_trade_pnl; double? get avg_holding_days;// Benchmarks
 double? get market_return_pct; double? get buy_hold_return_pct; String? get summary_narrative; List<AnalysisSection>? get what_you_did_right; List<AnalysisSection>? get what_you_did_wrong; List<AnalysisSection>? get what_you_could_have_done; List<TradeCommentary>? get trade_by_trade_commentary; double? get timing_score; double? get selection_score; double? get risk_score; double? get patience_score; String? get llm_provider; String? get created_at; String? get completed_at;
/// Create a copy of AIAnalysisResponse
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AIAnalysisResponseCopyWith<AIAnalysisResponse> get copyWith => _$AIAnalysisResponseCopyWithImpl<AIAnalysisResponse>(this as AIAnalysisResponse, _$identity);

  /// Serializes this AIAnalysisResponse to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AIAnalysisResponse&&(identical(other.id, id) || other.id == id)&&(identical(other.simulation_id, simulation_id) || other.simulation_id == simulation_id)&&(identical(other.status, status) || other.status == status)&&(identical(other.total_pnl, total_pnl) || other.total_pnl == total_pnl)&&(identical(other.total_pnl_pct, total_pnl_pct) || other.total_pnl_pct == total_pnl_pct)&&(identical(other.win_rate, win_rate) || other.win_rate == win_rate)&&(identical(other.sharpe_ratio, sharpe_ratio) || other.sharpe_ratio == sharpe_ratio)&&(identical(other.max_drawdown, max_drawdown) || other.max_drawdown == max_drawdown)&&(identical(other.total_trades, total_trades) || other.total_trades == total_trades)&&(identical(other.winning_trades, winning_trades) || other.winning_trades == winning_trades)&&(identical(other.losing_trades, losing_trades) || other.losing_trades == losing_trades)&&(identical(other.best_trade_pnl, best_trade_pnl) || other.best_trade_pnl == best_trade_pnl)&&(identical(other.worst_trade_pnl, worst_trade_pnl) || other.worst_trade_pnl == worst_trade_pnl)&&(identical(other.avg_holding_days, avg_holding_days) || other.avg_holding_days == avg_holding_days)&&(identical(other.market_return_pct, market_return_pct) || other.market_return_pct == market_return_pct)&&(identical(other.buy_hold_return_pct, buy_hold_return_pct) || other.buy_hold_return_pct == buy_hold_return_pct)&&(identical(other.summary_narrative, summary_narrative) || other.summary_narrative == summary_narrative)&&const DeepCollectionEquality().equals(other.what_you_did_right, what_you_did_right)&&const DeepCollectionEquality().equals(other.what_you_did_wrong, what_you_did_wrong)&&const DeepCollectionEquality().equals(other.what_you_could_have_done, what_you_could_have_done)&&const DeepCollectionEquality().equals(other.trade_by_trade_commentary, trade_by_trade_commentary)&&(identical(other.timing_score, timing_score) || other.timing_score == timing_score)&&(identical(other.selection_score, selection_score) || other.selection_score == selection_score)&&(identical(other.risk_score, risk_score) || other.risk_score == risk_score)&&(identical(other.patience_score, patience_score) || other.patience_score == patience_score)&&(identical(other.llm_provider, llm_provider) || other.llm_provider == llm_provider)&&(identical(other.created_at, created_at) || other.created_at == created_at)&&(identical(other.completed_at, completed_at) || other.completed_at == completed_at));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hashAll([runtimeType,id,simulation_id,status,total_pnl,total_pnl_pct,win_rate,sharpe_ratio,max_drawdown,total_trades,winning_trades,losing_trades,best_trade_pnl,worst_trade_pnl,avg_holding_days,market_return_pct,buy_hold_return_pct,summary_narrative,const DeepCollectionEquality().hash(what_you_did_right),const DeepCollectionEquality().hash(what_you_did_wrong),const DeepCollectionEquality().hash(what_you_could_have_done),const DeepCollectionEquality().hash(trade_by_trade_commentary),timing_score,selection_score,risk_score,patience_score,llm_provider,created_at,completed_at]);

@override
String toString() {
  return 'AIAnalysisResponse(id: $id, simulation_id: $simulation_id, status: $status, total_pnl: $total_pnl, total_pnl_pct: $total_pnl_pct, win_rate: $win_rate, sharpe_ratio: $sharpe_ratio, max_drawdown: $max_drawdown, total_trades: $total_trades, winning_trades: $winning_trades, losing_trades: $losing_trades, best_trade_pnl: $best_trade_pnl, worst_trade_pnl: $worst_trade_pnl, avg_holding_days: $avg_holding_days, market_return_pct: $market_return_pct, buy_hold_return_pct: $buy_hold_return_pct, summary_narrative: $summary_narrative, what_you_did_right: $what_you_did_right, what_you_did_wrong: $what_you_did_wrong, what_you_could_have_done: $what_you_could_have_done, trade_by_trade_commentary: $trade_by_trade_commentary, timing_score: $timing_score, selection_score: $selection_score, risk_score: $risk_score, patience_score: $patience_score, llm_provider: $llm_provider, created_at: $created_at, completed_at: $completed_at)';
}


}

/// @nodoc
abstract mixin class $AIAnalysisResponseCopyWith<$Res>  {
  factory $AIAnalysisResponseCopyWith(AIAnalysisResponse value, $Res Function(AIAnalysisResponse) _then) = _$AIAnalysisResponseCopyWithImpl;
@useResult
$Res call({
 int id, int simulation_id, String status, double? total_pnl, double? total_pnl_pct, double? win_rate, double? sharpe_ratio, double? max_drawdown, int? total_trades, int? winning_trades, int? losing_trades, double? best_trade_pnl, double? worst_trade_pnl, double? avg_holding_days, double? market_return_pct, double? buy_hold_return_pct, String? summary_narrative, List<AnalysisSection>? what_you_did_right, List<AnalysisSection>? what_you_did_wrong, List<AnalysisSection>? what_you_could_have_done, List<TradeCommentary>? trade_by_trade_commentary, double? timing_score, double? selection_score, double? risk_score, double? patience_score, String? llm_provider, String? created_at, String? completed_at
});




}
/// @nodoc
class _$AIAnalysisResponseCopyWithImpl<$Res>
    implements $AIAnalysisResponseCopyWith<$Res> {
  _$AIAnalysisResponseCopyWithImpl(this._self, this._then);

  final AIAnalysisResponse _self;
  final $Res Function(AIAnalysisResponse) _then;

/// Create a copy of AIAnalysisResponse
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? simulation_id = null,Object? status = null,Object? total_pnl = freezed,Object? total_pnl_pct = freezed,Object? win_rate = freezed,Object? sharpe_ratio = freezed,Object? max_drawdown = freezed,Object? total_trades = freezed,Object? winning_trades = freezed,Object? losing_trades = freezed,Object? best_trade_pnl = freezed,Object? worst_trade_pnl = freezed,Object? avg_holding_days = freezed,Object? market_return_pct = freezed,Object? buy_hold_return_pct = freezed,Object? summary_narrative = freezed,Object? what_you_did_right = freezed,Object? what_you_did_wrong = freezed,Object? what_you_could_have_done = freezed,Object? trade_by_trade_commentary = freezed,Object? timing_score = freezed,Object? selection_score = freezed,Object? risk_score = freezed,Object? patience_score = freezed,Object? llm_provider = freezed,Object? created_at = freezed,Object? completed_at = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,simulation_id: null == simulation_id ? _self.simulation_id : simulation_id // ignore: cast_nullable_to_non_nullable
as int,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String,total_pnl: freezed == total_pnl ? _self.total_pnl : total_pnl // ignore: cast_nullable_to_non_nullable
as double?,total_pnl_pct: freezed == total_pnl_pct ? _self.total_pnl_pct : total_pnl_pct // ignore: cast_nullable_to_non_nullable
as double?,win_rate: freezed == win_rate ? _self.win_rate : win_rate // ignore: cast_nullable_to_non_nullable
as double?,sharpe_ratio: freezed == sharpe_ratio ? _self.sharpe_ratio : sharpe_ratio // ignore: cast_nullable_to_non_nullable
as double?,max_drawdown: freezed == max_drawdown ? _self.max_drawdown : max_drawdown // ignore: cast_nullable_to_non_nullable
as double?,total_trades: freezed == total_trades ? _self.total_trades : total_trades // ignore: cast_nullable_to_non_nullable
as int?,winning_trades: freezed == winning_trades ? _self.winning_trades : winning_trades // ignore: cast_nullable_to_non_nullable
as int?,losing_trades: freezed == losing_trades ? _self.losing_trades : losing_trades // ignore: cast_nullable_to_non_nullable
as int?,best_trade_pnl: freezed == best_trade_pnl ? _self.best_trade_pnl : best_trade_pnl // ignore: cast_nullable_to_non_nullable
as double?,worst_trade_pnl: freezed == worst_trade_pnl ? _self.worst_trade_pnl : worst_trade_pnl // ignore: cast_nullable_to_non_nullable
as double?,avg_holding_days: freezed == avg_holding_days ? _self.avg_holding_days : avg_holding_days // ignore: cast_nullable_to_non_nullable
as double?,market_return_pct: freezed == market_return_pct ? _self.market_return_pct : market_return_pct // ignore: cast_nullable_to_non_nullable
as double?,buy_hold_return_pct: freezed == buy_hold_return_pct ? _self.buy_hold_return_pct : buy_hold_return_pct // ignore: cast_nullable_to_non_nullable
as double?,summary_narrative: freezed == summary_narrative ? _self.summary_narrative : summary_narrative // ignore: cast_nullable_to_non_nullable
as String?,what_you_did_right: freezed == what_you_did_right ? _self.what_you_did_right : what_you_did_right // ignore: cast_nullable_to_non_nullable
as List<AnalysisSection>?,what_you_did_wrong: freezed == what_you_did_wrong ? _self.what_you_did_wrong : what_you_did_wrong // ignore: cast_nullable_to_non_nullable
as List<AnalysisSection>?,what_you_could_have_done: freezed == what_you_could_have_done ? _self.what_you_could_have_done : what_you_could_have_done // ignore: cast_nullable_to_non_nullable
as List<AnalysisSection>?,trade_by_trade_commentary: freezed == trade_by_trade_commentary ? _self.trade_by_trade_commentary : trade_by_trade_commentary // ignore: cast_nullable_to_non_nullable
as List<TradeCommentary>?,timing_score: freezed == timing_score ? _self.timing_score : timing_score // ignore: cast_nullable_to_non_nullable
as double?,selection_score: freezed == selection_score ? _self.selection_score : selection_score // ignore: cast_nullable_to_non_nullable
as double?,risk_score: freezed == risk_score ? _self.risk_score : risk_score // ignore: cast_nullable_to_non_nullable
as double?,patience_score: freezed == patience_score ? _self.patience_score : patience_score // ignore: cast_nullable_to_non_nullable
as double?,llm_provider: freezed == llm_provider ? _self.llm_provider : llm_provider // ignore: cast_nullable_to_non_nullable
as String?,created_at: freezed == created_at ? _self.created_at : created_at // ignore: cast_nullable_to_non_nullable
as String?,completed_at: freezed == completed_at ? _self.completed_at : completed_at // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [AIAnalysisResponse].
extension AIAnalysisResponsePatterns on AIAnalysisResponse {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _AIAnalysisResponse value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _AIAnalysisResponse() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _AIAnalysisResponse value)  $default,){
final _that = this;
switch (_that) {
case _AIAnalysisResponse():
return $default(_that);}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _AIAnalysisResponse value)?  $default,){
final _that = this;
switch (_that) {
case _AIAnalysisResponse() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int id,  int simulation_id,  String status,  double? total_pnl,  double? total_pnl_pct,  double? win_rate,  double? sharpe_ratio,  double? max_drawdown,  int? total_trades,  int? winning_trades,  int? losing_trades,  double? best_trade_pnl,  double? worst_trade_pnl,  double? avg_holding_days,  double? market_return_pct,  double? buy_hold_return_pct,  String? summary_narrative,  List<AnalysisSection>? what_you_did_right,  List<AnalysisSection>? what_you_did_wrong,  List<AnalysisSection>? what_you_could_have_done,  List<TradeCommentary>? trade_by_trade_commentary,  double? timing_score,  double? selection_score,  double? risk_score,  double? patience_score,  String? llm_provider,  String? created_at,  String? completed_at)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _AIAnalysisResponse() when $default != null:
return $default(_that.id,_that.simulation_id,_that.status,_that.total_pnl,_that.total_pnl_pct,_that.win_rate,_that.sharpe_ratio,_that.max_drawdown,_that.total_trades,_that.winning_trades,_that.losing_trades,_that.best_trade_pnl,_that.worst_trade_pnl,_that.avg_holding_days,_that.market_return_pct,_that.buy_hold_return_pct,_that.summary_narrative,_that.what_you_did_right,_that.what_you_did_wrong,_that.what_you_could_have_done,_that.trade_by_trade_commentary,_that.timing_score,_that.selection_score,_that.risk_score,_that.patience_score,_that.llm_provider,_that.created_at,_that.completed_at);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int id,  int simulation_id,  String status,  double? total_pnl,  double? total_pnl_pct,  double? win_rate,  double? sharpe_ratio,  double? max_drawdown,  int? total_trades,  int? winning_trades,  int? losing_trades,  double? best_trade_pnl,  double? worst_trade_pnl,  double? avg_holding_days,  double? market_return_pct,  double? buy_hold_return_pct,  String? summary_narrative,  List<AnalysisSection>? what_you_did_right,  List<AnalysisSection>? what_you_did_wrong,  List<AnalysisSection>? what_you_could_have_done,  List<TradeCommentary>? trade_by_trade_commentary,  double? timing_score,  double? selection_score,  double? risk_score,  double? patience_score,  String? llm_provider,  String? created_at,  String? completed_at)  $default,) {final _that = this;
switch (_that) {
case _AIAnalysisResponse():
return $default(_that.id,_that.simulation_id,_that.status,_that.total_pnl,_that.total_pnl_pct,_that.win_rate,_that.sharpe_ratio,_that.max_drawdown,_that.total_trades,_that.winning_trades,_that.losing_trades,_that.best_trade_pnl,_that.worst_trade_pnl,_that.avg_holding_days,_that.market_return_pct,_that.buy_hold_return_pct,_that.summary_narrative,_that.what_you_did_right,_that.what_you_did_wrong,_that.what_you_could_have_done,_that.trade_by_trade_commentary,_that.timing_score,_that.selection_score,_that.risk_score,_that.patience_score,_that.llm_provider,_that.created_at,_that.completed_at);}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int id,  int simulation_id,  String status,  double? total_pnl,  double? total_pnl_pct,  double? win_rate,  double? sharpe_ratio,  double? max_drawdown,  int? total_trades,  int? winning_trades,  int? losing_trades,  double? best_trade_pnl,  double? worst_trade_pnl,  double? avg_holding_days,  double? market_return_pct,  double? buy_hold_return_pct,  String? summary_narrative,  List<AnalysisSection>? what_you_did_right,  List<AnalysisSection>? what_you_did_wrong,  List<AnalysisSection>? what_you_could_have_done,  List<TradeCommentary>? trade_by_trade_commentary,  double? timing_score,  double? selection_score,  double? risk_score,  double? patience_score,  String? llm_provider,  String? created_at,  String? completed_at)?  $default,) {final _that = this;
switch (_that) {
case _AIAnalysisResponse() when $default != null:
return $default(_that.id,_that.simulation_id,_that.status,_that.total_pnl,_that.total_pnl_pct,_that.win_rate,_that.sharpe_ratio,_that.max_drawdown,_that.total_trades,_that.winning_trades,_that.losing_trades,_that.best_trade_pnl,_that.worst_trade_pnl,_that.avg_holding_days,_that.market_return_pct,_that.buy_hold_return_pct,_that.summary_narrative,_that.what_you_did_right,_that.what_you_did_wrong,_that.what_you_could_have_done,_that.trade_by_trade_commentary,_that.timing_score,_that.selection_score,_that.risk_score,_that.patience_score,_that.llm_provider,_that.created_at,_that.completed_at);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _AIAnalysisResponse implements AIAnalysisResponse {
  const _AIAnalysisResponse({required this.id, required this.simulation_id, required this.status, this.total_pnl, this.total_pnl_pct, this.win_rate, this.sharpe_ratio, this.max_drawdown, this.total_trades, this.winning_trades, this.losing_trades, this.best_trade_pnl, this.worst_trade_pnl, this.avg_holding_days, this.market_return_pct, this.buy_hold_return_pct, this.summary_narrative, final  List<AnalysisSection>? what_you_did_right, final  List<AnalysisSection>? what_you_did_wrong, final  List<AnalysisSection>? what_you_could_have_done, final  List<TradeCommentary>? trade_by_trade_commentary, this.timing_score, this.selection_score, this.risk_score, this.patience_score, this.llm_provider, this.created_at, this.completed_at}): _what_you_did_right = what_you_did_right,_what_you_did_wrong = what_you_did_wrong,_what_you_could_have_done = what_you_could_have_done,_trade_by_trade_commentary = trade_by_trade_commentary;
  factory _AIAnalysisResponse.fromJson(Map<String, dynamic> json) => _$AIAnalysisResponseFromJson(json);

@override final  int id;
@override final  int simulation_id;
@override final  String status;
// Metrics
@override final  double? total_pnl;
@override final  double? total_pnl_pct;
@override final  double? win_rate;
@override final  double? sharpe_ratio;
@override final  double? max_drawdown;
@override final  int? total_trades;
@override final  int? winning_trades;
@override final  int? losing_trades;
@override final  double? best_trade_pnl;
@override final  double? worst_trade_pnl;
@override final  double? avg_holding_days;
// Benchmarks
@override final  double? market_return_pct;
@override final  double? buy_hold_return_pct;
@override final  String? summary_narrative;
 final  List<AnalysisSection>? _what_you_did_right;
@override List<AnalysisSection>? get what_you_did_right {
  final value = _what_you_did_right;
  if (value == null) return null;
  if (_what_you_did_right is EqualUnmodifiableListView) return _what_you_did_right;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(value);
}

 final  List<AnalysisSection>? _what_you_did_wrong;
@override List<AnalysisSection>? get what_you_did_wrong {
  final value = _what_you_did_wrong;
  if (value == null) return null;
  if (_what_you_did_wrong is EqualUnmodifiableListView) return _what_you_did_wrong;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(value);
}

 final  List<AnalysisSection>? _what_you_could_have_done;
@override List<AnalysisSection>? get what_you_could_have_done {
  final value = _what_you_could_have_done;
  if (value == null) return null;
  if (_what_you_could_have_done is EqualUnmodifiableListView) return _what_you_could_have_done;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(value);
}

 final  List<TradeCommentary>? _trade_by_trade_commentary;
@override List<TradeCommentary>? get trade_by_trade_commentary {
  final value = _trade_by_trade_commentary;
  if (value == null) return null;
  if (_trade_by_trade_commentary is EqualUnmodifiableListView) return _trade_by_trade_commentary;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(value);
}

@override final  double? timing_score;
@override final  double? selection_score;
@override final  double? risk_score;
@override final  double? patience_score;
@override final  String? llm_provider;
@override final  String? created_at;
@override final  String? completed_at;

/// Create a copy of AIAnalysisResponse
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$AIAnalysisResponseCopyWith<_AIAnalysisResponse> get copyWith => __$AIAnalysisResponseCopyWithImpl<_AIAnalysisResponse>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$AIAnalysisResponseToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _AIAnalysisResponse&&(identical(other.id, id) || other.id == id)&&(identical(other.simulation_id, simulation_id) || other.simulation_id == simulation_id)&&(identical(other.status, status) || other.status == status)&&(identical(other.total_pnl, total_pnl) || other.total_pnl == total_pnl)&&(identical(other.total_pnl_pct, total_pnl_pct) || other.total_pnl_pct == total_pnl_pct)&&(identical(other.win_rate, win_rate) || other.win_rate == win_rate)&&(identical(other.sharpe_ratio, sharpe_ratio) || other.sharpe_ratio == sharpe_ratio)&&(identical(other.max_drawdown, max_drawdown) || other.max_drawdown == max_drawdown)&&(identical(other.total_trades, total_trades) || other.total_trades == total_trades)&&(identical(other.winning_trades, winning_trades) || other.winning_trades == winning_trades)&&(identical(other.losing_trades, losing_trades) || other.losing_trades == losing_trades)&&(identical(other.best_trade_pnl, best_trade_pnl) || other.best_trade_pnl == best_trade_pnl)&&(identical(other.worst_trade_pnl, worst_trade_pnl) || other.worst_trade_pnl == worst_trade_pnl)&&(identical(other.avg_holding_days, avg_holding_days) || other.avg_holding_days == avg_holding_days)&&(identical(other.market_return_pct, market_return_pct) || other.market_return_pct == market_return_pct)&&(identical(other.buy_hold_return_pct, buy_hold_return_pct) || other.buy_hold_return_pct == buy_hold_return_pct)&&(identical(other.summary_narrative, summary_narrative) || other.summary_narrative == summary_narrative)&&const DeepCollectionEquality().equals(other._what_you_did_right, _what_you_did_right)&&const DeepCollectionEquality().equals(other._what_you_did_wrong, _what_you_did_wrong)&&const DeepCollectionEquality().equals(other._what_you_could_have_done, _what_you_could_have_done)&&const DeepCollectionEquality().equals(other._trade_by_trade_commentary, _trade_by_trade_commentary)&&(identical(other.timing_score, timing_score) || other.timing_score == timing_score)&&(identical(other.selection_score, selection_score) || other.selection_score == selection_score)&&(identical(other.risk_score, risk_score) || other.risk_score == risk_score)&&(identical(other.patience_score, patience_score) || other.patience_score == patience_score)&&(identical(other.llm_provider, llm_provider) || other.llm_provider == llm_provider)&&(identical(other.created_at, created_at) || other.created_at == created_at)&&(identical(other.completed_at, completed_at) || other.completed_at == completed_at));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hashAll([runtimeType,id,simulation_id,status,total_pnl,total_pnl_pct,win_rate,sharpe_ratio,max_drawdown,total_trades,winning_trades,losing_trades,best_trade_pnl,worst_trade_pnl,avg_holding_days,market_return_pct,buy_hold_return_pct,summary_narrative,const DeepCollectionEquality().hash(_what_you_did_right),const DeepCollectionEquality().hash(_what_you_did_wrong),const DeepCollectionEquality().hash(_what_you_could_have_done),const DeepCollectionEquality().hash(_trade_by_trade_commentary),timing_score,selection_score,risk_score,patience_score,llm_provider,created_at,completed_at]);

@override
String toString() {
  return 'AIAnalysisResponse(id: $id, simulation_id: $simulation_id, status: $status, total_pnl: $total_pnl, total_pnl_pct: $total_pnl_pct, win_rate: $win_rate, sharpe_ratio: $sharpe_ratio, max_drawdown: $max_drawdown, total_trades: $total_trades, winning_trades: $winning_trades, losing_trades: $losing_trades, best_trade_pnl: $best_trade_pnl, worst_trade_pnl: $worst_trade_pnl, avg_holding_days: $avg_holding_days, market_return_pct: $market_return_pct, buy_hold_return_pct: $buy_hold_return_pct, summary_narrative: $summary_narrative, what_you_did_right: $what_you_did_right, what_you_did_wrong: $what_you_did_wrong, what_you_could_have_done: $what_you_could_have_done, trade_by_trade_commentary: $trade_by_trade_commentary, timing_score: $timing_score, selection_score: $selection_score, risk_score: $risk_score, patience_score: $patience_score, llm_provider: $llm_provider, created_at: $created_at, completed_at: $completed_at)';
}


}

/// @nodoc
abstract mixin class _$AIAnalysisResponseCopyWith<$Res> implements $AIAnalysisResponseCopyWith<$Res> {
  factory _$AIAnalysisResponseCopyWith(_AIAnalysisResponse value, $Res Function(_AIAnalysisResponse) _then) = __$AIAnalysisResponseCopyWithImpl;
@override @useResult
$Res call({
 int id, int simulation_id, String status, double? total_pnl, double? total_pnl_pct, double? win_rate, double? sharpe_ratio, double? max_drawdown, int? total_trades, int? winning_trades, int? losing_trades, double? best_trade_pnl, double? worst_trade_pnl, double? avg_holding_days, double? market_return_pct, double? buy_hold_return_pct, String? summary_narrative, List<AnalysisSection>? what_you_did_right, List<AnalysisSection>? what_you_did_wrong, List<AnalysisSection>? what_you_could_have_done, List<TradeCommentary>? trade_by_trade_commentary, double? timing_score, double? selection_score, double? risk_score, double? patience_score, String? llm_provider, String? created_at, String? completed_at
});




}
/// @nodoc
class __$AIAnalysisResponseCopyWithImpl<$Res>
    implements _$AIAnalysisResponseCopyWith<$Res> {
  __$AIAnalysisResponseCopyWithImpl(this._self, this._then);

  final _AIAnalysisResponse _self;
  final $Res Function(_AIAnalysisResponse) _then;

/// Create a copy of AIAnalysisResponse
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? simulation_id = null,Object? status = null,Object? total_pnl = freezed,Object? total_pnl_pct = freezed,Object? win_rate = freezed,Object? sharpe_ratio = freezed,Object? max_drawdown = freezed,Object? total_trades = freezed,Object? winning_trades = freezed,Object? losing_trades = freezed,Object? best_trade_pnl = freezed,Object? worst_trade_pnl = freezed,Object? avg_holding_days = freezed,Object? market_return_pct = freezed,Object? buy_hold_return_pct = freezed,Object? summary_narrative = freezed,Object? what_you_did_right = freezed,Object? what_you_did_wrong = freezed,Object? what_you_could_have_done = freezed,Object? trade_by_trade_commentary = freezed,Object? timing_score = freezed,Object? selection_score = freezed,Object? risk_score = freezed,Object? patience_score = freezed,Object? llm_provider = freezed,Object? created_at = freezed,Object? completed_at = freezed,}) {
  return _then(_AIAnalysisResponse(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,simulation_id: null == simulation_id ? _self.simulation_id : simulation_id // ignore: cast_nullable_to_non_nullable
as int,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String,total_pnl: freezed == total_pnl ? _self.total_pnl : total_pnl // ignore: cast_nullable_to_non_nullable
as double?,total_pnl_pct: freezed == total_pnl_pct ? _self.total_pnl_pct : total_pnl_pct // ignore: cast_nullable_to_non_nullable
as double?,win_rate: freezed == win_rate ? _self.win_rate : win_rate // ignore: cast_nullable_to_non_nullable
as double?,sharpe_ratio: freezed == sharpe_ratio ? _self.sharpe_ratio : sharpe_ratio // ignore: cast_nullable_to_non_nullable
as double?,max_drawdown: freezed == max_drawdown ? _self.max_drawdown : max_drawdown // ignore: cast_nullable_to_non_nullable
as double?,total_trades: freezed == total_trades ? _self.total_trades : total_trades // ignore: cast_nullable_to_non_nullable
as int?,winning_trades: freezed == winning_trades ? _self.winning_trades : winning_trades // ignore: cast_nullable_to_non_nullable
as int?,losing_trades: freezed == losing_trades ? _self.losing_trades : losing_trades // ignore: cast_nullable_to_non_nullable
as int?,best_trade_pnl: freezed == best_trade_pnl ? _self.best_trade_pnl : best_trade_pnl // ignore: cast_nullable_to_non_nullable
as double?,worst_trade_pnl: freezed == worst_trade_pnl ? _self.worst_trade_pnl : worst_trade_pnl // ignore: cast_nullable_to_non_nullable
as double?,avg_holding_days: freezed == avg_holding_days ? _self.avg_holding_days : avg_holding_days // ignore: cast_nullable_to_non_nullable
as double?,market_return_pct: freezed == market_return_pct ? _self.market_return_pct : market_return_pct // ignore: cast_nullable_to_non_nullable
as double?,buy_hold_return_pct: freezed == buy_hold_return_pct ? _self.buy_hold_return_pct : buy_hold_return_pct // ignore: cast_nullable_to_non_nullable
as double?,summary_narrative: freezed == summary_narrative ? _self.summary_narrative : summary_narrative // ignore: cast_nullable_to_non_nullable
as String?,what_you_did_right: freezed == what_you_did_right ? _self._what_you_did_right : what_you_did_right // ignore: cast_nullable_to_non_nullable
as List<AnalysisSection>?,what_you_did_wrong: freezed == what_you_did_wrong ? _self._what_you_did_wrong : what_you_did_wrong // ignore: cast_nullable_to_non_nullable
as List<AnalysisSection>?,what_you_could_have_done: freezed == what_you_could_have_done ? _self._what_you_could_have_done : what_you_could_have_done // ignore: cast_nullable_to_non_nullable
as List<AnalysisSection>?,trade_by_trade_commentary: freezed == trade_by_trade_commentary ? _self._trade_by_trade_commentary : trade_by_trade_commentary // ignore: cast_nullable_to_non_nullable
as List<TradeCommentary>?,timing_score: freezed == timing_score ? _self.timing_score : timing_score // ignore: cast_nullable_to_non_nullable
as double?,selection_score: freezed == selection_score ? _self.selection_score : selection_score // ignore: cast_nullable_to_non_nullable
as double?,risk_score: freezed == risk_score ? _self.risk_score : risk_score // ignore: cast_nullable_to_non_nullable
as double?,patience_score: freezed == patience_score ? _self.patience_score : patience_score // ignore: cast_nullable_to_non_nullable
as double?,llm_provider: freezed == llm_provider ? _self.llm_provider : llm_provider // ignore: cast_nullable_to_non_nullable
as String?,created_at: freezed == created_at ? _self.created_at : created_at // ignore: cast_nullable_to_non_nullable
as String?,completed_at: freezed == completed_at ? _self.completed_at : completed_at // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
