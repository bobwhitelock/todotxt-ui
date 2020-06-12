export function addClassEventHandler(
  className,
  eventName,
  handlerFunction,
  options = {}
) {
  const { passThrough, runOnAttach } = options;

  forEachWithClass(className, element => {
    const runHandler = () => handlerFunction(element, passThrough);
    if (runOnAttach) {
      runHandler();
    }

    element.addEventListener(eventName, event => {
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
