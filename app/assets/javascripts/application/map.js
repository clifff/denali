var Denali = Denali || {};

Denali.Map = (function () {
  'use strict';

  var opts = {
    map_container_id  : 'map',
    default_latitude  : 38.8899389,
    default_longitude : -77.0112392
  };

  var map,
      loading,
      show_bar = true;

  var init = function () {
    if (document.getElementById(opts.map_container_id) === null) {
      return;
    }
    loading = document.querySelector('.js-loading');
    if (typeof map === 'undefined') {
      loadMapbox();
    } else {
      map.remove();
      initMap(opts.default_latitude, opts.default_longitude);
    }
  };

  var loadMapbox = function () {
    loadJS('https://api.tiles.mapbox.com/mapbox.js/v2.4.0/mapbox.js', function () {
      loadJS('https://api.mapbox.com/mapbox.js/plugins/leaflet-markercluster/v0.4.0/leaflet.markercluster.js', function () {
        initMap(opts.default_latitude, opts.default_longitude);
      });
    });
  };

  var showLoadingSpinner = function () {
    if (show_bar) {
      loading.style.display = 'block';
    }
  };

  var hideLoadingSpinner = function () {
    loading.style.display = 'none';
  };

  var getZoom = function () {
    var height = window.innerHeight,
        width = window.innerWidth;

    if ((width >= 2560) || (height >= 1440)) {
      return 4;
    } else if ((width >= 1920 ) || (height >= 1200)) {
      return 3;
    } else {
      return 2;
    }
  };

  var initMap = function (latitude, longitude) {
    setTimeout(showLoadingSpinner, 500);
    var south_west = L.latLng(-90, -180),
        north_east = L.latLng(90, 180),
        bounds = L.latLngBounds(south_west, north_east),
        zoom = getZoom();
    L.mapbox.accessToken = 'pk.eyJ1IjoiZ2VzdGV2ZXMiLCJhIjoiY2lrY3EyeDA3MG03Y3Y5a3V6d3MwNHR3cSJ9.qG9UBVJvti71fNvW5iKONA';
    map = L.mapbox.map(opts.map_container_id, 'gesteves.ce0e3aae', { minZoom: zoom, maxZoom: 18, maxBounds: bounds }).setView([latitude, longitude], zoom);

    var layer = L.mapbox.featureLayer();

    layer.on('layeradd', function(e) {
      var marker = e.layer,
          feature = marker.feature;
      var content = feature.properties.description;
      marker.setIcon(L.divIcon({
          className: 'map__marker map__marker--point',
          html: '&bull;',
          iconSize: [10, 10],
          iconAnchor: [5, 5]
        }));
      marker.bindPopup(content, {
        closeButton: true,
        minWidth: 319
      });
    });
    layer.on('ready', function() {
      map.fitBounds(layer.getBounds().pad(0.01));
    });
    layer.loadURL('/map/photos.json').on('ready', function (e) {
      var cluster_group = new L.MarkerClusterGroup({
        showCoverageOnHover: false,
        maxClusterRadius: 30,
        spiderfyDistanceMultiplier: 3,
        iconCreateFunction: function (cluster) {
          return L.divIcon({
              className: 'map__marker map__marker--cluster',
              html: cluster.getChildCount(),
              iconSize: cluster.getChildCount() > 99 ? [30, 30] : [20, 20],
              iconAnchor: cluster.getChildCount() > 99 ? [15, 15] : [10, 10]
            }
          );
        }
      });
      e.target.eachLayer(function (layer) {
        cluster_group.addLayer(layer);
      });
      map.addLayer(cluster_group);
      show_bar = false;
      hideLoadingSpinner();
    });
  };

  return {
    init : init
  };
})();
