// Adapted from https://stackoverflow.com/a/51790464/2620402.
export function turbolinksPersistScroll(persistScrollClass) {
  let scrollPosition = null;
  let enabled = false;

  document.addEventListener("turbolinks:before-visit", () => {
    if (enabled) {
      scrollPosition = window.scrollY;
    } else {
      scrollPosition = null;
    }
    enabled = false;
  });

  document.addEventListener("turbolinks:load", () => {
    addClassEventHandler(persistScrollClass, "click", () => (enabled = true));

    if (scrollPosition) {
      window.scrollTo(0, scrollPosition);
    }
  });
}

export function addClassEventHandler(
  className,
  eventName,
  handlerFunction,
  options = {}
) {
  const { passThrough, runOnAttach } = options;

  forEachWithClass(className, (element) => {
    const runHandler = () => handlerFunction(element, passThrough);
    if (runOnAttach) {
      runHandler();
    }

    element.addEventListener(eventName, (event) => {
      event.preventDefault();
      runHandler();
    });
  });
}

export function forEachWithClass(className, fn) {
  Array.from(document.getElementsByClassName(className)).forEach(fn);
}

export function scrollToTop() {
  window.scrollTo(0, 0);
}

export function scrollToBottom() {
  window.scrollTo(0, document.body.scrollHeight);
}
