FROM node:18-alpine

WORKDIR /app

COPY package*.json ./
RUN npm ci --production

COPY . .

# 非rootユーザー作成（Trivy config strict復帰の前提条件）
RUN getent passwd app >/dev/null || (useradd -m app 2>/dev/null || adduser -D app)

# 非rootユーザーに切り替え
USER app

ENV NODE_ENV=production
ENV PORT=8080

EXPOSE 8080

CMD ["node", "index.js"]
