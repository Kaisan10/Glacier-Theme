import { apiInitializer } from "discourse/lib/api";

export default apiInitializer((api) => {
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
    const sidebar = document.querySelector('#d-sidebar.sidebar-container');
    if (!sidebar) return;

    const existingControls = sidebar.querySelector('.sidebar-navigation-controls');
    if (existingControls) {
      existingControls.remove();
    }

    const hasDraftsMenu = document.querySelector('.navigation-controls [data-identifier="topic-drafts-menu"]');
    const buttonStyle = hasDraftsMenu 
      ? 'border-radius: 100px 0 0 100px; padding: 0.5em 0 0.5em 0.5em;'
      : 'border-radius: 100px; padding: 0.5em 0.65em;';

    const controlsHTML = `
      <div class="sidebar-navigation-controls">
        <button class="btn btn-icon-text btn-default" id="sidebar-create-topic" type="button" style="${buttonStyle}">
          <svg class="fa d-icon d-icon-far-pen-to-square svg-icon fa-width-auto svg-string" width="1em" height="1em" aria-hidden="true" xmlns="http://www.w3.org/2000/svg"><use href="#far-pen-to-square"></use></svg>
          <span class="d-button-label">新規トピック</span>
        </button>
        ${hasDraftsMenu ? `
        <button class="btn no-text btn-icon fk-d-menu__trigger sidebar-topic-drafts-menu-trigger btn-small btn-default" aria-expanded="false" title="最新の下書きメニューを開く" data-identifier="sidebar-topic-drafts-menu" type="button">
          <svg class="fa d-icon d-icon-chevron-down svg-icon fa-width-auto svg-string" width="1em" height="1em" aria-hidden="true" xmlns="http://www.w3.org/2000/svg"><use href="#chevron-down"></use></svg>
          <span aria-hidden="true">&ZeroWidthSpace;</span>
        </button>` : ''}
        <hr>
      </div>
    `;

    sidebar.insertAdjacentHTML('afterbegin', controlsHTML);
  }

  function handleUpdate() {
    if (settings["sidebar_create-topic"]) {
      updateSidebarControls();
    } else {
      applyCreateTopicStyle();
    }
  }

  api.onPageChange(() => {
    setTimeout(handleUpdate, 100);
  });

  const observer = new MutationObserver(handleUpdate);
  
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
