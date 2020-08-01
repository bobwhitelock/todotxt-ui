import Tribute from "tributejs";

import {
  turbolinksPersistScroll,
  addClassEventHandler,
  forEachWithClass,
  scrollToBottom,
  scrollToTop
} from "framework";

turbolinksPersistScroll("js-turbolinks-persist-scroll");

window.addEventListener("turbolinks:load", function() {
  const initialData = document.getElementById("js-initial-data");
  const projects = JSON.parse(initialData.getAttribute("data-projects"));
  const contexts = JSON.parse(initialData.getAttribute("data-contexts"));

  const tasksFormTextarea = "js-tasks-form-textarea";
  const tasksFormSubmit = "js-tasks-form-submit";

  addClassEventHandler("js-scroll-to-top", "click", scrollToTop);
  addClassEventHandler("js-scroll-to-bottom", "click", scrollToBottom);
  addClassEventHandler(tasksFormTextarea, "input", disableSubmitWhenUnchanged, {
    passThrough: {
      submitButtonClass: tasksFormSubmit,
      originalContentAttr: "data-original-content"
    },
    runOnAttach: true
  });

  addTagsAutocompletion(tasksFormTextarea, projects, contexts);
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
  const tribute = new Tribute({
    collection: [
      { values: toTributeValues(projects), trigger: "+" },
      { values: toTributeValues(contexts), trigger: "@" }
    ],
    noMatchTemplate: () => '<span class:"hidden"></span>',
    spaceSelectsMatch: true
  });

  tribute.attach(document.getElementsByClassName(className));
}

function toTributeValues(array) {
  return array.map(i => ({ key: i, value: i }));
}
