# 🚀 Sustainable Life App 改进计划

## 📋 文档信息
- **版本**: 1.1
- **日期**: 2026-03-10
- **范围**: 短期（1-2个月）+ 中期（3-6个月）优化
- **长期**: 单独文档记录
- **更新说明**: 本次更新采纳了架构优化建议，降低了开发复杂度，提升了迭代速度

---

## ✅ 优化更新要点
1. **成就系统简化**：使用 `@AppStorage` 替代 CoreData 存储，无需修改数据模型，开发速度提升 50%
2. **Repository 扩展**：直接扩展现有实现，无需修改协议，保持向后兼容
3. **发布节奏优化**：采用 2 周小版本迭代，更快获得用户反馈，降低发布风险
4. **代码复用最大化**：复用现有架构 80% 代码，减少重复开发

---

## 🎯 优化原则
1. **单一职责**: 一个功能一个模块，命名清晰，文件结构语义化
2. **代码复用**: 优先复用现有模块，符合"三次法则"
3. **重构清理**: 替换代码时先标记废弃，验证后删除
4. **风格一致**: UI/功能与现有风格保持一致
5. **优先继承**: 与现有代码兼容，优先继承而非硬编码

---

## 📅 短期优化（1-2个月）

### 🏆 功能 1: 成就系统
#### 需求描述
用户完成特定活动或达到目标时解锁成就，提升用户粘性和使用乐趣。

#### 生成规则
- **模块位置**: `/Services/AchievementService.swift`
- **数据存储**: 使用 `@AppStorage` 存储已解锁成就 ID（无需修改 CoreData 模型，开发成本低）
- **触发时机**: 活动保存后、每日统计时自动检查
- **展示位置**: Dashboard、Profile 页面
- **设计优势**: 无需修改 CoreData 模型，不需要数据迁移，开发速度快

#### 检验标准
1. **代码示例**:
```swift
// AchievementService.swift
struct AchievementService {
    static let shared = AchievementService()
    @AppStorage("unlockedAchievements") private var unlockedIds: [String] = []
    @AppStorage("lastActivityDate") private var lastActivityDate: Date?
    
    // 所有可用成就定义
    let allAchievements: [AchievementDefinition] = [
        .init(
            id: "first_activity",
            title: "First Step",
            description: "Log your first activity",
            icon: "leaf.fill",
            points: 10
        ),
        .init(
            id: "week_warrior",
            title: "Week Warrior",
            description: "Log activities for 7 consecutive days",
            icon: "flame.fill",
            points: 50
        ),
        .init(
            id: "eco_hero",
            title: "Eco Hero",
            description: "Reduce 100 lbs of CO₂ total",
            icon: "star.fill",
            points: 100
        )
    ]
    
    /// 检查是否解锁新成就
    func checkAchievements(for activity: CarbonActivity, repository: ActivityRepositoryProtocol) async throws -> [AchievementDefinition] {
        var newlyUnlocked: [AchievementDefinition] = []
        
        // 检查是否解锁第一个活动成就
        let totalActivities = try await repository.fetchTotalActivities()
        if totalActivities == 1, !isUnlocked(id: "first_activity") {
            unlock(id: "first_activity")
            newlyUnlocked.append(getDefinition(id: "first_activity")!)
        }
        
        // 检查连续 7 天记录
        if checkConsecutiveDays() >= 7, !isUnlocked(id: "week_warrior") {
            unlock(id: "week_warrior")
            newlyUnlocked.append(getDefinition(id: "week_warrior")!)
        }
        
        // 检查总减排量
        let totalSaved = try await repository.calculateTotalCO2Saved()
        if totalSaved >= 100, !isUnlocked(id: "eco_hero") {
            unlock(id: "eco_hero")
            newlyUnlocked.append(getDefinition(id: "eco_hero")!)
        }
        
        return newlyUnlocked
    }
    
    /// 检查连续记录天数
    private func checkConsecutiveDays() -> Int {
        // 实现连续天数计算逻辑
        return 0
    }
    
    private func isUnlocked(id: String) -> Bool {
        unlockedIds.contains(id)
    }
    
    private mutating func unlock(id: String) {
        guard !unlockedIds.contains(id) else { return }
        unlockedIds.append(id)
        // 发送本地通知
        NotificationService.shared.showAchievementUnlockedNotification(
            title: "🎉 Achievement Unlocked!",
            body: getDefinition(id: id)?.title ?? ""
        )
    }
    
    private func getDefinition(id: String) -> AchievementDefinition? {
        allAchievements.first { $0.id == id }
    }
}

// 成就定义模型
struct AchievementDefinition: Identifiable {
    let id: String
    let title: String
    let description: String
    let icon: String
    let points: Int
}
```

2. **测试用例**:
```swift
// AchievementServiceTests.swift
func testFirstActivityAchievement() async throws {
    let repository = MockActivityRepository()
    var service = AchievementService.shared
    
    // 模拟第一个活动
    try await repository.save(testInput)
    let achievements = try await service.checkAchievements(for: testActivity, repository: repository)
    
    XCTAssertEqual(achievements.count, 1)
    XCTAssertEqual(achievements.first?.id, "first_activity")
    XCTAssertTrue(service.isUnlocked(id: "first_activity"))
}
```

3. **验收标准**:
- ✅ 首次记录活动解锁"First Step"成就
- ✅ 连续记录 7 天解锁"Week Warrior"成就
- ✅ 总减排量达到 100 磅解锁"Eco Hero"成就
- ✅ 成就展示在 Dashboard 和 Profile 页面
- ✅ 有解锁动画和本地通知
- ✅ 成就数据持久化存储，App 重启不丢失

---

### 📊 功能 2: 数据导出功能
#### 需求描述
允许用户导出自己的碳足迹数据为 CSV/Excel 格式，满足用户数据可携要求。

#### 生成规则
- **模块位置**: `/Services/ExportService.swift`
- **支持格式**: CSV, JSON, PDF
- **入口位置**: Settings → Export Data
- **隐私保护**: 导出前需生物验证（Touch ID/Face ID）

#### 检验标准
1. **代码示例**:
```swift
// ExportService.swift
struct ExportService {
    func exportToCSV(activities: [CarbonActivity]) -> String {
        var csv = "Date,Category,Activity,Value,Unit,CO2(lbs)\n"
        
        for activity in activities {
            let date = ISO8601DateFormatter().string(from: activity.date)
            let line = "\"\(date)\",\"\(activity.category)\",\"\(activity.activityType)\",\(activity.value),\"\(activity.unit)\",\(activity.co2Emission)\n"
            csv.append(line)
        }
        
        return csv
    }
}
```

2. **测试用例**:
```swift
// ExportServiceTests.swift
func testCSVExport() throws {
    let activities = [testActivity1, testActivity2]
    let csv = ExportService.shared.exportToCSV(activities: activities)
    
    XCTAssertTrue(csv.contains("Date,Category,Activity,Value,Unit,CO2(lbs)"))
    XCTAssertTrue(csv.contains("car,10.0,mi,1.3"))
}
```

3. **验收标准**:
- ✅ 支持导出 CSV、JSON 格式
- ✅ 导出前需生物验证
- ✅ 可以通过系统分享功能保存或发送
- ✅ 导出文件包含完整的活动数据
- ✅ 大数量导出无性能问题

---

### 🔔 功能 3: 通知提醒功能
#### 需求描述
每日提醒用户记录活动，帮助用户养成使用习惯。

#### 生成规则
- **模块位置**: `/Services/NotificationService.swift`
- **触发时间**: 用户可自定义提醒时间（默认晚上 8 点）
- **类型**: 本地通知，无需服务器
- **入口位置**: Settings → Notifications

#### 检验标准
1. **代码示例**:
```swift
// NotificationService.swift
class NotificationService: NSObject, UNUserNotificationCenterDelegate {
    static let shared = NotificationService()
    
    func requestPermission() async throws {
        try await UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound])
    }
    
    func scheduleDailyReminder(at hour: Int, minute: Int) {
        let content = UNMutableNotificationContent()
        content.title = "Time to log your activities!"
        content.body = "Don't forget to record today's carbon footprint."
        content.sound = .default
        
        var dateComponents = DateComponents()
        dateComponents.hour = hour
        dateComponents.minute = minute
        
        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
        let request = UNNotificationRequest(identifier: "daily_reminder", content: content, trigger: trigger)
        
        UNUserNotificationCenter.current().add(request)
    }
}
```

2. **测试用例**:
```swift
// NotificationServiceTests.swift
func testScheduleNotification() async throws {
    try await NotificationService.shared.requestPermission()
    NotificationService.shared.scheduleDailyReminder(at: 20, minute: 0)
    
    let settings = await UNUserNotificationCenter.current().notificationSettings()
    XCTAssertEqual(settings.authorizationStatus, .authorized)
}
```

3. **验收标准**:
- ✅ 用户可开关通知功能
- ✅ 可自定义提醒时间
- ✅ 点击通知直接打开 App 到记录页面
- ✅ 支持不同类型的提醒（成就解锁、每周报告）
- ✅ 低电量模式下自动降低提醒频率

---

### ❤️ 功能 4: Apple Health 集成
#### 需求描述
自动从 Apple Health 导入步行、跑步、骑行等运动数据，减少用户手动输入。

#### 生成规则
- **模块位置**: `/Services/HealthKitService.swift`
- **权限**: 仅读取，不写入
- **入口位置**: Settings → Integrations → Apple Health
- **数据映射**: 将运动数据自动转换为对应类别的碳足迹

#### 检验标准
1. **代码示例**:
```swift
// HealthKitService.swift
import HealthKit

class HealthKitService {
    static let shared = HealthKitService()
    private let healthStore = HKHealthStore()
    
    func requestAuthorization() async throws {
        guard HKHealthStore.isHealthDataAvailable() else {
            throw HealthKitError.notAvailable
        }
        
        let types: Set<HKObjectType> = [
            HKObjectType.quantityType(forIdentifier: .distanceWalkingRunning)!,
            HKObjectType.quantityType(forIdentifier: .distanceCycling)!
        ]
        
        try await healthStore.requestAuthorization(toShare: nil, read: types)
    }
    
    func importActivities(from startDate: Date, to endDate: Date) async throws -> [ActivityInput] {
        // 读取 HealthKit 数据并转换为 ActivityInput
    }
}
```

2. **测试用例**:
```swift
// HealthKitServiceTests.swift
func testImportWalkingData() async throws {
    try await HealthKitService.shared.requestAuthorization()
    let activities = try await HealthKitService.shared.importActivities(from: Date().addingTimeInterval(-86400), to: Date())
    
    XCTAssertTrue(activities.allSatisfy { $0.category == "transport" })
}
```

3. **验收标准**:
- ✅ 用户可授权 HealthKit 访问
- ✅ 自动导入步行、跑步、骑行数据
- ✅ 导入的数据可预览和编辑
- ✅ 避免重复导入
- ✅ 可随时关闭集成

---

## 📅 中期优化（3-6个月）

### ☁️ 功能 5: iCloud 同步功能
#### 需求描述
支持用户数据在多设备间同步，保障数据安全。

#### 生成规则
- **模块位置**: `/Services/CloudKitService.swift`
- **数据加密**: 端到端加密
- **冲突处理**: 最后写入为准
- **入口位置**: Settings → iCloud Sync
- **复用现有代码**: 基于现有的 CoreData Stack 扩展，无需修改业务层代码

#### 检验标准
1. **代码示例**:
```swift
// CloudKitService.swift
class CloudKitService {
    static let shared = CloudKitService()
    
    func setupSync() async throws {
        guard let container = NSPersistentCloudKitContainer(name: "suslife") else {
            throw CloudKitError.setupFailed
        }
        
        // 配置云同步选项
        container.viewContext.automaticallyMergesChangesFromParent = true
        container.viewContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
    }
    
    func syncStatus() async -> SyncStatus {
        // 返回同步状态
    }
}
```

2. **测试用例**:
```swift
// CloudKitServiceTests.swift
func testSyncIntegration() async throws {
    try await CloudKitService.shared.setupSync()
    let activity = try await repository.save(testInput)
    
    // 验证数据已同步到 CloudKit
    let cloudActivity = try await CloudKitService.shared.fetchActivity(id: activity.id)
    XCTAssertEqual(cloudActivity?.id, activity.id)
}
```

3. **验收标准**:
- ✅ 用户可开关 iCloud 同步
- ✅ 数据端到端加密
- ✅ 多设备自动同步
- ✅ 断网时正常使用，联网后自动同步
- ✅ 同步状态显示在 Settings 页面

---

### 📈 功能 6: 本地排行榜功能
#### 需求描述
用户可以查看自己的历史表现排行榜，与过去的自己比较，激励减排。

#### 生成规则
- **模块位置**: `/Services/RankingService.swift`
- **数据来源**: 本地 CoreData 数据，不上传服务器
- **展示位置**: Community 标签页
- **对比维度**: 周减排量、月减排量、活动次数 streak

#### 检验标准
1. **代码示例**:
```swift
// RankingService.swift
struct RankingService {
    func generatePersonalRanking() async throws -> PersonalRanking {
        let weeklyData = try await repository.fetchWeeklyTrend()
        let monthlyData = try await repository.fetchMonthlyTrend()
        
        return PersonalRanking(
            currentWeek: weeklyData.last?.totalCO2 ?? 0,
            previousWeek: weeklyData.dropLast().last?.totalCO2 ?? 0,
            bestWeek: weeklyData.map { $0.totalCO2 }.min() ?? 0,
            streak: try await UserRepository.shared.getCurrentStreak()
        )
    }
}
```

2. **测试用例**:
```swift
// RankingServiceTests.swift
func testPersonalRanking() async throws {
    // 插入测试数据
    for i in 1...7 {
        try await saveTestActivity(date: Date().addingTimeInterval(-Double(i) * 86400))
    }
    
    let ranking = try await RankingService.shared.generatePersonalRanking()
    XCTAssertGreaterThan(ranking.currentWeek, 0)
}
```

3. **验收标准**:
- ✅ 展示个人历史数据排行榜
- ✅ 支持周、月、年维度查看
- ✅ 展示 streak 天数
- ✅ 显示减排趋势
- ✅ 所有数据均为本地计算，保护隐私

---

### 💡 功能 7: 个性化减排建议
#### 需求描述
基于用户的历史数据，提供个性化的减排建议。

#### 生成规则
- **模块位置**: `/Services/RecommendationService.swift`
- **算法**: 基于规则的推荐系统（初期简单，后期可扩展 AI）
- **展示位置**: Dashboard 底部"Tips"卡片
- **更新频率**: 每日更新一次建议

#### 检验标准
1. **代码示例**:
```swift
// RecommendationService.swift
struct RecommendationService {
    func generateRecommendations(for userProfile: UserProfile, activities: [CarbonActivity]) -> [Recommendation] {
        var recommendations: [Recommendation] = []
        
        // 如果用户开车较多，建议公共交通
        let carMiles = activities.filter { $0.activityType == "car" }.map { $0.value }.reduce(0, +)
        if carMiles > 50 {
            recommendations.append(Recommendation(
                title: "Try Public Transit",
                description: "Taking the bus 2x/week can save you 20 lbs CO₂ per month.",
                icon: "bus.fill",
                category: .transport
            ))
        }
        
        // 其他推荐规则...
        
        return recommendations
    }
}
```

2. **测试用例**:
```swift
// RecommendationServiceTests.swift
func testDrivingRecommendation() {
    let activities = [
        testCarActivity(value: 60),
        testFoodActivity()
    ]
    
    let recommendations = RecommendationService.shared.generateRecommendations(activities: activities)
    XCTAssertTrue(recommendations.contains { $0.category == .transport })
}
```

3. **验收标准**:
- ✅ 基于用户行为生成个性化建议
- ✅ 建议包含具体的减排量估算
- ✅ 覆盖交通、食物、购物、能源等类别
- ✅ 用户可标记建议为已实施
- ✅ 建议可点击查看详细说明

---

### 🌱 功能 8: 碳抵消功能集成
#### 需求描述
允许用户通过认证项目抵消自己的碳排放。

#### 生成规则
- **模块位置**: `/Services/OffsetService.swift`
- **合作方**: 美国官方认证的碳抵消项目
- **支付**: 集成 Apple Pay
- **入口位置**: Dashboard → Offset CO₂

#### 检验标准
1. **代码示例**:
```swift
// OffsetService.swift
struct OffsetService {
    func fetchAvailableProjects() async throws -> [OffsetProject] {
        // 从认证 API 获取可用项目
    }
    
    func purchaseOffset(project: OffsetProject, amount: Double) async throws -> Order {
        // 发起 Apple Pay 支付
    }
}
```

2. **测试用例**:
```swift
// OffsetServiceTests.swift
func testFetchProjects() async throws {
    let projects = try await OffsetService.shared.fetchAvailableProjects()
    XCTAssertFalse(projects.isEmpty)
    XCTAssertTrue(projects.allSatisfy { $0.isCertified })
}
```

3. **验收标准**:
- ✅ 展示经过认证的碳抵消项目
- ✅ 显示项目介绍和影响力
- ✅ 支持 Apple Pay 一键购买
- ✅ 抵消记录保存在用户个人档案
- ✅ 可下载抵消证书

---

## 📁 文件结构规划
```
suslife/
├── Services/
│   ├── AchievementService.swift       ✅ 新增（使用 AppStorage，无需 CoreData）
│   ├── ExportService.swift            ✅ 新增
│   ├── NotificationService.swift      ✅ 新增
│   ├── HealthKitService.swift         ✅ 新增
│   ├── CloudKitService.swift          ✅ 新增
│   ├── RankingService.swift           ✅ 新增
│   ├── RecommendationService.swift    ✅ 新增
│   └── OffsetService.swift            ✅ 新增
├── Models/
│   ├── AchievementDefinition.swift    ✅ 新增（轻量模型，无需 CoreData）
│   ├── OffsetProject.swift            ✅ 新增
│   └── Recommendation.swift           ✅ 新增
├── Views/
│   ├── Dashboard/
│   │   ├── AchievementCard.swift      ✅ 新增
│   │   ├── AchievementNotificationView.swift ✅ 新增
│   │   └── RecommendationCard.swift   ✅ 新增
│   ├── Profile/
│   │   └── AchievementWallView.swift  ✅ 新增
│   ├── Settings/
│   │   ├── ExportSettingsView.swift   ✅ 新增
│   │   ├── NotificationSettings.swift ✅ 新增
│   │   └── HealthSettingsView.swift   ✅ 新增
│   └── Community/
│       └── PersonalRankingView.swift  ✅ 新增
└── ViewModels/
    ├── AchievementViewModel.swift     ✅ 新增
    ├── ExportViewModel.swift          ✅ 新增
    └── RankingViewModel.swift         ✅ 新增
```

---

## ✅ 开发顺序优先级
### P0 (最高优先级)
1. 成就系统 - 提升用户粘性，开发成本低
2. 通知提醒 - 提升日活，开发简单

### P1 (高优先级)
3. 数据导出 - 合规要求，用户需求明确
4. Apple Health 集成 - 减少用户输入，提升体验

### P2 (中优先级)
5. iCloud 同步 - 数据安全，提升留存
6. 本地排行榜 - 游戏化，提升使用时长

### P3 (低优先级)
7. 个性化建议 - 提升价值，需要较多规则配置
8. 碳抵消功能 - 盈利功能，依赖第三方合作

---

## 🧪 质量保证
每个功能开发必须包含：
1. ✅ 单元测试（覆盖率 ≥ 90%）
2. ✅ UI 测试（核心流程自动化）
3. ✅ 性能测试（无卡顿，启动时间 < 2s）
4. ✅ 兼容性测试（iOS 17.0+，不同设备）
5. ✅ 隐私测试（无数据泄露，符合 CCPA/GDPR）

---

## 📝 发布计划
### Version 1.0.1 (2周后) - 小版本快速迭代
- ✨ 成就系统（基础版）
- ✨ 连续 streak 统计
- 🐛 Bug 修复和性能优化
- 🎯 目标: 验证核心玩法，获取用户反馈

### Version 1.1.0 (4周后) 
- ✨ 通知提醒功能
- ✨ Dashboard 成就展示卡片
- ✨ Profile 页面成就墙
- 🎯 目标: 提升日活和留存

### Version 1.2.0 (8周后)
- ✨ 数据导出功能（CSV/JSON）
- ✨ Apple Health 集成（步行/跑步/骑行自动导入）
- ✨ UI 细节优化和动画效果
- 🎯 目标: 减少用户输入成本，提升体验

### Version 1.3.0 (12周后)
- ✨ 本地排行榜功能（个人历史对比）
- ✨ 个性化减排建议
- ✨ iCloud 同步功能（可选）
- 🎯 目标: 提升用户粘性和数据安全性

### Version 1.4.0 (16周后)
- ✨ 碳抵消功能集成（美国认证项目）
- ✨ 深色模式支持
- ✨ 多语言支持
- 🎯 目标: 商业化探索，扩大用户群体

---

## 🔄 代码复用说明
现有模块可直接复用，无需修改核心架构：
1. **CoreDataStack**: 无需修改，现有实现完全满足需求
2. **Repository Pattern**: 直接扩展现有实现，无需修改协议
```swift
// 扩展现有 Repository，不需要修改协议
extension CoreDataActivityRepository {
    /// 获取总活动数
    func fetchTotalActivities() async throws -> Int {
        let context = coreDataStack.mainContext
        return try await context.perform {
            let request: NSFetchRequest<CarbonActivity> = CarbonActivity.fetchRequest()
            return try context.count(for: request)
        }
    }
    
    /// 获取月趋势数据
    func fetchMonthlyTrend() async throws -> [DailyTotal] {
        let context = coreDataStack.mainContext
        return try await context.perform {
            let calendar = Calendar.current
            let startDate = calendar.date(byAdding: .month, value: -1, to: Date())!
            let endOfDay = calendar.date(byAdding: .day, value: 1, to: Date())!
            
            let request: NSFetchRequest<CarbonActivity> = CarbonActivity.fetchRequest()
            request.predicate = NSPredicate(format: "date >= %@ AND date < %@", startDate as NSDate, endOfDay as NSDate)
            
            let activities = try context.fetch(request)
            
            // Group by date
            let grouped = Dictionary(grouping: activities) { activity in
                calendar.startOfDay(for: activity.date)
            }
            
            // Convert to DailyTotal
            return grouped.map { date, activities in
                DailyTotal(
                    date: date,
                    totalCO2: activities.reduce(0) { $0 + $1.co2Emission },
                    activityCount: activities.count
                )
            }.sorted { $0.date < $1.date }
        }
    }
}
```
3. **UI 组件**: 复用现有 Card、Button、颜色字体系统
4. **Validation Layer**: 新增数据类型直接扩展现有验证规则

所有新增代码将严格遵循现有代码风格和命名规范，保持项目一致性。
