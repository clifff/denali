/**
 * Checks if `requestIdleCallback` is supported before making a call to track
 * the current page in analytics.
 * https://developer.mozilla.org/en-US/docs/Web/API/Window/requestIdleCallback
 */
export function trackPageView () {
  if ('requestIdleCallback' in window) {
    requestIdleCallback(trackPage);
  } else {
    trackPage();
  }
}


/**
 * Product-agnostic function to make a page view tracking call.
 * Currently supports GA, either directly or as part of GTM.
 */
function trackPage () {
  if (typeof ga !== 'undefined') {
    ga('set', 'page', window.location.pathname);
    ga('send', 'pageview');
  }
  if (typeof gtag !== 'undefined' && typeof gaTrackingId !== 'undefined') {
    gtag('config', gaTrackingId, { 'page_path': window.location.pathname });
  }
}