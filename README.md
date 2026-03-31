# 项目简介

Flutter 商品列表页，使用 Riverpod 管理状态，支持下拉刷新、上拉加载；网格布局（自适应列数），骨架屏占位；收藏按钮支持后端同步与登录鉴权。

# 本地开发环境

- 操作系统：macOS / Linux / Windows 任一开发环境
- Flutter SDK：与 `pubspec.yaml` 中 Dart `^3.11.4` 兼容的稳定版本（推荐使用当前 stable）
- Dart：随 Flutter 自带即可
- Web 运行环境：
  - Chrome 浏览器（用于 `flutter run -d chrome`）
- 移动端调试（可选）：
  - Android：Android Studio + Android SDK / 模拟器 或 真机
  - iOS：Xcode + iOS 模拟器 / 真机（需要 macOS）
- 后端服务：
  - 提供 `http://localhost:4000`（默认，可通过 `API_BASE_URL` 覆盖）
  - 需实现以下接口：
    - `POST /api/auth/login`
    - `GET /api/products`
    - `GET /api/wishlist`
    - `POST /api/wishlist`

# 运行

脚本（推荐）：

```bash
chmod +x scripts/run_web.sh
./scripts/run_web.sh
```

或直接命令：

```bash
flutter run -d chrome --dart-define=API_BASE_URL=http://localhost:4000
```

可选同时注入认证 Token：

```bash
API_BASE_URL=http://localhost:4000 API_TOKEN=your-jwt-token ./scripts/run_web.sh
```

# 环境变量

- API_BASE_URL：后端地址，例如 http://localhost:4000
- API_TOKEN：可选，用于开发态直接注入认证（登录后会以页面获取的 token 为准）

# 登录

- 页面：启动后若无 token 显示登录页
- 接口：POST /api/auth/login
- 请求体：{ username, password }
- 成功后行为：写入 SharedPreferences 与 auth-token Cookie，后续请求自动携带

# 主要接口

- GET /api/products?page=1&limit=16：商品列表（分页）
- POST /api/wishlist：提交“当前所有收藏商品”的数组（全量同步）
- GET /api/wishlist：读取收藏列表（返回数组或包含 items/data/products 等键的对象）

# 功能概览

- 下拉刷新、上拉加载，错误提示使用 Snackbar
- 网格布局：SliverGridDelegateWithMaxCrossAxisExtent，自适应列数
- 骨架屏：首次刷新时显示占位卡片
- 收藏：乐观更新；后端失败自动回滚并同步

# 开发提示

- Web 环境已启用带凭据的请求客户端（withCredentials）
- 后端需正确配置 CORS（允许具体 Origin 与 Credentials、Headers/Methods）

# 目录与架构设计

核心目录只看 `lib/`：

```text
lib/
├─ api/                    # ApiClient：统一 baseUrl、token 注入、错误处理与日志
├─ models/
│  └─ product.dart         # 数据实体（Product）
├─ repositories/
│  ├─ auth_repository.dart     # 登录相关接口封装
│  └─ product_repository.dart  # 商品列表/收藏相关接口封装
├─ services/
│  ├─ auth/
│  │  ├─ auth_token_provider.dart # 登录态（Riverpod StateProvider）
│  │  ├─ cookie.dart / stub / web # Web Cookie 写入与平台适配
│  └─ products/
│     └─ product_list_notifier.dart # 商品列表状态管理（分页、刷新、收藏同步）
├─ common/
│  ├─ constants/
│  │  ├─ api_constants.dart   # API 地址与路径常量
│  │  ├─ route_names.dart     # 路由常量
│  │  └─ text_constants.dart  # 文案常量（标题、按钮文案等）
│  └─ utils/
│     └─ price_formatter.dart # 价格格式化工具
├─ router/
│  └─ app_router.dart         # 路由表 + 辅助方法（goHome / goLogin / goSplash）
├─ pages/
│  ├─ auth/
│  │  └─ login_page.dart      # 登录页
│  ├─ common/
│  │  └─ startup_gate.dart    # 启动初始化（从本地读取 token，进入首页）
│  └─ home/
│     ├─ home_root_page.dart     # 首页容器：IndexedStack + 自定义底部导航
│     ├─ product_list_page.dart  # 首页商品列表（搜索栏 + 签到/消息图标）
│     └─ favorites_page.dart     # 收藏列表（基于全局商品状态过滤）
├─ widgets/
│  ├─ product_card.dart       # 商品卡片 + 骨架卡片
│  └─ app_bottom_nav.dart     # 自定义底部导航组件（带登录拦截）
└─ main.dart                  # 应用入口：配置主题、初始路由、ProviderScope
```

架构层次简要说明：

- **api 层**：只关注 HTTP 请求细节（baseUrl、header、token、错误处理、日志/埋点钩子）
- **models 层**：只负责数据结构与 JSON 解析
- **repositories 层**：面向业务场景的“数据源”，组合调用 ApiClient，并对不稳定的返回结构做兼容处理
- **services 层**：放全局状态与业务状态管理（登录态、商品列表状态等）
- **common 层**：全局通用的常量与工具函数，避免魔法字符串与散落的格式化逻辑
- **router 层**：集中管理路由表与导航辅助方法，UI 层只调用 `AppRouter.goXxx`
- **pages 层**：聚焦 UI + 调用 service/repository，不直接做网络请求
- **widgets 层**：可复用组件（商品卡片、底部导航等），尽量保持无业务逻辑或仅包含少量可配置逻辑
