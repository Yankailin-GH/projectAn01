/**
 * auth.js - 登录 / 注册页面逻辑
 */

const TokenUtil = {
  set: (access, refresh) => {
    localStorage.setItem('accessToken', access);
    if (refresh) localStorage.setItem('refreshToken', refresh);
  }
};

function showAlert(message, type = 'danger') {
  const box = document.getElementById('alertBox');
  if (!box) return;
  box.className = 'alert alert-' + type;
  box.textContent = message;
  box.classList.remove('d-none');
  setTimeout(() => box.classList.add('d-none'), 5000);
}

function setLoading(btnId, spinnerId, textId, loading) {
  const btn = document.getElementById(btnId);
  const spinner = document.getElementById(spinnerId);
  const text = document.getElementById(textId);
  if (btn) btn.disabled = loading;
  if (spinner) spinner.classList.toggle('d-none', !loading);
  if (text) text.textContent = loading ? '请稍候...' : (btnId === 'loginBtn' ? '登录' : '注册');
}

// ---- 登录表单 ----
const loginForm = document.getElementById('loginForm');
if (loginForm) {
  loginForm.addEventListener('submit', async (e) => {
    e.preventDefault();
    const username = document.getElementById('username').value.trim();
    const password = document.getElementById('password').value;
    if (!username || !password) { showAlert('请填写用户名和密码'); return; }

    setLoading('loginBtn', 'loginSpinner', 'loginText', true);
    try {
      const resp = await fetch('/api/auth/login', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ username, password })
      });
      const result = await resp.json();
      if (result.success) {
        TokenUtil.set(result.data.accessToken, result.data.refreshToken);
        showAlert('登录成功，跳转中...', 'success');
        setTimeout(() => window.location.href = '/', 800);
      } else {
        showAlert(result.message || '登录失败');
      }
    } catch (err) {
      showAlert('网络错误，请稍后重试');
    } finally {
      setLoading('loginBtn', 'loginSpinner', 'loginText', false);
    }
  });
}

// ---- 注册表单 ----
const registerForm = document.getElementById('registerForm');
if (registerForm) {
  registerForm.addEventListener('submit', async (e) => {
    e.preventDefault();
    const username = document.getElementById('username').value.trim();
    const email = document.getElementById('email').value.trim();
    const fullName = document.getElementById('fullName')?.value.trim();
    const password = document.getElementById('password').value;
    const confirmPassword = document.getElementById('confirmPassword').value;

    if (!username || !email || !password || !confirmPassword) {
      showAlert('请填写所有必填项'); return;
    }
    if (password !== confirmPassword) { showAlert('两次密码不一致'); return; }
    if (password.length < 6) { showAlert('密码至少6个字符'); return; }

    setLoading('registerBtn', 'regSpinner', 'regText', true);
    try {
      const resp = await fetch('/api/auth/register', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ username, email, password, confirmPassword, fullName })
      });
      const result = await resp.json();
      if (result.success) {
        showAlert('注册成功！即将跳转到登录页...', 'success');
        setTimeout(() => window.location.href = '/auth/login', 1200);
      } else {
        showAlert(result.message || '注册失败');
      }
    } catch (err) {
      showAlert('网络错误，请稍后重试');
    } finally {
      setLoading('registerBtn', 'regSpinner', 'regText', false);
    }
  });
}

// ---- 密码显示切换 ----
const togglePwd = document.getElementById('togglePwd');
if (togglePwd) {
  togglePwd.addEventListener('click', () => {
    const pwdInput = document.getElementById('password');
    const eyeIcon  = document.getElementById('eyeIcon');
    const isPassword = pwdInput.type === 'password';
    pwdInput.type = isPassword ? 'text' : 'password';
    eyeIcon.className = isPassword ? 'bi bi-eye-slash' : 'bi bi-eye';
  });
}

// ---- 演示账号快填 ----
function fillDemo(username, password) {
  const u = document.getElementById('username');
  const p = document.getElementById('password');
  if (u) u.value = username;
  if (p) p.value = password;
}

