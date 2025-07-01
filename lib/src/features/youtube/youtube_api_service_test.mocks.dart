// Mockito generated mock file
import 'dart:async' as i5;

import 'package:dio/dio.dart' as i2;
import 'package:mockito/mockito.dart' as i1;

// ignore: camel_case_types
class _FakeDioError_0 extends i1.SmartFake implements i2.DioException {
  _FakeDioError_0(
    Object parent,
    Invocation parentInvocation,
  ) : super(
          parent,
          parentInvocation,
        );
}

// ignore: camel_case_types
class _FakeResponse_1<T> extends i1.SmartFake implements i2.Response<T> {
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
class MockDio extends i1.Mock implements i2.Dio {
  MockDio() {
    i1.throwOnMissingStub(this);
  }

  @override
  i5.Future<i2.Response<T>> get<T>(
    String? path, {
    Object? data,
    Map<String, dynamic>? queryParameters,
    i2.Options? options,
    i2.CancelToken? cancelToken,
    i2.ProgressCallback? onReceiveProgress,
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
        returnValue: i5.Future<i2.Response<T>>.value(
            _FakeResponse_1<T>(this, Invocation.method(#get, [path]))),
        returnValueForMissingStub: i5.Future<i2.Response<T>>.value(
            _FakeResponse_1<T>(this, Invocation.method(#get, [path]))),
      ) as i5.Future<i2.Response<T>>);
} 