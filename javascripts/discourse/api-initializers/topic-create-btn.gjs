import { apiInitializer } from "discourse/lib/api";

export default apiInitializer("1.8.0", (api) => {
  console.log('Initializer loaded');
  console.log('sidebar_create_topic setting:', settings.sidebar_create_topic);
  
  function applyCreateTopicStyle() {
    console.log('applyCreateTopicStyle called');
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
      console.log('Main create topic button styled');
    }
  }
  
  function updateSidebarControls() {
    console.log('updateSidebarControls called');
    const sidebar = document.querySelector('#d-sidebar.sidebar-container');
    console.log('Sidebar element:', sidebar);
    
    if (!sidebar) {
      console.log('Sidebar not found, exiting');
      return;
    }
    
    const existingControls = sidebar.querySelector('.sidebar-navigation-controls');
    if (existingControls) {
      console.log('Removing existing controls');
      existingControls.remove();
    }
    
    const hasDraftsMenu = document.querySelector('.navigation-controls [data-identifier="topic-drafts-menu"]');
    console.log('Has drafts menu:', !!hasDraftsMenu);
    
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
    console.log('Sidebar controls inserted successfully');
    
    const sidebarCreateButton = document.getElementById('sidebar-create-topic');
    if (sidebarCreateButton) {
      sidebarCreateButton.addEventListener('click', () => {
        const mainCreateButton = document.getElementById('create-topic');
        if (mainCreateButton) {
          mainCreateButton.click();
        }
      });
    }
  }
  
  function handleUpdate() {
    console.log('handleUpdate called');
    console.log('sidebar_create_topic value:', settings.sidebar_create_topic);
    
    if (settings.sidebar_create_topic) {
      console.log('Setting is ON, calling updateSidebarControls');
      updateSidebarControls();
    }
    
    applyCreateTopicStyle();
  }
  
  api.onPageChange(() => {
    console.log('onPageChange triggered');
    setTimeout(handleUpdate, 100);
  });
  
  setTimeout(handleUpdate, 500);
  
  const observer = new MutationObserver((mutations) => {
    const relevantChange = mutations.some(mutation => 
      mutation.target.classList && 
      (mutation.target.classList.contains('navigation-controls') ||
       mutation.target.id === 'd-sidebar')
    );
    
    if (relevantChange) {
      handleUpdate();
    }
  });
  
  setTimeout(() => {
    const targetNode = document.body;
    if (targetNode) {
      observer.observe(targetNode, {
        childList: true,
        subtree: true,
        attributes: true,
        attributeFilter: ['class']
      });
      console.log('MutationObserver started');
    }
  }, 200);
});
