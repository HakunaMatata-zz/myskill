# 本地补丁说明

本仓库的技能在原始上游基础上做了必要修补。升级上游时请重新应用。

---

## last30days-cn：浏览器代理支持

**问题**

技能启动 Playwright Chromium 时把启动参数写死为 `args=["--disable-blink-features=AutomationControlled"]`，不读取任何代理配置。Chromium 本身不识别 `HTTP_PROXY` / `HTTPS_PROXY` 环境变量，因此在必须经代理出网的环境中（企业内网、受限沙箱、部分代理软件的分流模式），浏览器会直连目标站点并被重置，报 `net::ERR_CONNECTION_RESET`。

失败时的表现具有误导性：`login` 命令仍会打印「登录成功」，因为它只比对 cookie 是否发生变化。实际抓到的是页面未加载完成时下发的访客临时 cookie，随后搜索会返回「页面要求登录」。**不要凭 login 的输出判断是否成功，必须跑一次实际搜索验证。**

**修改**

文件：`skills/last30days-cn/scripts/lib/crawler_bridge.py`

1. 新增常量 `_PROXY_ENV = "LAST30DAYS_PROXY"`（第 58 行附近）
2. 新增函数 `_proxy_server()`，按 `LAST30DAYS_PROXY` → `HTTPS_PROXY` → `http_proxy` 的顺序取值，跳过 `socks` 协议
3. `_browser_launch_kwargs()` 中追加 `kwargs["proxy"] = {"server": proxy}`

因为 `_launch_browser_context()` 和探针都通过 `_browser_launch_kwargs()` 传递启动参数，一处修改即可全局生效。

**行为变化**

- 有代理环境变量时，Chromium 自动走代理
- 无代理时行为与上游完全一致（`_proxy_server()` 返回空字符串，不注入 `proxy`）
- 想强制指定：`export LAST30DAYS_PROXY=http://127.0.0.1:7890`

**上游现状**

截至 v4.0.0-cn，上游未提供代理参数。若上游未来加入同名能力，本补丁可丢弃，改用上游实现。
