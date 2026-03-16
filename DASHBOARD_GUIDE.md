# 登录后仪表板功能说明

## 功能概述

创建了一个现代化的登录后仪表板，包含用户信息展示、可收缩的左侧菜单和右侧内容区域。

## 页面结构

### 1. 顶部栏 (Topbar)
- **左侧**：菜单切换按钮 + 应用标题
- **右侧**：用户信息 + 退出登录按钮

**用户信息展示：**
- 用户头像（显示用户名首字母）
- 用户名
- 用户角色
- 点击可展开用户菜单（可扩展）

### 2. 左侧菜单 (Sidebar)
**特性：**
- ✅ 可收缩/展开（点击菜单按钮）
- ✅ 每个菜单项都有图标
- ✅ 当前页面高亮显示
- ✅ 响应式设计（移动端自动收缩）
- ✅ 平滑动画过渡

**菜单项：**
1. 仪表板 - `<i class="bi bi-speedometer2"></i>`
2. 用户管理 - `<i class="bi bi-people"></i>`
3. 角色管理 - `<i class="bi bi-shield-check"></i>`
4. 菜单管理 - `<i class="bi bi-list"></i>`
5. 商品管理 - `<i class="bi bi-box-seam"></i>`
6. API 文档 - `<i class="bi bi-braces"></i>`

### 3. 主内容区 (Main Content)
**包含内容：**

#### 欢迎卡片
- 显示用户名
- 简短的欢迎信息

#### 统计卡片（4 列）
- 用户总数
- 角色总数
- 菜单总数
- 商品总数

#### 最近商品表格
- 商品名称
- 分类
- 价格
- 库存
- 状态（上架/下架）

## 技术实现

### 前端技术
- **框架**：Bootstrap 5 + Vanilla JavaScript
- **图标**：Bootstrap Icons
- **样式**：CSS3 + CSS 变量
- **动画**：CSS Transitions

### 关键特性

#### 1. 菜单收缩功能
```javascript
// 切换侧边栏
document.getElementById('toggleSidebarBtn').addEventListener('click', function() {
    const sidebar = document.getElementById('sidebar');
    const mainContent = document.getElementById('mainContent');
    sidebar.classList.toggle('collapsed');
    mainContent.classList.toggle('expanded');
});
```

#### 2. 用户头像初始化
```javascript
function getInitials(name) {
    return name ? name.charAt(0).toUpperCase() : 'U';
}
```

#### 3. 动态加载统计数据
```javascript
// 从 API 加载数据
fetch('/api/admin/users?page=1&size=1', {
    headers: { 'Authorization': `Bearer ${token}` }
})
.then(r => r.json())
.then(data => {
    if (data.code === 0) {
        document.getElementById('userCount').textContent = data.data.total;
    }
});
```

#### 4. 菜单项高亮
```javascript
document.querySelectorAll('.menu-link').forEach(link => {
    link.addEventListener('click', function() {
        document.querySelectorAll('.menu-link').forEach(l => l.classList.remove('active'));
        this.classList.add('active');
    });
});
```

## 样式设计

### 颜色方案
- **主色**：`#6366f1`（靛蓝）
- **深色**：`#4f46e5`
- **背景**：`#f5f7fa`
- **文字**：`#1f2937`（深灰）

### 响应式断点
- **桌面**：完整菜单 + 完整内容
- **平板**：菜单可收缩
- **手机**：菜单默认收缩

### 动画效果
- **过渡时间**：0.3s
- **缓动函数**：cubic-bezier(0.4, 0, 0.2, 1)
- **效果**：菜单收缩、卡片悬停、按钮交互

## 路由配置

### 页面路由
| 路由 | 方法 | 返回 | 说明 |
|------|------|------|------|
| GET /dashboard | dashboard() | dashboard | 登录后首页 |
| GET /admin | index() | admin/index | 管理后台首页 |
| GET /admin/users | users() | admin/users | 用户管理 |
| GET /admin/roles | roles() | admin/roles | 角色管理 |
| GET /admin/menus | menus() | admin/menus | 菜单管理 |

### API 调用
| 端点 | 用途 |
|------|------|
| GET /api/admin/users?page=1&size=1 | 获取用户总数 |
| GET /api/admin/roles?page=1&size=1 | 获取角色总数 |
| GET /api/admin/menus?page=1&size=1 | 获取菜单总数 |
| GET /api/products?page=1&size=5 | 获取最近商品 |

## 使用说明

### 访问仪表板
1. 登录系统
2. 自动重定向到 `/dashboard`
3. 查看用户信息和统计数据

### 菜单操作
1. **展开/收缩**：点击左上角菜单按钮
2. **导航**：点击菜单项跳转到对应页面
3. **高亮**：当前页面菜单项自动高亮

### 用户操作
1. **查看信息**：顶部栏显示用户名和角色
2. **退出登录**：点击右上角退出按钮

## 自定义菜单项

### 添加新菜单项
```html
<li class="menu-item">
    <a href="/your-page" class="menu-link">
        <div class="menu-icon"><i class="bi bi-your-icon"></i></div>
        <span class="menu-label">菜单标签</span>
    </a>
</li>
```

### 修改菜单图标
使用 Bootstrap Icons，访问 https://icons.getbootstrap.com/ 查看所有可用图标

### 修改颜色
编辑 CSS 变量：
```css
:root {
    --primary: #6366f1;        /* 主色 */
    --primary-dark: #4f46e5;   /* 深色 */
}
```

## 性能优化

1. **懒加载**：统计数据在页面加载后异步获取
2. **缓存**：使用 localStorage 存储 Token
3. **动画**：使用 CSS 动画而非 JavaScript
4. **响应式**：移动端自动调整布局

## 浏览器兼容性

- ✅ Chrome 90+
- ✅ Firefox 88+
- ✅ Safari 14+
- ✅ Edge 90+

## 文件位置

- **模板**：`src/main/resources/templates/dashboard.html`
- **路由**：`src/main/java/com/an/controller/PageController.java`

## 下一步改进

1. 添加用户菜单（修改密码、个人设置等）
2. 实现菜单权限动态加载
3. 添加通知/消息功能
4. 实现主题切换（亮色/暗色）
5. 添加快捷操作面板

