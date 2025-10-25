# AWS Lambda Python 3.12 公式イメージをベースにする
FROM public.ecr.aws/lambda/python:3.12

# アーキテクチャの検出とNode.js 18のインストール（Serverless Framework用）
RUN dnf install -y tar gzip xz && \
    ARCH=$(uname -m) && \
    if [ "$ARCH" = "aarch64" ]; then \
        NODE_ARCH="arm64"; \
    else \
        NODE_ARCH="x64"; \
    fi && \
    curl -fsSL https://nodejs.org/dist/v18.20.0/node-v18.20.0-linux-${NODE_ARCH}.tar.xz | tar -xJ -C /usr/local --strip-components=1 && \
    dnf clean all && \
    rm -rf /var/cache/dnf

# Node.js と npm、Python のバージョン確認
RUN node --version && npm --version && python --version

# 作業ディレクトリの設定
WORKDIR /app

# package.json をコピーして依存関係をインストール
COPY package*.json ./
RUN npm install

# アプリケーションのコードをコピー
COPY . .

# Serverless Framework のライセンス設定用の環境変数
ENV SERVERLESS_ACCESS_KEY=""

# デフォルトコマンド
CMD ["bash"]

