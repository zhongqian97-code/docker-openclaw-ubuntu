# OpenClaw Docker - Ubuntu 22.04 版本

🐳 基于 Ubuntu 22.04 的 OpenClaw 中国 IM 插件整合版 Docker 镜像。

基于 [justlovemaki/OpenClaw-Docker-CN-IM](https://github.com/justlovemaki/OpenClaw-Docker-CN-IM) 修改，将基础镜像从 `node:22-slim` 改为 `ubuntu:22.04`。

## 与原版的区别

| 项目 | 原版 | 本版 |
|------|------|------|
| 基础镜像 | `node:22-slim` (Debian) | `ubuntu:22.04` |
| Node.js 安装 | 镜像自带 | NodeSource 官方源安装 |
| Chromium | `chromium` | `chromium-browser` |
| 镜像体积 | 较小 | 较大 |

## 支持的平台

- ✅ 飞书（Feishu/Lark）
- ✅ 钉钉（DingTalk）
- ✅ QQ 机器人（QQ Bot）
- ✅ 企业微信（WeCom）
- ✅ Telegram

## 快速开始

### 1. 下载配置文件

```bash
wget https://raw.githubusercontent.com/zhongqian97-code/docker-openclaw-ubuntu/main/docker-compose.yml
wget https://raw.githubusercontent.com/zhongqian97-code/docker-openclaw-ubuntu/main/.env.example
```

### 2. 配置环境变量

```bash
cp .env.example .env
nano .env
```

最小配置：

| 环境变量 | 说明 | 示例值 |
|----------|------|--------|
| MODEL_ID | AI 模型名称 | gpt-4 |
| BASE_URL | AI 服务 API 地址 | https://api.openai.com/v1 |
| API_KEY | AI 服务 API 密钥 | sk-xxx... |

### 3. 启动服务

```bash
docker-compose up -d
```

### 4. 查看日志

```bash
docker-compose logs -f
```

## 自行构建

```bash
git clone https://github.com/zhongqian97-code/docker-openclaw-ubuntu.git
cd docker-openclaw-ubuntu
docker build -t docker-openclaw-ubuntu:latest .
```

## Docker 镜像地址

- GitHub Container Registry: `ghcr.io/zhongqian97-code/docker-openclaw-ubuntu:latest`

## 环境变量说明

详细的环境变量配置请参考 [.env.example](.env.example) 文件或原项目文档：
- [OpenClaw-Docker-CN-IM](https://github.com/justlovemaki/OpenClaw-Docker-CN-IM)

## 端口说明

- `18789` - OpenClaw Gateway 端口
- `18790` - OpenClaw Bridge 端口

## 许可证

本项目基于 OpenClaw 构建，遵循 GNU General Public License v3.0 (GPL-3.0) 许可证。

## 致谢

- [OpenClaw](https://github.com/openclaw/openclaw) - 原项目
- [justlovemaki/OpenClaw-Docker-CN-IM](https://github.com/justlovemaki/OpenClaw-Docker-CN-IM) - 原 Docker 整合版
