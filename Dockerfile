# OpenClaw Docker 镜像 - Ubuntu 22.04 版本
# 基于 https://github.com/justlovemaki/OpenClaw-Docker-CN-IM 修改
FROM ubuntu:22.04

# 设置工作目录
WORKDIR /app

# 设置环境变量
ENV BUN_INSTALL="/usr/local" \
    PATH="/usr/local/bin:$PATH" \
    DEBIAN_FRONTEND=noninteractive \
    NODE_MAJOR=22 \
    PLAYWRIGHT_BROWSERS_PATH=/opt/browsers

# 1. 安装系统依赖和 Node.js 22
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
    bash \
    ca-certificates \
    curl \
    fonts-liberation \
    fonts-noto-cjk \
    fonts-noto-color-emoji \
    git \
    gnupg \
    gosu \
    jq \
    python3 \
    socat \
    tini \
    unzip \
    websockify && \
    # 安装 Node.js 22 官方源
    mkdir -p /etc/apt/keyrings && \
    curl -fsSL https://deb.nodesource.com/gpgkey/nodesource-repo.gpg.key | gpg --dearmor -o /etc/apt/keyrings/nodesource.gpg && \
    echo "deb [signed-by=/etc/apt/keyrings/nodesource.gpg] https://deb.nodesource.com/node_$NODE_MAJOR.x nodistro main" > /etc/apt/sources.list.d/nodesource.list && \
    apt-get update && \
    apt-get install -y nodejs && \
    # 更新 npm 并安装全局包
    npm install -g npm@latest && \
    npm install -g openclaw@latest opencode-ai@latest playwright playwright-extra puppeteer-extra-plugin-stealth @steipete/bird && \
    # 安装 bun 和 qmd
    curl -fsSL https://bun.sh/install | BUN_INSTALL=/usr/local bash && \
    /usr/local/bin/bun install -g @tobilu/qmd && \
    # 安装 Playwright Chromium 浏览器和系统依赖到全局位置
    mkdir -p /opt/browsers && \
    npx playwright install chromium --with-deps && \
    chmod -R 755 /opt/browsers && \
    # 清理 apt 缓存
    apt-get purge -y --auto-remove gnupg && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* /tmp/* /root/.npm /root/.cache

# 2. 创建 node 用户
RUN groupadd -g 1000 node && \
    useradd -u 1000 -g node -m -s /bin/bash node && \
    mkdir -p /home/node/.openclaw/workspace /home/node/.openclaw/extensions && \
    chown -R node:node /home/node

# 3. 插件安装（作为 node 用户以避免后期权限修复带来的镜像膨胀）
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

# 4. 最终配置
USER root

# 复制初始化脚本
COPY ./init.sh /usr/local/bin/init.sh
RUN chmod +x /usr/local/bin/init.sh

# 设置环境变量
ENV HOME=/home/node \
    TERM=xterm-256color \
    NODE_PATH=/usr/local/lib/node_modules \
    PLAYWRIGHT_BROWSERS_PATH=/opt/browsers

# 暴露端口
EXPOSE 18789 18790

# 设置工作目录为 home
WORKDIR /home/node

# 使用初始化脚本作为入口点
ENTRYPOINT ["/bin/bash", "/usr/local/bin/init.sh"]
