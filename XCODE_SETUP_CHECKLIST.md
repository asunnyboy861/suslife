# ✅ Xcode 完整配置检查清单

## 📋 配置状态总览

| 配置项 | 状态 | 说明 |
|--------|------|------|
| Bundle ID | ✅ 已配置 | `com.zzoutuo.suslife` |
| Signing | ⚠️ 待确认 | 需要选择 Team |
| iCloud Capability | ✅ 已配置 | Key Value Store + CloudKit |
| Background Modes | ✅ 已配置 | Fetch + Remote notifications |
| Info.plist | ✅ 已配置 | 隐私描述已添加 |
| CoreData Model | ⏳ 待创建 | 需要手动在 Xcode 创建 |
| Entitlements | ✅ 已创建 | `suslife.entitlements` |
| Privacy Policy | ✅ 已创建 | `privacy.html` |
| AppIcon | ✅ 已配置 | Assets 已就绪 |

---

## 🎯 步骤 1: 验证 Signing & Capabilities

### 打开方式：
1. 在 Xcode 左侧导航器，点击项目根目录 **suslife**
2. 选择 **TARGETS** → **suslife**
3. 点击 **Signing & Capabilities** 标签

### 检查清单：

#### ✅ Signing (Automatic)
- [ ] **Automatically manage signing**: 已勾选 ✅
- [ ] **Team**: 选择你的 Apple Developer Team
  - 如果没有 Team，点击 **Add Account...** 登录 Apple ID
  - 个人开发者账号即可（免费账号也可以测试）
- [ ] **Bundle Identifier**: 显示 `com.zzoutuo.suslife`
- [ ] **Signing Certificate**: 显示绿色 ✅ (iOS Development)
- [ ] **Provisioning Profile**: 自动管理

#### ✅ iCloud Capability
- [ ] 在 Capabilities 列表中搜索 **iCloud**
- [ ] 点击 **+ Capability** 或直接勾选 iCloud
- [ ] 配置：
  - [ ] **iCloud Key Value Store**: ✅ 勾选
  - [ ] **CloudKit**: ❌ 不勾选（后期扩展用）

#### ✅ Background Modes
- [ ] 在 Capabilities 列表中搜索 **Background Modes**
- [ ] 点击 **+ Capability** 或直接勾选 Background Modes
- [ ] 配置：
  - [ ] **Background fetch**: ✅ 勾选
  - [ ] **Remote notifications**: ✅ 勾选

---

## 🎯 步骤 2: 配置 General 设置

### 打开方式：
点击 **TARGETS** → **suslife** → **General** 标签

### Identity 部分：
- [ ] **Display Name**: `Sustainable Life`
- [ ] **Bundle Identifier**: `com.zzoutuo.suslife`
- [ ] **Version**: `1.0.0`
- [ ] **Build**: `1`

### Deployment Info:
- [ ] **Minimum Deployments**:
  - [ ] iOS: `17.0`
  - [ ] iPadOS: `17.0` (可选)

### Device Orientation:
- [ ] ✅ Portrait
- [ ] ❌ Landscape Left
- [ ] ❌ Landscape Right
- [ ] ❌ Upside Down

### Status Bar Style:
- [ ] **Hidden**: ❌ 不勾选
- [ ] **Style**: Light Content

---

## 🎯 步骤 3: 创建 CoreData 模型 ⚠️ 关键步骤

### 📖 详细指南：
查看 [`COREDATA_MODEL_SETUP.md`](file:///Volumes/Untitled/app/20260309/suslife/COREDATA_MODEL_SETUP.md)

### 快速步骤：

#### 3.1 创建文件
1. **File → New → File...** (`Cmd + N`)
2. 选择 **iOS** → **Core Data** → **Data Model**
3. 命名为：`suslife`
4. 点击 **Create**

#### 3.2 添加 CarbonActivity Entity
1. 打开 `suslife.xcdatamodeld`
2. 点击 **+ Entity** 按钮
3. Name: `CarbonActivity`
4. Codegen: `Manual/None`
5. 添加属性（点击 **+** 在 Attributes 区域）：

| Name | Type | Optional |
|------|------|----------|
| id | UUID | ❌ |
| category | String | ❌ |
| activityType | String | ❌ |
| value | Double | ❌ |
| unit | String | ❌ |
| co2Emission | Double | ❌ |
| date | Date | ❌ |
| notes | String | ✅ |
| emissionFactorVersion | String | ✅ |

#### 3.3 添加 UserProfile Entity
1. 再次点击 **+ Entity**
2. Name: `UserProfile`
3. Codegen: `Manual/None`
4. 添加属性：

| Name | Type | Optional |
|------|------|----------|
| id | UUID | ❌ |
| dailyCO2Goal | Double | ❌ |
| weeklyStreak | Integer 32 | ❌ |
| totalActivitiesLogged | Integer 32 | ❌ |
| joinDate | Date | ❌ |
| cloudKitSyncEnabled | Boolean | ❌ |
| unitsSystem | String | ❌ |

#### 3.4 保存
- [ ] 按 `Cmd + S` 保存
- [ ] 按 `Cmd + B` 构建（验证无错误）

---

## 🎯 步骤 4: 验证 Info.plist

### 打开方式：
在导航器找到 `Info.plist`，双击打开

### 已配置项（自动）：
- [ ] ✅ `UIBackgroundModes`: fetch, remote-notification
- [ ] ✅ `NSLocationWhenInUseUsageDescription`
- [ ] ✅ `NSHealthShareUsageDescription`
- [ ] ✅ `NSHealthUpdateUsageDescription`
- [ ] ✅ `UIUserInterfaceStyle`: Light

---

## 🎯 步骤 5: 配置 Entitlements

### 文件位置：
`/Volumes/Untitled/app/20260309/suslife/suslife/suslife/suslife.entitlements`

### 在 Xcode 中关联：
1. 点击 **TARGETS** → **suslife**
2. 选择 **Signing & Capabilities** 标签
3. 在 **Custom Entitlements** 区域，确认文件已自动关联
4. 如果没有，点击 **+** 添加 `suslife.entitlements`

### 验证内容：
打开 `suslife.entitlements`，右键 → **Open As** → **Source Code**

确认包含：
```xml
<key>com.apple.security.application-groups</key>
<array>
    <string>group.com.zzoutuo.suslife</string>
</array>
<key>com.apple.developer.icloud-container-identifiers</key>
<array>
    <string>iCloud.com.zzoutuo.suslife</string>
</array>
```

---

## 🎯 步骤 6: 配置 App Icon

### 打开方式：
1. 导航到 `Assets.xcassets`
2. 找到 `AppIcon`

### 配置：
- [ ] 准备 1024x1024 px 的 App 图标
- [ ] 拖入到 **AppIcon** 的 1024x1024 槽位
- [ ] 或使用 AI 生成图标（推荐绿色主题 🌱）

### 临时方案（开发测试）：
如果暂时没有图标，可以：
1. 使用 SF Symbols 作为临时图标
2. 或使用在线工具生成占位图标

---

## 🎯 步骤 7: 配置 Launch Screen

### 打开方式：
找到 `LaunchScreen.storyboard` 并打开

### 简单配置：
1. 从库中拖入 **Image View**
2. 设置背景色为 `#2E7D32` (Primary Green)
3. 添加 App Logo 或名称文本

### 或使用默认：
保持默认空白启动页也可以

---

## 🎯 步骤 8: 验证 Build Settings

### 打开方式：
点击 **TARGETS** → **suslife** → **Build Settings** 标签

### 搜索并验证：

#### Swift Compiler - Language
- [ ] **Swift Language Version**: `Swift 5` 或 `Swift 5.9`

#### Packaging
- [ ] **Product Bundle Identifier**: `com.zzoutuo.suslife`

#### Deployment
- [ ] **iOS Deployment Target**: `iOS 17.0`

---

## 🎯 步骤 9: 添加隐私政策到 App Store Connect

### 部署隐私政策：

#### 选项 1: GitHub Pages（推荐）
1. 将 `privacy.html` 上传到 GitHub 仓库
2. 启用 GitHub Pages
3. 获取 URL：`https://yourusername.github.io/suslife/privacy.html`

#### 选项 2: 自有网站
1. 上传 `privacy.html` 到你的网站
2. 获取 URL：`https://yourwebsite.com/privacy.html`

#### 选项 3: 第三方托管
使用如 Netlify、Vercel 等免费托管服务

### 记录 URL：
```
Privacy Policy URL: ________________________________
```

---

## 🎯 步骤 10: 运行和测试

### 清理构建：
```bash
# 在 Xcode 中
Product → Clean Build Folder (Cmd + Shift + K)
```

### 构建项目：
```bash
# 按 Cmd + B
```

### 运行应用：
1. 选择目标设备（iPhone 15 Simulator 或真机）
2. 按 **Cmd + R** 运行

### 测试清单：
- [ ] App 启动成功
- [ ] 无 CoreData 错误
- [ ] Dashboard 显示正常
- [ ] 可以切换到不同 Tab
- [ ] 点击 Quick Log 按钮
- [ ] 记录活动成功
- [ ] 运行单元测试（Cmd + U）

---

## 🔧 常见问题排查

### ❌ 错误：Could not build module 'CoreData'
**解决方案**：
1. 确认已创建 `suslife.xcdatamodeld`
2. 检查 Entity 名称是否与代码一致
3. Clean Build Folder (`Cmd + Shift + K`)

### ❌ 错误：No such module 'suslife'
**解决方案**：
1. 检查 CoreData 容器名称是否为 `"suslife"`
2. 在 `CoreDataStack.swift` 中确认：
   ```swift
   let container = NSPersistentContainer(name: "suslife")
   ```

### ❌ 错误：Signing for "suslife" requires a team
**解决方案**：
1. 打开 **Signing & Capabilities**
2. 选择 **Team**
3. 如果没有 Team，点击 **Add Account...** 登录 Apple ID

### ❌ 错误：No provisioning profiles found
**解决方案**：
1. 在 **Signing & Capabilities** 中
2. 勾选 **Automatically manage signing**
3. Xcode 会自动创建配置文件

### ❌ 运行时崩溃：CoreData save error
**解决方案**：
1. 检查 CoreData Model 是否创建
2. 验证所有 Entity 和属性
3. 查看控制台错误日志

---

## 📊 最终检查清单

在提交 App Store 前，确认：

### 开发配置
- [ ] ✅ Bundle ID: `com.zzoutuo.suslife`
- [ ] ✅ Team 已选择
- [ ] ✅ Signing 正常（绿色✅）
- [ ] ✅ iCloud Capability 已添加
- [ ] ✅ Background Modes 已添加
- [ ] ✅ CoreData Model 已创建（16 个属性）
- [ ] ✅ Entitlements 已配置
- [ ] ✅ Info.plist 隐私描述完整
- [ ] ✅ App Icon 已添加
- [ ] ✅ 构建成功，无错误
- [ ] ✅ 所有单元测试通过

### App Store 准备
- [ ] ⏳ 隐私政策 URL 已部署
- [ ] ⏳ App Store Connect 中创建 App
- [ ] ⏳ 准备 App 截图（6.7" 和 6.1"）
- [ ] ⏳ 编写 App 描述和关键词
- [ ] ⏳ 准备隐私政策视频（如果需要）

---

## 🚀 下一步

完成以上配置后：

1. **运行测试**: `Cmd + U`
2. **构建应用**: `Cmd + B`
3. **运行应用**: `Cmd + R`
4. **测试功能**: 按照测试清单逐项验证
5. **准备提交**: 参考 `us.md` 中的 App Store 提交指南

---

## 📞 需要帮助？

如果配置过程中遇到问题：

1. 查看错误日志（Xcode → View → Navigators → Show Report Navigator）
2. 检查控制台输出
3. 参考 `COREDATA_MODEL_SETUP.md` 中的 CoreData 配置指南
4. 查看 `us.md` 中的技术实现细节

---

**最后更新**: 2026-03-10
**版本**: 1.0.0
**状态**: 配置文档已完成，等待 Xcode 手动配置
