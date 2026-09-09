# 迭代记录 / Release and iteration history

本记录合并历史 README、版本说明、源码与实际 GitHub 提交。每个版本按“问题 → 改动 → 优化结果 → 验证/边界”记录。提交日期是上传日期，不自动等于开发完成或 App Store 发布日期；未找到独立证据的版本差异明确注明。

This history combines earlier READMEs, version notes, source, and actual GitHub commits. Each entry describes the problem, change, benefit, and verification or limits. Commit dates are upload dates, not necessarily development or App Store release dates. Missing evidence is stated explicitly.

<a id="v250"></a>
## v2.5.0 — 本地陪伴预览 / Local companion preview

工程交付：2026-09-08；源码上传核验：2026-09-09。现有 GitHub 标签为 `V2.5`。

Engineering delivery: 2026-09-08. Source upload verified: 2026-09-09. Existing GitHub tag: `V2.5`.

### 中文：从需要配置的 AI 功能，到原生桌面陪伴

**1. 本地聊天与旧云端功能下线**

- 问题：用户填写 API key 或跳转网页才能聊天，不符合普通用户直接使用桌宠的目标。
- 改动：AppKit 原生对话窗口接入嵌入式 llama.cpp；内置模型构建使用 Qwen3-0.6B Q8，支持可选 1.7B Q8 下载。加入消息气泡、浅深色外观、窗口调整、逐步输出、取消与新对话。
- 移除：ChatGPT 网页聊天入口、OpenAI API 设置及网络请求。正式应用升级时只尝试删除旧钥匙串条目，不读取旧密钥。
- 优化结果：普通用户无需第三方账号、密钥、Ollama、Node.js，也没有按次云端模型费用。模型数据固定版本并校验 SHA-256；可选下载有进度、取消、重试、删除。
- 边界：小模型表达与准确性有限；CPU 推理速度随机器和上下文变化；短回答可能一次显示完成。额外下载不支持跨重启断点续传，没有新增语音互动。

**2. 每日新闻：准确日期、出处和持久化防重复**

- 问题：用户希望猫在当天首次打开时主动介绍当地关键新闻，同时避免重复打扰。
- 改动：按所选国家、城市和所在地时区筛选当天 RSS/Atom 条目；最多三条，保留原文标题、时间和链接。优先本国源与城市标题匹配，随后按发布时间排序；无本国源时使用已配置国际专题源。
- 优化过程：加入旧闻/未来/无日期过滤、链接限制、去重；把每日自动尝试标记持久化，覆盖退出重启场景。失败不反复自动重试，可手动重试；后台跨午夜不主动弹窗，下次激活再检查。
- 当前来源：GOV.UK、Beehive、英国外交部门与 NASA。联合国候选源默认禁用；公开访问不等于任意商用。
- 边界：尚未覆盖所有城市与国家；不保证每天恰好 2–3 条，也不等于专业编辑筛选的全球热点。标题保持来源语言，不生成未经验证的 AI 新闻摘要。新闻默认关闭。

**3. 桌面猫：更多行为与较少权限**

- 问题：原有角色互动较有限，需要在桌面形成更自然的陪伴。
- 改动：独立透明桌宠窗口、观察鼠标、扑跳、左右奔跑、窗口边缘停留、睡觉、被戳后的生气状态、抚摸、间隔求摸和拖动。双击聊天，右键选择动作或回小窝。
- 优化结果：提供安静模式和减少动态效果；只读取鼠标与公开窗口几何，不读取屏幕截图、标题或剪贴板，不执行其他应用的输入操作。无法获取窗口时回退桌面边缘。
- 边界：复用原 idle/waving/running 图像与位移、旋转和状态符号；专用睡眠、生气、趴卧动画帧尚待补齐。多显示器、Spaces、全屏、最小化行为未完成全场景实机验收。

**4. Today Memory → Long-term Memory**

- 问题：只看当前一句话的聊天缺少连续性，但简单累积信息容易误记用户习惯。
- 改动：记录礼拜喵实际观察到的应用内事件；用户显式“记住：…”可成为长期事实；重复模式至少要有三个不同日期的证据。临时疲惫不自动固化为长期人格标签。
- 优化结果：记忆默认关闭，可查看、编辑、清除。关闭记忆时取消生成并清空会话上下文。没有互动只表示观察范围，不推断用户没有礼拜或正在工作。
- 边界：归纳是规则式实现，仍需误记忆与遗忘体验验收。记忆是本地 JSON，并非应用级加密；最多约 1,000 条/30 天日记与 100 条长期事实，需持续验证保留策略。

**5. 本地备忘检索**

- 问题：旧版能保存备忘，但聊天无法自然利用已保存内容。
- 改动：检索应用自身 KnowledgeSpace 的 Markdown 文件，支持中文双字/英文关键词、文件出处与限定片段；限制读取大小和上下文长度。
- 优化结果：对话能够使用相关备忘片段，不必把所有个人文件导入云端。用户管理记忆与备忘的操作相互区分。
- 边界：不扫描整台电脑、不接入 Apple Notes；关闭聊天记忆不会删除用户的备忘文件。片段检索不等于保证模型准确引用。

**6. 面向公开分发的工程整理与验证过程**

1. 基于 v2.4.1 的原生 Objective-C/AppKit 工程接入模块，保留礼拜、斋月、备忘与 MapKit 功能。
2. 固定 llama.cpp 提交和模型来源/哈希，把推理编译进应用；GitHub 构建脚本在依赖缺失时获取固定版本。
3. 设置 macOS 13.0 部署目标、构建 arm64/x86_64 并合并 Universal 2；修正构建配置顺序导致的部署目标偏差后重新检查二进制。
4. 整理沙盒权限、隐私清单、许可说明和发布门槛。聊天/记忆本地处理，礼拜服务、地图、新闻、模型下载仍联网。
5. 检查聊天面板浅深色与不同宽度，修正深色背景表现；执行核心检查、真实推理和取消测试，检查临时签名。
6. 试用包使用独立 `com.yuqiqi.salahcat.preview` 标识；正式发行仍需发行者证书与审核信息。

已完成：33 项核心检查、本机真实 0.6B 问答与取消、两架构编译、部署版本字段检查、临时签名验证；在沙盒应用观察到真实聊天与当天新闻。尚未完成：Intel/macOS 13 实机、长期耗电、多显示器、低磁盘/断网/下载异常、记忆删除的完整用户流程与新增界面的完整阿语/乌尔都语本地化。

### English: from AI setup to a native desktop companion

**1. Local chat replaces cloud configuration**

- Problem: requiring a key or a separate website made conversation harder for ordinary users.
- Change: a native AppKit panel connects to embedded llama.cpp. Bundled-model builds use Qwen3-0.6B Q8, with an optional 1.7B Q8 download. Bubbles, light/dark appearance, resizing, progressive output, cancellation, and new conversations were added.
- Removed: ChatGPT chat links, OpenAI API settings, and API requests. A production-app upgrade only attempts to delete the legacy keychain item; it does not read the old key.
- Benefit: no account, key, Ollama, Node.js, or per-request cloud-model fee for users. Model versions and SHA-256 hashes are pinned; optional downloads have progress, cancellation, retry, and deletion.
- Limits: small-model quality and CPU speed vary. Short replies may arrive all at once. Downloads do not resume across restarts; voice interaction was not added.

**2. Daily news with dates, attribution, and persistent deduplication**

- Problem: provide a first-opening news greeting without repeatedly interrupting the user.
- Change: filter RSS/Atom entries by the selected country's, city's, and timezone's current date; show up to three original headlines with dates and links. Prefer configured domestic sources and city-title matches, then recency; fall back to configured international topics.
- Refinement: reject old, future, undated, invalid-link, and duplicate items. Persist the daily automatic-attempt marker across restarts. Failures do not cause repeated automatic reports; manual retry is available. Crossing midnight in the background does not trigger a popup.
- Sources: GOV.UK, Beehive, UK foreign-affairs updates, and NASA. The UN candidate is disabled. Public availability does not establish unrestricted commercial reuse.
- Limits: coverage is incomplete and neither exactly two or three items nor editorially selected global headlines are guaranteed. Original headline language is retained, without unverified AI summaries. News is off by default.

**3. More pet behavior within limited permissions**

- Problem: expand the original character's limited interactions into desktop companionship.
- Change: a separate transparent pet window supports cursor watching, pouncing, running, window-edge resting, sleep, annoyance after poking, petting, occasional attention requests, and dragging. Double-click opens chat; the context menu selects behaviors or returns home.
- Benefit: quiet mode and reduced motion are available. Only cursor position and public window geometry are used, without screenshots, window titles, clipboard reads, or input into other apps. Missing geometry falls back to desktop edges.
- Limits: existing idle/waving/running frames plus transforms and symbols represent the new states. Dedicated sleep/annoyance/resting art and complete multi-display, Spaces, fullscreen, and minimized-window validation remain outstanding.

**4. Today Memory → Long-term Memory**

- Problem: conversation needs continuity, but indiscriminate accumulation can create false assumptions about users.
- Change: record events actually observable inside Prayer Cat. Explicit “Remember: …” requests may become facts; inferred patterns need evidence from at least three distinct days. Temporary tiredness does not automatically become a permanent trait.
- Benefit: memory is opt-in, inspectable, editable, and clearable. Disabling it cancels generation and clears conversation context. Lack of interaction is not interpreted as lack of prayer or active work.
- Limits: inference is rule-based and needs further false-memory/forgetting evaluation. Storage is local JSON, not application-encrypted. Approximate caps are 1,000 events/30 days and 100 long-term facts; retention behavior needs ongoing validation.

**5. Retrieval from local notes**

- Problem: previously saved notes were not naturally available to chat.
- Change: retrieve bounded snippets from Markdown files in the app's KnowledgeSpace using Chinese bigrams/English keywords and filename attribution, with read-size and context limits.
- Benefit: relevant notes can inform replies without uploading personal files to a cloud model. Memory and note management remain distinct.
- Limits: no whole-disk scan or Apple Notes integration. Disabling memory does not delete notes. Retrieval does not guarantee accurate model quotations.

**6. Distribution engineering and validation sequence**

1. Integrated the modules into the v2.4.1 Objective-C/AppKit application while retaining prayer, Ramadan, notes, and MapKit features.
2. Pinned llama.cpp and official model revisions/hashes; embedded inference in the binary. The GitHub build bootstrap obtains the fixed dependency when absent.
3. Set macOS 13.0, compiled arm64/x86_64, and combined Universal 2. Corrected configuration ordering that produced the wrong minimum deployment target, then reinspected binaries.
4. Added sandbox configuration, privacy manifest, license information, and release gates. Chat/memory stay local; external information and model downloads still use the network.
5. Checked narrow/wide and light/dark chat rendering, corrected dark backgrounds, ran core checks and real inference/cancellation, and verified ad-hoc signing.
6. Used the separate `com.yuqiqi.salahcat.preview` identifier. Formal distribution still needs publisher signing and review information.

Completed: 33 core checks, real local 0.6B inference/cancellation, dual-architecture compilation, deployment-field and ad-hoc signature checks, plus observed sandboxed chat and dated news. Outstanding: Intel/macOS 13 hardware runs, sustained power use, multiple displays, low-disk/offline/download failures, full memory-deletion user flows, and complete Arabic/Urdu localization of new screens.

<a id="v241"></a>
## v2.4.1 — 免密钥地图版交付 / Key-free MapKit delivery

GitHub 上传记录 / Upload evidence: 2026-08-23.

**中文**

- 基线：延续 v2.4 的附近清真寺能力，以及既有礼拜、斋月和备忘功能。
- 可核实改动：仓库加入标记为 v2.4.1 的源码 ZIP 和 MapKit 免密钥安装 ZIP；公开 `src/` 中的原生入口与清真寺模块；README 四种语言增加附近清真寺介绍并更新版本引用。
- 优化点：说明普通用户无需 Google API key，明确授权定位、路线跳转和可选礼拜前建议的流程。
- 证据边界：没有独立记录证明 v2.4 → v2.4.1 包含哪些额外底层修复，因此不虚构修复条目。旧 README 指向 v2.4.1 Release，但本次核验未找到该独立 Release；实际 ZIP 在仓库根目录。
- 历史状态：该阶段仍描述用户自带 OpenAI API key 的聊天，直到 v2.5.0 才移除。

**English**

- Baseline: retains v2.4 mosque discovery alongside prayer, Ramadan, and notes.
- Verified changes: v2.4.1 source and key-free MapKit application ZIPs were uploaded; native entry-point and mosque modules appeared in `src/`; four-language README text added mosque discovery and updated version references.
- Improvement: clarified that users need no Google API key and explained location consent, route handoff, and optional pre-prayer suggestions.
- Evidence limit: no independent record identifies additional low-level v2.4-to-v2.4.1 fixes, so none are invented here. The old README linked to a v2.4.1 Release, but none was found during this audit; the ZIPs are at repository root.
- Historical state: this stage still documented user-key OpenAI chat, removed only in v2.5.0.

<a id="v24"></a>
## v2.4 — 原生附近清真寺 / Native nearby mosques

来源为保留的版本说明；没有独立发布日期证据。Based on retained version notes; no independently verified release date.

**中文**

- 问题：从礼拜提醒进一步帮助用户寻找附近礼拜地点，避免普通用户配置开发者密钥。
- 新增：MapKit 地图与当前位置、原生清真寺搜索、10 公里范围最多 10 条的直线距离排序列表、Apple Maps 路线，以及主动开启的礼拜前清真寺建议通知。
- 优化点：由系统地图服务承担搜索，不要求注册 Google Cloud；位置仅用于用户发起的搜索或已开启的提醒，不保存精确位置历史。版本说明记录自动刷新最多每 6 小时一次，关闭提醒删除待发清真寺建议。
- 保留：多语言文案、Intel/Apple Silicon 通用构建、既有礼拜/斋月/备忘。
- 边界：Google Places 仅预留架构入口，并未成为当前用户功能；临时签名不代表 App Store 发行验证。

**English**

- Problem: help users find a prayer location without requiring developer credentials.
- Added: native MapKit map/current location, mosque search, up to ten results within 10 km sorted by straight-line distance, Apple Maps directions, and opt-in pre-prayer mosque suggestions.
- Improvement: system map services replace Google Cloud setup. Location is tied to searches or enabled reminders, with no precise location history stored. Retained notes specify refresh at most every six hours and removal of pending suggestions when disabled.
- Retained: multilingual text, Intel/Apple Silicon universal builds, prayer/Ramadan/notes features.
- Limits: Google Places was only an architectural placeholder, not a shipped user feature. Ad-hoc signing does not establish App Store readiness.

<a id="v23"></a>
## v2.3 — 斋月与多语言基础 / Ramadan and multilingual foundation

GitHub 首次公开记录与 Release：2026-08-23。First public repository record and release: 2026-08-23.

**中文**

- 目标：为穆斯林用户提供礼拜意识、本地记录与桌面陪伴。
- 可核实内容：版本说明记录恢复斋月模式，中/英/阿/乌尔都语支持，本地备忘与知识空间，使用主体猫形象的应用图标；充值和礼包功能下线。
- README 随后补充产品定位、礼拜时间与温柔提醒、隐私原则、角色互动和当时的可选 AI 聊天介绍，并增加 Release 下载入口。
- 优化点：收拢产品范围，让礼拜、斋月和个人记录成为核心体验；在仓库中建立安装包与使用说明。
- 边界：后续 README 丰富不代表同日每次提交都是新功能发布；没有足够资料重建 v2.3 之前的详细版本。不将旧“App Store 准备版”措辞解释为已过审。

**English**

- Goal: prayer awareness, private reflection, and desktop companionship for Muslim users.
- Verified content: restoration of Ramadan Mode; Chinese, English, Arabic, and Urdu support; local notes/knowledge space; a cat-based app icon; removal of recharge and gift-package functionality.
- Later README updates described the product, prayer reminders, privacy principles, character interaction, and then-optional AI chat, and added the release download link.
- Improvement: focused the product on prayer, Ramadan, and personal records, with installation materials and documentation in the repository.
- Limits: richer README text does not prove that each same-day commit shipped new functionality. Evidence is insufficient to reconstruct detailed versions before v2.3. Earlier “App Store-ready” wording does not mean approval was obtained.

## 上传核验与文档整理 / Upload audit and documentation consolidation

**2026-09-09**：核验 74 个源码/素材/文档 blob 与本地候选完全一致。`V2.5` Release 当时仅包含 README 和 CHANGELOG 两份附件；手动展开的应用目录缺失运行资源。此次整理保留历史能力，明确新旧云聊天差异、版本证据、优化过程与未完成项，提供中英对应内容。

**2026-09-09**: all 74 source/asset/document blobs matched the local candidate. At that point, the `V2.5` Release had only README and CHANGELOG attachments; the expanded application directory was missing runtime resources. This documentation consolidation preserves historical capabilities while distinguishing old cloud chat from new local chat, documenting evidence, refinement steps, and outstanding work in both languages.

## 历史证据 / Historical evidence

- [v2.3 初始 README / Initial README](https://github.com/kiki177/prayer-cat/blob/2dd470ec020f01e037025f4f9ec50107c1e5e926/README.md)
- [v2.3 Release](https://github.com/kiki177/prayer-cat/releases/tag/v2.3)
- [v2.4 保留说明 / Retained version notes](src/README-v2.4.md)
- [v2.4.1 README 快照 / README snapshot](https://github.com/kiki177/prayer-cat/blob/278fe1f377dfbac1ca215dff5280e1bea7ace8a9/README.md)
- [v2.4.1 源码上传 / Source upload](https://github.com/kiki177/prayer-cat/commit/292e6cf54b60c314ead8e2ca3cd7714f618cf78b)
- [v2.4.1 包与说明同步 / Packages and README](https://github.com/kiki177/prayer-cat/commit/278fe1f377dfbac1ca215dff5280e1bea7ace8a9)
- [v2.5.0 上传记录 / Upload record](https://github.com/kiki177/prayer-cat/commit/7a456ed4a04f3ca983689534ae974447497a890a)
- [应用目录上传 / Expanded application upload](https://github.com/kiki177/prayer-cat/commit/2244faa2e52f0ab618120329b9e29cb0d675744a)
- [验证报告 / Validation report](docs/TEST-REPORT-v2.5.0.md) · [发布门槛 / Release gates](src/RELEASE-GATES.md)
