import Tribute from "tributejs";

import {
  addClassEventHandler,
  forEachWithClass,
  scrollToBottom,
  scrollToTop
} from "framework";

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

function disableSubmitWhenUnchanged(
  element,
  { submitButtonClass, originalContentAttr }
) {
  const originalContent = element.getAttribute(originalContentAttr);

  forEachWithClass(submitButtonClass, button => {
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
