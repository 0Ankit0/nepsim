// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'market_models.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$LatestQuoteResponse {

 String get symbol; String get date; double? get ltp; double? get open; double? get high; double? get low; double? get close; double? get prev_close; double? get diff; double? get diff_pct; double? get vwap; double? get vol; double? get turnover; double? get weeks_52_high; double? get weeks_52_low;
/// Create a copy of LatestQuoteResponse
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$LatestQuoteResponseCopyWith<LatestQuoteResponse> get copyWith => _$LatestQuoteResponseCopyWithImpl<LatestQuoteResponse>(this as LatestQuoteResponse, _$identity);

  /// Serializes this LatestQuoteResponse to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is LatestQuoteResponse&&(identical(other.symbol, symbol) || other.symbol == symbol)&&(identical(other.date, date) || other.date == date)&&(identical(other.ltp, ltp) || other.ltp == ltp)&&(identical(other.open, open) || other.open == open)&&(identical(other.high, high) || other.high == high)&&(identical(other.low, low) || other.low == low)&&(identical(other.close, close) || other.close == close)&&(identical(other.prev_close, prev_close) || other.prev_close == prev_close)&&(identical(other.diff, diff) || other.diff == diff)&&(identical(other.diff_pct, diff_pct) || other.diff_pct == diff_pct)&&(identical(other.vwap, vwap) || other.vwap == vwap)&&(identical(other.vol, vol) || other.vol == vol)&&(identical(other.turnover, turnover) || other.turnover == turnover)&&(identical(other.weeks_52_high, weeks_52_high) || other.weeks_52_high == weeks_52_high)&&(identical(other.weeks_52_low, weeks_52_low) || other.weeks_52_low == weeks_52_low));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,symbol,date,ltp,open,high,low,close,prev_close,diff,diff_pct,vwap,vol,turnover,weeks_52_high,weeks_52_low);

@override
String toString() {
  return 'LatestQuoteResponse(symbol: $symbol, date: $date, ltp: $ltp, open: $open, high: $high, low: $low, close: $close, prev_close: $prev_close, diff: $diff, diff_pct: $diff_pct, vwap: $vwap, vol: $vol, turnover: $turnover, weeks_52_high: $weeks_52_high, weeks_52_low: $weeks_52_low)';
}


}

/// @nodoc
abstract mixin class $LatestQuoteResponseCopyWith<$Res>  {
  factory $LatestQuoteResponseCopyWith(LatestQuoteResponse value, $Res Function(LatestQuoteResponse) _then) = _$LatestQuoteResponseCopyWithImpl;
@useResult
$Res call({
 String symbol, String date, double? ltp, double? open, double? high, double? low, double? close, double? prev_close, double? diff, double? diff_pct, double? vwap, double? vol, double? turnover, double? weeks_52_high, double? weeks_52_low
});




}
/// @nodoc
class _$LatestQuoteResponseCopyWithImpl<$Res>
    implements $LatestQuoteResponseCopyWith<$Res> {
  _$LatestQuoteResponseCopyWithImpl(this._self, this._then);

  final LatestQuoteResponse _self;
  final $Res Function(LatestQuoteResponse) _then;

/// Create a copy of LatestQuoteResponse
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? symbol = null,Object? date = null,Object? ltp = freezed,Object? open = freezed,Object? high = freezed,Object? low = freezed,Object? close = freezed,Object? prev_close = freezed,Object? diff = freezed,Object? diff_pct = freezed,Object? vwap = freezed,Object? vol = freezed,Object? turnover = freezed,Object? weeks_52_high = freezed,Object? weeks_52_low = freezed,}) {
  return _then(_self.copyWith(
symbol: null == symbol ? _self.symbol : symbol // ignore: cast_nullable_to_non_nullable
as String,date: null == date ? _self.date : date // ignore: cast_nullable_to_non_nullable
as String,ltp: freezed == ltp ? _self.ltp : ltp // ignore: cast_nullable_to_non_nullable
as double?,open: freezed == open ? _self.open : open // ignore: cast_nullable_to_non_nullable
as double?,high: freezed == high ? _self.high : high // ignore: cast_nullable_to_non_nullable
as double?,low: freezed == low ? _self.low : low // ignore: cast_nullable_to_non_nullable
as double?,close: freezed == close ? _self.close : close // ignore: cast_nullable_to_non_nullable
as double?,prev_close: freezed == prev_close ? _self.prev_close : prev_close // ignore: cast_nullable_to_non_nullable
as double?,diff: freezed == diff ? _self.diff : diff // ignore: cast_nullable_to_non_nullable
as double?,diff_pct: freezed == diff_pct ? _self.diff_pct : diff_pct // ignore: cast_nullable_to_non_nullable
as double?,vwap: freezed == vwap ? _self.vwap : vwap // ignore: cast_nullable_to_non_nullable
as double?,vol: freezed == vol ? _self.vol : vol // ignore: cast_nullable_to_non_nullable
as double?,turnover: freezed == turnover ? _self.turnover : turnover // ignore: cast_nullable_to_non_nullable
as double?,weeks_52_high: freezed == weeks_52_high ? _self.weeks_52_high : weeks_52_high // ignore: cast_nullable_to_non_nullable
as double?,weeks_52_low: freezed == weeks_52_low ? _self.weeks_52_low : weeks_52_low // ignore: cast_nullable_to_non_nullable
as double?,
  ));
}

}


/// Adds pattern-matching-related methods to [LatestQuoteResponse].
extension LatestQuoteResponsePatterns on LatestQuoteResponse {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _LatestQuoteResponse value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _LatestQuoteResponse() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _LatestQuoteResponse value)  $default,){
final _that = this;
switch (_that) {
case _LatestQuoteResponse():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _LatestQuoteResponse value)?  $default,){
final _that = this;
switch (_that) {
case _LatestQuoteResponse() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String symbol,  String date,  double? ltp,  double? open,  double? high,  double? low,  double? close,  double? prev_close,  double? diff,  double? diff_pct,  double? vwap,  double? vol,  double? turnover,  double? weeks_52_high,  double? weeks_52_low)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _LatestQuoteResponse() when $default != null:
return $default(_that.symbol,_that.date,_that.ltp,_that.open,_that.high,_that.low,_that.close,_that.prev_close,_that.diff,_that.diff_pct,_that.vwap,_that.vol,_that.turnover,_that.weeks_52_high,_that.weeks_52_low);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String symbol,  String date,  double? ltp,  double? open,  double? high,  double? low,  double? close,  double? prev_close,  double? diff,  double? diff_pct,  double? vwap,  double? vol,  double? turnover,  double? weeks_52_high,  double? weeks_52_low)  $default,) {final _that = this;
switch (_that) {
case _LatestQuoteResponse():
return $default(_that.symbol,_that.date,_that.ltp,_that.open,_that.high,_that.low,_that.close,_that.prev_close,_that.diff,_that.diff_pct,_that.vwap,_that.vol,_that.turnover,_that.weeks_52_high,_that.weeks_52_low);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String symbol,  String date,  double? ltp,  double? open,  double? high,  double? low,  double? close,  double? prev_close,  double? diff,  double? diff_pct,  double? vwap,  double? vol,  double? turnover,  double? weeks_52_high,  double? weeks_52_low)?  $default,) {final _that = this;
switch (_that) {
case _LatestQuoteResponse() when $default != null:
return $default(_that.symbol,_that.date,_that.ltp,_that.open,_that.high,_that.low,_that.close,_that.prev_close,_that.diff,_that.diff_pct,_that.vwap,_that.vol,_that.turnover,_that.weeks_52_high,_that.weeks_52_low);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _LatestQuoteResponse implements LatestQuoteResponse {
  const _LatestQuoteResponse({required this.symbol, required this.date, this.ltp, this.open, this.high, this.low, this.close, this.prev_close, this.diff, this.diff_pct, this.vwap, this.vol, this.turnover, this.weeks_52_high, this.weeks_52_low});
  factory _LatestQuoteResponse.fromJson(Map<String, dynamic> json) => _$LatestQuoteResponseFromJson(json);

@override final  String symbol;
@override final  String date;
@override final  double? ltp;
@override final  double? open;
@override final  double? high;
@override final  double? low;
@override final  double? close;
@override final  double? prev_close;
@override final  double? diff;
@override final  double? diff_pct;
@override final  double? vwap;
@override final  double? vol;
@override final  double? turnover;
@override final  double? weeks_52_high;
@override final  double? weeks_52_low;

/// Create a copy of LatestQuoteResponse
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$LatestQuoteResponseCopyWith<_LatestQuoteResponse> get copyWith => __$LatestQuoteResponseCopyWithImpl<_LatestQuoteResponse>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$LatestQuoteResponseToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _LatestQuoteResponse&&(identical(other.symbol, symbol) || other.symbol == symbol)&&(identical(other.date, date) || other.date == date)&&(identical(other.ltp, ltp) || other.ltp == ltp)&&(identical(other.open, open) || other.open == open)&&(identical(other.high, high) || other.high == high)&&(identical(other.low, low) || other.low == low)&&(identical(other.close, close) || other.close == close)&&(identical(other.prev_close, prev_close) || other.prev_close == prev_close)&&(identical(other.diff, diff) || other.diff == diff)&&(identical(other.diff_pct, diff_pct) || other.diff_pct == diff_pct)&&(identical(other.vwap, vwap) || other.vwap == vwap)&&(identical(other.vol, vol) || other.vol == vol)&&(identical(other.turnover, turnover) || other.turnover == turnover)&&(identical(other.weeks_52_high, weeks_52_high) || other.weeks_52_high == weeks_52_high)&&(identical(other.weeks_52_low, weeks_52_low) || other.weeks_52_low == weeks_52_low));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,symbol,date,ltp,open,high,low,close,prev_close,diff,diff_pct,vwap,vol,turnover,weeks_52_high,weeks_52_low);

@override
String toString() {
  return 'LatestQuoteResponse(symbol: $symbol, date: $date, ltp: $ltp, open: $open, high: $high, low: $low, close: $close, prev_close: $prev_close, diff: $diff, diff_pct: $diff_pct, vwap: $vwap, vol: $vol, turnover: $turnover, weeks_52_high: $weeks_52_high, weeks_52_low: $weeks_52_low)';
}


}

/// @nodoc
abstract mixin class _$LatestQuoteResponseCopyWith<$Res> implements $LatestQuoteResponseCopyWith<$Res> {
  factory _$LatestQuoteResponseCopyWith(_LatestQuoteResponse value, $Res Function(_LatestQuoteResponse) _then) = __$LatestQuoteResponseCopyWithImpl;
@override @useResult
$Res call({
 String symbol, String date, double? ltp, double? open, double? high, double? low, double? close, double? prev_close, double? diff, double? diff_pct, double? vwap, double? vol, double? turnover, double? weeks_52_high, double? weeks_52_low
});




}
/// @nodoc
class __$LatestQuoteResponseCopyWithImpl<$Res>
    implements _$LatestQuoteResponseCopyWith<$Res> {
  __$LatestQuoteResponseCopyWithImpl(this._self, this._then);

  final _LatestQuoteResponse _self;
  final $Res Function(_LatestQuoteResponse) _then;

/// Create a copy of LatestQuoteResponse
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? symbol = null,Object? date = null,Object? ltp = freezed,Object? open = freezed,Object? high = freezed,Object? low = freezed,Object? close = freezed,Object? prev_close = freezed,Object? diff = freezed,Object? diff_pct = freezed,Object? vwap = freezed,Object? vol = freezed,Object? turnover = freezed,Object? weeks_52_high = freezed,Object? weeks_52_low = freezed,}) {
  return _then(_LatestQuoteResponse(
symbol: null == symbol ? _self.symbol : symbol // ignore: cast_nullable_to_non_nullable
as String,date: null == date ? _self.date : date // ignore: cast_nullable_to_non_nullable
as String,ltp: freezed == ltp ? _self.ltp : ltp // ignore: cast_nullable_to_non_nullable
as double?,open: freezed == open ? _self.open : open // ignore: cast_nullable_to_non_nullable
as double?,high: freezed == high ? _self.high : high // ignore: cast_nullable_to_non_nullable
as double?,low: freezed == low ? _self.low : low // ignore: cast_nullable_to_non_nullable
as double?,close: freezed == close ? _self.close : close // ignore: cast_nullable_to_non_nullable
as double?,prev_close: freezed == prev_close ? _self.prev_close : prev_close // ignore: cast_nullable_to_non_nullable
as double?,diff: freezed == diff ? _self.diff : diff // ignore: cast_nullable_to_non_nullable
as double?,diff_pct: freezed == diff_pct ? _self.diff_pct : diff_pct // ignore: cast_nullable_to_non_nullable
as double?,vwap: freezed == vwap ? _self.vwap : vwap // ignore: cast_nullable_to_non_nullable
as double?,vol: freezed == vol ? _self.vol : vol // ignore: cast_nullable_to_non_nullable
as double?,turnover: freezed == turnover ? _self.turnover : turnover // ignore: cast_nullable_to_non_nullable
as double?,weeks_52_high: freezed == weeks_52_high ? _self.weeks_52_high : weeks_52_high // ignore: cast_nullable_to_non_nullable
as double?,weeks_52_low: freezed == weeks_52_low ? _self.weeks_52_low : weeks_52_low // ignore: cast_nullable_to_non_nullable
as double?,
  ));
}


}


/// @nodoc
mixin _$HistoricDataRow {

 String get date; double? get open; double? get high; double? get low; double? get close; double? get vol;
/// Create a copy of HistoricDataRow
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$HistoricDataRowCopyWith<HistoricDataRow> get copyWith => _$HistoricDataRowCopyWithImpl<HistoricDataRow>(this as HistoricDataRow, _$identity);

  /// Serializes this HistoricDataRow to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is HistoricDataRow&&(identical(other.date, date) || other.date == date)&&(identical(other.open, open) || other.open == open)&&(identical(other.high, high) || other.high == high)&&(identical(other.low, low) || other.low == low)&&(identical(other.close, close) || other.close == close)&&(identical(other.vol, vol) || other.vol == vol));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,date,open,high,low,close,vol);

@override
String toString() {
  return 'HistoricDataRow(date: $date, open: $open, high: $high, low: $low, close: $close, vol: $vol)';
}


}

/// @nodoc
abstract mixin class $HistoricDataRowCopyWith<$Res>  {
  factory $HistoricDataRowCopyWith(HistoricDataRow value, $Res Function(HistoricDataRow) _then) = _$HistoricDataRowCopyWithImpl;
@useResult
$Res call({
 String date, double? open, double? high, double? low, double? close, double? vol
});




}
/// @nodoc
class _$HistoricDataRowCopyWithImpl<$Res>
    implements $HistoricDataRowCopyWith<$Res> {
  _$HistoricDataRowCopyWithImpl(this._self, this._then);

  final HistoricDataRow _self;
  final $Res Function(HistoricDataRow) _then;

/// Create a copy of HistoricDataRow
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? date = null,Object? open = freezed,Object? high = freezed,Object? low = freezed,Object? close = freezed,Object? vol = freezed,}) {
  return _then(_self.copyWith(
date: null == date ? _self.date : date // ignore: cast_nullable_to_non_nullable
as String,open: freezed == open ? _self.open : open // ignore: cast_nullable_to_non_nullable
as double?,high: freezed == high ? _self.high : high // ignore: cast_nullable_to_non_nullable
as double?,low: freezed == low ? _self.low : low // ignore: cast_nullable_to_non_nullable
as double?,close: freezed == close ? _self.close : close // ignore: cast_nullable_to_non_nullable
as double?,vol: freezed == vol ? _self.vol : vol // ignore: cast_nullable_to_non_nullable
as double?,
  ));
}

}


/// Adds pattern-matching-related methods to [HistoricDataRow].
extension HistoricDataRowPatterns on HistoricDataRow {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _HistoricDataRow value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _HistoricDataRow() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _HistoricDataRow value)  $default,){
final _that = this;
switch (_that) {
case _HistoricDataRow():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _HistoricDataRow value)?  $default,){
final _that = this;
switch (_that) {
case _HistoricDataRow() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String date,  double? open,  double? high,  double? low,  double? close,  double? vol)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _HistoricDataRow() when $default != null:
return $default(_that.date,_that.open,_that.high,_that.low,_that.close,_that.vol);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String date,  double? open,  double? high,  double? low,  double? close,  double? vol)  $default,) {final _that = this;
switch (_that) {
case _HistoricDataRow():
return $default(_that.date,_that.open,_that.high,_that.low,_that.close,_that.vol);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String date,  double? open,  double? high,  double? low,  double? close,  double? vol)?  $default,) {final _that = this;
switch (_that) {
case _HistoricDataRow() when $default != null:
return $default(_that.date,_that.open,_that.high,_that.low,_that.close,_that.vol);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _HistoricDataRow implements HistoricDataRow {
  const _HistoricDataRow({required this.date, this.open, this.high, this.low, this.close, this.vol});
  factory _HistoricDataRow.fromJson(Map<String, dynamic> json) => _$HistoricDataRowFromJson(json);

@override final  String date;
@override final  double? open;
@override final  double? high;
@override final  double? low;
@override final  double? close;
@override final  double? vol;

/// Create a copy of HistoricDataRow
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$HistoricDataRowCopyWith<_HistoricDataRow> get copyWith => __$HistoricDataRowCopyWithImpl<_HistoricDataRow>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$HistoricDataRowToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _HistoricDataRow&&(identical(other.date, date) || other.date == date)&&(identical(other.open, open) || other.open == open)&&(identical(other.high, high) || other.high == high)&&(identical(other.low, low) || other.low == low)&&(identical(other.close, close) || other.close == close)&&(identical(other.vol, vol) || other.vol == vol));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,date,open,high,low,close,vol);

@override
String toString() {
  return 'HistoricDataRow(date: $date, open: $open, high: $high, low: $low, close: $close, vol: $vol)';
}


}

/// @nodoc
abstract mixin class _$HistoricDataRowCopyWith<$Res> implements $HistoricDataRowCopyWith<$Res> {
  factory _$HistoricDataRowCopyWith(_HistoricDataRow value, $Res Function(_HistoricDataRow) _then) = __$HistoricDataRowCopyWithImpl;
@override @useResult
$Res call({
 String date, double? open, double? high, double? low, double? close, double? vol
});




}
/// @nodoc
class __$HistoricDataRowCopyWithImpl<$Res>
    implements _$HistoricDataRowCopyWith<$Res> {
  __$HistoricDataRowCopyWithImpl(this._self, this._then);

  final _HistoricDataRow _self;
  final $Res Function(_HistoricDataRow) _then;

/// Create a copy of HistoricDataRow
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? date = null,Object? open = freezed,Object? high = freezed,Object? low = freezed,Object? close = freezed,Object? vol = freezed,}) {
  return _then(_HistoricDataRow(
date: null == date ? _self.date : date // ignore: cast_nullable_to_non_nullable
as String,open: freezed == open ? _self.open : open // ignore: cast_nullable_to_non_nullable
as double?,high: freezed == high ? _self.high : high // ignore: cast_nullable_to_non_nullable
as double?,low: freezed == low ? _self.low : low // ignore: cast_nullable_to_non_nullable
as double?,close: freezed == close ? _self.close : close // ignore: cast_nullable_to_non_nullable
as double?,vol: freezed == vol ? _self.vol : vol // ignore: cast_nullable_to_non_nullable
as double?,
  ));
}


}


/// @nodoc
mixin _$HistoricDataResponse {

 String get symbol; int get count; List<HistoricDataRow> get data;
/// Create a copy of HistoricDataResponse
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$HistoricDataResponseCopyWith<HistoricDataResponse> get copyWith => _$HistoricDataResponseCopyWithImpl<HistoricDataResponse>(this as HistoricDataResponse, _$identity);

  /// Serializes this HistoricDataResponse to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is HistoricDataResponse&&(identical(other.symbol, symbol) || other.symbol == symbol)&&(identical(other.count, count) || other.count == count)&&const DeepCollectionEquality().equals(other.data, data));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,symbol,count,const DeepCollectionEquality().hash(data));

@override
String toString() {
  return 'HistoricDataResponse(symbol: $symbol, count: $count, data: $data)';
}


}

/// @nodoc
abstract mixin class $HistoricDataResponseCopyWith<$Res>  {
  factory $HistoricDataResponseCopyWith(HistoricDataResponse value, $Res Function(HistoricDataResponse) _then) = _$HistoricDataResponseCopyWithImpl;
@useResult
$Res call({
 String symbol, int count, List<HistoricDataRow> data
});




}
/// @nodoc
class _$HistoricDataResponseCopyWithImpl<$Res>
    implements $HistoricDataResponseCopyWith<$Res> {
  _$HistoricDataResponseCopyWithImpl(this._self, this._then);

  final HistoricDataResponse _self;
  final $Res Function(HistoricDataResponse) _then;

/// Create a copy of HistoricDataResponse
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? symbol = null,Object? count = null,Object? data = null,}) {
  return _then(_self.copyWith(
symbol: null == symbol ? _self.symbol : symbol // ignore: cast_nullable_to_non_nullable
as String,count: null == count ? _self.count : count // ignore: cast_nullable_to_non_nullable
as int,data: null == data ? _self.data : data // ignore: cast_nullable_to_non_nullable
as List<HistoricDataRow>,
  ));
}

}


/// Adds pattern-matching-related methods to [HistoricDataResponse].
extension HistoricDataResponsePatterns on HistoricDataResponse {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _HistoricDataResponse value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _HistoricDataResponse() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _HistoricDataResponse value)  $default,){
final _that = this;
switch (_that) {
case _HistoricDataResponse():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _HistoricDataResponse value)?  $default,){
final _that = this;
switch (_that) {
case _HistoricDataResponse() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String symbol,  int count,  List<HistoricDataRow> data)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _HistoricDataResponse() when $default != null:
return $default(_that.symbol,_that.count,_that.data);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String symbol,  int count,  List<HistoricDataRow> data)  $default,) {final _that = this;
switch (_that) {
case _HistoricDataResponse():
return $default(_that.symbol,_that.count,_that.data);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String symbol,  int count,  List<HistoricDataRow> data)?  $default,) {final _that = this;
switch (_that) {
case _HistoricDataResponse() when $default != null:
return $default(_that.symbol,_that.count,_that.data);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _HistoricDataResponse implements HistoricDataResponse {
  const _HistoricDataResponse({required this.symbol, required this.count, required final  List<HistoricDataRow> data}): _data = data;
  factory _HistoricDataResponse.fromJson(Map<String, dynamic> json) => _$HistoricDataResponseFromJson(json);

@override final  String symbol;
@override final  int count;
 final  List<HistoricDataRow> _data;
@override List<HistoricDataRow> get data {
  if (_data is EqualUnmodifiableListView) return _data;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_data);
}


/// Create a copy of HistoricDataResponse
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$HistoricDataResponseCopyWith<_HistoricDataResponse> get copyWith => __$HistoricDataResponseCopyWithImpl<_HistoricDataResponse>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$HistoricDataResponseToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _HistoricDataResponse&&(identical(other.symbol, symbol) || other.symbol == symbol)&&(identical(other.count, count) || other.count == count)&&const DeepCollectionEquality().equals(other._data, _data));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,symbol,count,const DeepCollectionEquality().hash(_data));

@override
String toString() {
  return 'HistoricDataResponse(symbol: $symbol, count: $count, data: $data)';
}


}

/// @nodoc
abstract mixin class _$HistoricDataResponseCopyWith<$Res> implements $HistoricDataResponseCopyWith<$Res> {
  factory _$HistoricDataResponseCopyWith(_HistoricDataResponse value, $Res Function(_HistoricDataResponse) _then) = __$HistoricDataResponseCopyWithImpl;
@override @useResult
$Res call({
 String symbol, int count, List<HistoricDataRow> data
});




}
/// @nodoc
class __$HistoricDataResponseCopyWithImpl<$Res>
    implements _$HistoricDataResponseCopyWith<$Res> {
  __$HistoricDataResponseCopyWithImpl(this._self, this._then);

  final _HistoricDataResponse _self;
  final $Res Function(_HistoricDataResponse) _then;

/// Create a copy of HistoricDataResponse
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? symbol = null,Object? count = null,Object? data = null,}) {
  return _then(_HistoricDataResponse(
symbol: null == symbol ? _self.symbol : symbol // ignore: cast_nullable_to_non_nullable
as String,count: null == count ? _self.count : count // ignore: cast_nullable_to_non_nullable
as int,data: null == data ? _self._data : data // ignore: cast_nullable_to_non_nullable
as List<HistoricDataRow>,
  ));
}


}


/// @nodoc
mixin _$IndicatorRow {

 String get date; double? get rsi_14; double? get macd_line; double? get macd_signal; double? get macd_hist; double? get bb_upper; double? get bb_lower;
/// Create a copy of IndicatorRow
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$IndicatorRowCopyWith<IndicatorRow> get copyWith => _$IndicatorRowCopyWithImpl<IndicatorRow>(this as IndicatorRow, _$identity);

  /// Serializes this IndicatorRow to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is IndicatorRow&&(identical(other.date, date) || other.date == date)&&(identical(other.rsi_14, rsi_14) || other.rsi_14 == rsi_14)&&(identical(other.macd_line, macd_line) || other.macd_line == macd_line)&&(identical(other.macd_signal, macd_signal) || other.macd_signal == macd_signal)&&(identical(other.macd_hist, macd_hist) || other.macd_hist == macd_hist)&&(identical(other.bb_upper, bb_upper) || other.bb_upper == bb_upper)&&(identical(other.bb_lower, bb_lower) || other.bb_lower == bb_lower));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,date,rsi_14,macd_line,macd_signal,macd_hist,bb_upper,bb_lower);

@override
String toString() {
  return 'IndicatorRow(date: $date, rsi_14: $rsi_14, macd_line: $macd_line, macd_signal: $macd_signal, macd_hist: $macd_hist, bb_upper: $bb_upper, bb_lower: $bb_lower)';
}


}

/// @nodoc
abstract mixin class $IndicatorRowCopyWith<$Res>  {
  factory $IndicatorRowCopyWith(IndicatorRow value, $Res Function(IndicatorRow) _then) = _$IndicatorRowCopyWithImpl;
@useResult
$Res call({
 String date, double? rsi_14, double? macd_line, double? macd_signal, double? macd_hist, double? bb_upper, double? bb_lower
});




}
/// @nodoc
class _$IndicatorRowCopyWithImpl<$Res>
    implements $IndicatorRowCopyWith<$Res> {
  _$IndicatorRowCopyWithImpl(this._self, this._then);

  final IndicatorRow _self;
  final $Res Function(IndicatorRow) _then;

/// Create a copy of IndicatorRow
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? date = null,Object? rsi_14 = freezed,Object? macd_line = freezed,Object? macd_signal = freezed,Object? macd_hist = freezed,Object? bb_upper = freezed,Object? bb_lower = freezed,}) {
  return _then(_self.copyWith(
date: null == date ? _self.date : date // ignore: cast_nullable_to_non_nullable
as String,rsi_14: freezed == rsi_14 ? _self.rsi_14 : rsi_14 // ignore: cast_nullable_to_non_nullable
as double?,macd_line: freezed == macd_line ? _self.macd_line : macd_line // ignore: cast_nullable_to_non_nullable
as double?,macd_signal: freezed == macd_signal ? _self.macd_signal : macd_signal // ignore: cast_nullable_to_non_nullable
as double?,macd_hist: freezed == macd_hist ? _self.macd_hist : macd_hist // ignore: cast_nullable_to_non_nullable
as double?,bb_upper: freezed == bb_upper ? _self.bb_upper : bb_upper // ignore: cast_nullable_to_non_nullable
as double?,bb_lower: freezed == bb_lower ? _self.bb_lower : bb_lower // ignore: cast_nullable_to_non_nullable
as double?,
  ));
}

}


/// Adds pattern-matching-related methods to [IndicatorRow].
extension IndicatorRowPatterns on IndicatorRow {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _IndicatorRow value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _IndicatorRow() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _IndicatorRow value)  $default,){
final _that = this;
switch (_that) {
case _IndicatorRow():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _IndicatorRow value)?  $default,){
final _that = this;
switch (_that) {
case _IndicatorRow() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String date,  double? rsi_14,  double? macd_line,  double? macd_signal,  double? macd_hist,  double? bb_upper,  double? bb_lower)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _IndicatorRow() when $default != null:
return $default(_that.date,_that.rsi_14,_that.macd_line,_that.macd_signal,_that.macd_hist,_that.bb_upper,_that.bb_lower);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String date,  double? rsi_14,  double? macd_line,  double? macd_signal,  double? macd_hist,  double? bb_upper,  double? bb_lower)  $default,) {final _that = this;
switch (_that) {
case _IndicatorRow():
return $default(_that.date,_that.rsi_14,_that.macd_line,_that.macd_signal,_that.macd_hist,_that.bb_upper,_that.bb_lower);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String date,  double? rsi_14,  double? macd_line,  double? macd_signal,  double? macd_hist,  double? bb_upper,  double? bb_lower)?  $default,) {final _that = this;
switch (_that) {
case _IndicatorRow() when $default != null:
return $default(_that.date,_that.rsi_14,_that.macd_line,_that.macd_signal,_that.macd_hist,_that.bb_upper,_that.bb_lower);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _IndicatorRow implements IndicatorRow {
  const _IndicatorRow({required this.date, this.rsi_14, this.macd_line, this.macd_signal, this.macd_hist, this.bb_upper, this.bb_lower});
  factory _IndicatorRow.fromJson(Map<String, dynamic> json) => _$IndicatorRowFromJson(json);

@override final  String date;
@override final  double? rsi_14;
@override final  double? macd_line;
@override final  double? macd_signal;
@override final  double? macd_hist;
@override final  double? bb_upper;
@override final  double? bb_lower;

/// Create a copy of IndicatorRow
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$IndicatorRowCopyWith<_IndicatorRow> get copyWith => __$IndicatorRowCopyWithImpl<_IndicatorRow>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$IndicatorRowToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _IndicatorRow&&(identical(other.date, date) || other.date == date)&&(identical(other.rsi_14, rsi_14) || other.rsi_14 == rsi_14)&&(identical(other.macd_line, macd_line) || other.macd_line == macd_line)&&(identical(other.macd_signal, macd_signal) || other.macd_signal == macd_signal)&&(identical(other.macd_hist, macd_hist) || other.macd_hist == macd_hist)&&(identical(other.bb_upper, bb_upper) || other.bb_upper == bb_upper)&&(identical(other.bb_lower, bb_lower) || other.bb_lower == bb_lower));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,date,rsi_14,macd_line,macd_signal,macd_hist,bb_upper,bb_lower);

@override
String toString() {
  return 'IndicatorRow(date: $date, rsi_14: $rsi_14, macd_line: $macd_line, macd_signal: $macd_signal, macd_hist: $macd_hist, bb_upper: $bb_upper, bb_lower: $bb_lower)';
}


}

/// @nodoc
abstract mixin class _$IndicatorRowCopyWith<$Res> implements $IndicatorRowCopyWith<$Res> {
  factory _$IndicatorRowCopyWith(_IndicatorRow value, $Res Function(_IndicatorRow) _then) = __$IndicatorRowCopyWithImpl;
@override @useResult
$Res call({
 String date, double? rsi_14, double? macd_line, double? macd_signal, double? macd_hist, double? bb_upper, double? bb_lower
});




}
/// @nodoc
class __$IndicatorRowCopyWithImpl<$Res>
    implements _$IndicatorRowCopyWith<$Res> {
  __$IndicatorRowCopyWithImpl(this._self, this._then);

  final _IndicatorRow _self;
  final $Res Function(_IndicatorRow) _then;

/// Create a copy of IndicatorRow
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? date = null,Object? rsi_14 = freezed,Object? macd_line = freezed,Object? macd_signal = freezed,Object? macd_hist = freezed,Object? bb_upper = freezed,Object? bb_lower = freezed,}) {
  return _then(_IndicatorRow(
date: null == date ? _self.date : date // ignore: cast_nullable_to_non_nullable
as String,rsi_14: freezed == rsi_14 ? _self.rsi_14 : rsi_14 // ignore: cast_nullable_to_non_nullable
as double?,macd_line: freezed == macd_line ? _self.macd_line : macd_line // ignore: cast_nullable_to_non_nullable
as double?,macd_signal: freezed == macd_signal ? _self.macd_signal : macd_signal // ignore: cast_nullable_to_non_nullable
as double?,macd_hist: freezed == macd_hist ? _self.macd_hist : macd_hist // ignore: cast_nullable_to_non_nullable
as double?,bb_upper: freezed == bb_upper ? _self.bb_upper : bb_upper // ignore: cast_nullable_to_non_nullable
as double?,bb_lower: freezed == bb_lower ? _self.bb_lower : bb_lower // ignore: cast_nullable_to_non_nullable
as double?,
  ));
}


}


/// @nodoc
mixin _$IndicatorsResponse {

 String get symbol; int get count; List<IndicatorRow> get data;
/// Create a copy of IndicatorsResponse
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$IndicatorsResponseCopyWith<IndicatorsResponse> get copyWith => _$IndicatorsResponseCopyWithImpl<IndicatorsResponse>(this as IndicatorsResponse, _$identity);

  /// Serializes this IndicatorsResponse to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is IndicatorsResponse&&(identical(other.symbol, symbol) || other.symbol == symbol)&&(identical(other.count, count) || other.count == count)&&const DeepCollectionEquality().equals(other.data, data));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,symbol,count,const DeepCollectionEquality().hash(data));

@override
String toString() {
  return 'IndicatorsResponse(symbol: $symbol, count: $count, data: $data)';
}


}

/// @nodoc
abstract mixin class $IndicatorsResponseCopyWith<$Res>  {
  factory $IndicatorsResponseCopyWith(IndicatorsResponse value, $Res Function(IndicatorsResponse) _then) = _$IndicatorsResponseCopyWithImpl;
@useResult
$Res call({
 String symbol, int count, List<IndicatorRow> data
});




}
/// @nodoc
class _$IndicatorsResponseCopyWithImpl<$Res>
    implements $IndicatorsResponseCopyWith<$Res> {
  _$IndicatorsResponseCopyWithImpl(this._self, this._then);

  final IndicatorsResponse _self;
  final $Res Function(IndicatorsResponse) _then;

/// Create a copy of IndicatorsResponse
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? symbol = null,Object? count = null,Object? data = null,}) {
  return _then(_self.copyWith(
symbol: null == symbol ? _self.symbol : symbol // ignore: cast_nullable_to_non_nullable
as String,count: null == count ? _self.count : count // ignore: cast_nullable_to_non_nullable
as int,data: null == data ? _self.data : data // ignore: cast_nullable_to_non_nullable
as List<IndicatorRow>,
  ));
}

}


/// Adds pattern-matching-related methods to [IndicatorsResponse].
extension IndicatorsResponsePatterns on IndicatorsResponse {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _IndicatorsResponse value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _IndicatorsResponse() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _IndicatorsResponse value)  $default,){
final _that = this;
switch (_that) {
case _IndicatorsResponse():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _IndicatorsResponse value)?  $default,){
final _that = this;
switch (_that) {
case _IndicatorsResponse() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String symbol,  int count,  List<IndicatorRow> data)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _IndicatorsResponse() when $default != null:
return $default(_that.symbol,_that.count,_that.data);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String symbol,  int count,  List<IndicatorRow> data)  $default,) {final _that = this;
switch (_that) {
case _IndicatorsResponse():
return $default(_that.symbol,_that.count,_that.data);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String symbol,  int count,  List<IndicatorRow> data)?  $default,) {final _that = this;
switch (_that) {
case _IndicatorsResponse() when $default != null:
return $default(_that.symbol,_that.count,_that.data);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _IndicatorsResponse implements IndicatorsResponse {
  const _IndicatorsResponse({required this.symbol, required this.count, required final  List<IndicatorRow> data}): _data = data;
  factory _IndicatorsResponse.fromJson(Map<String, dynamic> json) => _$IndicatorsResponseFromJson(json);

@override final  String symbol;
@override final  int count;
 final  List<IndicatorRow> _data;
@override List<IndicatorRow> get data {
  if (_data is EqualUnmodifiableListView) return _data;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_data);
}


/// Create a copy of IndicatorsResponse
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$IndicatorsResponseCopyWith<_IndicatorsResponse> get copyWith => __$IndicatorsResponseCopyWithImpl<_IndicatorsResponse>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$IndicatorsResponseToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _IndicatorsResponse&&(identical(other.symbol, symbol) || other.symbol == symbol)&&(identical(other.count, count) || other.count == count)&&const DeepCollectionEquality().equals(other._data, _data));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,symbol,count,const DeepCollectionEquality().hash(_data));

@override
String toString() {
  return 'IndicatorsResponse(symbol: $symbol, count: $count, data: $data)';
}


}

/// @nodoc
abstract mixin class _$IndicatorsResponseCopyWith<$Res> implements $IndicatorsResponseCopyWith<$Res> {
  factory _$IndicatorsResponseCopyWith(_IndicatorsResponse value, $Res Function(_IndicatorsResponse) _then) = __$IndicatorsResponseCopyWithImpl;
@override @useResult
$Res call({
 String symbol, int count, List<IndicatorRow> data
});




}
/// @nodoc
class __$IndicatorsResponseCopyWithImpl<$Res>
    implements _$IndicatorsResponseCopyWith<$Res> {
  __$IndicatorsResponseCopyWithImpl(this._self, this._then);

  final _IndicatorsResponse _self;
  final $Res Function(_IndicatorsResponse) _then;

/// Create a copy of IndicatorsResponse
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? symbol = null,Object? count = null,Object? data = null,}) {
  return _then(_IndicatorsResponse(
symbol: null == symbol ? _self.symbol : symbol // ignore: cast_nullable_to_non_nullable
as String,count: null == count ? _self.count : count // ignore: cast_nullable_to_non_nullable
as int,data: null == data ? _self._data : data // ignore: cast_nullable_to_non_nullable
as List<IndicatorRow>,
  ));
}


}


/// @nodoc
mixin _$IndexRow {

 String get date; String get index; double? get current; double? get point_change; double? get pct_change; double? get turnover;
/// Create a copy of IndexRow
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$IndexRowCopyWith<IndexRow> get copyWith => _$IndexRowCopyWithImpl<IndexRow>(this as IndexRow, _$identity);

  /// Serializes this IndexRow to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is IndexRow&&(identical(other.date, date) || other.date == date)&&(identical(other.index, index) || other.index == index)&&(identical(other.current, current) || other.current == current)&&(identical(other.point_change, point_change) || other.point_change == point_change)&&(identical(other.pct_change, pct_change) || other.pct_change == pct_change)&&(identical(other.turnover, turnover) || other.turnover == turnover));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,date,index,current,point_change,pct_change,turnover);

@override
String toString() {
  return 'IndexRow(date: $date, index: $index, current: $current, point_change: $point_change, pct_change: $pct_change, turnover: $turnover)';
}


}

/// @nodoc
abstract mixin class $IndexRowCopyWith<$Res>  {
  factory $IndexRowCopyWith(IndexRow value, $Res Function(IndexRow) _then) = _$IndexRowCopyWithImpl;
@useResult
$Res call({
 String date, String index, double? current, double? point_change, double? pct_change, double? turnover
});




}
/// @nodoc
class _$IndexRowCopyWithImpl<$Res>
    implements $IndexRowCopyWith<$Res> {
  _$IndexRowCopyWithImpl(this._self, this._then);

  final IndexRow _self;
  final $Res Function(IndexRow) _then;

/// Create a copy of IndexRow
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? date = null,Object? index = null,Object? current = freezed,Object? point_change = freezed,Object? pct_change = freezed,Object? turnover = freezed,}) {
  return _then(_self.copyWith(
date: null == date ? _self.date : date // ignore: cast_nullable_to_non_nullable
as String,index: null == index ? _self.index : index // ignore: cast_nullable_to_non_nullable
as String,current: freezed == current ? _self.current : current // ignore: cast_nullable_to_non_nullable
as double?,point_change: freezed == point_change ? _self.point_change : point_change // ignore: cast_nullable_to_non_nullable
as double?,pct_change: freezed == pct_change ? _self.pct_change : pct_change // ignore: cast_nullable_to_non_nullable
as double?,turnover: freezed == turnover ? _self.turnover : turnover // ignore: cast_nullable_to_non_nullable
as double?,
  ));
}

}


/// Adds pattern-matching-related methods to [IndexRow].
extension IndexRowPatterns on IndexRow {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _IndexRow value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _IndexRow() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _IndexRow value)  $default,){
final _that = this;
switch (_that) {
case _IndexRow():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _IndexRow value)?  $default,){
final _that = this;
switch (_that) {
case _IndexRow() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String date,  String index,  double? current,  double? point_change,  double? pct_change,  double? turnover)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _IndexRow() when $default != null:
return $default(_that.date,_that.index,_that.current,_that.point_change,_that.pct_change,_that.turnover);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String date,  String index,  double? current,  double? point_change,  double? pct_change,  double? turnover)  $default,) {final _that = this;
switch (_that) {
case _IndexRow():
return $default(_that.date,_that.index,_that.current,_that.point_change,_that.pct_change,_that.turnover);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String date,  String index,  double? current,  double? point_change,  double? pct_change,  double? turnover)?  $default,) {final _that = this;
switch (_that) {
case _IndexRow() when $default != null:
return $default(_that.date,_that.index,_that.current,_that.point_change,_that.pct_change,_that.turnover);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _IndexRow implements IndexRow {
  const _IndexRow({required this.date, required this.index, this.current, this.point_change, this.pct_change, this.turnover});
  factory _IndexRow.fromJson(Map<String, dynamic> json) => _$IndexRowFromJson(json);

@override final  String date;
@override final  String index;
@override final  double? current;
@override final  double? point_change;
@override final  double? pct_change;
@override final  double? turnover;

/// Create a copy of IndexRow
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$IndexRowCopyWith<_IndexRow> get copyWith => __$IndexRowCopyWithImpl<_IndexRow>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$IndexRowToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _IndexRow&&(identical(other.date, date) || other.date == date)&&(identical(other.index, index) || other.index == index)&&(identical(other.current, current) || other.current == current)&&(identical(other.point_change, point_change) || other.point_change == point_change)&&(identical(other.pct_change, pct_change) || other.pct_change == pct_change)&&(identical(other.turnover, turnover) || other.turnover == turnover));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,date,index,current,point_change,pct_change,turnover);

@override
String toString() {
  return 'IndexRow(date: $date, index: $index, current: $current, point_change: $point_change, pct_change: $pct_change, turnover: $turnover)';
}


}

/// @nodoc
abstract mixin class _$IndexRowCopyWith<$Res> implements $IndexRowCopyWith<$Res> {
  factory _$IndexRowCopyWith(_IndexRow value, $Res Function(_IndexRow) _then) = __$IndexRowCopyWithImpl;
@override @useResult
$Res call({
 String date, String index, double? current, double? point_change, double? pct_change, double? turnover
});




}
/// @nodoc
class __$IndexRowCopyWithImpl<$Res>
    implements _$IndexRowCopyWith<$Res> {
  __$IndexRowCopyWithImpl(this._self, this._then);

  final _IndexRow _self;
  final $Res Function(_IndexRow) _then;

/// Create a copy of IndexRow
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? date = null,Object? index = null,Object? current = freezed,Object? point_change = freezed,Object? pct_change = freezed,Object? turnover = freezed,}) {
  return _then(_IndexRow(
date: null == date ? _self.date : date // ignore: cast_nullable_to_non_nullable
as String,index: null == index ? _self.index : index // ignore: cast_nullable_to_non_nullable
as String,current: freezed == current ? _self.current : current // ignore: cast_nullable_to_non_nullable
as double?,point_change: freezed == point_change ? _self.point_change : point_change // ignore: cast_nullable_to_non_nullable
as double?,pct_change: freezed == pct_change ? _self.pct_change : pct_change // ignore: cast_nullable_to_non_nullable
as double?,turnover: freezed == turnover ? _self.turnover : turnover // ignore: cast_nullable_to_non_nullable
as double?,
  ));
}


}


/// @nodoc
mixin _$IndicesResponse {

 int get count; List<IndexRow> get data;
/// Create a copy of IndicesResponse
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$IndicesResponseCopyWith<IndicesResponse> get copyWith => _$IndicesResponseCopyWithImpl<IndicesResponse>(this as IndicesResponse, _$identity);

  /// Serializes this IndicesResponse to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is IndicesResponse&&(identical(other.count, count) || other.count == count)&&const DeepCollectionEquality().equals(other.data, data));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,count,const DeepCollectionEquality().hash(data));

@override
String toString() {
  return 'IndicesResponse(count: $count, data: $data)';
}


}

/// @nodoc
abstract mixin class $IndicesResponseCopyWith<$Res>  {
  factory $IndicesResponseCopyWith(IndicesResponse value, $Res Function(IndicesResponse) _then) = _$IndicesResponseCopyWithImpl;
@useResult
$Res call({
 int count, List<IndexRow> data
});




}
/// @nodoc
class _$IndicesResponseCopyWithImpl<$Res>
    implements $IndicesResponseCopyWith<$Res> {
  _$IndicesResponseCopyWithImpl(this._self, this._then);

  final IndicesResponse _self;
  final $Res Function(IndicesResponse) _then;

/// Create a copy of IndicesResponse
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? count = null,Object? data = null,}) {
  return _then(_self.copyWith(
count: null == count ? _self.count : count // ignore: cast_nullable_to_non_nullable
as int,data: null == data ? _self.data : data // ignore: cast_nullable_to_non_nullable
as List<IndexRow>,
  ));
}

}


/// Adds pattern-matching-related methods to [IndicesResponse].
extension IndicesResponsePatterns on IndicesResponse {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _IndicesResponse value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _IndicesResponse() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _IndicesResponse value)  $default,){
final _that = this;
switch (_that) {
case _IndicesResponse():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _IndicesResponse value)?  $default,){
final _that = this;
switch (_that) {
case _IndicesResponse() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int count,  List<IndexRow> data)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _IndicesResponse() when $default != null:
return $default(_that.count,_that.data);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int count,  List<IndexRow> data)  $default,) {final _that = this;
switch (_that) {
case _IndicesResponse():
return $default(_that.count,_that.data);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int count,  List<IndexRow> data)?  $default,) {final _that = this;
switch (_that) {
case _IndicesResponse() when $default != null:
return $default(_that.count,_that.data);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _IndicesResponse implements IndicesResponse {
  const _IndicesResponse({required this.count, required final  List<IndexRow> data}): _data = data;
  factory _IndicesResponse.fromJson(Map<String, dynamic> json) => _$IndicesResponseFromJson(json);

@override final  int count;
 final  List<IndexRow> _data;
@override List<IndexRow> get data {
  if (_data is EqualUnmodifiableListView) return _data;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_data);
}


/// Create a copy of IndicesResponse
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$IndicesResponseCopyWith<_IndicesResponse> get copyWith => __$IndicesResponseCopyWithImpl<_IndicesResponse>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$IndicesResponseToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _IndicesResponse&&(identical(other.count, count) || other.count == count)&&const DeepCollectionEquality().equals(other._data, _data));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,count,const DeepCollectionEquality().hash(_data));

@override
String toString() {
  return 'IndicesResponse(count: $count, data: $data)';
}


}

/// @nodoc
abstract mixin class _$IndicesResponseCopyWith<$Res> implements $IndicesResponseCopyWith<$Res> {
  factory _$IndicesResponseCopyWith(_IndicesResponse value, $Res Function(_IndicesResponse) _then) = __$IndicesResponseCopyWithImpl;
@override @useResult
$Res call({
 int count, List<IndexRow> data
});




}
/// @nodoc
class __$IndicesResponseCopyWithImpl<$Res>
    implements _$IndicesResponseCopyWith<$Res> {
  __$IndicesResponseCopyWithImpl(this._self, this._then);

  final _IndicesResponse _self;
  final $Res Function(_IndicesResponse) _then;

/// Create a copy of IndicesResponse
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? count = null,Object? data = null,}) {
  return _then(_IndicesResponse(
count: null == count ? _self.count : count // ignore: cast_nullable_to_non_nullable
as int,data: null == data ? _self._data : data // ignore: cast_nullable_to_non_nullable
as List<IndexRow>,
  ));
}


}


/// @nodoc
mixin _$LatestIndicesResponse {

 List<IndexRow> get data;
/// Create a copy of LatestIndicesResponse
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$LatestIndicesResponseCopyWith<LatestIndicesResponse> get copyWith => _$LatestIndicesResponseCopyWithImpl<LatestIndicesResponse>(this as LatestIndicesResponse, _$identity);

  /// Serializes this LatestIndicesResponse to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is LatestIndicesResponse&&const DeepCollectionEquality().equals(other.data, data));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(data));

@override
String toString() {
  return 'LatestIndicesResponse(data: $data)';
}


}

/// @nodoc
abstract mixin class $LatestIndicesResponseCopyWith<$Res>  {
  factory $LatestIndicesResponseCopyWith(LatestIndicesResponse value, $Res Function(LatestIndicesResponse) _then) = _$LatestIndicesResponseCopyWithImpl;
@useResult
$Res call({
 List<IndexRow> data
});




}
/// @nodoc
class _$LatestIndicesResponseCopyWithImpl<$Res>
    implements $LatestIndicesResponseCopyWith<$Res> {
  _$LatestIndicesResponseCopyWithImpl(this._self, this._then);

  final LatestIndicesResponse _self;
  final $Res Function(LatestIndicesResponse) _then;

/// Create a copy of LatestIndicesResponse
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? data = null,}) {
  return _then(_self.copyWith(
data: null == data ? _self.data : data // ignore: cast_nullable_to_non_nullable
as List<IndexRow>,
  ));
}

}


/// Adds pattern-matching-related methods to [LatestIndicesResponse].
extension LatestIndicesResponsePatterns on LatestIndicesResponse {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _LatestIndicesResponse value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _LatestIndicesResponse() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _LatestIndicesResponse value)  $default,){
final _that = this;
switch (_that) {
case _LatestIndicesResponse():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _LatestIndicesResponse value)?  $default,){
final _that = this;
switch (_that) {
case _LatestIndicesResponse() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( List<IndexRow> data)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _LatestIndicesResponse() when $default != null:
return $default(_that.data);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( List<IndexRow> data)  $default,) {final _that = this;
switch (_that) {
case _LatestIndicesResponse():
return $default(_that.data);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( List<IndexRow> data)?  $default,) {final _that = this;
switch (_that) {
case _LatestIndicesResponse() when $default != null:
return $default(_that.data);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _LatestIndicesResponse implements LatestIndicesResponse {
  const _LatestIndicesResponse({required final  List<IndexRow> data}): _data = data;
  factory _LatestIndicesResponse.fromJson(Map<String, dynamic> json) => _$LatestIndicesResponseFromJson(json);

 final  List<IndexRow> _data;
@override List<IndexRow> get data {
  if (_data is EqualUnmodifiableListView) return _data;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_data);
}


/// Create a copy of LatestIndicesResponse
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$LatestIndicesResponseCopyWith<_LatestIndicesResponse> get copyWith => __$LatestIndicesResponseCopyWithImpl<_LatestIndicesResponse>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$LatestIndicesResponseToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _LatestIndicesResponse&&const DeepCollectionEquality().equals(other._data, _data));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(_data));

@override
String toString() {
  return 'LatestIndicesResponse(data: $data)';
}


}

/// @nodoc
abstract mixin class _$LatestIndicesResponseCopyWith<$Res> implements $LatestIndicesResponseCopyWith<$Res> {
  factory _$LatestIndicesResponseCopyWith(_LatestIndicesResponse value, $Res Function(_LatestIndicesResponse) _then) = __$LatestIndicesResponseCopyWithImpl;
@override @useResult
$Res call({
 List<IndexRow> data
});




}
/// @nodoc
class __$LatestIndicesResponseCopyWithImpl<$Res>
    implements _$LatestIndicesResponseCopyWith<$Res> {
  __$LatestIndicesResponseCopyWithImpl(this._self, this._then);

  final _LatestIndicesResponse _self;
  final $Res Function(_LatestIndicesResponse) _then;

/// Create a copy of LatestIndicesResponse
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? data = null,}) {
  return _then(_LatestIndicesResponse(
data: null == data ? _self._data : data // ignore: cast_nullable_to_non_nullable
as List<IndexRow>,
  ));
}


}

// dart format on
