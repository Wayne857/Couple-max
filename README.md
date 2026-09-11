# Couple Max（两小只）

面向情侣共同生活的原生 iPhone 应用原型。项目使用 SwiftUI，最低支持 iOS 17。

## 当前功能

- 情侣小屋首页与双人状态
- 点菜、留言、接单流程
- 从小红书分享文本或链接读取标题、正文与封面，并整理食材和做法
- 从淘宝链接生成心愿卡片的原生入口
- 菜谱搜索、心愿完成状态与本地持久化
- `couplemax://` 深层链接入口，为后续 Share Extension 预留

小红书解析目前直接在 iPhone 上请求公开分享页，支持 `xhslink.com` 短链和
`xiaohongshu.com` 笔记链接。若笔记已删除、仅自己可见，或小红书返回安全验证页，
应用会显示具体失败原因；正式上线前仍建议加入服务端解析兜底与情侣账号同步。

## 本地运行

1. 从 Mac App Store 安装完整 Xcode。
2. 打开 `CoupleMax.xcodeproj`。
3. 在 Signing & Capabilities 中选择你的 Apple Developer Team。
4. 选择一个 iPhone 模拟器并运行。

VS Code 已安装 Swift、SweetPad、LLDB、Mobile Canvas 和 MobileView；仓库中的扩展推荐文件会自动匹配这套环境。

网页版本已归档在 `Prototype/Web`，仅作为交互设计参考，不是正式产品代码。
