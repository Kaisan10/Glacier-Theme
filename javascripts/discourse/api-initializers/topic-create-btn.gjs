import { apiInitializer } from "discourse/lib/api";

export default apiInitializer("1.8.0", (api) => {
  let isUpdating = false; // 無限ループ防止フラグ
  let observer = null;
  
  function applyCreateTopicStyle() {
    const hasDraftsMenu = document.querySelector('.navigation-controls [data-identifier="topic-drafts-menu"]');
    const createTopic = document.getElementById('create-topic');
    
    if (createTopic) {
      if (hasDraftsMenu) {
        createTopic.style.borderRadius = '100px 0 0 100px';
        createTopic.style.padding = '.5em 0 .5em .5em';
      } else {
        createTopic.style.borderRadius = '100px';
        createTopic.style.padding = '.5em .65em';
      }
    }
  }
  
  function updateSidebarControls() {
    if (isUpdating) return; // 既に更新中なら何もしない
    
    const sidebar = document.querySelector('#d-sidebar.sidebar-container');
    if (!sidebar) return;
    
    isUpdating = true; // 更新開始
    
    // Observer を一時停止
    if (observer) {
      observer.disconnect();
    }
    
    const existingControls = sidebar.querySelector('.sidebar-navigation-controls');
    if (existingControls) {
      existingControls.remove();
    }
    
    const hasDraftsMenu = document.querySelector('.navigation-controls [data-identifier="topic-drafts-menu"]');
    
    const createButtonStyle = hasDraftsMenu 
      ? 'border-radius: 0; padding: 0.5em 0 0.5em 0.5em;'
      : 'border-radius: 0 100px 100px 0; padding: 0.5em 0.65em;';
    
    const draftsButtonStyle = 'border-radius: 0 100px 100px 0;';
    
    const controlsHTML = `
      <div class="sidebar-navigation-controls" style="position: relative;">
        <button class="btn btn-icon-text btn-default" id="sidebar-create-topic" type="button" style="${createButtonStyle}">
          <svg class="fa d-icon d-icon-far-pen-to-square svg-icon svg-string" xmlns="http://www.w3.org/2000/svg" width="1em" height="1em"><use href="#far-pen-to-square"></use></svg>
          <span class="d-button-label">新規トピック</span>
        </button>${hasDraftsMenu ? `<button class="btn no-text btn-icon fk-d-menu__trigger sidebar-topic-drafts-menu-trigger btn-default" aria-expanded="false" title="最新の下書きメニューを開く" data-identifier="sidebar-topic-drafts-menu" type="button" style="${draftsButtonStyle}">
          <svg class="fa d-icon d-icon-chevron-down svg-icon svg-string" xmlns="http://www.w3.org/2000/svg" width="1em" height="1em"><use href="#chevron-down"></use></svg>
          <span aria-hidden="true"></span>
        </button>` : ''}
      </div>
    `;
    
    sidebar.insertAdjacentHTML('afterbegin', controlsHTML);
    
    // 新規トピックボタンのイベントリスナー
    const sidebarCreateButton = document.getElementById('sidebar-create-topic');
    if (sidebarCreateButton) {
      sidebarCreateButton.addEventListener('click', () => {
        const mainCreateButton = document.getElementById('create-topic');
        if (mainCreateButton) {
          mainCreateButton.click();
        }
      });
    }
    
    // 修正: ドラフトボタンのカスタムトグル処理
    const sidebarDraftsButton = sidebar.querySelector('.sidebar-topic-drafts-menu-trigger');
    if (sidebarDraftsButton && hasDraftsMenu) {
      sidebarDraftsButton.addEventListener('click', (e) => {
        e.preventDefault();
        e.stopPropagation();
        
        const mainDraftsButton = document.querySelector('.navigation-controls [data-identifier="topic-drafts-menu"]');
        if (!mainDraftsButton) return;
        
        const isExpanded = sidebarDraftsButton.getAttribute('aria-expanded') === 'true';
        
        if (isExpanded) {
          // 既に開いている場合は閉じる
          mainDraftsButton.click();
          sidebarDraftsButton.setAttribute('aria-expanded', 'false');
        } else {
          // 閉じている場合は開く
          mainDraftsButton.click();
          sidebarDraftsButton.setAttribute('aria-expanded', 'true');
          
          // メニューの位置をサイドバーのボタンに合わせる
          setTimeout(() => {
            const menu = document.querySelector('.fk-d-menu[data-identifier="topic-drafts-menu"]');
            if (menu) {
              const buttonRect = sidebarDraftsButton.getBoundingClientRect();
              menu.style.position = 'fixed';
              menu.style.top = `${buttonRect.bottom + 5}px`;
              menu.style.left = `${buttonRect.left}px`;
              menu.style.right = 'auto';
            }
          }, 10);
        }
      });
      
      // メニューが閉じられた時にaria-expandedを更新
      const checkMenuClosed = setInterval(() => {
        const menu = document.querySelector('.fk-d-menu[data-identifier="topic-drafts-menu"]');
        if (!menu && sidebarDraftsButton.getAttribute('aria-expanded') === 'true') {
          sidebarDraftsButton.setAttribute('aria-expanded', 'false');
        }
      }, 500);
      
      // クリーンアップ
      setTimeout(() => clearInterval(checkMenuClosed), 30000);
    }
    
    // Observer を再開
    setTimeout(() => {
      if (observer) {
        const targetNode = document.body;
        observer.observe(targetNode, {
          childList: true,
          subtree: true
        });
      }
      isUpdating = false; // 更新完了
    }, 100);
  }
  
  function handleUpdate() {
    if (isUpdating) return; // 既に更新中なら何もしない
    
    if (settings.sidebar_create_topic) {
      updateSidebarControls();
    }
    
    applyCreateTopicStyle();
  }
  
  api.onPageChange(() => {
    setTimeout(handleUpdate, 100);
  });
  
  setTimeout(handleUpdate, 500);
  
  // MutationObserver の設定
  observer = new MutationObserver(() => {
    if (!isUpdating) {
      // navigation-controls または create-topic が変更された時のみ
      const hasCreateButton = document.getElementById('create-topic');
      const hasSidebar = document.querySelector('#d-sidebar.sidebar-container');
      
      if (hasCreateButton || hasSidebar) {
        setTimeout(handleUpdate, 50);
      }
    }
  });
  
  setTimeout(() => {
    const targetNode = document.body;
    if (targetNode) {
      observer.observe(targetNode, {
        childList: true,
        subtree: true
      });
    }
  }, 200);
});
