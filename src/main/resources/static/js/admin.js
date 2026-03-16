/**
 * admin.js - 管理后台商品 CRUD
 */

const TOKEN = () => localStorage.getItem('accessToken');

async function apiFetch(url, options = {}) {
  const headers = { 'Content-Type': 'application/json', ...(options.headers || {}) };
  const t = TOKEN();
  if (t) headers['Authorization'] = 'Bearer ' + t;
  const resp = await fetch(url, { ...options, headers });
  if (resp.status === 401) { window.location.href = '/auth/login'; return null; }
  return resp;
}

function showToast(message, type = 'success') {
  let container = document.getElementById('toastContainer');
  if (!container) {
    container = document.createElement('div');
    container.id = 'toastContainer';
    container.style.cssText = 'position:fixed;top:1rem;right:1rem;z-index:9999;display:flex;flex-direction:column;gap:.5rem;';
    document.body.appendChild(container);
  }
  const toast = document.createElement('div');
  toast.className = 'alert alert-' + (type === 'success' ? 'success' : 'danger');
  toast.style.cssText = 'min-width:240px;padding:.75rem 1rem;border-radius:8px;animation:slideIn .3s ease;';
  toast.textContent = message;
  container.appendChild(toast);
  setTimeout(() => toast.remove(), 3500);
}

// ---- 新增 / 编辑商品 ----
const saveBtn = document.getElementById('saveProductBtn');
if (saveBtn) {
  saveBtn.addEventListener('click', async () => {
    const id    = document.getElementById('productId').value;
    const name  = document.getElementById('pName').value.trim();
    const price = document.getElementById('pPrice').value;
    const stock = document.getElementById('pStock').value;
    const sku   = document.getElementById('pSku').value.trim();
    const imageUrl    = document.getElementById('pImageUrl').value.trim();
    const description = document.getElementById('pDescription').value.trim();

    if (!name || !price) { showToast('商品名称和价格为必填项', 'danger'); return; }

    const payload = { name, price: parseFloat(price), stock: parseInt(stock) || 0,
      sku, imageUrl, description };
    const url    = id ? `/api/products/${id}` : '/api/products';
    const method = id ? 'PUT' : 'POST';

    saveBtn.disabled = true;
    saveBtn.textContent = '保存中...';
    try {
      const resp = await apiFetch(url, { method, body: JSON.stringify(payload) });
      if (!resp) return;
      const result = await resp.json();
      if (result.success) {
        showToast(id ? '商品更新成功' : '商品创建成功');
        const modal = bootstrap.Modal.getInstance(document.getElementById('productModal'));
        if (modal) modal.hide();
        setTimeout(() => location.reload(), 800);
      } else {
        showToast(result.message || '操作失败', 'danger');
      }
    } catch (e) {
      showToast('网络错误', 'danger');
    } finally {
      saveBtn.disabled = false;
      saveBtn.textContent = '保存';
    }
  });
}

// ---- 编辑商品（填充表单）----
async function editProduct(id) {
  try {
    const resp = await apiFetch(`/api/products/${id}`);
    if (!resp) return;
    const result = await resp.json();
    if (!result.success) { showToast('获取商品信息失败', 'danger'); return; }
    const p = result.data;
    document.getElementById('productId').value   = p.id;
    document.getElementById('pName').value        = p.name || '';
    document.getElementById('pPrice').value       = p.price || '';
    document.getElementById('pStock').value       = p.stock || 0;
    document.getElementById('pSku').value         = p.sku || '';
    document.getElementById('pImageUrl').value    = p.imageUrl || '';
    document.getElementById('pDescription').value = p.description || '';
    document.getElementById('modalTitle').textContent = '编辑商品';
    new bootstrap.Modal(document.getElementById('productModal')).show();
  } catch (e) {
    showToast('网络错误', 'danger');
  }
}

// ---- 删除商品 ----
async function deleteProduct(id) {
  if (!confirm('确认删除该商品？此操作不可恢复。')) return;
  try {
    const resp = await apiFetch(`/api/products/${id}`, { method: 'DELETE' });
    if (!resp) return;
    const result = await resp.json();
    if (result.success) {
      showToast('商品已删除');
      setTimeout(() => location.reload(), 800);
    } else {
      showToast(result.message || '删除失败', 'danger');
    }
  } catch (e) {
    showToast('网络错误', 'danger');
  }
}

// 重置 Modal 表单
const productModal = document.getElementById('productModal');
if (productModal) {
  productModal.addEventListener('hidden.bs.modal', () => {
    document.getElementById('productId').value = '';
    document.getElementById('pName').value = '';
    document.getElementById('pPrice').value = '';
    document.getElementById('pStock').value = '0';
    document.getElementById('pSku').value = '';
    document.getElementById('pImageUrl').value = '';
    document.getElementById('pDescription').value = '';
    document.getElementById('modalTitle').textContent = '新增商品';
  });
}

// CSS keyframes for toast
const style = document.createElement('style');
style.textContent = '@keyframes slideIn{from{transform:translateX(100%);opacity:0}to{transform:translateX(0);opacity:1}}';
document.head.appendChild(style);

