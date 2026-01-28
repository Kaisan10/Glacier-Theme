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
    
    const buttonStyle = hasDraftsMenu 
      ? 'border-radius: 100px 0 0 100px; padding: 0.5em 0 0.5em 0.5em;'
      : 'border-radius: 100px; padding: 0.5em 0.65em;';
    
    const controlsHTML = `
      <div class="sidebar-navigation-controls" style="padding: 1em;">
        <button class="btn btn-icon-text btn-default" id="sidebar-create-topic" type="button" style="${buttonStyle}">
          <svg class="fa d-icon d-icon-far-pen-to-square svg-icon svg-string" xmlns="http://www.w3.org/2000/svg" width="1em" height="1em"><use href="#far-pen-to-square"></use></svg>
          <span class="d-button-label">新規トピック</span>
        </button>
        ${hasDraftsMenu ? `
        <button class="btn no-text btn-icon fk-d-menu__trigger sidebar-topic-drafts-menu-trigger btn-small btn-default" aria-expanded="false" title="最新の下書きメニューを開く" data-identifier="sidebar-topic-drafts-menu" type="button" style="border-radius: 0 100px 100px 0;">
          <svg class="fa d-icon d-icon-chevron-down svg-icon svg-string" xmlns="http://www.w3.org/2000/svg" width="1em" height="1em"><use href="#chevron-down"></use></svg>
          <span aria-hidden="true">&ZeroWidthSpace;</span>
        </button>` : ''}
        <hr style="margin-top: 1em;">
      </div>
    `;
    
    sidebar.insertAdjacentHTML('afterbegin', controlsHTML);
    
    const sidebarCreateButton = document.getElementById('sidebar-create-topic');
    if (sidebarCreateButton) {
      sidebarCreateButton.addEventListener('click', () => {
        const mainCreateButton = document.getElementById('create-topic');
        if (mainCreateButton) {
          mainCreateButton.click();
        }
      });
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
