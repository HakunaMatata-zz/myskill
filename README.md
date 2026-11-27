# myskill

HakunaMatata 的 Agent Skills 集合。可复用的 SKILL 包，供 Claude Code / Codex / Cursor / Gemini CLI / WorkBuddy 等 Agent 直接调用。

## 技能清单

| 技能 | 用途 | 依赖 | 来源 |
|---|---|---|---|
| [`last30days-cn`](skills/last30days-cn/) | 中文互联网热点搜集与研究：微博、小红书、B站、知乎、抖音、微信公众号、百度、今日头条 8 平台，支持每日全网热榜（`--hot`）与 30 天主题研究 | Python 3.8+ 标准库（零必需依赖） | [Jesseovo/last30days-skill-cn](https://github.com/Jesseovo/last30days-skill-cn) |
| [`short-drama` 全家桶](skills/short-drama/)（12 个技能） | AI 短剧 / 漫剧全流程：原著分析 → 分集剧本 → 视觉设定 → 分镜 → 图/视频提示词 → 剪辑成片 → 审查 | Python 3.9+（部分技能需 ffmpeg） | [zenstory-ai/drama-skills](https://github.com/zenstory-ai/drama-skills) |

### short-drama 的 12 个技能分工

装了就是一套产线，彼此靠技能名路由，不需要手动调用。日常只用 `short-drama` 一个入口即可。

| 技能 | 职责 | 产出 |
|---|---|---|
| `short-drama` | 总控：立项、配置、制作形态、Lookdev 统筹、路由、创作台、打包 | `short-drama.json` |
| `short-drama-develop` | 开发创意、核心看点、改编方案、分集大纲 | 项目开发文档 |
| `short-drama-novel-analyze` | 拆解长篇原著、抽样快评、分集候选 | `项目开发/source-analysis/` |
| `short-drama-breakdown` | 拆解对标剧、同尺比对、视频反推剧本 | `项目开发/对标拆解.md` |
| `short-drama-write` | 写或改单集剧本 | `剧集/<EP>/剧本.md` |
| `short-drama-assets` | 人物、造型、地点、道具、声线设定 | `剧集/<EP>/视觉设定.md` |
| `short-drama-image-prompts` | 静态设定图、视觉调性图、首尾帧提示词 | `剧集/<EP>/图片提示词.md` |
| `short-drama-storyboard` | 分镜与首尾帧 | `剧集/<EP>/分镜.md` |
| `short-drama-video-prompts` | 视频动态提示词、配乐提示词 | `剧集/<EP>/视频提示词.md` |
| `short-drama-produce` | 调外部模型出图/出视频/配音（先预览，确认后执行） | 素材 |
| `short-drama-edit` | 编排剪辑单、渲染成片 | `剧集/<EP>/剪辑单.md`、`制作成果/成片/` |
| `short-drama-review` | 独立审稿、连戏核查、出片问题归因 | 审查报告 |

**核心机制「连戏锁」**：跨镜不变的穿着、造型被写成可原样贴入提示词的固定短语；每镜首帧写明出场设定；`creator_markdown_check.py` 自动核对跨文档引用。这是防穿帮的主力。

**所有付费生成都必须先预览再确认**，不会静默烧算力。

## 安装

### 方式一：一键脚本（最快）

```bash
# 装漫剧全套（12 个技能）
curl -fsSL https://raw.githubusercontent.com/HakunaMatata-zz/myskill/main/install.sh | sh -s drama

# 只装热点搜集
curl -fsSL https://raw.githubusercontent.com/HakunaMatata-zz/myskill/main/install.sh | sh -s last30days-cn

# 装全部
curl -fsSL https://raw.githubusercontent.com/HakunaMatata-zz/myskill/main/install.sh | sh -s all
```

脚本会自动探测已有的技能目录（`~/.claude/skills` → `~/.workbuddy/skills` → `~/.codex/skills`）。
要指定目录，前置 `SKILLS_DIR=/your/path`。查看可用技能：`sh install.sh list`。

> Windows 用户用 Git Bash 执行，或直接走方式二。

### 方式二：整仓克隆

```bash
git clone https://github.com/HakunaMatata-zz/myskill.git
```

把需要的技能目录拷进你的 Agent 技能目录：

```bash
# Claude Code / Codex / 通用 skills 目录
cp -r myskill/skills/last30days-cn ~/.claude/skills/

# WorkBuddy
cp -r myskill/skills/last30days-cn ~/.workbuddy/skills/
```

### 方式三：只取单个技能

```bash
git clone --depth 1 --filter=blob:none --sparse https://github.com/HakunaMatata-zz/myskill.git
cd myskill
git sparse-checkout set skills/last30days-cn
```

### 方式四：交给 Agent

把这句话发给你的 Agent：

```text
执行 curl -fsSL https://raw.githubusercontent.com/HakunaMatata-zz/myskill/main/install.sh | sh -s last30days-cn
安装技能，然后检查可用数据源并查看今天的全网热榜。
```

## 使用

```bash
cd <技能目录>

# 每日全网热榜（微博 / 百度 / 抖音 / 头条 / B站 / 知乎）
python scripts/last30days.py --hot

# 只关注某个方向的热点
python scripts/last30days.py --hot AI

# 主题研究：最近 7 天跨平台讨论
python scripts/last30days.py "AI 编程助手" --days 7

# 生成可离线阅读的 HTML 报告
python scripts/last30days.py "具身智能" --emit html-path

# 诊断各平台可用性
python scripts/last30days.py --diagnose
```

## 前置条件

**开箱可用（无需登录、无需 Key）：** B站、今日头条、百度网页搜索、全网热榜。热榜抓取完全不需要登录。

**需要登录态（扫码一次即可，需 Playwright）：** 小红书、微博、知乎、抖音。

```bash
python -m pip install playwright && python -m playwright install chromium
python scripts/last30days.py login xiaohongshu   # 也支持 weibo / zhihu / douyin / bilibili
```

不登录不会报错，会降级为「热榜匹配 + 公开搜索」，报告里会明确标注「只有公开链接，缺少互动数据」。

### 实测覆盖（2026-11-27）

| 平台 | 状态 | 实测结果 |
|---|---|---|
| 小红书 | ✅ 完整 | 19 条原始结果 / 4.6s（网页访客态即可搜索） |
| 知乎 | ✅ 完整 | 20 条原始结果 / 4.6s |
| 微博 | ✅ 完整 | 24 条原始结果 / 5s |
| 抖音 | ⚠️ 不稳定 | 首次 16 条成功，连续请求后触发风控失效。长期用请配 `TIKHUB_API_KEY`，热榜功能不受影响 |
| B站 | ✅ 完整 | 免登录 WBI 签名搜索 |
| 今日头条 | ✅ 完整 | 免登录 |
| 微信公众号 | ⚠️ 降级 | 搜狗微信触发反爬，需 `WECHAT_API_KEY` |
| 百度 | ⚠️ 降级 | 需 `BAIDU_API_KEY`（千帆 AI 搜索），否则走网页搜索易被验证码拦截 |

> **登录成功的判断不要只看 `login` 命令输出。** 它只比对 cookie 是否变化，页面加载失败时也会误报「登录成功」。装完必须跑一次 `python scripts/last30days.py "测试词" --search <平台> --days 7` 确认真的能返回结果。

### 多平台并发会互相挤掉

同时查多个平台时，技能默认并发开两个浏览器，实测小红书会被挤掉导致搜索失败。**建议固定串行**，写进 `~/.config/last30days-cn/.env`：

```ini
LAST30DAYS_BROWSER_CONCURRENCY=1
```

串行后微博 / 小红书 / 知乎三平台联合搜索稳定通过（5s + 12s + 9s）。代价是总耗时增加，可以接受。

### 代理环境必读

Chromium 不识别 `HTTP_PROXY` / `HTTPS_PROXY` 环境变量。如果你的机器需要走代理才能出网，必须先设置：

```bash
export LAST30DAYS_PROXY=http://127.0.0.1:7890   # 换成你的代理地址
```

否则浏览器会直连被重置，报 `ERR_CONNECTION_RESET`。本仓库已打补丁支持（会自动回退读取标准代理变量），详见 [PATCHES.md](PATCHES.md)。

**可选 Key：** `TIKHUB_API_KEY`（抖音，可替代登录）、`WECHAT_API_KEY`（公众号）、`BAIDU_API_KEY`（百度千帆）、`WEIBO_ACCESS_TOKEN`、`GITHUB_TOKEN`（提升额度）。详见技能内 `docs/usage.zh-CN.md`。

## 合规提示

本项目基于对公开页面与用户自有登录态的访问，**仅限学习研究**。禁止商用、禁止大规模高频抓取、禁止对外提供自动化采集服务。使用时请遵守各平台服务条款与 `robots.txt`。完整声明见 [`skills/last30days-cn/docs/usage.zh-CN.md`](skills/last30days-cn/docs/usage.zh-CN.md)。

## 许可

各技能沿用其原始许可证。`last30days-cn` 为 MIT License，原作者 [Jesse](https://github.com/Jesseovo)，上游为 Matt Van Horn 的 [last30days-skill](https://github.com/mvanhorn/last30days-skill)。本仓库仅做收集与分发，未修改技能源码。
