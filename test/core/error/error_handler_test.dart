import "package:firebase_auth/firebase_auth.dart";
import "package:flutter_test/flutter_test.dart";
import "package:starlist/src/core/error/app_error.dart";
import "package:starlist/src/core/error/error_handler.dart";

void main() {
  group("ErrorHandler", () {
    test("handleFirebaseAuthException", () {
      final error = FirebaseAuthException(
        code: "user-not-found",
        message: "User not found",
      );
      final result = ErrorHandler.handleFirebaseAuthException(error);
      expect(result, isA<AuthError>());
      expect(result.message, "ユーザーが見つかりません");
      expect(result.code, "user-not-found");
    });

    test("handleFirebaseException", () {
      final error = FirebaseAuthException(
        code: "invalid-email",
        message: "Invalid email",
      );
      final result = ErrorHandler.handleFirebaseException(error);
      expect(result, isA<AuthError>());
      expect(result.message, "無効なメールアドレスです");
      expect(result.code, "invalid-email");
    });

    test("handleNetworkException", () {
      final error = Exception("Network error");
      final result = ErrorHandler.handleNetworkException(error);
      expect(result, isA<NetworkError>());
      expect(result.message, "ネットワークエラーが発生しました");
      expect(result.originalError, error);
    });

    test("handleValidationException", () {
      final error = Exception("Validation error");
      final result = ErrorHandler.handleValidationException(error);
      expect(result, isA<ValidationError>());
      expect(result.message, "入力値が無効です");
      expect(result.originalError, error);
    });

    test("handlePaymentException", () {
      final error = Exception("Payment error");
      final result = ErrorHandler.handlePaymentException(error);
      expect(result, isA<PaymentError>());
      expect(result.message, "支払いエラーが発生しました");
      expect(result.originalError, error);
    });

    test("handleSubscriptionException", () {
      final error = Exception("Subscription error");
      final result = ErrorHandler.handleSubscriptionException(error);
      expect(result, isA<SubscriptionError>());
      expect(result.message, "サブスクリプションエラーが発生しました");
      expect(result.originalError, error);
    });

    test("handlePrivacyException", () {
      final error = Exception("Privacy error");
      final result = ErrorHandler.handlePrivacyException(error);
      expect(result, isA<PrivacyError>());
      expect(result.message, "プライバシー設定エラーが発生しました");
      expect(result.originalError, error);
    });

    test("handleRankingException", () {
      final error = Exception("Ranking error");
      final result = ErrorHandler.handleRankingException(error);
      expect(result, isA<RankingError>());
      expect(result.message, "ランキングエラーが発生しました");
      expect(result.originalError, error);
    });

    test("handleYouTubeException", () {
      final error = Exception("YouTube error");
      final result = ErrorHandler.handleYouTubeException(error);
      expect(result, isA<YouTubeError>());
      expect(result.message, "YouTube APIエラーが発生しました");
      expect(result.originalError, error);
    });

    test("handleUnknownException", () {
      final error = Exception("Unknown error");
      final result = ErrorHandler.handleUnknownException(error);
      expect(result, isA<AppError>());
      expect(result.message, "予期せぬエラーが発生しました");
      expect(result.originalError, error);
    });
  });
}
