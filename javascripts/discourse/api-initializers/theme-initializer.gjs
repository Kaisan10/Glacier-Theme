import { apiInitializer } from "discourse/lib/api";

export default apiInitializer((api) => {
  function applyCreateTopicStyle() {
    const hasDraftsMenu = document.querySelector('.navigation-controls [data-identifier="topic-drafts-menu"]');
    const createTopic = document.getElementById('create-topic');

    if (createTopic) {
      if (hasDraftsMenu) {
        createTopic.style.borderRadius = '100px 0 0 100px';
        createTopic.style.padding = '.5em 0px .5em .5em';
      } else {
        createTopic.style.borderRadius = '100px';
        createTopic.style.padding = '.5em .65em';
      }
    }
  }

  // 初回実行
  api.onPageChange(() => {
    setTimeout(applyCreateTopicStyle, 100);
  });

  // MutationObserverで監視
  const observer = new MutationObserver(applyCreateTopicStyle);
  
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
