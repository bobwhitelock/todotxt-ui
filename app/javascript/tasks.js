window.addEventListener("turbolinks:load", function() {
  addClassEventHandler("js-scroll-to-top", "click", scrollToTop);
  addClassEventHandler("js-scroll-to-bottom", "click", scrollToBottom);
});

function addClassEventHandler(className, eventName, handlerFunction) {
  Array.from(document.getElementsByClassName(className)).forEach(element => {
    element.addEventListener(eventName, event => {
      event.preventDefault();
      handlerFunction();
    });
  });
}

function scrollToTop() {
  window.scrollTo(0, 0);
}

function scrollToBottom() {
  window.scrollTo(0, document.body.scrollHeight);
}
