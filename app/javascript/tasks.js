import Tribute from "tributejs";

window.addEventListener("turbolinks:load", function() {
  const initialData = document.getElementById("js-initial-data");
  const projects = JSON.parse(initialData.getAttribute("data-projects"));
  const contexts = JSON.parse(initialData.getAttribute("data-contexts"));

  addClassEventHandler("js-scroll-to-top", "click", scrollToTop);
  addClassEventHandler("js-scroll-to-bottom", "click", scrollToBottom);
  addClassEventHandler(
    "js-disable-submit-when-unchanged",
    "input",
    disableSubmitWhenUnchanged,
    {
      passThrough: {
        submitButtonClass: "js-submit-button",
        originalContentAttr: "data-original-content"
      },
      runOnAttach: true
    }
  );

  addTagsAutocompletion("js-autocomplete-tags", projects, contexts);
});

function addClassEventHandler(
  className,
  eventName,
  handlerFunction,
  options = {}
) {
  const { passThrough, runOnAttach } = options;

  Array.from(document.getElementsByClassName(className)).forEach(element => {
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

function scrollToTop() {
  window.scrollTo(0, 0);
}

function scrollToBottom() {
  window.scrollTo(0, document.body.scrollHeight);
}

function disableSubmitWhenUnchanged(
  element,
  { submitButtonClass, originalContentAttr }
) {
  const submitButtons = Array.from(
    document.getElementsByClassName(submitButtonClass)
  );
  const originalContent = element.getAttribute(originalContentAttr);
  submitButtons.forEach(button => {
    if (element.value.trim() === originalContent.trim()) {
      button.setAttribute("disabled", "");
    } else {
      button.removeAttribute("disabled");
    }
  });
}

function addTagsAutocompletion(className, projects, contexts) {
  // XXX Could also allow autocompleting tags only present for archived tasks,
  // and distinguish these from current ones (by colour?)
  const tribute = new Tribute({
    collection: [
      { values: toTributeValues(projects), trigger: "+" },
      { values: toTributeValues(contexts), trigger: "@" }
    ],
    noMatchTemplate: () => '<span class:"hidden"></span>'

    // XXX Enable once https://github.com/zurb/tribute/issues/495 is resolved.
    // spaceSelectsMatch: true
  });

  tribute.attach(document.getElementsByClassName(className));
}

function toTributeValues(array) {
  return array.map(i => ({ key: i, value: i }));
}
