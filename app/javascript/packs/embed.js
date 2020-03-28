const WRAPPER_ID = "__circulate_inventory__";
const page = document.getElementById(WRAPPER_ID);

const HOST = process.env.EMBED_SERVER_HOST;
const URL = HOST + "/embed/items";

let stack = 0;

function includeStylesheet(doc) {
  let linkTag = doc.createElement("link");
  linkTag.rel = "stylesheet";
  linkTag.type = "text/css";
  linkTag.href = "<%= Webpacker.manifest.lookup('embed_styles.css') %>";
  let head = doc.getElementsByTagName('head')[0];

  head.appendChild(linkTag);
}

// Called when page first loads to handle params in hash
function boot() {
  let params = new URLSearchParams(window.location.hash.replace("#", ""));

  let data = Object.fromEntries(params);
  if (Object.keys(data).length > 0) { 
    window.history.replaceState(data, "");
  }
  sync();
}

// Update page based on params in current history state
function sync() {
  let data = window.history.state;
  let url;  

  if (data) {
    if (data.item_id) {
      url = URL + "/" + data.item_id;
    } else {
      let params = new URLSearchParams(data);
      url = URL + "?" + params.toString();
    }
  } else {
    url = URL + "?" + window.location.hash.replace("#", "")
  }

  fetch(url).then(response => response.text()).then(data => {
    page.innerHTML = data;
  });
}

function pushState(data, title, url) {
  stack++;
  window.history.pushState(data, title, url);
  sync();
}

// doesn't seem to happen on squarespace
page.addEventListener("submit", function(event) {
  // console.debug(event);
  event.preventDefault();
  event.stopPropagation();
  if (event.target.nodeName === "FORM") {
    let form = event.target;
    let formData = new FormData(form);
    let data = Object.fromEntries(formData);
    let params = new URLSearchParams(data);
    pushState(data, "", "#" + params.toString());
  }
});

page.addEventListener("click", function(event) {
  if (event.target.nodeName === "A") {
    event.preventDefault();
    event.stopPropagation();
    let a = event.target;

    // Handle back button on item page
    if (a.classList.contains("history-back") && stack > 0) {
      window.history.back();
      return;
    }

    let params = new URLSearchParams(a.hash.replace("#", ""));
    let data = Object.fromEntries(params);
    if (Object.keys(data).length === 0) {
      pushState(data, "", document.location.pathname);
    } else {
      pushState(data, "", "#" + params.toString());
    }
    sync();
  }
});

window.addEventListener("popstate", function(event) {
  stack--;
  sync();
});

// includeStylesheet(document);
boot();