const {registerSettings: e, getObjectForTheme: t} = await window.moduleBroker.lookup("discourse/lib/theme-settings-store")
  , {apiInitializer: n} = await window.moduleBroker.lookup("discourse/lib/api")
e(32, {
    "left-and-right-margins": 100,
    "sidebar_create-topic": !1
})
const i = t(32)
var o = n(e => {
    function t() {
        i.sidebar_create_topic ? function() {
            const e = document.querySelector("#d-sidebar.sidebar-container")
            if (!e)
                return
            const t = e.querySelector(".sidebar-navigation-controls")
            t && t.remove()
            const n = document.querySelector('.navigation-controls [data-identifier="topic-drafts-menu"]')
              , i = `\n      <div class="sidebar-navigation-controls">\n        <button class="btn btn-icon-text btn-default" id="sidebar-create-topic" type="button" style="${n ? "border-radius: 100px 0 0 100px; padding: 0.5em 0 0.5em 0.5em;" : "border-radius: 100px; padding: 0.5em 0.65em;"}">\n          <svg class="fa d-icon d-icon-far-pen-to-square svg-icon fa-width-auto svg-string" width="1em" height="1em" aria-hidden="true" xmlns="http://www.w3.org/2000/svg"><use href="#far-pen-to-square"></use></svg>\n          <span class="d-button-label">新規トピック</span>\n        </button>\n        ${n ? '\n        <button class="btn no-text btn-icon fk-d-menu__trigger sidebar-topic-drafts-menu-trigger btn-small btn-default" aria-expanded="false" title="最新の下書きメニューを開く" data-identifier="sidebar-topic-drafts-menu" type="button">\n          <svg class="fa d-icon d-icon-chevron-down svg-icon fa-width-auto svg-string" width="1em" height="1em" aria-hidden="true" xmlns="http://www.w3.org/2000/svg"><use href="#chevron-down"></use></svg>\n          <span aria-hidden="true">&ZeroWidthSpace;</span>\n        </button>' : ""}\n        <hr>\n      </div>\n    `
            e.insertAdjacentHTML("afterbegin", i)
        }() : function() {
            const e = document.querySelector('.navigation-controls [data-identifier="topic-drafts-menu"]')
              , t = document.getElementById("create-topic")
            t && (e ? (t.style.borderRadius = "100px 0 0 100px",
            t.style.padding = ".5em 0 .5em .5em") : (t.style.borderRadius = "100px",
            t.style.padding = ".5em .65em"))
        }()
    }
    e.onPageChange( () => {
        setTimeout(t, 100)
    }
    )
    const n = new MutationObserver(t)
    setTimeout( () => {
        const e = document.body
        e && n.observe(e, {
            childList: !0,
            subtree: !0
        })
    }
    , 200)
}
)
  , r = Object.freeze({
    __proto__: null,
    default: o
})
const a = {}
a["discourse/api-initializers/theme-initializer"] = r
export {a as default}

//# sourceMappingURL=9ad981078230d4a444c95fe57fccabdbe47dddb4.map?__ws=forum.bac0n.f5.si
