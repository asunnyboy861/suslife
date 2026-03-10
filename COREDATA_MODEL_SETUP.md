# 📦 CoreData Model 创建指南

## ⚠️ 重要提示

CoreData 模型文件**必须在 Xcode 中手动创建**，无法通过代码自动生成。

## 📝 创建步骤

### 步骤 1: 创建 Data Model 文件

1. 在 Xcode 中，点击菜单 **File → New → File...** (或按 `Cmd + N`)
2. 选择 **iOS** 标签
3. 滚动找到 **Core Data** 分类
4. 选择 **Data Model**
5. 点击 **Next**
6. 输入文件名：`suslife`
7. 确保：
   - **Container**: 选择 `suslife`
   - **Entities**: 留空（我们会手动添加）
8. 点击 **Create**

文件会创建在：`/Volumes/Untitled/app/20260309/suslife/suslife/suslife/suslife.xcdatamodeld`

---

### 步骤 2: 添加 CarbonActivity Entity

1. **双击打开** `suslife.xcdatamodeld` 文件
2. 在左侧 **Entity** 列表下方，点击 **+** 按钮
3. 在右侧 **Data Model Inspector** (右侧面板) 中：
   - **Name**: 输入 `CarbonActivity`
   - **Class**: 保持 `CarbonActivity` (会自动匹配)
   - **Codegen**: 选择 `Manual/None` (因为我们已经有代码了)

4. 在底部的 **Attributes** 区域，点击 **+** 添加以下属性：

| # | Name | Type | Optional |
|---|------|------|----------|
| 1 | `id` | UUID | ❌ 取消勾选 |
| 2 | `category` | String | ❌ 取消勾选 |
| 3 | `activityType` | String | ❌ 取消勾选 |
| 4 | `value` | Double | ❌ 取消勾选 |
| 5 | `unit` | String | ❌ 取消勾选 |
| 6 | `co2Emission` | Double | ❌ 取消勾选 |
| 7 | `date` | Date | ❌ 取消勾选 |
| 8 | `notes` | String | ✅ 保持勾选 |
| 9 | `emissionFactorVersion` | String | ✅ 保持勾选 |

**详细操作**：
- 点击 **+** 按钮
- 在 **Name** 列输入属性名（如 `id`）
- 在 **Type** 列选择类型（如 `UUID`）
- 在 **Optional** 列取消或保持勾选

---

### 步骤 3: 添加 UserProfile Entity

1. 再次点击左侧 **Entity** 列表下方的 **+** 按钮
2. 在右侧 **Data Model Inspector** 中：
   - **Name**: 输入 `UserProfile`
   - **Class**: 保持 `UserProfile`
   - **Codegen**: 选择 `Manual/None`

3. 添加以下属性：

| # | Name | Type | Optional |
|---|------|------|----------|
| 1 | `id` | UUID | ❌ 取消勾选 |
| 2 | `dailyCO2Goal` | Double | ❌ 取消勾选 |
| 3 | `weeklyStreak` | Integer 32 | ❌ 取消勾选 |
| 4 | `totalActivitiesLogged` | Integer 32 | ❌ 取消勾选 |
| 5 | `joinDate` | Date | ❌ 取消勾选 |
| 6 | `cloudKitSyncEnabled` | Boolean | ❌ 取消勾选 |
| 7 | `unitsSystem` | String | ❌ 取消勾选 |

---

### 步骤 4: 验证配置

1. 点击 `CarbonActivity` Entity
2. 按 `Cmd + 1` 打开 **Data Model Inspector**
3. 确认所有属性都已正确添加

4. 对 `UserProfile` 重复上述步骤

---

### 步骤 5: 保存并构建

1. 按 `Cmd + S` 保存
2. 按 `Cmd + B` 构建项目
3. 检查是否有编译错误

---

## 🔍 验证清单

创建完成后，确认：

- [ ] `suslife.xcdatamodeld` 文件已创建
- [ ] `CarbonActivity` Entity 有 9 个属性
- [ ] `UserProfile` Entity 有 7 个属性
- [ ] 所有必填字段（Optional 未勾选）都已正确设置
- [ ] 类型都正确（UUID, String, Double, Date, Integer 32, Boolean）
- [ ] 构建成功，无错误

---

## 📸 可视化参考

### Xcode Data Model 界面

```
┌─────────────────────────────────────────────────┐
│  suslife.xcdatamodeld                           │
├─────────────────────────────────────────────────┤
│                                                 │
│  ENTITY LIST        │  DATA MODEL INSPECTOR    │
│  ───────────        │  ─────────────────────   │
│                     │                           │
│  + CarbonActivity   │  Name: CarbonActivity    │
│  + UserProfile      │  Class: CarbonActivity   │
│                     │  Codegen: Manual/None    │
│                     │                           │
│                     │  ATTRIBUTES:              │
│                     │  ─────────────            │
│                     │  + id (UUID)             │
│                     │  + category (String)     │
│                     │  + activityType (String) │
│                     │  + value (Double)        │
│                     │  + unit (String)         │
│                     │  + co2Emission (Double)  │
│                     │  + date (Date)           │
│                     │  + notes (String) ✓      │
│                     │  + emissionFactorVersion │
│                                                 │
└─────────────────────────────────────────────────┘
```

---

## ❓ 常见问题

### Q: 找不到 Data Model 选项？
**A**: 确保在 **File → New → File...** 对话框中选择了 **iOS** 标签，然后滚动找到 **Core Data** 分类。

### Q: 属性类型不对？
**A**: 
- `Int32` 对应 Swift 的 `Int32`
- `Boolean` 对应 Swift 的 `Bool`
- `UUID` 对应 Swift 的 `UUID`
- `String` 对应 Swift 的 `String`
- `Double` 对应 Swift 的 `Double`
- `Date` 对应 Swift 的 `Date`

### Q: 构建时提示找不到 Entity？
**A**: 检查：
1. Entity 名称是否与代码中的类名一致
2. Codegen 是否设置为 `Manual/None`
3. `.xcdatamodeld` 文件是否在 target 的 **Build Phases → Compile Sources** 中

### Q: 运行时提示找不到 persistent store？
**A**: 检查 `CoreDataStack.swift` 中的容器名称是否为 `"suslife"`：
```swift
let container = NSPersistentContainer(name: "suslife")
```

---

## 🎯 下一步

创建完 CoreData 模型后，继续配置：
1. ✅ Info.plist (已完成)
2. ⏳ CoreData Model (进行中)
3. ⏹️ AppIcon 配置
4. ⏹️ Entitlements 文件
5. ⏹️ 隐私政策页面

---

**提示**: 如果在创建过程中遇到任何问题，请截图并告诉我具体哪一步有问题！
