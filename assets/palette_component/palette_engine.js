/**
 * PaletteEngine - Dynamic 102-Palette Swapping, Cross-Subdomain Cookie / Storage Engine,
 * Catalog Picker Modal, BroadcastChannel Tab Synchronization, and Reveal.js Slide Sync for Sunstone.
 * Zero-dependency UMD/Browser module integrated from sol-vin/sol.vin.
 */
(function(root) {
  'use strict';

  var FA_ICONS = {
    palette: '<svg class="project-icon-svg" xmlns="http://www.w3.org/2000/svg" viewBox="0 0 512 512"><path fill="currentColor" d="M512 256c0 .9 0 1.8 0 2.7-.4 36.5-33.6 61.3-70.1 61.3L344 320c-26.5 0-48 21.5-48 48 0 3.4 .4 6.7 1 9.9 2.1 10.2 6.5 20 10.8 29.9 6.1 13.8 12.1 27.5 12.1 42 0 31.8-21.6 60.7-53.4 62-3.5 .1-7 .2-10.6 .2-141.4 0-256-114.6-256-256S114.6 0 256 0 512 114.6 512 256zM128 288a32 32 0 1 0 -64 0 32 32 0 1 0 64 0zm0-96a32 32 0 1 0 0-64 32 32 0 1 0 0 64zM288 96a32 32 0 1 0 -64 0 32 32 0 1 0 64 0zm96 96a32 32 0 1 0 0-64 32 32 0 1 0 0 64z"/></svg>',
    dice: '<svg class="project-icon-svg" xmlns="http://www.w3.org/2000/svg" viewBox="0 0 512 512"><path fill="currentColor" d="M141.4 2.3C103-8 63.5 14.8 53.3 53.2L2.5 242.7C-7.8 281.1 15 320.6 53.4 330.9l189.5 50.8c38.4 10.3 77.9-12.5 88.2-50.9l50.8-189.5c10.3-38.4-12.5-77.9-50.9-88.2L141.4 2.3zm23 205.7a32 32 0 1 1 55.4-32 32 32 0 1 1 -55.4 32zM79.2 220.3a32 32 0 1 1 32 55.4 32 32 0 1 1 -32-55.4zm185 96.4a32 32 0 1 1 -32-55.4 32 32 0 1 1 32 55.4zm9-208.4a32 32 0 1 1 32 55.4 32 32 0 1 1 -32-55.4zm-121 14.4a32 32 0 1 1 -32-55.4 32 32 0 1 1 32 55.4zM418 192L377.4 343.2c-17.2 64-83 102-147 84.9l-38.3-10.3 0 30.2c0 35.3 28.7 64 64 64l192 0c35.3 0 64-28.7 64-64l0-192c0-35.3-28.7-64-64-64L418 192z"/></svg>',
    xmark: '<svg class="project-icon-svg" xmlns="http://www.w3.org/2000/svg" viewBox="0 0 384 512"><path fill="currentColor" d="M55.1 73.4c-12.5-12.5-32.8-12.5-45.3 0s-12.5 32.8 0 45.3L147.2 256 9.9 393.4c-12.5 12.5-12.5 32.8 0 45.3s32.8 12.5 45.3 0L192.5 301.3 329.9 438.6c12.5 12.5 32.8 12.5 45.3 0s12.5-32.8 0-45.3L237.8 256 375.1 118.6c12.5-12.5 12.5-32.8 0-45.3s-32.8-12.5-45.3 0L192.5 210.7 55.1 73.4z"/></svg>',
    bracketLeft: '<svg class="project-icon-svg" xmlns="http://www.w3.org/2000/svg" viewBox="0 0 192 512"><path fill="currentColor" d="M0 96C0 60.7 28.7 32 64 32l64 0c17.7 0 32 14.3 32 32s-14.3 32-32 32l-64 0 0 320 64 0c17.7 0 32 14.3 32 32s-14.3 32-32 32l-64 0c-35.3 0-64-28.7-64-64L0 96z"/></svg>',
    bracketRight: '<svg class="project-icon-svg" xmlns="http://www.w3.org/2000/svg" viewBox="0 0 192 512"><path fill="currentColor" d="M192 96c0-35.3-28.7-64-64-64L64 32C46.3 32 32 46.3 32 64S46.3 96 64 96l64 0 0 320-64 0c-17.7 0-32 14.3-32 32s14.3 32 32 32l64 0c35.3 0 64-28.7 64-64l0-320z"/></svg>'
  };

  function createEngineInstance(customConfig) {
    var cfg = Object.assign({
      buttonId: 'palette-swap-btn',
      colorPreviewId: 'palette-color-preview',
      nameLabelId: 'palette-name-label',
      modalOverlayId: 'palette-picker-modal-overlay',
      modalGridId: 'palette-picker-grid',
      modalCloseId: 'palette-picker-modal-close',
      modalRandomId: 'palette-picker-random-btn',
      modalTitleId: 'palette-picker-modal-title',
      modalTitleText: 'THEME // Palette Selector // Color Catalog',
      modalRandomLabel: '[ RANDOM // Palette ]',
      modalDescriptionText: 'Select a theme palette from the catalog below to instantly customize slide deck appearance:',
      storageKey: 'solvin_palette_id',
      channelName: 'solvin_palette_channel',
      holdDuration: 2000,
      spinnerDelay: 500,
      autoInjectModal: true,
      syncSlides: true,
      onChange: null
    }, customConfig || {});

    var PaletteEngine = {
      ICONS: FA_ICONS,
      config: cfg,
      palettes: [],
      currentPalette: null,
      currentIndex: 0,
      STORAGE_KEY: cfg.storageKey,
      CHANNEL_NAME: cfg.channelName,
      channel: null,
      _userOverridden: false,

      /**
       * Updates configuration options on this PaletteEngine instance.
       */
      configure: function(options) {
        if (!options) return this;
        Object.assign(this.config, options);
        if (options.storageKey) this.STORAGE_KEY = options.storageKey;
        if (options.channelName) this.CHANNEL_NAME = options.channelName;
        return this;
      },

      /**
       * Creates an isolated PaletteEngine instance with custom configuration.
       */
      createInstance: function(options) {
        return createEngineInstance(options);
      },

      /**
       * Renders the canonical `#palette-swap-btn` HTML markup.
       */
      renderSwapButtonHtml: function(options) {
        var o = Object.assign({}, this.config, options || {});
        var defaultName = (this.currentPalette && (this.currentPalette.name || this.currentPalette.id)) || o.defaultLabel || 'Warm Paper';
        var tooltip = o.tooltip || 'Left-click: Next | Right-click: Prev | Left Hold: Palette Selection Menu | Right Hold: Reset Default';
        return '<button id="' + o.buttonId + '" class="palette-swap-btn" type="button" aria-label="Swap Color Palette" data-tooltip="' + tooltip + '">' +
               '[ PALETTE: <span id="' + o.colorPreviewId + '" class="palette-color-preview">●</span><span id="' + o.nameLabelId + '">' + defaultName + '</span> ]' +
               '</button>';
      },

      /**
       * Renders the canonical `#palette-picker-modal-overlay` catalog grid HTML markup using FontAwesome SVGs.
       */
      renderModalHtml: function(options) {
        var o = Object.assign({}, this.config, options || {});
        return '<div id="' + o.modalOverlayId + '" class="skill-modal-overlay" role="dialog" aria-modal="true" aria-labelledby="' + o.modalTitleId + '">' +
               '  <div class="terminal-window skill-modal-window palette-picker-window">' +
               '    <div class="window-header window-header-flex">' +
               '      <h1 id="' + o.modalTitleId + '" class="window-title palette-modal-title">' +
               '        <span class="window-header-icon" title="Theme Palette Selector">' + FA_ICONS.palette + '</span>' + o.modalTitleText +
               '      </h1>' +
               '      <div class="window-controls">' +
               '        <button type="button" id="' + o.modalCloseId + '" class="window-btn window-btn-close" title="Close Catalog">' +
               '<span class="window-btn-bracket">' + FA_ICONS.bracketLeft + '</span>' +
               '<span class="window-btn-icon-wrap">' + FA_ICONS.xmark + '</span>' +
               '<span class="window-btn-bracket">' + FA_ICONS.bracketRight + '</span>' +
               '</button>' +
               '      </div>' +
               '    </div>' +
               '    <div class="window-body palette-modal-body">' +
               '      <div class="palette-modal-top-bar">' +
               '        <p class="palette-modal-text">' + o.modalDescriptionText + '</p>' +
               '        <button id="' + o.modalRandomId + '" type="button" class="export-btn export-btn-bold-sm" title="Pick Random Palette">' + FA_ICONS.dice + ' ' + o.modalRandomLabel + '</button>' +
               '      </div>' +
               '      <div id="' + o.modalGridId + '"></div>' +
               '    </div>' +
               '  </div>' +
               '</div>';
      },

      /**
       * Mounts the canonical `#palette-swap-btn` into a target container selector or element.
       */
      mountButton: function(targetContainer, options) {
        if (typeof document === 'undefined') return null;
        var container = typeof targetContainer === 'string' ? document.querySelector(targetContainer) : targetContainer;
        if (!container) return null;
        container.innerHTML = this.renderSwapButtonHtml(options);
        var btn = document.getElementById((options && options.buttonId) || this.config.buttonId);
        if (this.currentPalette) {
          this.updateButtonLabel(this.currentPalette);
        }
        return btn;
      },

      /**
       * Ensures `#palette-picker-modal-overlay` exists in `document.body`, injecting it if missing.
       */
      ensureModal: function(options) {
        if (typeof document === 'undefined' || !document.body) return null;
        var overlayId = (options && options.modalOverlayId) || this.config.modalOverlayId;
        var existing = document.getElementById(overlayId);
        if (existing) return existing;
        var wrapper = document.createElement('div');
        wrapper.innerHTML = this.renderModalHtml(options);
        var modalEl = wrapper.firstElementChild;
        if (modalEl) {
          document.body.appendChild(modalEl);
          this._bindModalEvents();
        }
        return modalEl;
      },

      /**
       * Resolves multi-label root domain for setting shared domain cookies across subdomains.
       */
      getRootDomain: function() {
        if (typeof window === 'undefined' || !window.location) return null;
        var host = window.location.hostname;
        if (!host) return null;
        var isIp = /^(\d{1,3}\.){3}\d{1,3}$/.test(host) || host.includes(':');
        if (isIp || host === 'localhost' || host.endsWith('.localhost')) return null;
        var parts = host.split('.');
        if (parts.length < 2) return null;
        return parts.slice(-2).join('.');
      },

      /**
       * Reads a cookie value by name from document.cookie.
       */
      getCookie: function(name) {
        if (typeof document === 'undefined' || typeof document.cookie !== 'string') return null;
        var match = document.cookie.match(new RegExp('(?:^|; )' + name.replace(/([\.$?*|{}\(\)\[\]\\\/\+^])/g, '\\$1') + '=([^;]*)'));
        return match ? decodeURIComponent(match[1]) : null;
      },

      /**
       * Writes a cookie and persists to localStorage fallback.
       */
      setCookie: function(name, value, days) {
        if (typeof document !== 'undefined') {
          var rootDomain = this.getRootDomain();
          var expires = days ? '; max-age=' + (days * 86400) : '';
          var secure = (typeof window !== 'undefined' && window.location && window.location.protocol === 'https:') ? '; Secure' : '';
          var cookieStr = name + '=' + encodeURIComponent(value) + expires + '; path=/; SameSite=Lax' + secure;
          if (rootDomain) {
            cookieStr += '; domain=' + rootDomain;
          }
          try { document.cookie = cookieStr; } catch(e) {}
        }
        try {
          if (typeof window !== 'undefined' && window.localStorage) {
            window.localStorage.setItem(name, value);
          }
        } catch(e) {}
      },

      /**
       * Retrieves saved palette ID from cookies or localStorage fallback.
       */
      getSavedPaletteId: function() {
        var fromCookie = this.getCookie(this.STORAGE_KEY);
        if (fromCookie) return fromCookie;
        try {
          if (typeof window !== 'undefined' && window.localStorage) {
            return window.localStorage.getItem(this.STORAGE_KEY);
          }
        } catch(e) {}
        return null;
      },

      /**
       * Resolves variable color keys against defined color dictionary.
       */
      getResolvedColors: function(palette) {
        if (!palette) return {};
        if (!palette.variables && palette.colors) {
          return palette.colors;
        }
        var colorDefs = palette.palette_colors || palette.colors || {};
        var vars = palette.variables || palette.colors || {};
        var resolved = {};
        if (palette.colors) {
          for (var cKey in palette.colors) {
            if (Object.prototype.hasOwnProperty.call(palette.colors, cKey)) {
              resolved[cKey] = palette.colors[cKey];
            }
          }
        }
        for (var key in vars) {
          if (Object.prototype.hasOwnProperty.call(vars, key)) {
            var val = vars[key];
            if (typeof val === 'object' && val !== null) {
              val = val.value;
            }
            if (typeof val === 'string' && colorDefs[val]) {
              resolved[key] = (typeof colorDefs[val] === 'object' && colorDefs[val] !== null) ? colorDefs[val].value : colorDefs[val];
            } else {
              resolved[key] = val;
            }
          }
        }
        return resolved;
      },

      /**
       * Applies CSS variable overrides to a target element for both Sol.vin and Sunstone variables.
       */
      _applyCssVariablesToElement: function(el, palette, colors) {
        if (!el || !el.style || !colors) return;
        for (var key in colors) {
          if (Object.prototype.hasOwnProperty.call(colors, key)) {
            var val = colors[key];
            var cssVarName = '--' + key.replace(/_/g, '-');
            el.style.setProperty(cssVarName, val);
          }
        }

        var bg = colors.bg_color || '#0f172a';
        var surface = colors.surface_color || colors.bg_window || '#1e293b';
        var surfaceHover = colors.surface_hover || '#273549';
        var textPrimary = colors.text_primary || colors.text_color || '#f8fafc';
        var textSecondary = colors.text_secondary || colors.text_color || '#cbd5e1';
        var textMuted = colors.text_muted || colors.text_dim || '#94a3b8';
        var accent = colors.accent_color || '#38bdf8';
        var accentSec = colors.accent_secondary || '#818cf8';
        var accentTert = colors.accent_tertiary || '#34d399';
        var border = colors.border_color || '#334155';
        var borderActive = colors.border_active || accent;
        var codeBg = colors.code_bg || bg;
        var linkColor = colors.link_color || accent;
        var cubeColor = colors.cube || colors.cube_stroke_color || textPrimary;
        var cubeHover = colors.cube_hover || borderActive;
        var shadowColor = colors.shadow_color || '#000000';

        el.style.setProperty('--bg-color', bg);
        el.style.setProperty('--bg-window', surface);
        el.style.setProperty('--text-color', textPrimary);
        el.style.setProperty('--text-dim', textMuted);
        el.style.setProperty('--link-color', linkColor);
        el.style.setProperty('--border-color', border);
        el.style.setProperty('--border-active', borderActive);
        el.style.setProperty('--accent-color', accent);
        el.style.setProperty('--accent-secondary', accentSec);
        el.style.setProperty('--accent-tertiary', accentTert);
        el.style.setProperty('--shadow-color', shadowColor);
        el.style.setProperty('--cube', cubeColor);
        el.style.setProperty('--cube-hover', cubeHover);
        el.style.setProperty('--cube-stroke-color', cubeColor);

        el.style.setProperty('--cyan-accent', borderActive);
        el.style.setProperty('--godot-blue', linkColor);
        el.style.setProperty('--crystal-purp', accentSec);
        el.style.setProperty('--emerald-green', accent);
        el.style.setProperty('--coral-red', accentSec);
        el.style.setProperty('--amber-gold', accentTert);

        el.style.setProperty('--sunstone-bg', bg);
        el.style.setProperty('--sunstone-surface', surface);
        el.style.setProperty('--sunstone-surface-hover', surfaceHover);
        el.style.setProperty('--sunstone-text-primary', textPrimary);
        el.style.setProperty('--sunstone-text-secondary', textSecondary);
        el.style.setProperty('--sunstone-text-muted', textMuted);
        el.style.setProperty('--sunstone-accent', accent);
        el.style.setProperty('--sunstone-accent-secondary', accentSec);
        el.style.setProperty('--sunstone-accent-tertiary', accentTert);
        el.style.setProperty('--sunstone-border', border);
        el.style.setProperty('--sunstone-border-active', borderActive);
        el.style.setProperty('--sunstone-code-bg', codeBg);

        if (palette && palette.id && typeof document !== 'undefined' && document.getElementById('emoji-filter-' + palette.id)) {
          el.style.setProperty('--emoji-filter', 'url(#emoji-filter-' + palette.id + ')');
        }
      },

      /**
       * Synchronizes all Sunstone slide `<section class="slide">` elements with the active palette.
       */
      syncSlideDeck: function(palette, colors) {
        if (!this.config.syncSlides || typeof document === 'undefined' || !palette) return;
        var resolved = colors || this.getResolvedColors(palette);
        var bg = resolved.bg_color || '#0f172a';
        var cubeColor = resolved.cube || resolved.cube_stroke_color || resolved.text_primary || resolved.text_color || '#1c1c1e';
        var cubeHover = resolved.cube_hover || resolved.border_active || resolved.accent_color || cubeColor;

        var slides = document.querySelectorAll('.reveal .slides section.slide, section.solvin-slide');
        for (var i = 0; i < slides.length; i++) {
          var sec = slides[i];
          var prevPal = sec.getAttribute('data-palette');
          if (!sec.dataset.originalPalette && prevPal) {
            sec.dataset.originalPalette = prevPal;
            sec.dataset.originalPaletteName = sec.getAttribute('data-palette-name') || '';
            sec.dataset.originalBgColor = sec.getAttribute('data-background-color') || '';
            sec.dataset.originalCube = sec.getAttribute('data-palette-cube') || '';
            sec.dataset.originalCubeHover = sec.getAttribute('data-palette-cube-hover') || '';
          }
          if (prevPal && prevPal !== palette.id && sec.classList) {
            sec.classList.remove(prevPal);
          }
          if (palette.id && sec.classList) {
            sec.classList.add(palette.id);
          }
          sec.setAttribute('data-palette', palette.id || '');
          sec.setAttribute('data-palette-name', palette.name || palette.id || '');
          sec.setAttribute('data-background-color', bg);
          sec.setAttribute('data-palette-cube', cubeColor);
          sec.setAttribute('data-palette-cube-hover', cubeHover);
          this._applyCssVariablesToElement(sec, palette, resolved);
        }

        var bgs = document.querySelectorAll('.reveal .backgrounds .slide-background');
        for (var b = 0; b < bgs.length; b++) {
          bgs[b].style.backgroundColor = bg;
        }
      },

      /**
       * Applies CSS variable overrides to documentElement and updates active dataset attributes.
       */
      applyPalette: function(palette) {
        if (!palette || typeof document === 'undefined' || !document.documentElement) return;
        var colors = this.getResolvedColors(palette);
        if (!colors) return;
        var rootEl = document.documentElement;
        this._applyCssVariablesToElement(rootEl, palette, colors);
        rootEl.setAttribute('data-palette', palette.id || '');

        if (this._userOverridden) {
          this.syncSlideDeck(palette, colors);
        }

        this.updateButtonLabel(palette);
        this.updateDuotoneFilter(palette);
        this.refreshChartColors();
        if (typeof this.config.onChange === 'function') {
          try { this.config.onChange(palette, colors); } catch(e) {}
        }
        try {
          if (typeof document !== 'undefined' && document.dispatchEvent && typeof CustomEvent === 'function') {
            document.dispatchEvent(new CustomEvent('palettechange', { detail: { palette: palette, colors: colors } }));
          }
        } catch(e) {}
      },

      /**
       * Refreshes all active Chart.js chart instances on the page if Chart.js is loaded.
       */
      refreshChartColors: function() {
        if (typeof window !== 'undefined' && window.Chart && window.Chart.instances) {
          var instances = window.Chart.instances;
          for (var id in instances) {
            if (Object.prototype.hasOwnProperty.call(instances, id)) {
              var chart = instances[id];
              if (chart && typeof chart.update === 'function') {
                chart.update();
              }
            }
          }
        }
      },

      /**
       * Parses CSS hex/rgb color string into normalized RGB values [0..1].
       */
      parseColorToRgb: function(colorStr) {
        if (colorStr === null || colorStr === undefined) return { r: 0, g: 0, b: 0 };
        if (typeof colorStr !== 'string') {
          if (typeof colorStr === 'object' && colorStr !== null && colorStr.value) {
            colorStr = String(colorStr.value);
          } else {
            colorStr = String(colorStr);
          }
        }
        colorStr = colorStr.trim();
        if (!colorStr) return { r: 0, g: 0, b: 0 };

        var cleanHex = colorStr.startsWith('#') ? colorStr.substring(1) : colorStr;
        if (/^[0-9a-fA-F]{3}$/.test(cleanHex) || /^[0-9a-fA-F]{6}$/.test(cleanHex)) {
          if (cleanHex.length === 3) {
            cleanHex = cleanHex[0] + cleanHex[0] + cleanHex[1] + cleanHex[1] + cleanHex[2] + cleanHex[2];
          }
          var num = parseInt(cleanHex, 16);
          if (!isNaN(num)) {
            return {
              r: ((num >> 16) & 255) / 255,
              g: ((num >> 8) & 255) / 255,
              b: (num & 255) / 255
            };
          }
        }
        var match = colorStr.match(/rgba?\(\s*(\d+)\s*,\s*(\d+)\s*,\s*(\d+)/i);
        if (match) {
          return {
            r: parseInt(match[1], 10) / 255,
            g: parseInt(match[2], 10) / 255,
            b: parseInt(match[3], 10) / 255
          };
        }
        return { r: 0, g: 0, b: 0 };
      },

      /**
       * Calculates feColorMatrix 5x4 matrix values string for interpolating between
       * duotone color palette mapping (progress t=0.0) and full-color original image (progress t=1.0).
       */
      getDuotoneMatrixValues: function(palette, t) {
        t = Math.max(0, Math.min(1, typeof t === 'number' ? t : 0));
        var startVal = '#1c1c1e';
        var endVal = '#faf6ee';

        var colors = this.getResolvedColors(palette);
        if (colors && Object.keys(colors).length > 0) {
          if (colors.filter_start_color) {
            startVal = colors.filter_start_color;
          } else if (colors.text_color) {
            startVal = colors.text_color;
          }
          if (colors.filter_end_color) {
            endVal = colors.filter_end_color;
          } else if (colors.bg_color) {
            endVal = colors.bg_color;
          }
        } else if (typeof window !== 'undefined' && window.getComputedStyle && typeof document !== 'undefined' && document.documentElement) {
          var rootStyles = getComputedStyle(document.documentElement);
          if (rootStyles) {
            var getVar = function(prop) {
              var raw = rootStyles.getPropertyValue(prop);
              return (typeof raw === 'string' && raw) ? raw.trim() : '';
            };
            startVal = getVar('--filter-start-color') || getVar('--text-color') || startVal;
            endVal = getVar('--filter-end-color') || getVar('--bg-color') || endVal;
          }
        }

        var bg = this.parseColorToRgb(endVal);
        var txt = this.parseColorToRgb(startVal);

        var dr = bg.r - txt.r;
        var dg = bg.g - txt.g;
        var db = bg.b - txt.b;

        var invT = 1 - t;

        var rR = invT * dr * 0.2126 + t;
        var rG = invT * dr * 0.7152;
        var rB = invT * dr * 0.0722;
        var rC = invT * txt.r;

        var gR = invT * dg * 0.2126;
        var gG = invT * dg * 0.7152 + t;
        var gB = invT * dg * 0.0722;
        var gC = invT * txt.g;

        var bR = invT * db * 0.2126;
        var bG = invT * db * 0.7152;
        var bB = invT * db * 0.0722 + t;
        var bC = invT * txt.b;

        return [
          rR.toFixed(4), rG.toFixed(4), rB.toFixed(4), 0, rC.toFixed(4),
          gR.toFixed(4), gG.toFixed(4), gB.toFixed(4), 0, gC.toFixed(4),
          bR.toFixed(4), bG.toFixed(4), bB.toFixed(4), 0, bC.toFixed(4),
          0, 0, 0, 1, 0
        ].join(' ');
      },

      /**
       * Updates SVG feColorMatrix values with current palette text and bg colors.
       */
      updateDuotoneFilter: function(palette) {
        if (typeof document === 'undefined') return;
        var self = this;
        this._activePalette = palette;
        var globalMatrix = document.getElementById('palette-duotone-matrix');
        if (globalMatrix) {
          globalMatrix.setAttribute('values', this.getDuotoneMatrixValues(palette, 0));
        }

        var svgContainer = document.getElementById('duotone-svg-container');
        if (!svgContainer) return;

        var activeFilters = svgContainer.querySelectorAll('feColorMatrix[data-duotone-matrix]');
        for (var f = 0; f < activeFilters.length; f++) {
          var mat = activeFilters[f];
          var img = mat._boundImg;
          var currentT = (img && typeof img._duotoneProgress === 'number') ? img._duotoneProgress : 0;
          mat.setAttribute('values', self.getDuotoneMatrixValues(palette, currentT));
        }
      },

      /**
       * Updates the UI button text label and color dot if elements are present in DOM.
       */
      updateButtonLabel: function(palette) {
        if (typeof document === 'undefined' || !palette) return;
        var label = document.getElementById(this.config.nameLabelId);
        if (label) {
          label.textContent = palette.name || palette.id;
        }
        var preview = document.getElementById(this.config.colorPreviewId);
        if (preview) {
          var colors = this.getResolvedColors(palette);
          var secColor = colors.accent_secondary || colors.accent_color || colors.text_color;
          if (secColor) preview.style.color = secColor;
        }
      },

      /**
       * Synchronizes the button display with a specific slide element when not manually overridden.
       */
      syncWithSlide: function(slideEl) {
        if (!slideEl || this._userOverridden) return;
        var palId = slideEl.getAttribute('data-palette');
        if (palId) {
          var idx = this.findPaletteIndexById(palId);
          if (idx >= 0) {
            this.currentIndex = idx;
            this.currentPalette = this.palettes[idx];
            this.updateButtonLabel(this.currentPalette);
            return;
          }
        }
        var palName = slideEl.getAttribute('data-palette-name');
        if (palName) {
          var label = document.getElementById(this.config.nameLabelId);
          if (label) label.textContent = palName;
        }
      },

      openPaletteModal: function() {
        if (typeof document === 'undefined') return;
        var modalOverlay = document.getElementById(this.config.modalOverlayId);
        if (!modalOverlay && this.config.autoInjectModal) {
          modalOverlay = this.ensureModal();
        }
        var modalGrid = document.getElementById(this.config.modalGridId);
        if (!modalOverlay || !modalGrid) return;

        this.renderPaletteGrid();
        modalOverlay.style.cssText = 'display: flex !important; z-index: 999999;';
        if (document.body) {
          document.body.style.overflow = 'hidden';
        }
      },

      closePaletteModal: function() {
        if (typeof document === 'undefined') return;
        var modalOverlay = document.getElementById(this.config.modalOverlayId);
        if (!modalOverlay) return;
        modalOverlay.style.cssText = 'display: none !important;';
        if (document.body) {
          document.body.style.overflow = '';
        }
      },

      renderPaletteGrid: function() {
        if (typeof document === 'undefined') return;
        var modalGrid = document.getElementById(this.config.modalGridId);
        if (!modalGrid || !this.palettes) return;

        var self = this;
        modalGrid.innerHTML = '';

        for (var i = 0; i < this.palettes.length; i++) {
          (function(idx) {
            var pal = self.palettes[idx];
            var btn = document.createElement('button');
            btn.type = 'button';
            btn.className = 'export-btn palette-grid-item-btn';
            btn.setAttribute('data-palette-id', pal.id || '');
            btn.setAttribute('data-palette-index', String(idx));

            var colors = self.getResolvedColors(pal);
            var bg = colors.bg_color || '#faf6ee';
            var txt = colors.text_color || '#1c1c1e';
            var border = colors.border_color || '#1c1c1e';
            var shadow = colors.shadow_color || border;
            var circleColor = colors.accent_secondary || colors.accent_color || txt;

            btn.style.cssText = 'background: ' + bg + ' !important; color: ' + txt + ' !important; border: 2px solid ' + border + ' !important; box-shadow: 2px 2px 0px ' + shadow + ' !important; padding: 0.6rem 0.8rem; font-size: 0.85rem; font-weight: bold; cursor: pointer; text-align: left; display: flex; align-items: center; justify-content: space-between; font-family: monospace; border-radius: 3px;';

            if (idx === self.currentIndex) {
              btn.style.outline = '2px solid ' + txt;
              btn.classList.add('is-active');
            }

            var leftSpan = document.createElement('span');
            leftSpan.className = 'palette-grid-item-label';

            var dotSpan = document.createElement('span');
            dotSpan.className = 'palette-grid-item-dot';
            dotSpan.style.color = circleColor;
            dotSpan.textContent = '●';

            var nameSpan = document.createElement('span');
            nameSpan.textContent = pal.name || pal.id;

            leftSpan.appendChild(dotSpan);
            leftSpan.appendChild(document.createTextNode(' '));
            leftSpan.appendChild(nameSpan);

            var rightSpan = document.createElement('span');
            rightSpan.className = 'palette-grid-item-index';
            rightSpan.textContent = '[ #' + (idx + 1) + ' ]';

            btn.appendChild(leftSpan);
            btn.appendChild(rightSpan);

            btn.addEventListener('click', function(e) {
              e.preventDefault();
              self._userOverridden = true;
              self.selectIndex(idx);
              self.closePaletteModal();
            });

            modalGrid.appendChild(btn);
          })(i);
        }
      },

      findPaletteIndexById: function(id) {
        if (!id || !this.palettes) return -1;
        for (var i = 0; i < this.palettes.length; i++) {
          if (this.palettes[i].id === id) return i;
        }
        return -1;
      },

      selectById: function(id) {
        var idx = this.findPaletteIndexById(id);
        if (idx >= 0) {
          this._userOverridden = true;
          this.selectIndex(idx);
          return true;
        }
        return false;
      },

      selectIndex: function(idx, options) {
        if (!this.palettes || this.palettes.length === 0) return;
        var opts = options || {};
        var safeIdx = (idx % this.palettes.length + this.palettes.length) % this.palettes.length;
        if (!opts.silentOverride) {
          this._userOverridden = true;
        }
        this.currentIndex = safeIdx;
        this.currentPalette = this.palettes[safeIdx];
        this.applyPalette(this.currentPalette);

        if (this.currentPalette && this.currentPalette.id && !opts.skipPersist) {
          this.setCookie(this.STORAGE_KEY, this.currentPalette.id, 365);
          if (this.channel && !opts.fromBroadcast) {
            try { this.channel.postMessage({ id: this.currentPalette.id, index: safeIdx }); } catch(e) {}
          }
        }
      },

      nextPalette: function() {
        if (!this.palettes || this.palettes.length === 0) return;
        this._userOverridden = true;
        this.selectIndex(this.currentIndex + 1);
      },

      prevPalette: function() {
        if (!this.palettes || this.palettes.length === 0) return;
        this._userOverridden = true;
        this.selectIndex(this.currentIndex - 1);
      },

      resetDefaultPalette: function() {
        this._userOverridden = true;
        this.selectIndex(0);
      },

      randomPalette: function() {
        if (!this.palettes || this.palettes.length === 0) return;
        this._userOverridden = true;
        if (this.palettes.length === 1) {
          this.selectIndex(0);
          return;
        }
        var randomIdx = this.currentIndex;
        do {
          randomIdx = Math.floor(Math.random() * this.palettes.length);
        } while (randomIdx === this.currentIndex);
        this.selectIndex(randomIdx);
      },

      syncFromStorage: function() {
        var savedId = this.getSavedPaletteId();
        if (savedId) {
          var idx = this.findPaletteIndexById(savedId);
          if (idx >= 0 && idx !== this.currentIndex) {
            this._userOverridden = true;
            this.selectIndex(idx, { fromBroadcast: true });
          }
        }
      },

      initHead: function(palettes) {
        this.palettes = palettes || (typeof window !== 'undefined' && window.SITE_PALETTES) || [];
        var savedId = this.getSavedPaletteId();
        var idx = this.findPaletteIndexById(savedId);
        if (idx >= 0) {
          this._userOverridden = true;
          this.selectIndex(idx, { fromBroadcast: true });
        } else {
          this._userOverridden = false;
          this.selectIndex(0, { silentOverride: true, skipPersist: true });
        }
      },

      initDuotoneImages: function(scope) {
        if (typeof document === 'undefined') return;
        scope = scope || document;
        var self = this;

        var svgContainer = document.getElementById('duotone-svg-container');
        if (!svgContainer) return;

        var activeFilters = svgContainer.querySelectorAll('feColorMatrix[data-duotone-matrix]');
        for (var f = 0; f < activeFilters.length; f++) {
          var mat = activeFilters[f];
          mat.setAttribute('values', self.getDuotoneMatrixValues(self._activePalette || self.currentPalette, 0));
        }
      },

      _bindModalEvents: function() {
        if (typeof document === 'undefined') return;
        var self = this;
        var closeBtn = document.getElementById(this.config.modalCloseId);
        var modalOverlay = document.getElementById(this.config.modalOverlayId);
        var randomBtn = document.getElementById(this.config.modalRandomId);

        if (randomBtn && !randomBtn._paletteBound) {
          randomBtn._paletteBound = true;
          randomBtn.addEventListener('click', function(e) {
            e.preventDefault();
            self.randomPalette();
            if (modalOverlay && modalOverlay.style.display !== 'none') {
              self.renderPaletteGrid();
            }
          });
        }
        if (closeBtn && !closeBtn._paletteBound) {
          closeBtn._paletteBound = true;
          closeBtn.addEventListener('click', function(e) {
            e.preventDefault();
            self.closePaletteModal();
          });
        }
        if (modalOverlay && !modalOverlay._paletteBound) {
          modalOverlay._paletteBound = true;
          modalOverlay.addEventListener('click', function(e) {
            if (e.target === modalOverlay) self.closePaletteModal();
          });
        }
      },

      initDom: function(options) {
        if (options) this.configure(options);
        if (this._domInitialized) return;
        this._domInitialized = true;
        var self = this;

        if (!this.currentPalette && (!this.palettes || this.palettes.length === 0)) {
          if (typeof window !== 'undefined' && window.SITE_PALETTES && window.SITE_PALETTES.length > 0) {
            this.initHead(window.SITE_PALETTES);
          }
        }

        if (this._userOverridden && this.currentPalette) {
          this.syncSlideDeck(this.currentPalette);
        } else if (typeof document !== 'undefined') {
          var activeSlide = document.querySelector('.reveal .slides section.present') || document.querySelector('.reveal .slides section.slide');
          if (activeSlide) {
            this.syncWithSlide(activeSlide);
          }
        }

        if (this.currentPalette) {
          this.updateButtonLabel(this.currentPalette);
          this.updateDuotoneFilter(this.currentPalette);
        }

        if (typeof window !== 'undefined' && window.Reveal && typeof window.Reveal.on === 'function') {
          window.Reveal.on('ready', function(event) {
            if (self._userOverridden && self.currentPalette) {
              self.syncSlideDeck(self.currentPalette);
            } else if (event && event.currentSlide) {
              self.syncWithSlide(event.currentSlide);
            }
          });
          window.Reveal.on('slidechanged', function(event) {
            if (self._userOverridden && self.currentPalette) {
              self.syncSlideDeck(self.currentPalette);
            } else if (event && event.currentSlide) {
              self.syncWithSlide(event.currentSlide);
            }
          });
        }

        try {
          if (typeof window !== 'undefined' && 'BroadcastChannel' in window && !this.channel) {
            this.channel = new BroadcastChannel(this.CHANNEL_NAME);
            this.channel.onmessage = function(e) {
              if (e && e.data) {
                self._userOverridden = true;
                if (typeof e.data.index === 'number' && e.data.index >= 0 && e.data.index < self.palettes.length) {
                  if (e.data.index !== self.currentIndex) {
                    self.selectIndex(e.data.index, { fromBroadcast: true });
                  }
                } else if (e.data.id) {
                  var idx = self.findPaletteIndexById(e.data.id);
                  if (idx >= 0 && idx !== self.currentIndex) {
                    self.selectIndex(idx, { fromBroadcast: true });
                  }
                }
              }
            };
          }
        } catch(e) {}

        if (typeof window !== 'undefined') {
          window.addEventListener('visibilitychange', function() {
            if (typeof document !== 'undefined' && !document.hidden) self.syncFromStorage();
          });
          window.addEventListener('focus', function() {
            self.syncFromStorage();
          });
        }

        this._bindModalEvents();

        if (typeof document !== 'undefined') {
          document.addEventListener('keydown', function(e) {
            var modalOverlay = document.getElementById(self.config.modalOverlayId);
            if (e.key === 'Escape' && modalOverlay && modalOverlay.style.display && modalOverlay.style.display !== 'none') {
              e.preventDefault();
              e.stopPropagation();
              if (typeof e.stopImmediatePropagation === 'function') e.stopImmediatePropagation();
              self.closePaletteModal();
            }
          }, true);

          var btn = document.getElementById(this.config.buttonId);
          var HoldClickCtrl = (typeof window !== 'undefined' && window.HoldClick) || (root && root.HoldClick);
          if (btn && HoldClickCtrl) {
            HoldClickCtrl.attach(btn, {
              holdDuration: this.config.holdDuration,
              spinnerDelay: this.config.spinnerDelay,
              onLeftClick: function() { self.nextPalette(); },
              onRightClick: function() { self.prevPalette(); },
              onLeftHold: function() { self.openPaletteModal(); },
              onRightHold: function() { self.resetDefaultPalette(); }
            });
          }
        }
      }
    };

    return PaletteEngine;
  }

  var singletonEngine = createEngineInstance();

  if (root) {
    root.PaletteEngine = singletonEngine;
  }
  if (typeof module !== 'undefined' && module.exports) {
    module.exports = singletonEngine;
  }
})(typeof window !== 'undefined' ? window : (typeof globalThis !== 'undefined' ? globalThis : this));
