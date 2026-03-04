# OpenClaw Docker 镜像 - Ubuntu 22.04 版本
# 基于 https://github.com/justlovemaki/OpenClaw-Docker-CN-IM 修改
FROM ubuntu:22.04

WORKDIR /app

ENV BUN_INSTALL="/usr/local" \
    PATH="/usr/local/bin:$PATH" \
    DEBIAN_FRONTEND=noninteractive \
    NODE_MAJOR=22

# 1. 安装基础工具 + 添加软件源（gnupg/wget 只用于添加源，之后删除）
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        ca-certificates curl gnupg wget && \
    # 添加 Google Chrome 源
    wget -q -O - https://dl.google.com/linux/linux_signing_key.pub | \
        gpg --dearmor -o /etc/apt/keyrings/google-chrome.gpg && \
    echo "deb [arch=amd64 signed-by=/etc/apt/keyrings/google-chrome.gpg] http://dl.google.com/linux/chrome/deb/ stable main" \
        > /etc/apt/sources.list.d/google-chrome.list && \
    # 添加 Node.js 22 源
    curl -fsSL https://deb.nodesource.com/gpgkey/nodesource-repo.gpg.key | \
        gpg --dearmor -o /etc/apt/keyrings/nodesource.gpg && \
    echo "deb [signed-by=/etc/apt/keyrings/nodesource.gpg] https://deb.nodesource.com/node_${NODE_MAJOR}.x nodistro main" \
        > /etc/apt/sources.list.d/nodesource.list && \
    # 清理临时工具（源已添加，不再需要 gnupg/wget）
    apt-get purge -y gnupg wget && \
    apt-get autoremove -y && \
    rm -rf /var/lib/apt/lists/*

# 2. 安装 Chrome + Node.js + 其他依赖（分开的 RUN 避免依赖被误删）
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        bash \
        fonts-liberation \
        fonts-noto-cjk \
        fonts-noto-color-emoji \
        git \
        google-chrome-stable \
        gosu \
        jq \
        nodejs \
        python3 \
        socat \
        tini \
        unzip \
        websockify && \
    # 验证 Chrome 安装
    /usr/bin/google-chrome-stable --version && \
    # 安装 npm 全局包
    npm install -g npm@latest && \
    npm install -g openclaw@latest opencode-ai@latest playwright playwright-extra puppeteer-extra-plugin-stealth @steipete/bird && \
    # 安装 bun 和 qmd
    curl -fsSL https://bun.sh/install | BUN_INSTALL=/usr/local bash && \
    /usr/local/bin/bun install -g @tobilu/qmd && \
    # 清理
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* /tmp/* /root/.npm /root/.cache

# 3. 创建 node 用户
RUN groupadd -g 1000 node && \
    useradd -u 1000 -g node -m -s /bin/bash node && \
    mkdir -p /home/node/.openclaw/workspace /home/node/.openclaw/extensions && \
    chown -R node:node /home/node

# 4. 插件安装（作为 node 用户）
USER node
ENV HOME=/home/node
WORKDIR /home/node

RUN cd /home/node/.openclaw/extensions && \
    git clone --depth 1 https://github.com/soimy/openclaw-channel-dingtalk.git dingtalk && \
    cd dingtalk && \
    npm install --production && \
    timeout 300 openclaw plugins install -l . || true && \
    cd /home/node/.openclaw && \
    git clone --depth 1 https://github.com/justlovemaki/qqbot.git && \
    cd qqbot && \
    timeout 300 openclaw plugins install . || true && \
    timeout 300 openclaw plugins install @sunnoy/wecom || true && \
    find /home/node/.openclaw/extensions -name ".git" -type d -exec rm -rf {} + && \
    rm -rf /home/node/.openclaw/qqbot/.git && \
    rm -rf /tmp/* /home/node/.npm /home/node/.cache

# 5. 最终配置
USER root

COPY ./init.sh /usr/local/bin/init.sh
RUN chmod +x /usr/local/bin/init.sh

ENV HOME=/home/node \
    TERM=xterm-256color \
    NODE_PATH=/usr/local/lib/node_modules \
    CHROME_BIN=/usr/bin/google-chrome-stable

EXPOSE 18789 18790
WORKDIR /home/node
ENTRYPOINT ["/bin/bash", "/usr/local/bin/init.sh"]
