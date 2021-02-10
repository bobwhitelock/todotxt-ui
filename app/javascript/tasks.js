import Tribute from "tributejs";

import {
  turbolinksPersistScroll,
  addClassEventHandler,
  forEachWithClass,
  scrollToBottom,
  scrollToTop,
  enableNavigationWarning,
  disableNavigationWarning,
} from "framework";

const tasksFormSubmitClass = "js-tasks-form-submit";
const tasksFormTextareaClass = "js-tasks-form-textarea";

turbolinksPersistScroll("js-turbolinks-persist-scroll");

window.addEventListener("turbolinks:load", function () {
  // Ensure no navigation warning initially given on page load.
  disableNavigationWarning();

  const initialData = document.getElementById("js-initial-data");
  const projects = JSON.parse(initialData.getAttribute("data-projects"));
  const contexts = JSON.parse(initialData.getAttribute("data-contexts"));

  addClassEventHandler("js-scroll-to-top", "click", scrollToTop);
  addClassEventHandler("js-scroll-to-bottom", "click", scrollToBottom);

  addClassEventHandler(tasksFormTextareaClass, "input", handleTasksFormInput, {
    runOnAttach: true,
  });
  addTagsAutocompletion(tasksFormTextareaClass, projects, contexts);
});

function handleTasksFormInput(element) {
  const originalContentAttr = "data-original-content";
  const originalContent = element.getAttribute(originalContentAttr);

  forEachWithClass(tasksFormSubmitClass, (button) => {
    if (element.value.trim() === originalContent.trim()) {
      // When content unchanged, prevent submission and allow navigation away
      // without warning.
      button.setAttribute("disabled", "");
      disableNavigationWarning();
    } else {
      // When content changed, allow submission and warn on navigation.
      button.removeAttribute("disabled");
      enableNavigationWarning();
    }
  });
}

function addTagsAutocompletion(className, projects, contexts) {
  const tribute = new Tribute({
    collection: [
      { values: toTributeValues(projects), trigger: "+" },
      { values: toTributeValues(contexts), trigger: "@" },
    ],
    noMatchTemplate: () => '<span class:"hidden"></span>',
    spaceSelectsMatch: true,
  });

  tribute.attach(document.getElementsByClassName(className));
}

function toTributeValues(array) {
  return array.map((i) => ({ key: i, value: i }));
}
