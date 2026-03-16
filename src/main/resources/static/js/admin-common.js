// ==================== 通用工具函数 ====================

// 获取用户名首字母
function getInitials(name) {
    return name ? name.charAt(0).toUpperCase() : 'U';
}

// 初始化用户头像
function initUserAvatar() {
    const userName = document.getElementById('userName');
    const userAvatar = document.getElementById('userAvatar');
    if (userName && userAvatar) {
        userAvatar.textContent = getInitials(userName.textContent);
    }
}

// 切换侧边栏
function toggleSidebar() {
    const sidebar = document.getElementById('sidebar');
    const mainContent = document.getElementById('mainContent');
    if (sidebar && mainContent) {
        sidebar.classList.toggle('collapsed');
        mainContent.classList.toggle('expanded');
    }
}

// 退出登录
function logout() {
    showConfirm('确定要退出登录吗？', () => {
        localStorage.removeItem('token');
        window.location.href = '/auth/login';
    });
}

// ==================== 初始化管理页面 ====================
function initAdminPage() {
    // 检查 token
    const token = localStorage.getItem('token');
    if (!token) {
        window.location.href = '/auth/login';
        return;
    }

    // 从 localStorage 填充用户信息
    const username = localStorage.getItem('username') || '';
    const userNameEl = document.getElementById('userName');
    if (userNameEl && username) {
        userNameEl.textContent = username;
    }

    // 初始化用户头像
    initUserAvatar();

    // 绑定侧边栏切换按钮
    const toggleBtn = document.getElementById('toggleSidebarBtn');
    if (toggleBtn) {
        toggleBtn.addEventListener('click', toggleSidebar);
    }
}

// ==================== API 请求封装 ====================

// 通用 GET 请求
async function apiGet(url) {
    const token = localStorage.getItem('token');
    const response = await fetch(url, {
        method: 'GET',
        headers: {
            'Authorization': `Bearer ${token}`,
            'Content-Type': 'application/json'
        }
    });
    return await response.json();
}

// 通用 POST 请求
async function apiPost(url, data) {
    const token = localStorage.getItem('token');
    const response = await fetch(url, {
        method: 'POST',
        headers: {
            'Authorization': `Bearer ${token}`,
            'Content-Type': 'application/json'
        },
        body: JSON.stringify(data)
    });
    return await response.json();
}

// 通用 PUT 请求
async function apiPut(url, data) {
    const token = localStorage.getItem('token');
    const response = await fetch(url, {
        method: 'PUT',
        headers: {
            'Authorization': `Bearer ${token}`,
            'Content-Type': 'application/json'
        },
        body: JSON.stringify(data)
    });
    return await response.json();
}

// 通用 DELETE 请求
async function apiDelete(url) {
    const token = localStorage.getItem('token');
    const response = await fetch(url, {
        method: 'DELETE',
        headers: {
            'Authorization': `Bearer ${token}`,
            'Content-Type': 'application/json'
        }
    });
    return await response.json();
}

// ==================== 通用提示函数 ====================

// 创建提示容器（如果不存在）
function createToastContainer() {
    let container = document.getElementById('toastContainer');
    if (!container) {
        container = document.createElement('div');
        container.id = 'toastContainer';
        container.style.cssText = `
            position: fixed;
            top: 80px;
            left: 50%;
            transform: translateX(-50%);
            z-index: 9999;
            display: flex;
            flex-direction: column;
            gap: 10px;
            pointer-events: none;
        `;
        document.body.appendChild(container);
    }
    return container;
}

// 显示提示消息
function showToast(message, type = 'info') {
    const container = createToastContainer();
    
    // 创建提示元素
    const toast = document.createElement('div');
    toast.className = `toast-message toast-${type}`;
    
    // 根据类型设置图标和颜色
    const icons = {
        success: '✓',
        error: '✕',
        warning: '⚠',
        info: 'ℹ'
    };
    
    const colors = {
        success: '#10b981',
        error: '#ef4444',
        warning: '#f59e0b',
        info: '#3b82f6'
    };
    
    const icon = icons[type] || icons.info;
    const color = colors[type] || colors.info;
    
    toast.innerHTML = `
        <div style="
            display: flex;
            align-items: center;
            gap: 12px;
            padding: 16px 24px;
            background: white;
            border-left: 4px solid ${color};
            border-radius: 8px;
            box-shadow: 0 8px 24px rgba(0,0,0,0.2);
            min-width: 320px;
            max-width: 500px;
            animation: fadeInScale 0.3s ease-out;
            pointer-events: auto;
        ">
            <div style="
                width: 28px;
                height: 28px;
                border-radius: 50%;
                background: ${color};
                color: white;
                display: flex;
                align-items: center;
                justify-content: center;
                font-weight: bold;
                font-size: 18px;
                flex-shrink: 0;
            ">${icon}</div>
            <div style="
                flex: 1;
                color: #374151;
                font-size: 15px;
                line-height: 1.5;
                font-weight: 500;
            ">${message}</div>
            <button onclick="this.parentElement.parentElement.remove()" style="
                background: none;
                border: none;
                color: #9ca3af;
                cursor: pointer;
                font-size: 22px;
                line-height: 1;
                padding: 0;
                width: 24px;
                height: 24px;
                flex-shrink: 0;
                transition: color 0.2s;
            " onmouseover="this.style.color='#374151'" onmouseout="this.style.color='#9ca3af'">×</button>
        </div>
    `;
    
    container.appendChild(toast);
    
    // 3秒后自动移除
    setTimeout(() => {
        toast.style.animation = 'fadeOutScale 0.3s ease-in';
        setTimeout(() => toast.remove(), 300);
    }, 3000);
}

// 根据响应结果显示提示
function handleResponse(response, defaultSuccessMsg = '操作成功', defaultErrorMsg = '操作失败') {
    const message = response.msg || response.message || (response.code === 0 ? defaultSuccessMsg : defaultErrorMsg);
    
    if (response.code === 0) {
        showToast(message, 'success');
        return true;
    } else {
        showToast(message, 'error');
        return false;
    }
}

// 成功提示
function showSuccess(message) {
    showToast(message, 'success');
}

// 错误提示
function showError(message) {
    showToast(message, 'error');
}

// 警告提示
function showWarning(message) {
    showToast(message, 'warning');
}

// 信息提示
function showInfo(message) {
    showToast(message, 'info');
}

// 确认对话框
function showConfirm(message, onConfirm, onCancel) {
    return new Promise((resolve) => {
        // 创建遮罩层
        const overlay = document.createElement('div');
        overlay.className = 'confirm-overlay';
        
        // 创建确认框
        const confirmBox = document.createElement('div');
        confirmBox.className = 'confirm-box';
        confirmBox.innerHTML = `
            <div class="confirm-icon">
                <i class="bi bi-question-circle"></i>
            </div>
            <div class="confirm-message">${message}</div>
            <div class="confirm-buttons">
                <button class="confirm-btn confirm-btn-cancel" id="confirmCancel">
                    <i class="bi bi-x-lg me-2"></i>
                    取消
                </button>
                <button class="confirm-btn confirm-btn-confirm" id="confirmOk">
                    <i class="bi bi-check-lg me-2"></i>
                    确定
                </button>
            </div>
        `;
        
        overlay.appendChild(confirmBox);
        document.body.appendChild(overlay);
        
        // 添加动画
        setTimeout(() => {
            overlay.classList.add('show');
        }, 10);
        
        // 关闭确认框
        function closeConfirm(result) {
            overlay.classList.remove('show');
            setTimeout(() => {
                overlay.remove();
                resolve(result);
                if (result && onConfirm) {
                    onConfirm();
                } else if (!result && onCancel) {
                    onCancel();
                }
            }, 300);
        }
        
        // 绑定事件
        document.getElementById('confirmOk').onclick = () => closeConfirm(true);
        document.getElementById('confirmCancel').onclick = () => closeConfirm(false);
        overlay.onclick = (e) => {
            if (e.target === overlay) {
                closeConfirm(false);
            }
        };
        
        // ESC 键关闭
        const escHandler = (e) => {
            if (e.key === 'Escape') {
                closeConfirm(false);
                document.removeEventListener('keydown', escHandler);
            }
        };
        document.addEventListener('keydown', escHandler);
    });
}

// ==================== 日期格式化 ====================
function formatDate(dateString) {
    if (!dateString) return '-';
    const date = new Date(dateString);
    const year = date.getFullYear();
    const month = String(date.getMonth() + 1).padStart(2, '0');
    const day = String(date.getDate()).padStart(2, '0');
    return `${year}-${month}-${day}`;
}

function formatDateTime(dateString) {
    if (!dateString) return '-';
    const date = new Date(dateString);
    const year = date.getFullYear();
    const month = String(date.getMonth() + 1).padStart(2, '0');
    const day = String(date.getDate()).padStart(2, '0');
    const hours = String(date.getHours()).padStart(2, '0');
    const minutes = String(date.getMinutes()).padStart(2, '0');
    return `${year}-${month}-${day} ${hours}:${minutes}`;
}

// ==================== 页面加载完成后自动初始化 ====================
document.addEventListener('DOMContentLoaded', function() {
    // 如果页面中有管理后台的元素，自动初始化
    if (document.querySelector('.dashboard-container')) {
        initAdminPage();
        renderSidebar();
    }
});

// ==================== 侧边栏动态渲染 ====================

const FIXED_BOTTOM_MENUS = [
    { name: '返回首页', path: '/', icon: 'house', key: 'home' },
    { name: 'API 文档', path: '/swagger-ui.html', icon: 'braces', key: 'swagger', target: '_blank' }
];

const ADMIN_DEFAULT_MENUS = [
    { name: '仪表板', path: '/dashboard', icon: 'speedometer2', key: 'dashboard', type: 1 },
    {
        name: '系统管理', icon: 'gear', key: 'system', type: 1, children: [
            { name: '用户管理', path: '/admin/users', icon: 'people', key: 'users', type: 1 },
            { name: '角色管理', path: '/admin/roles', icon: 'shield-check', key: 'roles', type: 1 },
            { name: '菜单管理', path: '/admin/menus', icon: 'list-ul', key: 'menus', type: 1 }
        ]
    },
    {
        name: '商品管理', icon: 'shop', key: 'shop', type: 1, children: [
            { name: '商品管理', path: '/admin/products', icon: 'box-seam', key: 'products', type: 1 }
        ]
    },
    {
        name: '订单管理', icon: 'file-text', key: 'order', type: 1, children: [
            { name: '订单列表', path: '/admin/orders', icon: 'list-ol', key: 'orders', type: 1 }
        ]
    },
    {
        name: '用户中心', icon: 'person', key: 'profile', type: 1, children: [
            { name: '个人信息', path: '/profile/info', icon: 'person-badge', key: 'info', type: 1 },
            { name: '修改密码', path: '/profile/password', icon: 'lock', key: 'password', type: 1 }
        ]
    }
];

function renderSidebar() {
    const sidebarEl = document.getElementById('sidebar');
    const menuEl = document.getElementById('sidebarMenu');
    if (!sidebarEl || !menuEl) return;

    const activePage = sidebarEl.dataset.active || '';
    const roles = JSON.parse(localStorage.getItem('roles') || '[]');
    const isAdmin = roles.includes('ROLE_ADMIN');
    const storedMenus = JSON.parse(localStorage.getItem('menus') || '[]');

    // admin 用默认全量菜单；其他用户用服务端返回的菜单
    const menus = isAdmin ? ADMIN_DEFAULT_MENUS : convertToSidebarMenus(storedMenus);

    let html = '';
    menus.forEach(menu => {
        if (menu.type === 2) return;
        html += renderSidebarNode(menu, activePage);
    });

    FIXED_BOTTOM_MENUS.forEach(item => {
        html += `<li class="menu-item">
            <a href="${item.path}" class="menu-link" ${item.target ? 'target="_blank"' : ''}>
                <div class="menu-icon"><i class="bi bi-${item.icon}"></i></div>
                <span class="menu-label">${item.name}</span>
            </a>
        </li>`;
    });

    menuEl.innerHTML = html;

    // 绑定折叠展开事件
    menuEl.querySelectorAll('.menu-group-header').forEach(header => {
        header.addEventListener('click', function() {
            const submenu = this.nextElementSibling;
            const arrow = this.querySelector('.menu-arrow');
            if (submenu) {
                submenu.classList.toggle('open');
                arrow && arrow.classList.toggle('rotated');
                this.classList.toggle('active', submenu.classList.contains('open'));
            }
        });
    });
}

function renderSidebarNode(menu, activePage) {
    const hasChildren = menu.children && menu.children.filter(c => c.type !== 2).length > 0;
    const isActiveGroup = hasChildren && menu.children.some(c => c.key === activePage);

    if (hasChildren) {
        const subItems = menu.children.filter(c => c.type !== 2).map(child => `
            <li>
                <a href="${child.path || '#'}" class="menu-link submenu-link ${child.key === activePage ? 'active' : ''}">
                    <div class="menu-icon"><i class="bi bi-${child.icon || 'circle'}"></i></div>
                    <span class="menu-label">${child.name}</span>
                </a>
            </li>
        `).join('');

        return `<li class="menu-item menu-group">
            <div class="menu-link menu-group-header ${isActiveGroup ? 'active' : ''}">
                <div class="menu-icon"><i class="bi bi-${menu.icon || 'folder'}"></i></div>
                <span class="menu-label">${menu.name}</span>
                <i class="bi bi-chevron-down menu-arrow ${isActiveGroup ? 'rotated' : ''}"></i>
            </div>
            <ul class="submenu ${isActiveGroup ? 'open' : ''}">${subItems}</ul>
        </li>`;
    } else {
        return `<li class="menu-item">
            <a href="${menu.path || '#'}" class="menu-link ${menu.key === activePage ? 'active' : ''}">
                <div class="menu-icon"><i class="bi bi-${menu.icon || 'circle'}"></i></div>
                <span class="menu-label">${menu.name}</span>
            </a>
        </li>`;
    }
}

function convertToSidebarMenus(menus) {
    function pathToKey(path) {
        if (!path) return '';
        const parts = path.split('/').filter(Boolean);
        return parts[parts.length - 1] || '';
    }
    function convert(menu) {
        const node = {
            name: menu.name,
            path: menu.path,
            icon: menu.icon || 'circle',
            key: pathToKey(menu.path),
            type: menu.type
        };
        if (menu.children && menu.children.length > 0) {
            node.children = menu.children.map(convert);
        }
        return node;
    }
    return menus.map(convert);
}

