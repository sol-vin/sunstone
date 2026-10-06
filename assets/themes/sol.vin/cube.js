/**
 * Sol.vin 3D Isometric Wireframe Cube for Lapis Presentation Deck
 * Ported from https://www.sol.vin/js/cube.js
 *
 * Features:
 * - 3D wireframe cube rendered via SVG vector lines.
 * - Interactive mouse rotation, drag velocity, and friction.
 * - Left click triggers fast-spin; right click re-centers to 45-degree isometric hold.
 * - Automatically hooks into Reveal.js slide changes to update palette colors dynamically.
 */

(function() {
  const svgNS = 'http://www.w3.org/2000/svg';
  const rad45 = Math.PI / 4;

  function matMult3x3(A, B) {
    const C = [[0, 0, 0], [0, 0, 0], [0, 0, 0]];
    for (let i = 0; i < 3; i++) {
      for (let j = 0; j < 3; j++) {
        C[i][j] = A[i][0] * B[0][j] + A[i][1] * B[1][j] + A[i][2] * B[2][j];
      }
    }
    return C;
  }

  const Rx45 = [
    [1, 0, 0],
    [0, Math.cos(rad45), -Math.sin(rad45)],
    [0, Math.sin(rad45), Math.cos(rad45)]
  ];
  const Ry45 = [
    [Math.cos(rad45), 0, Math.sin(rad45)],
    [0, 1, 0],
    [-Math.sin(rad45), 0, Math.cos(rad45)]
  ];
  const Rz45 = [
    [Math.cos(rad45), -Math.sin(rad45), 0],
    [Math.sin(rad45), Math.cos(rad45), 0],
    [0, 0, 1]
  ];
  const targetR = matMult3x3(Rz45, matMult3x3(Ry45, Rx45));

  function transpose3x3(M) {
    return [
      [M[0][0], M[1][0], M[2][0]],
      [M[0][1], M[1][1], M[2][1]],
      [M[0][2], M[1][2], M[2][2]]
    ];
  }

  function getRandomDirection() {
    let rx = (Math.random() - 0.5) * 2;
    let ry = (Math.random() - 0.5) * 2;
    let rz = (Math.random() - 0.5) * 2;
    if (Math.abs(rx) < 0.2) rx += (rx >= 0 ? 0.4 : -0.4);
    if (Math.abs(ry) < 0.2) ry += (ry >= 0 ? 0.4 : -0.4);
    const len = Math.hypot(rx, ry, rz) || 1;
    return [rx / len, ry / len, rz / len];
  }

  class SolvinCubeInstance {
    constructor(container, options = {}) {
      this.container = container;
      this.size = options.size || parseInt(container.dataset.size, 10) || 48;
      this.s = options.s || 14;

      this.svg = document.createElementNS(svgNS, 'svg');
      this.svg.setAttribute('class', 'cube-svg');
      this.svg.setAttribute('width', String(this.size));
      this.svg.setAttribute('height', String(this.size));
      this.svg.setAttribute('viewBox', '0 0 64 64');

      this.baseVertices = [
        [-this.s, -this.s, -this.s],
        [ this.s, -this.s, -this.s],
        [ this.s,  this.s, -this.s],
        [-this.s,  this.s, -this.s],
        [-this.s, -this.s,  this.s],
        [ this.s, -this.s,  this.s],
        [ this.s,  this.s,  this.s],
        [-this.s,  this.s,  this.s]
      ];

      this.edges = [
        [0,1], [1,2], [2,3], [3,0],
        [4,5], [5,6], [6,7], [7,4],
        [0,4], [1,5], [2,6], [3,7]
      ];

      this.lineElems = this.edges.map(() => {
        const line = document.createElementNS(svgNS, 'line');
        line.setAttribute('class', 'cube-edge');
        this.svg.appendChild(line);
        return line;
      });

      this.container.appendChild(this.svg);

      this.R = targetR;
      this.MIN_SPEED = 0.008;
      this.MAX_SPEED = 0.18;
      this.FRICTION = 0.985;
      this.HOLD_DURATION = 5000;
      this.RAMP_DURATION = 1500;

      this.vx = 0;
      this.vy = 0;
      this.vz = 0;

      this.prevMousePos = null;
      this.centeringTimer = null;
      this.isCentering = false;
      this.isDriftRamping = false;
      this.driftRampStartTime = 0;
      this.startDriftVel = [0, 0, 0];
      this.targetDriftVel = [0, 0, 0];

      this.container.style.cursor = 'pointer';
      this.bindEvents();
      this.triggerCenter();

      this.animate = this.animate.bind(this);
      requestAnimationFrame(this.animate);
    }

    startDrifting() {
      const dir = getRandomDirection();
      const targetSpeed = this.MIN_SPEED * 1.5;
      this.targetDriftVel = [
        dir[0] * targetSpeed,
        dir[1] * targetSpeed,
        dir[2] * targetSpeed
      ];
      this.startDriftVel = [this.vx, this.vy, this.vz];
      this.isDriftRamping = true;
      this.driftRampStartTime = performance.now();
    }

    triggerCenter() {
      if (this.centeringTimer) clearTimeout(this.centeringTimer);
      this.isCentering = true;
      this.isDriftRamping = false;
      this.vx = 0;
      this.vy = 0;
      this.vz = 0;
      this.centeringTimer = setTimeout(() => {
        this.isCentering = false;
        this.centeringTimer = null;
        this.startDrifting();
      }, this.HOLD_DURATION);
    }

    triggerFastSpin() {
      if (this.centeringTimer) {
        clearTimeout(this.centeringTimer);
        this.centeringTimer = null;
      }
      this.isCentering = false;
      this.isDriftRamping = false;
      const dir = getRandomDirection();
      this.vx = dir[0] * this.MAX_SPEED;
      this.vy = dir[1] * this.MAX_SPEED;
      this.vz = dir[2] * this.MAX_SPEED;
    }

    bindEvents() {
      this.container.addEventListener('click', (e) => {
        if (e.button === 0) {
          this.triggerFastSpin();
        }
      });

      this.container.addEventListener('contextmenu', (e) => {
        e.preventDefault();
        this.triggerCenter();
      });

      this.container.addEventListener('mouseenter', (e) => {
        this.prevMousePos = { x: e.clientX, y: e.clientY };
      });

      this.container.addEventListener('mouseleave', () => {
        this.prevMousePos = null;
      });

      this.container.addEventListener('mousemove', (e) => {
        if (this.isCentering) return;
        if (!this.prevMousePos) {
          this.prevMousePos = { x: e.clientX, y: e.clientY };
          return;
        }
        const dx = e.clientX - this.prevMousePos.x;
        const dy = e.clientY - this.prevMousePos.y;
        this.prevMousePos = { x: e.clientX, y: e.clientY };

        const deltaDist = Math.hypot(dx, dy);
        if (deltaDist > 0) {
          if (this.isDriftRamping) {
            this.isDriftRamping = false;
          }
          this.vy += dx * 0.0025;
          this.vx -= dy * 0.0025;
          this.vz += (dx - dy) * 0.001;

          const currentSpeed = Math.hypot(this.vx, this.vy, this.vz);
          if (currentSpeed > this.MAX_SPEED) {
            const scale = this.MAX_SPEED / currentSpeed;
            this.vx *= scale;
            this.vy *= scale;
            this.vz *= scale;
          }
        }
      });
    }

    animate() {
      if (this.isCentering) {
        const R_T = transpose3x3(this.R);
        const R_rel = matMult3x3(targetR, R_T);
        const trace = R_rel[0][0] + R_rel[1][1] + R_rel[2][2];
        const cosTheta = Math.min(1, Math.max(-1, (trace - 1) / 2));
        const theta = Math.acos(cosTheta);

        if (theta < 0.001) {
          this.R = targetR;
          this.vx = 0;
          this.vy = 0;
          this.vz = 0;
        } else {
          let rx = R_rel[2][1] - R_rel[1][2];
          let ry = R_rel[0][2] - R_rel[2][0];
          let rz = R_rel[1][0] - R_rel[0][1];
          let len = Math.hypot(rx, ry, rz);
          if (len < 1e-6) {
            rx = 1; ry = 0; rz = 0; len = 1;
          }
          const w = Math.min(0.2, Math.max(0.01, theta * 0.15));
          this.vx = (rx / len) * w;
          this.vy = (ry / len) * w;
          this.vz = (rz / len) * w;
        }
      } else if (this.isDriftRamping) {
        const elapsed = performance.now() - this.driftRampStartTime;
        const t = Math.min(1, elapsed / this.RAMP_DURATION);
        const easeT = t * t * (3 - 2 * t);
        this.vx = this.startDriftVel[0] + (this.targetDriftVel[0] - this.startDriftVel[0]) * easeT;
        this.vy = this.startDriftVel[1] + (this.targetDriftVel[1] - this.startDriftVel[1]) * easeT;
        this.vz = this.startDriftVel[2] + (this.targetDriftVel[2] - this.startDriftVel[2]) * easeT;
        if (t >= 1) {
          this.isDriftRamping = false;
        }
      } else {
        this.vx *= this.FRICTION;
        this.vy *= this.FRICTION;
        this.vz *= this.FRICTION;

        let speed = Math.hypot(this.vx, this.vy, this.vz);

        if (speed < this.MIN_SPEED) {
          if (speed < 0.0001) {
            const dir = getRandomDirection();
            this.vx = dir[0] * this.MIN_SPEED;
            this.vy = dir[1] * this.MIN_SPEED;
            this.vz = dir[2] * this.MIN_SPEED;
          } else {
            const scale = this.MIN_SPEED / speed;
            this.vx *= scale;
            this.vy *= scale;
            this.vz *= scale;
          }
          speed = this.MIN_SPEED;
        } else if (speed > this.MAX_SPEED) {
          const scale = this.MAX_SPEED / speed;
          this.vx *= scale;
          this.vy *= scale;
          this.vz *= scale;
          speed = this.MAX_SPEED;
        }
      }

      const speed = Math.hypot(this.vx, this.vy, this.vz);
      if (speed > 0.00001) {
        const ax = this.vx / speed, ay = this.vy / speed, az = this.vz / speed;
        const cos = Math.cos(speed), sin = Math.sin(speed), c1 = 1 - cos;

        const dR = [
          [cos + ax*ax*c1,      ax*ay*c1 - az*sin, ax*az*c1 + ay*sin],
          [ay*ax*c1 + az*sin, cos + ay*ay*c1,      ay*az*c1 - ax*sin],
          [az*ax*c1 - ay*sin, az*ay*c1 + ax*sin, cos + az*az*c1]
        ];

        const nextR = [
          [0, 0, 0],
          [0, 0, 0],
          [0, 0, 0]
        ];
        for (let i = 0; i < 3; i++) {
          for (let j = 0; j < 3; j++) {
            nextR[i][j] = dR[i][0] * this.R[0][j] + dR[i][1] * this.R[1][j] + dR[i][2] * this.R[2][j];
          }
        }
        this.R = nextR;
      }

      const proj = this.baseVertices.map(v => [
        32 + (this.R[0][0]*v[0] + this.R[0][1]*v[1] + this.R[0][2]*v[2]),
        32 + (this.R[1][0]*v[0] + this.R[1][1]*v[1] + this.R[1][2]*v[2])
      ]);

      this.edges.forEach((edge, idx) => {
        const p1 = proj[edge[0]];
        const p2 = proj[edge[1]];
        this.lineElems[idx].setAttribute('x1', p1[0].toFixed(2));
        this.lineElems[idx].setAttribute('y1', p1[1].toFixed(2));
        this.lineElems[idx].setAttribute('x2', p2[0].toFixed(2));
        this.lineElems[idx].setAttribute('y2', p2[1].toFixed(2));
      });

      requestAnimationFrame(this.animate);
    }
  }

  function initAllCubes() {
    const containers = document.querySelectorAll('#header-cube-app, .cube-app-slot, .hero-cube');
    containers.forEach(el => {
      if (!el.dataset.cubeInitialized) {
        el.dataset.cubeInitialized = 'true';
        new SolvinCubeInstance(el);
      }
    });
  }

  // Hook into Reveal.js slide change events to update theme colors
  function setupRevealThemeSync() {
    if (window.Reveal) {
      function syncCurrentSlide(slide) {
        if (!slide) return;
        const palName = slide.getAttribute('data-palette-name');
        const palCube = slide.getAttribute('data-palette-cube');
        const palHover = slide.getAttribute('data-palette-cube-hover');

        const badgeName = document.getElementById('active-deck-palette-name');
        if (badgeName && palName) {
          badgeName.textContent = palName;
        }

        if (palCube) {
          document.documentElement.style.setProperty('--cube', palCube);
          document.documentElement.style.setProperty('--cube-stroke-color', palCube);
        }
        if (palHover) {
          document.documentElement.style.setProperty('--cube-hover', palHover);
        }
      }

      window.Reveal.on('slidechanged', (event) => {
        syncCurrentSlide(event.currentSlide);
      });

      window.Reveal.on('ready', (event) => {
        syncCurrentSlide(event.currentSlide);
      });
    }
  }

  if (document.readyState === 'loading') {
    document.addEventListener('DOMContentLoaded', () => {
      initAllCubes();
      setupRevealThemeSync();
    });
  } else {
    initAllCubes();
    setupRevealThemeSync();
  }

  setTimeout(initAllCubes, 200);
  setTimeout(initAllCubes, 1000);
})();
