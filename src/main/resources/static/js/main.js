/**
 * main.js - 公共 JS（所有页面）
 */

// Token 工具
const TokenUtil = {
  getAccess:  () => localStorage.getItem('accessToken'),
  getRefresh: () => localStorage.getItem('refreshToken'),
  set: (access, refresh) => {
    localStorage.setItem('accessToken', access);
    if (refresh) localStorage.setItem('refreshToken', refresh);
  },
  clear: () => {
    localStorage.removeItem('accessToken');
    localStorage.removeItem('refreshToken');
  }
};

// 统一 fetch 封装（自动带 JWT）
async function apiFetch(url, options = {}) {
  const token = TokenUtil.getAccess();
  const headers = { 'Content-Type': 'application/json', ...(options.headers || {}) };
  if (token) headers['Authorization'] = 'Bearer ' + token;
  const resp = await fetch(url, { ...options, headers });
  if (resp.status === 401) {
    TokenUtil.clear();
    window.location.href = '/auth/login';
    return null;
  }
  return resp;
}

// 退出登录
const logoutBtn = document.getElementById('logoutBtn');
if (logoutBtn) {
  logoutBtn.addEventListener('click', () => {
    TokenUtil.clear();
    window.location.href = '/';
  });
}

// 如果已登录（有 token），更新导航状态
document.addEventListener('DOMContentLoaded', () => {
  const token = TokenUtil.getAccess();
  if (token) {
    // 可按需展示用户名等信息
  }
});

