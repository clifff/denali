//= require ../vendors/speedindex

var Denali = Denali || {};

Denali.SpeedIndex = (function () {
  'use strict';

  var init = function () {
    console.log('GA present', typeof ga !== 'undefined');
    console.log('Speed index present', typeof RUMSpeedIndex() !== 'undefined');
    if (typeof RUMSpeedIndex() !== 'undefined') {
      console.log('Speed index', RUMSpeedIndex());
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
  window.addEventListener('load', Denali.SpeedIndex.init);
}