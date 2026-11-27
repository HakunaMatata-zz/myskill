# myskill

HakunaMatata 的 Agent Skills 集合。可复用的 SKILL 包，供 Claude Code / Codex / Cursor / Gemini CLI / WorkBuddy 等 Agent 直接调用。

## 技能清单

| 技能 | 用途 | 依赖 | 来源 |
|---|---|---|---|
| [`last30days-cn`](skills/last30days-cn/) | 中文互联网热点搜集与研究：微博、小红书、B站、知乎、抖音、微信公众号、百度、今日头条 8 平台，支持每日全网热榜（`--hot`）与 30 天主题研究 | Python 3.8+ 标准库（零必需依赖） | [Jesseovo/last30days-skill-cn](https://github.com/Jesseovo/last30days-skill-cn) |

## 安装

### 方式一：一键脚本（最快）

```bash
curl -fsSL https://raw.githubusercontent.com/HakunaMatata-zz/myskill/main/install.sh | sh -s last30days-cn
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

**开箱可用（无需登录、无需 Key）：** B站、今日头条、百度网页搜索、全网热榜。

**需要登录态（扫码一次即可，需 Playwright）：** 小红书、微博、知乎、抖音。

```bash
python -m pip install playwright && python -m playwright install chromium
python scripts/last30days.py login xiaohongshu   # 也支持 weibo / zhihu / douyin / bilibili
```

不登录不会报错，会降级为「热榜匹配 + 公开搜索」，报告里会明确标注「只有公开链接，缺少互动数据」。

**可选 Key：** `TIKHUB_API_KEY`（抖音）、`WECHAT_API_KEY`（公众号）、`BAIDU_API_KEY`（百度千帆）、`WEIBO_ACCESS_TOKEN`、`GITHUB_TOKEN`（提升额度）。详见技能内 `docs/usage.zh-CN.md`。

## 合规提示

本项目基于对公开页面与用户自有登录态的访问，**仅限学习研究**。禁止商用、禁止大规模高频抓取、禁止对外提供自动化采集服务。使用时请遵守各平台服务条款与 `robots.txt`。完整声明见 [`skills/last30days-cn/docs/usage.zh-CN.md`](skills/last30days-cn/docs/usage.zh-CN.md)。

## 许可

各技能沿用其原始许可证。`last30days-cn` 为 MIT License，原作者 [Jesse](https://github.com/Jesseovo)，上游为 Matt Van Horn 的 [last30days-skill](https://github.com/mvanhorn/last30days-skill)。本仓库仅做收集与分发，未修改技能源码。
