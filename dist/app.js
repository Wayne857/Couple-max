const views = [...document.querySelectorAll('.app-view')];
const navButtons = [...document.querySelectorAll('[data-nav]')];
const bottomNavButtons = [...document.querySelectorAll('.bottom-nav [data-nav]')];
const sheets = [...document.querySelectorAll('.bottom-sheet')];
const backdrop = document.getElementById('backdrop');
const toast = document.getElementById('toast');
let pickedDish = '番茄牛腩面';

function setView(name) {
  views.forEach(view => view.classList.toggle('active', view.dataset.view === name));
  bottomNavButtons.forEach(button => button.classList.toggle('active', button.dataset.nav === name));
  const active = document.querySelector(`.app-view[data-view="${name}"]`);
  if (active) active.scrollTop = 0;
}

function openSheet(id) {
  sheets.forEach(sheet => sheet.classList.remove('open'));
  document.getElementById(id).classList.add('open');
  backdrop.classList.add('open');
  document.body.style.overflow = 'hidden';
}

function closeSheets() {
  sheets.forEach(sheet => sheet.classList.remove('open'));
  backdrop.classList.remove('open');
  document.body.style.overflow = '';
}

let toastTimer;
function showToast(message) {
  toast.querySelector('p').textContent = message;
  toast.classList.add('show');
  clearTimeout(toastTimer);
  toastTimer = setTimeout(() => toast.classList.remove('show'), 2600);
}

navButtons.forEach(button => button.addEventListener('click', () => setView(button.dataset.nav)));
backdrop.addEventListener('click', closeSheets);
document.addEventListener('keydown', event => { if (event.key === 'Escape') closeSheets(); });

document.querySelectorAll('[data-action]').forEach(button => {
  button.addEventListener('click', () => {
    const action = button.dataset.action;
    if (action === 'open-order') openSheet('orderSheet');
    if (action === 'open-recipe') openSheet('recipeSheet');
    if (action === 'open-wish') openSheet('wishSheet');
    if (action === 'close-sheet') closeSheets();
    if (action === 'accept-order') {
      const card = document.getElementById('requestCard');
      card.classList.add('accepted');
      button.textContent = '已接单 ✓';
      showToast('绵绵会收到“今晚做给你吃”的提醒');
    }
    if (action === 'paste-demo') {
      const field = document.getElementById(button.dataset.target);
      field.value = field.id === 'recipeUrl' ? 'https://xhslink.com/a/TomatoEgg' : 'https://m.tb.cn/h.TinyWish';
      field.focus();
    }
    if (action === 'submit-order') submitOrder();
    if (action === 'parse-recipe') parseRecipe();
    if (action === 'parse-wish') parseWish();
  });
});

document.querySelectorAll('[data-pick]').forEach(button => {
  button.addEventListener('click', () => {
    pickedDish = button.dataset.pick;
    document.querySelectorAll('[data-pick]').forEach(item => item.classList.toggle('selected', item === button));
    document.getElementById('customDish').value = '';
  });
});

document.querySelectorAll('[data-dish]').forEach(button => {
  button.addEventListener('click', () => {
    pickedDish = button.dataset.dish;
    document.querySelectorAll('[data-pick]').forEach(item => item.classList.toggle('selected', item.dataset.pick === pickedDish));
    openSheet('orderSheet');
  });
});

function submitOrder() {
  const custom = document.getElementById('customDish').value.trim();
  const dish = custom || pickedDish;
  if (!dish) return showToast('先写一道想吃的菜吧');
  createMealRequest(dish, document.getElementById('orderNote').value.trim() || '想吃你做的～');
  closeSheets();
  showToast(`点菜单已送给舟舟：${dish}`);
}

function createMealRequest(dish, note) {
  document.getElementById('requestedDish').textContent = dish;
  document.querySelector('.request-copy span').textContent = `“${note}”`;
  const card = document.getElementById('requestCard');
  card.classList.remove('accepted');
  card.querySelector('button').textContent = '接单';
  localStorage.setItem('couple-last-dish', dish);
  return { dish, note, status: 'sent', recipient: '舟舟' };
}

function parseRecipe() {
  const field = document.getElementById('recipeUrl');
  if (!field.value.trim()) { field.focus(); return showToast('请先粘贴小红书链接'); }
  const preview = document.getElementById('recipePreview');
  preview.classList.remove('hidden');
  const button = document.querySelector('[data-action="parse-recipe"]');
  button.disabled = true; button.textContent = '正在解析…';
  setTimeout(() => {
    const card = document.createElement('article');
    card.className = 'recipe-card'; card.dataset.category = 'quick'; card.dataset.name = '葱油拌面';
    card.innerHTML = '<div class="recipe-image" style="background:#ead2a3"><span class="food-emoji">🍝</span><span>12 分钟</span></div><div class="recipe-info"><h3>葱油拌面</h3><p>葱香浓郁 · 5 个步骤</p><div><span>刚从小红书导入</span><button aria-label="收藏葱油拌面">♥</button></div></div>';
    document.getElementById('recipeGrid').prepend(card);
    preview.classList.add('hidden'); button.disabled = false; button.textContent = '解析并收藏';
    closeSheets(); setView('recipes'); showToast('菜谱整理好了，食材和 5 个步骤已保存');
    field.value = '';
  }, 1200);
}

function parseWish() {
  const field = document.getElementById('wishUrl');
  if (!field.value.trim()) { field.focus(); return showToast('请先粘贴淘宝商品链接'); }
  const preview = document.getElementById('wishPreview');
  preview.classList.remove('hidden');
  const button = document.querySelector('[data-action="parse-wish"]');
  button.disabled = true; button.textContent = '正在生成卡片…';
  setTimeout(() => {
    const reason = document.getElementById('wishReason').value.trim() || '想和你一起用';
    const card = document.createElement('article'); card.className = 'wish-card';
    card.innerHTML = `<div class="product-image" style="background:#e5d8c7">🏕</div><div class="product-copy"><span class="source-pill">淘宝</span><h3>双人轻量露营椅</h3><p>绵绵的心愿 · ${reason}</p><strong>¥328</strong></div><button class="wish-heart liked" aria-label="取消喜欢">♥</button>`;
    document.getElementById('wishlist').prepend(card);
    document.getElementById('wishCount').textContent = '9';
    preview.classList.add('hidden'); button.disabled = false; button.textContent = '加入心愿清单';
    closeSheets(); setView('wishlist'); showToast('商品卡片已加入共同心愿');
    field.value = ''; document.getElementById('wishReason').value = '';
  }, 1200);
}

document.getElementById('recipeSearch').addEventListener('input', event => {
  const keyword = event.target.value.trim().toLowerCase();
  document.querySelectorAll('.recipe-card').forEach(card => card.classList.toggle('hidden-card', !card.dataset.name.toLowerCase().includes(keyword)));
});

document.querySelectorAll('[data-filter]').forEach(button => {
  button.addEventListener('click', () => {
    const filter = button.dataset.filter;
    document.querySelectorAll('[data-filter]').forEach(item => item.classList.toggle('active', item === button));
    document.querySelectorAll('.recipe-card').forEach(card => card.classList.toggle('hidden-card', filter !== 'all' && card.dataset.category !== filter));
  });
});

document.addEventListener('click', event => {
  const heart = event.target.closest('.wish-heart, .recipe-info button');
  if (!heart) return;
  heart.classList.toggle('liked');
  if (heart.classList.contains('wish-heart')) heart.textContent = heart.classList.contains('liked') ? '♥' : '♡';
});

const storedDish = localStorage.getItem('couple-last-dish');
if (storedDish) document.getElementById('requestedDish').textContent = storedDish;
const now = new Date();
document.getElementById('statusTime').textContent = `${String(now.getHours()).padStart(2,'0')}:${String(now.getMinutes()).padStart(2,'0')}`;

// 让支持 WebMCP 的浏览器或智能助手可以完成与界面一致的核心动作。
if (document.modelContext?.registerTool) {
  const lifecycle = new AbortController();
  try {
    Promise.resolve(document.modelContext.registerTool({
      name: 'create_meal_request',
      title: '给另一半点菜',
      description: '在情侣小屋中创建一条点菜请求，并同步更新首页的待接单卡片。',
      inputSchema: {
        type: 'object',
        properties: {
          dish: { type: 'string', minLength: 1, maxLength: 18, description: '想吃的菜名' },
          note: { type: 'string', maxLength: 30, description: '给另一半的留言' }
        },
        required: ['dish'],
        additionalProperties: false
      },
      annotations: { readOnlyHint: false, untrustedContentHint: false },
      execute(input) {
        const dish = typeof input?.dish === 'string' ? input.dish.trim() : '';
        const note = typeof input?.note === 'string' ? input.note.trim() : '想吃你做的～';
        if (!dish || dish.length > 18 || note.length > 30) throw new Error('菜名或留言不符合长度要求');
        const result = createMealRequest(dish, note || '想吃你做的～');
        setView('home');
        showToast(`点菜单已送给舟舟：${dish}`);
        return result;
      }
    }, { signal: lifecycle.signal })).catch(() => {});
  } catch (_) {}
}
