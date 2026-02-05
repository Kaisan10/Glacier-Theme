import { apiInitializer } from "discourse/lib/api";
import { i18n } from "discourse-i18n";

export default apiInitializer("1.8.0", (api) => {
  let isUpdating = false;
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
  
  // イベント委譲を使用
  function setupSidebarButtonHandlers() {
    // 新規トピックボタン用の委譲ハンドラ
    document.body.addEventListener('click', (e) => {
      const sidebarCreateButton = e.target.closest('#sidebar-create-topic');
      if (sidebarCreateButton) {
        e.preventDefault();
        const mainCreateButton = document.getElementById('create-topic');
        if (mainCreateButton) {
          mainCreateButton.click();
        }
      }
    });
    
    // ドラフトボタン用の委譲ハンドラ
    document.body.addEventListener('click', (e) => {
      const sidebarDraftsButton = e.target.closest('.sidebar-topic-drafts-menu-trigger');
      if (sidebarDraftsButton) {
        e.preventDefault();
        e.stopPropagation();
        
        const mainDraftsButton = document.querySelector('.navigation-controls [data-identifier="topic-drafts-menu"]');
        if (!mainDraftsButton) return;
        
        const isExpanded = sidebarDraftsButton.getAttribute('aria-expanded') === 'true';
        
        if (isExpanded) {
          mainDraftsButton.click();
          sidebarDraftsButton.setAttribute('aria-expanded', 'false');
        } else {
          mainDraftsButton.click();
          sidebarDraftsButton.setAttribute('aria-expanded', 'true');
          
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
      }
    });
  }
  
  function updateSidebarControls() {
    if (isUpdating) return;
    
    const sidebar = document.querySelector('#d-sidebar.sidebar-container');
    if (!sidebar) return;
    
    isUpdating = true;
    
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
    
    const createTopicLabel = i18n("topic.create");
    
    const controlsHTML = `
      <div class="sidebar-navigation-controls" style="position: relative;">
        <button class="btn btn-icon-text btn-default" id="sidebar-create-topic" type="button" style="${createButtonStyle}">
          <svg class="fa d-icon d-icon-far-pen-to-square svg-icon svg-string" xmlns="http://www.w3.org/2000/svg" width="1em" height="1em"><use href="#far-pen-to-square"></use></svg>
          <span class="d-button-label">
            ${createTopicLabel}
          </span>
        </button>${hasDraftsMenu ? `<button class="btn no-text btn-icon fk-d-menu__trigger sidebar-topic-drafts-menu-trigger btn-default" aria-expanded="false" title="Open the Recent Drafts menu" data-identifier="sidebar-topic-drafts-menu" type="button" style="${draftsButtonStyle}">
          <svg class="fa d-icon d-icon-chevron-down svg-icon svg-string" xmlns="http://www.w3.org/2000/svg" width="1em" height="1em"><use href="#chevron-down"></use></svg>
          <span aria-hidden="true"></span>
        </button>` : ''}
      </div>
    `;
    
    sidebar.insertAdjacentHTML('afterbegin', controlsHTML);
    
    // ドラフトメニューの状態監視
    const sidebarDraftsButton = sidebar.querySelector('.sidebar-topic-drafts-menu-trigger');
    if (sidebarDraftsButton && hasDraftsMenu) {
      const checkMenuClosed = setInterval(() => {
        const menu = document.querySelector('.fk-d-menu[data-identifier="topic-drafts-menu"]');
        if (!menu && sidebarDraftsButton.getAttribute('aria-expanded') === 'true') {
          sidebarDraftsButton.setAttribute('aria-expanded', 'false');
        }
      }, 500);
      
      setTimeout(() => clearInterval(checkMenuClosed), 30000);
    }
    
    setTimeout(() => {
      if (observer) {
        const targetNode = document.body;
        observer.observe(targetNode, {
          childList: true,
          subtree: true
        });
      }
      isUpdating = false;
    }, 100);
  }
  
  function handleUpdate() {
    if (isUpdating) return;
    
    if (settings.sidebar_create_topic) {
      updateSidebarControls();
    }
    
    applyCreateTopicStyle();
  }
  
  // 初期化時に一度だけイベントハンドラを設定
  setupSidebarButtonHandlers();
  
  api.onPageChange(() => {
    setTimeout(handleUpdate, 100);
  });
  
  setTimeout(handleUpdate, 500);
  
  observer = new MutationObserver(() => {
    if (!isUpdating) {
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
