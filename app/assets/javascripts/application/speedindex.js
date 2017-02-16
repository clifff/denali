//= require ../vendors/speedindex

var Denali = Denali || {};

Denali.SpeedIndex = (function () {
  'use strict';

  var init = function () {
    if (typeof RUMSpeedIndex() !== 'undefined') {
      console.log('[INFO] Speed Index', Math.round(RUMSpeedIndex()));
      ga('send', {
        hitType: 'timing',
        timingCategory: 'RUM',
        timingVar: 'speedindex',
        timingValue: RUMSpeedIndex()
      });
    }
  };

  return {
    init : init
  };
})();

if (document.readyState === 'complete') {
  Denali.SpeedIndex.init();
} else {
  window.addEventListener('load', Denali.SpeedIndex.init, true);
}
