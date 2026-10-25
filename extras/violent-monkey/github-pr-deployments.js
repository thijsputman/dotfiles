// ==UserScript==
// @name         GitHub – Hide "deployments"-clutter in PRs
// @match        https://github.com/*/*/pull/*
// @grant        none
// @run-at       document-idle
// ==/UserScript==

(function () {
  "use strict";

  const timelineRowSelector = [
    ".js-timeline-item",
    ".TimelineItem",
    ".discussion-item",
    ".timeline-comment-group",
  ].join(", ");

  const statusSelector = [
    '[title="Deployment Status Label: Active"]',
    '[title="Deployment Status Label: Inactive"]',
    '[title="Deployment Status Label: Error"]',
    '[title="Deployment Status Label: Failure"]',
    '[title="Deployment Status Label: In progress"]',
  ].join(", ");

  function filterDeployments() {
    const rows = [
      ...new Set(
        Array.from(
          document.querySelectorAll(
            `.js-socket-channel[data-gid^="PR"] ${statusSelector}`,
          ),
          (status) => status.closest(timelineRowSelector),
        ).filter((row) => row?.querySelector(".octicon-rocket")),
      ),
    ];

    // Leave last row intact (as an FYI/canary)
    rows.pop();

    for (const row of rows) {
      row.remove();
    }
  }

  filterDeployments();

  const observer = new MutationObserver(filterDeployments);
  observer.observe(document.body, {
    childList: true,
    subtree: true,
  });
})();
