# 项目简介

Flutter 商品列表页，使用 Riverpod 管理状态，支持下拉刷新、上拉加载；网格布局（自适应列数），骨架屏占位；收藏按钮支持后端同步与登录鉴权。

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
