const WRAPPER_ID = "__circulate_inventory__";
const page = document.getElementById(WRAPPER_ID);

const HOST = process.env.EMBED_SERVER_HOST;
const URL = HOST + "/embed/items";

function includeStylesheet(doc) {
  let linkTag = doc.createElement("link");
  linkTag.rel = "stylesheet";
  linkTag.type = "text/css";
  linkTag.href = "<%= Webpacker.manifest.lookup('embed_styles.css') %>";
  let head = doc.getElementsByTagName('head')[0];

  head.appendChild(linkTag);
}

function sync() {
  let data = window.history.state;
  let url;  

  if (data) {
    let params = new URLSearchParams(data);
    url = URL + "?" + params.toString();
  } else {
    url = URL + "?" + window.location.hash.replace("#", "")
  }

  fetch(url).then(response => response.text()).then(data => {
    page.innerHTML = data;
  });
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
    window.history.pushState(data, "", "#" + params.toString());
    sync();
  }
});

page.addEventListener("click", function(event) {
  console.debug(event);
  if (event.target.nodeName === "A") {
    event.preventDefault();
    event.stopPropagation();
    let a = event.target;
    let params = new URLSearchParams(a.hash.replace("#", ""));
    let data = Object.fromEntries(params);
    console.debug(a);
    console.debug(params);
    console.debug(data);
    if (Object.keys(data).length === 0) {
      window.history.pushState(data, "", document.location.pathname);
    } else {
      window.history.pushState(data, "", "#" + params.toString());
    }
    sync();
  }
});

window.addEventListener("popstate", function(event) {
  sync();
});

// includeStylesheet(document);
sync();