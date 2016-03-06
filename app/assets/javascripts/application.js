//= require turbolinks
//= require ./vendors/loadjs
//= require ./vendors/loadcss
//= require ./vendors/salvattore
//= require_tree ./application

'use strict';

Turbolinks.enableProgressBar();

// I'm loading scripts async, so if the page has finished loading then
// I need to init these scripts directly, because the `page:change`
// event has already fired.
if (document.readyState !== 'loading') {
  Denali.SocialShare.init();
  Denali.Shortcuts.init();
  Denali.ImageZoom.init();
  Denali.Grid.init();
  Denali.Map.init();
  Denali.Analytics.sendPageview();
}

document.addEventListener('page:change', Denali.SocialShare.init);
document.addEventListener('page:change', Denali.Shortcuts.init);
document.addEventListener('page:change', Denali.ImageZoom.init);
document.addEventListener('page:change', Denali.Grid.init);
document.addEventListener('page:change', Denali.Map.init);
document.addEventListener('page:change', Denali.Analytics.sendPageview);
document.addEventListener('orientationchange', Denali.ImageZoom.init);
document.addEventListener('keydown', Denali.Shortcuts.handleKeyPress);
