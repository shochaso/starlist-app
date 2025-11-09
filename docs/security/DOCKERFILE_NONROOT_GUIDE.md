# Dockerfile非root化ガイド

**Status**: Active  
**Last Updated**: 2025-11-09  
**Owner**: DevOps + SecOps

---

## 概要

Trivy config strict復帰の前提条件として、主要Dockerfileの非root化を横展開します。

---

## 対象Dockerfile

### 検出済みファイル

1. `cloudrun/ocr-proxy/Dockerfile`
   - 現状: rootユーザーで実行
   - 対応: 非rootユーザー追加が必要

---

## 適用テンプレート

### 基本パターン

```Dockerfile
# (最終ステージ)
RUN getent passwd app >/dev/null || (useradd -m app 2>/dev/null || adduser -D app)
USER app
```

### 多段ビルドの場合

```Dockerfile
# ビルドステージ（root可）
FROM node:18-alpine AS builder
WORKDIR /app
COPY package*.json ./
RUN npm ci
COPY . .
RUN npm run build

# ランタイムステージ（非root必須）
FROM node:18-alpine
WORKDIR /app

# 非rootユーザー作成
RUN getent passwd app >/dev/null || (useradd -m app 2>/dev/null || adduser -D app)

# ビルド成果物をコピー
COPY --from=builder /app/dist ./dist
COPY --from=builder /app/node_modules ./node_modules
COPY package*.json ./

# 非rootユーザーに切り替え
USER app

ENV NODE_ENV=production
ENV PORT=8080
EXPOSE 8080

CMD ["node", "dist/index.js"]
```

---

## 適用手順

### 1. Dockerfileの確認

```bash
git ls-files | grep -E "(^|/)Dockerfile$"
```

### 2. 各Dockerfileに適用

1. 非rootユーザー作成コマンドを追加
2. `USER app`を最終ステージのCMD直前に入れる
3. root必須の操作がある場合は多段ビルドに分割

### 3. 動作確認

```bash
docker build -t test-image .
docker run --rm test-image id
# 出力: uid=1000(app) gid=1000(app) groups=1000(app)
```

### 4. Trivy config strict復帰

非root化完了後、該当サービスで`SKIP_TRIVY_CONFIG=0`に戻す。

---

## チェックリスト

- [ ] `cloudrun/ocr-proxy/Dockerfile`に非rootユーザー追加
- [ ] 動作確認（`docker run`でユーザー確認）
- [ ] CI/CDパイプラインでビルド成功確認
- [ ] Trivy config strict復帰（該当サービス）

---

## 関連Issue

- `sec: re-enable Trivy config (strict) service-by-service` (#36)

---

**作成日**: 2025-11-09

