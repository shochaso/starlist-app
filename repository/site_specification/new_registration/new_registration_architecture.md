---
source_of_truth: true
version: 0.1.0
updated_date: 2025-11-15
owner: STARLIST Docs Automation Team
---



## 新規登録アーキテクチャ

このドキュメントでは、Starlistの新規登録フローに関する技術的なアーキテクチャを定義します。

## 認証フロー

SNSアカウントによる初回ログイン後、ユーザーはスターとして活動を開始するために、以下の多段階認証フローを完了する必要があります。
`verification_status`が`approved`になるまで、コンテンツ投稿などの主要機能は利用できません。

### 認証ステータス (`verification_status`)

ユーザーの認証進捗を管理するステータスです。`users`テーブルに`TEXT`型で保持します。

- `awaiting_terms_agreement`: 事務所利用規約の同意待ち（初期状態）
- `awaiting_ekyc`: eKYCの実施待ち
- `awaiting_parental_consent`: (18歳未満の場合) 親権者の同意待ち
- `awaiting_sns_verification`: SNSアカウントの所有権確認待ち
- `pending_review`: 全ての書類提出が完了し、運営のレビュー待ち
- `approved`: 全ての認証が完了し、承認済み
- `rejected`: 運営によって申請が拒否された状態

### 認証ステップ

1.  **ステップA: 事務所利用規約への同意**
    - **画面**: `TermsAgreementScreen`
    - **処理**: 規約に同意後、ステータスを `awaiting_ekyc` に更新。

2.  **ステップB: eKYCによる本人・年齢確認**
    - **画面**: `eKYCStartScreen`
    - **処理**:
        - サードパーティeKYCサービスを呼び出す。
        - コールバックで年齢を判定。
        - **18歳以上**: ステータスを `awaiting_sns_verification` に更新。
        - **18歳未満**: ステータスを `awaiting_parental_consent` に更新。

3.  **ステップC: 親権者同意フロー (18歳未満のみ)**
    - **画面**: `ParentalConsentScreen`
    - **処理**: 親権者情報と同意書画像を提出後、ステータスを `awaiting_sns_verification` に更新。

4.  **ステップD: SNSアカウント所有権確認**
    - **画面**: `SNSVerificationScreen`
    - **処理**: アカウント所有権の確認後、ステータスを `pending_review` に更新。

5.  **ステップE: 運営によるレビュー**
    - **画面**: 運営管理画面
    - **処理**: 運営が提出された全ての情報を確認し、ステータスを `approved` または `rejected` に更新。

## データベース設計

### `parental_consents` テーブル

未成年者の親権者同意情報を保存します。

| カラム名                 | 型        | 説明                               |
| ------------------------ | --------- | ---------------------------------- |
| `id`                     | `uuid`    | Primary Key                        |
| `user_id`                | `uuid`    | `users.id`へのForeign Key         |
| `parent_name`            | `text`    | 親権者の氏名                       |
| `parent_contact_info`    | `text`    | 親権者の連絡先（暗号化を検討）     |
| `consent_document_url`   | `text`    | 同意書のStorage URL                |
| `status`                 | `text`    | 同意書の状態 (`submitted`, `approved`) |
| `created_at`             | `timestamptz` | 作成日時                           |
| `updated_at`             | `timestamptz` | 更新日時                           |

## DoD (Definition of Done)
- [ ] 文書の目的と完了基準を明記しました。
