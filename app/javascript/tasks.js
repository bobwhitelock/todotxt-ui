window.addEventListener('turbolinks:load', function() {
  Array.from(document.getElementsByClassName('js-scroll-to-top')).forEach(
    element => {
      element.addEventListener('click', event => {
        event.preventDefault();
        scrollToTop();
      });
    },
  );

  Array.from(document.getElementsByClassName('js-scroll-to-bottom')).forEach(
    element => {
      element.addEventListener('click', event => {
        event.preventDefault();
        scrollToBottom();
      });
    },
  );
});

function scrollToTop() {
  window.scrollTo(0, 0);
}

function scrollToBottom() {
  window.scrollTo(0, document.body.scrollHeight);
}
