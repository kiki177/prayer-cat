# 礼拜喵 · Prayer Cat

原生 macOS 礼拜提醒与桌面猫陪伴应用。

**v2.5.0 本地陪伴预览版**加入了无需 API key 的桌面聊天、每日新闻、桌宠动作，以及本地记忆和备忘检索。当前是可编译的工程预览版本，尚未完成正式 App Store 发布验收。

[详细更新日志](CHANGELOG.md) · [使用与构建](src/README.md) · [测试记录](docs/TEST-REPORT-v2.5.0.md) · [上架前清单](src/RELEASE-GATES.md) · [反馈](https://github.com/kiki177/prayer-cat/issues)

## 本次更新

| 模块 | v2.5.0 的变化 |
| --- | --- |
| 桌面聊天 | 原生消息气泡、逐步显示回复、取消、新对话；内置 Qwen3-0.6B 的试用包可离线聊天，支持可选 1.7B 模型 |
| 移除旧云聊天 | 下架 ChatGPT 网页入口与 OpenAI API 设置、调用；普通用户无需账号或密钥 |
| 每日新闻 | 启用后按所在地时区筛选当天新闻，最多三条，带日期和原文链接；当天退出重开不重复自动播报 |
| 桌宠互动 | 看鼠标、扑跳、奔跑、窗边停留、睡觉、生气、抚摸、求摸、拖动与双击聊天 |
| 本地记忆 | 区分当日事件与长期事实；支持明确记忆、重复模式归纳、查看编辑清除 |
| 备忘检索 | 对话调用应用内 KnowledgeSpace 的相关 Markdown 片段，不扫描其他个人文件 |
| 分发工程 | macOS 13 部署目标、Universal 2、沙盒、隐私清单、固定模型哈希与依赖版本 |

礼拜时间、提醒、本地备忘和附近清真寺等原有功能继续保留。新闻与记忆默认关闭，由用户自行开启。

## 使用范围与现状

- **免费本地推理**：没有按次云端模型费用；用户无需 Ollama、Node.js 或 API key。运行仍受 Mac 内存、CPU 和模型能力限制。
- **新闻覆盖有限**：当前包括英国、新西兰和国际专题来源，不能承诺每个国家/城市每天都有 2–3 条关键新闻；保留原文标题，不虚构摘要。
- **动作素材仍需完善**：现有动作复用原图像序列和变换，并非一套新增完整手绘动画。
- **记忆只反映可观察事件**：不监视其他应用，不把没有互动推断为没有礼拜或正在工作。
- **发布状态**：预览包只有临时签名，未经正式签名/公证；新增界面尚未完整本地化。不要把本版宣传为已过审或可保证上架。

## 开发者构建

```sh
git clone https://github.com/kiki177/prayer-cat.git
cd prayer-cat/src
bash scripts/build.sh
```

需要 macOS、Xcode / Command Line Tools、CMake 3.22+ 与 Python 3.11+。这些只用于开发构建，安装预览包的用户不需要。构建脚本下载并校验约 639 MB 的模型，生成包含本地模型的 Universal 2 应用。

首次构建会通过 Git 获取固定提交的 llama.cpp。GitHub 自动源码包也可使用同一构建脚本；发布附件中的完整源码包已包含该依赖。

## 文件与历史版本

最新原生源码在 [`src/`](src/)，本次详细变化见 [`CHANGELOG.md`](CHANGELOG.md)。仓库根目录保留的 v2.3 / v2.4.1 ZIP 是历史文件，不代表 v2.5.0。旧版介绍可在 Git 历史中查看。

## English

Prayer Cat is a native macOS prayer reminder and desktop companion. The v2.5.0 preview adds on-device text chat with Qwen3 and llama.cpp, opt-in daily news, desktop pet interactions, and editable local memories with retrieval from the app's own notes. ChatGPT links and OpenAI API integration have been removed. Bundled-model builds need no API key, account, Ollama or Node.js for end users.

This is a preview, not an App Store-approved release. News coverage, dedicated animation assets, full localization and hardware validation remain incomplete. Apple Silicon inference and cross-compilation for Intel were tested; Intel hardware and macOS 13 runtime validation are still required. New UI strings currently cover Chinese and English. See the linked release gates before distribution.

## 许可与归属

llama.cpp、Qwen 模型与新闻来源的说明见 [`src/Privacy-and-Licenses.txt`](src/Privacy-and-Licenses.txt)。各上游许可证按其各自范围适用，不代表整个应用及角色素材被自动授予相同许可。发行者仍需确认原有素材与目标市场的新闻使用权。
