// Generated by CoffeeScript 1.10.0
(function() {
  var Beat, MAX_GLOBAL_HUE, MIN_GLOBAL_HUE, Nebula, NebulaStar, ShootingStar, StarParticle, audioEl, canvasSize, fft, globalHue, globalHueModifier, jsonLoaded, nebulae, r, renderBars, renderWaveform, scheduleBars, scheduleBeats, scheduleSections, selectSong, shootingStars, theBeat, theNebula, triggerBeat,
    bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; };

  MIN_GLOBAL_HUE = 210;

  MAX_GLOBAL_HUE = 290;

  audioEl = null;

  shootingStars = [];

  nebulae = [];

  globalHue = MIN_GLOBAL_HUE;

  globalHueModifier = 4;

  fft = null;

  r = 1;

  canvasSize = 1;

  StarParticle = (function() {
    function StarParticle() {
      this.draw = bind(this.draw, this);
    }

    StarParticle.prototype.draw = function(starX, starY, sd) {
      var x, y;
      if (sd == null) {
        sd = 4;
      }
      x = randomGaussian(starX, sd);
      y = randomGaussian(starY, sd);
      fill(color(230, 10, 95, 12));
      return ellipse(x, y, 1, 1);
    };

    return StarParticle;

  })();

  ShootingStar = (function() {
    function ShootingStar(maxAge) {
      this.kill = bind(this.kill, this);
      this.draw = bind(this.draw, this);
      var i, j, maxDiameter, minDiameter;
      this.maxAge = maxAge * 1000;
      this.birth = Date.now();
      shootingStars.push(this);
      this.x = ~~(Math.random() * canvasSize) + (canvasSize / 10);
      this.y = -(~~(Math.random() * 100) + 20);
      this.velY = (Math.random() * 2) + 0.6;
      this.velX = -this.velY;
      this.alpha = 40;
      maxDiameter = canvasSize / 100;
      minDiameter = canvasSize / 150;
      this.diameter = ~~(Math.random() * (maxDiameter - minDiameter) + minDiameter);
      this.starParticles = [];
      for (i = j = 1; j <= 50; i = ++j) {
        this.starParticles.push(new StarParticle());
      }
    }

    ShootingStar.prototype.draw = function() {
      var j, len, particle, ref, results;
      if (Date.now() - this.birth > this.maxAge) {
        this.alpha -= 1;
      }
      if (this.alpha === 0) {
        this.kill();
        return;
      }
      this.x += this.velX;
      this.y += this.velY;
      this.diameter -= 0.02;
      fill(color(230, 10, 95, this.alpha));
      noStroke();
      ellipse(this.x, this.y, this.diameter, this.diameter);
      ref = this.starParticles;
      results = [];
      for (j = 0, len = ref.length; j < len; j++) {
        particle = ref[j];
        results.push(particle.draw(this.x, this.y, this.diameter * 0.6));
      }
      return results;
    };

    ShootingStar.prototype.kill = function() {
      this.starParticles = [];
      return shootingStars.splice(shootingStars.indexOf(this), 1);
    };

    return ShootingStar;

  })();

  NebulaStar = (function() {
    function NebulaStar() {
      this.kill = bind(this.kill, this);
      this.draw = bind(this.draw, this);
      var angle, maxRad, minRad, radius;
      angle = Math.random() * Math.PI * 2;
      minRad = canvasSize / 4;
      maxRad = canvasSize;
      console.log(minRad, maxRad);
      radius = ~~(Math.random() * (maxRad - minRad) + minRad);
      this.x = Math.cos(angle) * radius;
      this.y = Math.sin(angle) * radius;
      this.alpha = 10;
      this.diameter = ~~(Math.random() * (5 - 1) + 1);
      this.origDiameter = this.diameter;
      this.starParticles = [];
    }

    NebulaStar.prototype.draw = function() {
      var j, len, particle, ref, results;
      if (this.diameter > this.origDiameter) {
        this.diameter *= 0.9;
      }
      if (this.diameter > this.origDiameter * 3) {
        this.diameter = this.origDiameter;
      }
      fill("rgba(220, 208, 229, " + (this.alpha / 100) + ")");
      noStroke();
      ellipse(this.x, this.y, this.diameter, this.diameter);
      ref = this.starParticles;
      results = [];
      for (j = 0, len = ref.length; j < len; j++) {
        particle = ref[j];
        results.push(particle.draw(this.x, this.y, this.diameter / 2));
      }
      return results;
    };

    NebulaStar.prototype.kill = function() {
      this.starParticles = [];
      return shootingStars.splice(shootingStars.indexOf(this), 1);
    };

    return NebulaStar;

  })();

  Nebula = (function() {
    function Nebula(x1, y1, x21, y21, starCount) {
      var i, j;
      this.x = x1;
      this.y = y1;
      this.x2 = x21;
      this.y2 = y21;
      this.starCount = starCount;
      this.draw = bind(this.draw, this);
      nebulae.push(this);
      this.rot = 0;
      this.stars = [];
      for (i = j = 0; j <= 250; i = ++j) {
        this.stars.push(new NebulaStar());
      }
    }

    Nebula.prototype.draw = function() {
      var j, len, ref, star;
      this.rot = (this.rot + 0.2) % 360;
      push();
      translate(canvasSize / 2, canvasSize - (canvasSize / 4));
      rotate(this.rot);
      ref = this.stars;
      for (j = 0, len = ref.length; j < len; j++) {
        star = ref[j];
        star.draw();
      }
      return pop();
    };

    return Nebula;

  })();

  Beat = (function() {
    function Beat() {
      this.diameter = 60;
      this.decayRate = 1.3;
      this.extraRad = 1;
      this.radRate = 1;
      this.maxDiameter = canvasSize / 3;
      this.hue = 50;
    }

    Beat.prototype.triggerBeat = function() {
      this.extraRad = 20;
      this.radRate = 1.3;
      return this.hue = (this.hue + 5) % 360;
    };

    Beat.prototype.draw = function() {};

    return Beat;

  })();

  selectSong = function(e) {
    var json, mp3, src;
    src = e.target.getAttribute('data-src');
    mp3 = src + ".mp3";
    json = src + ".json";
    loadJSON(json, jsonLoaded);
    if (audioEl) {
      audioEl.stop();
    }
    audioEl = createAudio(mp3);
    return fft.setInput(audioEl);
  };

  triggerBeat = function() {
    return theBeat.triggerBeat();
  };

  renderWaveform = function(waveform) {
    var i, j, len, wave, x, y;
    noFill();
    stroke('rgba(18, 57, 98, 0.7)');
    beginShape();
    strokeJoin(ROUND);
    strokeCap(ROUND);
    strokeWeight(height / 55);
    for (i = j = 0, len = waveform.length; j < len; i = ++j) {
      wave = waveform[i];
      x = map(i, 0, waveform.length, 0, canvasSize + 60);
      y = map(wave, -1, 1, height - 200, canvasSize + 200);
      vertex(x, y);
    }
    return endShape();
  };

  renderBars = function(waveform) {
    var i, j, len, results, wave, x, x2, y, y2;
    stroke('rgba(68, 130, 162, 0.7)');
    strokeWeight(height / 280);
    results = [];
    for (i = j = 0, len = waveform.length; j < len; i = ++j) {
      wave = waveform[i];
      x = map(i, 0, waveform.length, 0, canvasSize);
      y = (-(r + wave * 200)) * (wave * 1.2) + canvasSize;
      x2 = x;
      y2 = height + 5;
      results.push(line(x, y, x2, y2));
    }
    return results;
  };

  scheduleBeats = function(beats) {
    var beat, j, len, results;
    results = [];
    for (j = 0, len = beats.length; j < len; j++) {
      beat = beats[j];
      results.push(audioEl.addCue(beat.start, function() {
        var k, len1, ref, star;
        ref = theNebula.stars;
        for (k = 0, len1 = ref.length; k < len1; k++) {
          star = ref[k];
          star.diameter += 3;
        }
        globalHue = globalHue + globalHueModifier;
        if (globalHue > MAX_GLOBAL_HUE || globalHue < MIN_GLOBAL_HUE) {
          return globalHueModifier = -globalHueModifier;
        }
      }));
    }
    return results;
  };

  scheduleBars = function(bars) {
    var bar, j, len, results;
    results = [];
    for (j = 0, len = bars.length; j < len; j++) {
      bar = bars[j];
      results.push(audioEl.addCue(bar.start, function() {
        var i, k, lum, results1;
        lum = map(globalHue, MIN_GLOBAL_HUE, MAX_GLOBAL_HUE, 12, 18);
        background(color(globalHue, 80, lum, 18));
        results1 = [];
        for (i = k = 0; k <= 1; i = ++k) {
          results1.push(new ShootingStar(bar.duration * 3));
        }
        return results1;
      }));
    }
    return results;
  };

  scheduleSections = function(sections) {
    var j, len, results, section;
    results = [];
    for (j = 0, len = sections.length; j < len; j++) {
      section = sections[j];
      results.push(audioEl.addCue(section.start, function() {
        return console.log('section', section);
      }));
    }
    return results;
  };

  jsonLoaded = function(json) {
    console.log('boom', json);
    scheduleBars(json.bars);
    scheduleBeats(json.beats);
    scheduleSections(json.sections);
    audioEl.elt.volume = 0.9;
    return audioEl.play();
  };

  theBeat = null;

  theNebula = null;

  window.setup = function() {
    var j, len, ref, results, song;
    canvasSize = Math.min(windowWidth, windowHeight) * 0.8;
    document.getElementById('album-art').style.width = canvasSize + "px";
    theBeat = new Beat();
    theNebula = new Nebula();
    background(2);
    fft = new p5.FFT(0.8, 128);
    angleMode(DEGREES);
    colorMode(HSB, 360, 100, 100, 100);
    createCanvas(canvasSize, canvasSize);
    ref = document.querySelectorAll('.song');
    results = [];
    for (j = 0, len = ref.length; j < len; j++) {
      song = ref[j];
      results.push(song.addEventListener('click', selectSong));
    }
    return results;
  };

  window.draw = function() {
    var j, k, len, len1, lum, nebula, shootingStar, waveform;
    lum = map(globalHue, MIN_GLOBAL_HUE, MAX_GLOBAL_HUE, 12, 18);
    background(color(globalHue, 80, lum, 6));
    waveform = fft.waveform();
    renderWaveform(waveform);
    renderBars(waveform);
    theBeat.draw();
    for (j = 0, len = nebulae.length; j < len; j++) {
      nebula = nebulae[j];
      if (nebula != null) {
        nebula.draw();
      }
    }
    for (k = 0, len1 = shootingStars.length; k < len1; k++) {
      shootingStar = shootingStars[k];
      if (shootingStar != null) {
        shootingStar.draw();
      }
    }
    return null;
  };

}).call(this);
