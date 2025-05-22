// Mockito generated mock file
import 'dart:async' as _i5;

import 'package:dio/dio.dart' as _i2;
import 'package:mockito/mockito.dart' as _i1;

// ignore: camel_case_types
class _FakeDioError_0 extends _i1.SmartFake implements _i2.DioException {
  _FakeDioError_0(
    Object parent,
    Invocation parentInvocation,
  ) : super(
          parent,
          parentInvocation,
        );
}

// ignore: camel_case_types
class _FakeResponse_1<T> extends _i1.SmartFake implements _i2.Response<T> {
  _FakeResponse_1(
    Object parent,
    Invocation parentInvocation,
  ) : super(
          parent,
          parentInvocation,
        );
}

/// A class which mocks [Dio].
///
/// See the documentation for Mockito's code generation for more information.
class MockDio extends _i1.Mock implements _i2.Dio {
  MockDio() {
    _i1.throwOnMissingStub(this);
  }

  @override
  _i5.Future<_i2.Response<T>> get<T>(
    String? path, {
    Object? data,
    Map<String, dynamic>? queryParameters,
    _i2.Options? options,
    _i2.CancelToken? cancelToken,
    _i2.ProgressCallback? onReceiveProgress,
  }) =>
      (super.noSuchMethod(
        Invocation.method(
          #get,
          [path],
          {
            #data: data,
            #queryParameters: queryParameters,
            #options: options,
            #cancelToken: cancelToken,
            #onReceiveProgress: onReceiveProgress,
          },
        ),
        returnValue: _i5.Future<_i2.Response<T>>.value(
            _FakeResponse_1<T>(this, Invocation.method(#get, [path]))),
        returnValueForMissingStub: _i5.Future<_i2.Response<T>>.value(
            _FakeResponse_1<T>(this, Invocation.method(#get, [path]))),
      ) as _i5.Future<_i2.Response<T>>);
} 