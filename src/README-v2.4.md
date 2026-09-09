# 礼拜喵 macOS v2.4

本版本在 v2.3 斋月模式基础上新增：

- MapKit 原生地图与当前位置显示
- Apple MapKit 原生清真寺搜索，无需用户填写任何 API 密钥
- 按直线距离排序的清真寺列表（10 公里、最多 10 条）
- 选中清真寺后使用 Apple Maps 打开路线
- 用户主动开启的“礼拜前推荐附近清真寺”本地通知
- 架构上预留 Google Places 服务端增强入口，但不进入当前用户流程
- 英语、阿语、罗马乌尔都语、中文界面文案
- Intel 与 Apple Silicon 通用二进制

## 构建

需要 macOS 13 或更高版本，以及 Apple Command Line Tools 或 Xcode。

```sh
clang -fobjc-arc -fmodules -mmacosx-version-min=13.0 \
  -arch arm64 -arch x86_64 \
  -framework Cocoa -framework UserNotifications -framework Security \
  -framework MapKit -framework CoreLocation \
  main.m MosqueFeature.m -o SalahCat
```

提交 Mac App Store 时请使用自己的 Apple Distribution 证书、Provisioning Profile 和 Xcode Archive。当前交付应用仅采用本地临时签名，用于功能检查。

## 使用附近清真寺

1. 在礼拜喵菜单中打开“附近清真寺”。
2. 点击“查找附近清真寺”，按系统提示授权定位。
3. 如需提醒，可主动开启“礼拜前推荐附近清真寺”。

用户不需要注册 Google Cloud，也不需要填写任何 API 密钥。未来启用 Google Places 增强时，应由开发者后端代理请求，不能要求普通用户配置开发者密钥。

## 隐私边界

- 仅在用户搜索或主动开启提醒后请求位置。
- 不保存精确位置历史。
- 搜索由 Apple MapKit 完成。
- 自动刷新最多每 6 小时一次。
- 关闭清真寺提醒时会删除待发送的清真寺推荐通知。
