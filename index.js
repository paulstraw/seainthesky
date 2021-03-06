// Generated by CoffeeScript 1.10.0
(function() {
  var MAX_GLOBAL_HUE, MIN_GLOBAL_HUE, Nebula, NebulaStar, ShootingStar, StarParticle, audioEl, canvasSize, fft, globalHue, globalHueModifier, handleTimeChange, isMobile, jsonLoaded, minuteSecondStringFromNumber, nebulae, nextSong, pause, paused, play, playing, r, renderBars, renderWaveform, scheduleBars, scheduleBeats, setSongTitle, shootingStars, songIndex, songs, theNebula,
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

  isMobile = /Android|webOS|iPhone|iPad|iPod|BlackBerry|IEMobile|Opera Mini/i.test(navigator.userAgent);

  playing = false;

  paused = false;

  songs = [
    {
      title: 'Tread Lightly',
      path: './songs/treadlightly'
    }, {
      title: 'Tamagotchi',
      path: './songs/tamagotchi'
    }, {
      title: 'Visions',
      path: './songs/visions'
    }, {
      title: 'Krill',
      path: './songs/krill'
    }, {
      title: 'Serenity',
      path: './songs/serenity'
    }
  ];

  songIndex = 0;

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
      var i, j, maxDiameter, maxParticles, minDiameter, ref;
      this.maxAge = maxAge * 1000;
      this.birth = Date.now();
      shootingStars.push(this);
      this.x = ~~(Math.random() * canvasSize) + (canvasSize / 10);
      this.y = -(~~(Math.random() * (canvasSize / 12)) + 20);
      this.velY = ((Math.random() * 2) + 0.6) * canvasSize / 1500;
      this.velX = -this.velY;
      this.alpha = 40;
      maxDiameter = canvasSize / 100;
      minDiameter = canvasSize / 150;
      this.diameter = Math.random() * (maxDiameter - minDiameter) + minDiameter;
      this.starParticles = [];
      maxParticles = isMobile ? 18 : 50;
      for (i = j = 1, ref = maxParticles; 1 <= ref ? j <= ref : j >= ref; i = 1 <= ref ? ++j : --j) {
        this.starParticles.push(new StarParticle());
      }
    }

    ShootingStar.prototype.draw = function(curDate) {
      var j, len, particle, ref, results;
      if (curDate - this.birth > this.maxAge) {
        this.alpha -= 1;
      }
      if (this.alpha === 0) {
        this.kill();
        return;
      }
      this.x += this.velX;
      this.y += this.velY;
      if (this.diameter > 0) {
        this.diameter -= 0.015;
      }
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
      radius = ~~(Math.random() * (maxRad - minRad) + minRad);
      this.x = Math.cos(angle) * radius;
      this.y = Math.sin(angle) * radius;
      this.alpha = 10;
      this.diameter = Math.random() * ((canvasSize / 220) - 1) + 1;
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
      this.rot = 0;
      this.stars = [];
      for (i = j = 0; j <= 280; i = ++j) {
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

  nextSong = function() {
    songIndex += 1;
    paused = false;
    if (songIndex >= songs.length) {
      songIndex = 0;
    }
    setSongTitle();
    if (playing) {
      return play();
    }
  };

  setSongTitle = function() {
    return document.querySelector('.song-title').innerText = songs[songIndex].title;
  };

  play = function() {
    var json, mp3, song, src;
    playing = true;
    document.querySelector('.big-dumb-play-button').classList.add('playing');
    document.querySelector('.play-pause').classList.add('playing');
    if (paused) {
      paused = false;
      audioEl.play();
      return;
    }
    song = songs[songIndex];
    src = song.path;
    mp3 = src + ".mp3";
    json = src + ".json";
    if (audioEl) {
      audioEl.clearCues();
      audioEl.stop();
    }
    audioEl = createAudio(mp3);
    audioEl.elt.addEventListener('ended', nextSong, false);
    audioEl.elt.addEventListener('timeupdate', handleTimeChange, false);
    audioEl.play();
    return setTimeout(function() {
      audioEl.pause();
      if (!isMobile) {
        fft.setInput(audioEl);
      }
      return setTimeout(function() {
        return loadJSON(json, jsonLoaded);
      }, 150);
    }, 150);
  };

  minuteSecondStringFromNumber = function(num) {
    var minutes, seconds;
    minutes = Math.floor(num / 60);
    seconds = Math.round(num % 60);
    if (seconds < 10) {
      seconds = '0' + seconds;
    }
    return minutes + ":" + seconds;
  };

  handleTimeChange = function() {
    var curTime, duration, percentComplete;
    percentComplete = 0;
    if (audioEl.elt.currentTime > 0) {
      percentComplete = (100 / audioEl.elt.duration) * audioEl.elt.currentTime;
    }
    curTime = minuteSecondStringFromNumber(audioEl.elt.currentTime);
    duration = minuteSecondStringFromNumber(audioEl.elt.duration);
    if (audioEl.elt.duration) {
      document.querySelector('.timer').textContent = curTime + "/" + duration;
    } else {
      document.querySelector('.timer').textContent = '';
    }
    return document.querySelector('.progress').style.width = percentComplete + "%";
  };

  pause = function() {
    playing = false;
    document.querySelector('.big-dumb-play-button').classList.remove('playing');
    paused = true;
    document.querySelector('.play-pause').classList.remove('playing');
    if (audioEl) {
      return audioEl.pause();
    }
  };

  renderWaveform = function(waveform) {
    var i, j, len, wave, x, y;
    noFill();
    stroke('rgba(18, 57, 98, 0.7)');
    beginShape();
    strokeJoin(ROUND);
    strokeCap(ROUND);
    strokeWeight(canvasSize / 55);
    for (i = j = 0, len = waveform.length; j < len; i = ++j) {
      wave = waveform[i];
      x = map(i, 0, waveform.length, 0, canvasSize + 60);
      y = map(wave, -1, 1, canvasSize - (canvasSize / 5), canvasSize + (canvasSize / 5));
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
      y = (-(r + wave * (canvasSize / 5))) * (wave * 1.2) + canvasSize;
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

  jsonLoaded = function(json) {
    scheduleBars(json.bars);
    scheduleBeats(json.beats);
    audioEl.elt.volume = 0.9;
    return audioEl.play();
  };

  theNebula = null;

  window.setup = function() {
    var cnv, j, len, ref, results, song;
    canvasSize = Math.min(window.innerWidth, window.innerHeight) * 0.92;
    document.getElementById('canvas-wrapper').style.width = canvasSize + "px";
    theNebula = new Nebula();
    background(2);
    if (!isMobile) {
      fft = new p5.FFT(0.8, 128);
    }
    angleMode(DEGREES);
    colorMode(HSB, 360, 100, 100, 100);
    cnv = createCanvas(canvasSize, canvasSize);
    cnv.parent('canvas-wrapper');
    ref = document.querySelectorAll('.song');
    results = [];
    for (j = 0, len = ref.length; j < len; j++) {
      song = ref[j];
      results.push(song.addEventListener('click', selectSong));
    }
    return results;
  };

  window.windowResized = function() {
    canvasSize = Math.min(window.innerWidth, window.innerHeight) * 0.92;
    document.getElementById('canvas-wrapper').style.width = canvasSize + "px";
    resizeCanvas(canvasSize, canvasSize);
    return theNebula = new Nebula();
  };

  window.draw = function() {
    var curDate, j, len, lum, shootingStar, waveform;
    curDate = Date.now();
    lum = map(globalHue, MIN_GLOBAL_HUE, MAX_GLOBAL_HUE, 12, 18);
    background(color(globalHue, 80, lum, 6));
    if (!isMobile) {
      waveform = fft.waveform();
      renderWaveform(waveform);
      renderBars(waveform);
    }
    if (theNebula != null) {
      theNebula.draw();
    }
    for (j = 0, len = shootingStars.length; j < len; j++) {
      shootingStar = shootingStars[j];
      if (shootingStar != null) {
        shootingStar.draw(curDate);
      }
    }
    return null;
  };

  setSongTitle();

  document.querySelector('.next-song').addEventListener('click', nextSong, false);

  document.querySelector('.play-pause').addEventListener('click', function() {
    if (playing) {
      return pause();
    } else {
      return play();
    }
  }, false);

  document.querySelector('.big-dumb-play-button').addEventListener('click', function() {
    if (playing) {
      return pause();
    } else {
      return play();
    }
  }, false);

}).call(this);
