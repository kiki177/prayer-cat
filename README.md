# 礼拜喵 · Prayer Cat

**一只陪你感知礼拜时间、记录思考，并在桌面安静陪伴的原生 macOS 猫咪。**

**A native macOS cat companion for prayer awareness, personal reflection, and quiet company on your desktop.**

[中文](#中文) · [English](#english) · [中英双语迭代记录 / Bilingual history](CHANGELOG.md) · [源码 / Source](src/) · [反馈 / Feedback](https://github.com/kiki177/prayer-cat/issues)

## 中文

### 产品定位

礼拜喵面向希望在工作、学习和生活中保持礼拜节奏的穆斯林用户。它把礼拜时间、温柔提醒、斋月模式、本地备忘与桌面猫结合在一起。v2.5.0 进一步加入本地 AI 聊天、每日新闻、丰富的桌宠互动以及可编辑的本地记忆。

产品的原则是：时间来自可核对的数据；提醒保持克制；个人记录留在本机；AI 不替代宗教学者，也不虚构礼拜时间。充值与礼包功能已在历史版本中下线。

名称延续：中文「礼拜喵」、English「Prayer Cat」、Arabic「Salah Cat」、Urdu「Namaz Cat」。

### 当前版本与下载状态

当前开发版本是 **v2.5.0 预览工程**。GitHub 已有的发布标签名为 [`V2.5`](https://github.com/kiki177/prayer-cat/releases/tag/V2.5)，它不是另一个功能版本。

2026-09-09 核验结果：

- `src/`、素材、测试和原有更新文档共 74 个文件，与本地待上传版本的 Git blob 哈希一致，源码上传成功。
- `V2.5` 发布页当时只有两份 Markdown 附件，尚未附上完整的 v2.5.0 安装 ZIP 与完整源码 ZIP。
- 根目录中手动展开上传的 `.app` 缺少模型、Info.plist 和部分资源，**不要把它当作完整安装包下载运行**。
- 可浏览和构建当前 `src/`。历史 [v2.3 Release](https://github.com/kiki177/prayer-cat/releases/tag/v2.3) 和仓库中的 v2.4.1 ZIP 不包含 v2.5.0 新功能。

该核验是带日期的上传快照。后续附件以发布页实际文件为准；只有说明文字中列出文件名，不代表文件已经上传。

### 功能总览

| 模块 | 目前提供什么 | 使用边界 |
| --- | --- | --- |
| 礼拜时间与提醒 | 根据城市、国家、计算方式取得每日礼拜时间，显示下一次礼拜并轻提醒 | 数据获取失败时不编造时间 |
| 斋月模式 | 延续历史版本的 Ramadan Mode，提供更安静、专注的陪伴体验 | 不等于自动识别用户宗教行为 |
| 附近清真寺 | Apple MapKit 地图、定位后搜索、按直线距离排序、Apple Maps 路线、可选礼拜前建议 | 用户主动搜索或开启提醒后使用位置；无需 Google API key |
| 本地备忘 | KnowledgeSpace 保存个人想法、学习记录与每日计划 | 保存于当前用户本机空间 |
| 本地聊天 | 原生消息气泡、调整窗口、浅深色外观、逐步显示回答、停止生成、新对话 | 轻量模型可能答错；速度受硬件和上下文影响 |
| 每日新闻 | 用户启用后，按所在地日期筛选最多三条新闻，显示标题、时间和出处；当天重开不重复自动播报 | 来源覆盖有限，不保证每个城市每天都有 2–3 条关键时事 |
| 桌面猫 | 看鼠标、扑跳、奔跑、窗边停留、睡觉、生气、抚摸、求摸、拖动、双击聊天 | 复用原素材与变换，专用新动作美术帧尚待补齐 |
| 本地记忆与检索 | 今日事件、显式长期事实、重复模式归纳、编辑清除，以及应用内 Markdown 备忘片段检索 | 默认关闭；不监视其他应用，不扫描整台电脑或 Apple Notes |

### v2.5.0 的关键优化

**从云端配置走向本机聊天。** 旧版要求用户提供 OpenAI API key，或跳转 ChatGPT。新版移除了这些入口与请求，改用编译在应用内的 llama.cpp 和 Qwen 模型。带内置模型的应用构建可使用约 639 MB 的 Qwen3-0.6B Q8，支持可选下载 1.7B Q8。普通用户无需账号、密钥、Ollama 或 Node.js；没有按次云端模型调用费用，但仍消耗本机计算资源。

**从反复打扰走向每日一次。** 新闻与记忆默认关闭。启用新闻后，首次自动尝试标记持久化保存，即使请求失败，当天重开也不会再次自动播报；可手动重试。按照所在地时区判断当天，排除旧闻、未来日期、无日期及重复条目，不拿旧闻凑数。当前主要来源是 GOV.UK、Beehive、英国外交部门与 NASA；原文标题不经过未经验证的 AI 摘要。

**从一次观察走向有证据的记忆。** “记住：我喜欢轻提醒”可成为长期事实；重复行为模式至少需要三个不同日期的证据。“今天有点累”不会直接变成永久标签。没有与猫互动，不代表没有礼拜或正在工作。记忆可查看、编辑、清除，关闭记忆会取消当前生成并清空会话上下文。

**从静态摆件走向有边界的互动。** 桌面猫只使用鼠标位置和公开窗口几何，不读取屏幕截图、窗口标题或剪贴板，不替用户操作其他应用。读取不到可用窗口时回退桌面边缘；提供安静模式与减少动态效果。

### 使用与构建

有完整试用包时：解压应用 → 设置城市/国家/礼拜计算方式 → 点击“和我聊聊吧” → 在陪伴设置自主启用新闻与记忆 → 菜单“到桌面散步”。试用构建使用独立应用标识，避免覆盖正式版数据。

开发者从当前源码构建：

```sh
git clone https://github.com/kiki177/prayer-cat.git
cd prayer-cat/src
bash scripts/build.sh
```

需要 macOS、Xcode / Command Line Tools、CMake 3.22+、Python 3.11+ 和 Git。首次构建在依赖缺失时获取固定提交的 llama.cpp，并下载、校验模型；生成 arm64/x86_64 Universal 2 包。这些开发工具不是普通安装用户的使用前提。详细说明见 [`src/README.md`](src/README.md)。

### 隐私、验证与上架状态

聊天与记忆不发送到云端模型；记忆以本地 JSON 保存，**并非应用级加密数据库**。礼拜时间服务、地图、新闻和可选模型下载仍需联网。没有新增麦克风、录屏或辅助功能权限。原有位置请求用于附近清真寺等已说明功能。

已完成 33 项核心检查、实际本地模型问答/取消、两架构编译、最低部署版本字段和临时签名检查。已在沙盒试用应用中观察到真实聊天与当天新闻。**Intel 仅交叉编译；macOS 13 部署字段验证不是 macOS 13 实机验收。**

当前不应宣传为已过审或完整上架成品：仍需正式分发签名、真实隐私/支持网址、素材与新闻授权确认、长期耗电和异常场景测试、多显示器验收、完整本地化。旧主体有中/英/阿/乌尔都语，新界面目前中英完整，阿语/乌尔都语回退英文。

参阅 [测试报告](docs/TEST-REPORT-v2.5.0.md)、[发布门槛](src/RELEASE-GATES.md)、[许可与来源说明](src/Privacy-and-Licenses.txt)。

## English

### What Prayer Cat is

Prayer Cat helps Muslim users stay aware of prayer while working, studying, or creating. It combines daily prayer times, gentle reminders, Ramadan Mode, private notes, and a desktop cat. The v2.5.0 preview adds on-device AI chat, daily news, richer pet interactions, and editable local memories.

The guiding principles remain verifiable timings, restrained reminders, local personal records, and clear AI boundaries. The cat is not a religious authority and must not invent prayer times. Recharge and gift-package features were removed in earlier versions.

The names remain 礼拜喵 in Chinese, Prayer Cat in English, Salah Cat in Arabic, and Namaz Cat in Urdu.

### Version and download status

The current development version is **v2.5.0 preview**. Its existing GitHub release tag is [`V2.5`](https://github.com/kiki177/prayer-cat/releases/tag/V2.5); this is a tag naming difference, not a separate feature version.

Audit on 2026-09-09:

- All 74 source, asset, test, and documentation files matched the local upload candidate by Git blob hash. The source upload succeeded.
- At audit time, `V2.5` contained only two Markdown attachments, without the complete v2.5.0 application ZIP or full-source ZIP.
- The manually expanded `.app` directory in the repository lacks the model, Info.plist, and other resources. **It is not a complete runnable distribution.**
- Current source is available in `src/`. The historical [v2.3 release](https://github.com/kiki177/prayer-cat/releases/tag/v2.3) and v2.4.1 ZIPs do not include the v2.5.0 features.

This is a dated upload snapshot. Check actual release attachments for later additions; a filename mentioned in release notes does not establish that the file was uploaded.

### Features

| Area | Current behavior | Boundary |
| --- | --- | --- |
| Prayer times and reminders | Daily timings from the selected city, country, and method; next-prayer awareness and gentle reminders | No invented fallback timings |
| Ramadan Mode | Retains the quieter Ramadan companion experience | Does not detect a user's religious activity |
| Nearby mosques | Native MapKit map and search, straight-line distance sorting, Apple Maps routes, optional pre-prayer suggestions | Location follows user action or opt-in; no Google API key required |
| Private notes | KnowledgeSpace for reflections, learning notes, and daily plans | Stored in the current user's local space |
| On-device chat | Native bubbles, resizable panel, light/dark appearance, progressive replies, cancellation, new conversations | Small models can be wrong; performance depends on hardware and context |
| Daily news | Opt-in same-day items with title, date, and source; up to three; no repeated automatic report after reopening that day | Limited coverage; no guarantee of key headlines for every city |
| Desktop pet | Cursor watching, pouncing, running, window-edge resting, sleep, annoyance, petting, attention requests, dragging, double-click chat | Existing frames and transforms; dedicated new animation artwork remains incomplete |
| Memory and retrieval | Daily events, explicit facts, repeated-pattern inference, editing/deletion, snippets from the app's Markdown notes | Off by default; no monitoring other apps, whole-disk scan, or Apple Notes integration |

### What v2.5.0 improves

**Local conversation replaces cloud setup.** Earlier chat used a user-supplied OpenAI key or a ChatGPT link. These settings, links, and requests have been removed. The application embeds llama.cpp and supports Qwen models. Bundled builds include the approximately 639 MB Qwen3-0.6B Q8 model, with an optional 1.7B Q8 download. End users need no account, key, Ollama, or Node.js. There is no per-request cloud-model fee, although local computing resources are required.

**Daily persistence reduces interruption.** News and memory are opt-in. Automatic news attempts are persisted by local date, including failed attempts; reopening on the same day does not trigger another automatic report. Manual retry remains available. Filtering uses the selected location's timezone and rejects old, future, undated, or duplicate items. Current sources include GOV.UK, Beehive, UK foreign-affairs updates, and NASA. Original headlines are retained instead of unverified AI summaries.

**Evidence separates events from long-term memory.** Explicit requests such as “Remember: I prefer gentle reminders” can become facts. Inferred patterns need evidence from at least three distinct days. Temporary tiredness does not become a permanent personality label. No interaction does not imply no prayer or active work. Memories can be inspected, edited, and cleared; disabling memory cancels generation and clears conversation context.

**Pet interaction stays within clear limits.** The cat uses cursor position and public window geometry. It does not read screenshots, window titles, or the clipboard, and does not control other applications. Unavailable window geometry falls back to desktop edges. Quiet mode and reduced motion are supported.

### Use and build

With a complete preview package: unzip the app, configure location and prayer method, open chat, optionally enable news and memory, then choose the desktop-walk menu. The preview uses a separate application identifier to keep its data separate from the production app.

```sh
git clone https://github.com/kiki177/prayer-cat.git
cd prayer-cat/src
bash scripts/build.sh
```

Developers need macOS, Xcode / Command Line Tools, CMake 3.22+, Python 3.11+, and Git. The build obtains the pinned llama.cpp revision if missing, downloads and verifies the model, and produces an arm64/x86_64 Universal 2 package. End users do not need these development tools. See [build instructions](src/README.md).

### Privacy and release readiness

Chat and memories are not sent to a cloud model. Memory is local JSON, not an application-encrypted database. Prayer services, maps, news, and optional model downloads still use the network. No microphone, screen-recording, or Accessibility permission was added.

Validation includes 33 core checks, real local inference and cancellation, dual-architecture compilation, deployment-target inspection, and ad-hoc signature checks. Chat and dated news were observed in a sandboxed preview. Intel was cross-compiled only; a macOS 13 deployment field is not a macOS 13 runtime test.

This is not an App Store-approved finished release. Distribution signing, genuine privacy/support URLs, rights review, long-running power and failure tests, multi-display validation, and complete localization remain outstanding. The older interface includes Chinese, English, Arabic, and Urdu; new screens currently have complete Chinese/English strings and fall back to English for Arabic/Urdu.

See the [test report](docs/TEST-REPORT-v2.5.0.md), [release gates](src/RELEASE-GATES.md), and [licenses/source attribution](src/Privacy-and-Licenses.txt).

## 版本导航 / Version history

| 版本 / Version | 核心变化 / Main change | 记录 / Record |
| --- | --- | --- |
| v2.3 | 斋月、多语言与本地知识空间；下线充值礼包 / Ramadan, multilingual local notes; recharge/gifts removed | [历史 / History](CHANGELOG.md#v23) |
| v2.4 | 原生 MapKit 清真寺搜索与路线 / Native MapKit mosque search and routes | [历史 / History](CHANGELOG.md#v24) |
| v2.4.1 | 免密钥版本源码、安装包与介绍同步 / Key-free source/package and documentation alignment | [历史 / History](CHANGELOG.md#v241) |
| v2.5.0 | 本地聊天、新闻、记忆与桌宠行为 / Local chat, news, memory, and pet behaviors | [历史 / History](CHANGELOG.md#v250) |

## 参考与许可 / References and licensing

交互方向参考 / Interaction references: [Mochi](https://github.com/NatBrian/mochi-llm-pet), [Miru](https://github.com/kiyotakali/Miru), [Open-LLM-VTuber](https://github.com/Open-LLM-VTuber/Open-LLM-VTuber).

未移植这些项目的角色素材、音频或 Python/Windows/Live2D 代码。推理使用 llama.cpp 与 Qwen 官方模型，各许可证按各自范围适用；不得据此推断整个应用及角色素材自动采用同一许可。

No character assets, audio, or Python/Windows/Live2D implementations were ported from these references. Inference uses llama.cpp and official Qwen models. Each upstream license applies to its own material and does not automatically license the entire application or character artwork.
