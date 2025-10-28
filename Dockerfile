FROM public.ecr.aws/lambda/python:3.12

# install nodejs 20
RUN curl -fsSL https://rpm.nodesource.com/setup_20.x | bash - && \
    dnf install -y nodejs && \
    dnf clean all && \
    rm -rf /var/cache/dnf

# Install AWS SAM CLI
RUN pip3 install aws-sam-cli

RUN node --version && npm --version && python --version && sam --version

WORKDIR /app

COPY package*.json ./
RUN npm install

COPY . .
