/**
 * HoldClick - Reusable Left/Right Click & Hold Handler with Progress Spinner
 * Zero-dependency UMD/Browser module exported from sol-vin/sol.vin for Sunstone.
 */
(function(root) {
  'use strict';

  function getSpinnerMarkup() {
    var injected = (root && root.SOLVIN_PALETTE_ICONS) || (typeof window !== 'undefined' && window.SOLVIN_PALETTE_ICONS);
    if (injected && injected.holdSpinner) {
      return injected.holdSpinner;
    }
    return '<img src="/icons/hold-spinner.svg" data-svg-src="src/web/svgs/hold-spinner.svg" width="32" height="32" alt="" />';
  }

  var SPINNER_SVG = getSpinnerMarkup();

  function HoldClick(target, options) {
    if (!(this instanceof HoldClick)) {
      return new HoldClick(target, options);
    }

    this.options = Object.assign({
      holdDuration: 2000,                  // Total hold time (ms) = 500ms delay + 1500ms charge up
      spinnerDelay: 500,                   // Delay before showing spinner (ms)
      spinnerId: 'palette-hold-spinner',   // DOM ID for floating progress ring
      delegateSelector: null,              // Optional selector for event delegation
      onLeftClick: null,                   // Callback(e, targetEl)
      onRightClick: null,                  // Callback(e, targetEl)
      onLeftHold: null,                    // Callback(e, targetEl)
      onRightHold: null                    // Callback(e, targetEl)
    }, options || {});

    this.container = (typeof target === 'string' && typeof document !== 'undefined')
      ? document.querySelector(target)
      : target;
    if (!this.container) return;

    this.animFrameId = null;
    this.heldLong = false;
    this.mouseX = 0;
    this.mouseY = 0;
    this.spinnerEl = null;
    this.progressCircle = null;
    this.circumference = 2 * Math.PI * 11; // ~69.115

    this._onMouseMove = this._onMouseMove.bind(this);
    this._onMouseDown = this._onMouseDown.bind(this);
    this._onMouseUp = this._onMouseUp.bind(this);
    this._onMouseLeave = this._onMouseLeave.bind(this);
    this._onClick = this._onClick.bind(this);
    this._onContextMenu = this._onContextMenu.bind(this);

    this.init();
  }

  HoldClick.SPINNER_SVG = SPINNER_SVG;

  HoldClick.prototype.ensureSpinner = function() {
    if (this.spinnerEl || typeof document === 'undefined') return;
    var spinnerId = this.options.spinnerId || 'palette-hold-spinner';
    var existing = document.getElementById(spinnerId);
    if (existing) {
      this.spinnerEl = existing;
    } else {
      this.spinnerEl = document.createElement('div');
      this.spinnerEl.id = spinnerId;
      this.spinnerEl.className = 'palette-hold-spinner hold-click-spinner';
      this.spinnerEl.innerHTML = getSpinnerMarkup();
      document.body.appendChild(this.spinnerEl);
    }
    this.progressCircle = this.spinnerEl.querySelector('.spinner-progress');
  };

  HoldClick.prototype._updateSpinnerPos = function(e) {
    if (e) {
      this.mouseX = e.clientX;
      this.mouseY = e.clientY;
    }
    if (this.spinnerEl) {
      this.spinnerEl.style.left = (this.mouseX + 14) + 'px';
      this.spinnerEl.style.top = (this.mouseY + 14) + 'px';
    }
  };

  HoldClick.prototype._onMouseMove = function(e) {
    this._updateSpinnerPos(e);
  };

  HoldClick.prototype.stopHoldAnimation = function() {
    if (this.animFrameId && typeof cancelAnimationFrame === 'function') {
      cancelAnimationFrame(this.animFrameId);
      this.animFrameId = null;
    }
    if (this.spinnerEl) {
      this.spinnerEl.classList.remove('is-visible');
    }
    if (typeof window !== 'undefined') {
      window.removeEventListener('mousemove', this._onMouseMove);
    }
  };

  HoldClick.prototype.getTargetElement = function(e) {
    if (!e || !e.target) return null;
    if (this.options.delegateSelector && typeof e.target.closest === 'function') {
      return e.target.closest(this.options.delegateSelector);
    }
    return (this.container && typeof this.container.contains === 'function' && this.container.contains(e.target))
      ? this.container
      : null;
  };

  HoldClick.prototype._onMouseDown = function(e) {
    var targetEl = this.getTargetElement(e);
    if (!targetEl) return;

    if (e.button !== 0 && e.button !== 2) return;

    this.stopHoldAnimation();
    this.ensureSpinner();
    this.heldLong = false;

    this._updateSpinnerPos(e);
    if (typeof window !== 'undefined') {
      window.addEventListener('mousemove', this._onMouseMove);
    }

    var self = this;
    var startTime = Date.now();
    var isLeftClick = (e.button === 0);
    var holdDuration = this.options.holdDuration;
    var spinnerDelay = this.options.spinnerDelay;

    function step() {
      var elapsed = Date.now() - startTime;
      if (elapsed >= spinnerDelay) {
        if (self.spinnerEl) {
          self.spinnerEl.classList.add('is-visible');
        }
        var progress = Math.min(1, Math.max(0, (elapsed - spinnerDelay) / (holdDuration - spinnerDelay)));
        if (self.progressCircle) {
          var offset = self.circumference * (1 - progress);
          self.progressCircle.style.strokeDashoffset = offset + 'px';
          self.progressCircle.setAttribute('stroke-dashoffset', offset);
        }
      } else {
        if (self.spinnerEl) {
          self.spinnerEl.classList.remove('is-visible');
        }
      }

      if (elapsed >= holdDuration) {
        self.heldLong = true;
        self.stopHoldAnimation();

        if (isLeftClick) {
          if (typeof self.options.onLeftHold === 'function') {
            self.options.onLeftHold(e, targetEl);
          }
        } else {
          if (typeof self.options.onRightHold === 'function') {
            self.options.onRightHold(e, targetEl);
          }
        }
      } else if (typeof requestAnimationFrame === 'function') {
        self.animFrameId = requestAnimationFrame(step);
      }
    }

    if (typeof requestAnimationFrame === 'function') {
      this.animFrameId = requestAnimationFrame(step);
    }
  };

  HoldClick.prototype._onMouseUp = function() {
    this.stopHoldAnimation();
  };

  HoldClick.prototype._onMouseLeave = function() {
    this.stopHoldAnimation();
  };

  HoldClick.prototype._onClick = function(e) {
    var targetEl = this.getTargetElement(e);
    if (!targetEl) return;

    e.preventDefault();
    this.stopHoldAnimation();

    if (this.heldLong) {
      this.heldLong = false;
      return;
    }

    if (typeof this.options.onLeftClick === 'function') {
      this.options.onLeftClick(e, targetEl);
    }
  };

  HoldClick.prototype._onContextMenu = function(e) {
    var targetEl = this.getTargetElement(e);
    if (!targetEl) return;

    e.preventDefault();
    this.stopHoldAnimation();

    if (this.heldLong) {
      this.heldLong = false;
      return;
    }

    if (typeof this.options.onRightClick === 'function') {
      this.options.onRightClick(e, targetEl);
    }
  };

  HoldClick.prototype.init = function() {
    if (!this.container || typeof this.container.addEventListener !== 'function') return;
    this.container.addEventListener('mousedown', this._onMouseDown);
    this.container.addEventListener('mouseup', this._onMouseUp);
    this.container.addEventListener('mouseleave', this._onMouseLeave);
    this.container.addEventListener('click', this._onClick);
    this.container.addEventListener('contextmenu', this._onContextMenu);
  };

  HoldClick.prototype.destroy = function() {
    this.stopHoldAnimation();
    if (!this.container || typeof this.container.removeEventListener !== 'function') return;
    this.container.removeEventListener('mousedown', this._onMouseDown);
    this.container.removeEventListener('mouseup', this._onMouseUp);
    this.container.removeEventListener('mouseleave', this._onMouseLeave);
    this.container.removeEventListener('click', this._onClick);
    this.container.removeEventListener('contextmenu', this._onContextMenu);
  };

  HoldClick.attach = function(target, options) {
    return new HoldClick(target, options);
  };

  if (root) {
    root.HoldClick = HoldClick;
  }
  if (typeof module !== 'undefined' && module.exports) {
    module.exports = HoldClick;
  }
})(typeof window !== 'undefined' ? window : (typeof globalThis !== 'undefined' ? globalThis : this));
