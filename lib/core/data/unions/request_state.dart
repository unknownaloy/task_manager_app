import 'package:freezed_annotation/freezed_annotation.dart';

part 'request_state.freezed.dart';

@freezed
class RequestState<T> with _$RequestState<T> {
  const factory RequestState.idle() = _Idle<T>;
  const factory RequestState.loading() = _Loading<T>;
  const factory RequestState.success(T? data) = _Success<T>;
  const factory RequestState.error({required String message}) = _Error<T>;
}
