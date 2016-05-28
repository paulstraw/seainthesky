MIN_GLOBAL_HUE = 210
MAX_GLOBAL_HUE = 290

audioEl = null
shootingStars = []
nebulae = []
globalHue = MIN_GLOBAL_HUE
globalHueModifier = 4
fft = null
r = 1
canvasSize = 1

class StarParticle
  constructor: ->


  draw: (starX, starY, sd = 4) =>
    # TODO: bias toward the opposite direction the star is moving, to create a tail?

    x = randomGaussian(starX, sd)
    y = randomGaussian(starY, sd)

    fill(color(230, 10, 95, 12))
    ellipse(x, y, 1, 1)


class ShootingStar
  constructor: (maxAge) ->
    @maxAge = maxAge * 1000 # convert maxAge to milliseconds
    @birth = Date.now()
    shootingStars.push(this)

    @x = ~~(Math.random() * canvasSize) + (canvasSize / 10)
    @y = -(~~(Math.random() * 100) + 20)
    @velY = ((Math.random() * 2) + 0.6) * canvasSize / 1500
    @velX = -@velY
    @alpha = 40
    maxDiameter = canvasSize / 100
    minDiameter = canvasSize / 150
    @diameter = (Math.random() * (maxDiameter - minDiameter) + minDiameter);

    @starParticles = []
    @starParticles.push new StarParticle() for i in [1..50]

  draw: (curDate) =>
    @alpha -= 1 if curDate - @birth > @maxAge
    if @alpha == 0
      @kill()
      return

    @x += @velX
    @y += @velY
    @diameter -= 0.015 if @diameter > 0

    fill(color(230, 10, 95, @alpha))
    noStroke()
    ellipse(@x, @y, @diameter, @diameter)
    # drawingContext.shadowOffsetX = 0;
    # drawingContext.shadowOffsetY = 0;
    # drawingContext.shadowBlur = 5;
    # drawingContext.shadowColor = 'rgba(255, 255, 255, 0.75)';

    particle.draw(@x, @y, @diameter / 2) for particle in @starParticles

  kill: =>
    @starParticles = []
    shootingStars.splice(shootingStars.indexOf(this), 1)


class NebulaStar
  constructor: ->
    # @x = ~~(Math.random() * window.innerWidth)
    # @y = ~~(Math.random() * window.innerHeight)
    angle = Math.random() * Math.PI * 2
    minRad = canvasSize / 4
    maxRad = canvasSize
    console.log(minRad, maxRad)
    radius = ~~(Math.random() * (maxRad - minRad) + minRad)

    @x = Math.cos(angle) * radius;
    @y = Math.sin(angle) * radius;
    @alpha = 10
    @diameter = (Math.random() * ((canvasSize / 220) - 1) + 1)
    @origDiameter = @diameter

    @starParticles = []
    # @starParticles.push new StarParticle() for i in [1..2]

  draw: =>
    @diameter *= 0.9 if @diameter > @origDiameter
    @diameter = @origDiameter if @diameter > @origDiameter * 3

    # fill(color(230, 10, 95, @alpha))
    fill("rgba(220, 208, 229, #{@alpha / 100})")
    noStroke()
    ellipse(@x, @y, @diameter, @diameter)
    # drawingContext.shadowOffsetX = 0;
    # drawingContext.shadowOffsetY = 0;
    # drawingContext.shadowBlur = 5;
    # drawingContext.shadowColor = 'rgba(255, 255, 255, 0.75)';

    particle.draw(@x, @y, @diameter / 2) for particle in @starParticles

  kill: =>
    @starParticles = []
    shootingStars.splice(shootingStars.indexOf(this), 1)


class Nebula
  constructor: (@x, @y, @x2, @y2, @starCount) ->
    nebulae.push this
    @rot = 0

    @stars = []
    for i in [0..280]
      # starAge = ~~(Math.random() * (@maxAge - (@maxAge / 2)) + @maxAge / 2)
      @stars.push new NebulaStar()

  draw: =>
    @rot = (@rot + 0.2) % 360
    push()
    translate(canvasSize / 2, canvasSize - (canvasSize / 4))
    rotate(@rot)
    star.draw() for star in @stars
    # rotate(-@rot)
    pop()


class Beat
  constructor: ->
    @diameter = 60
    @decayRate = 1.3
    @extraRad = 1
    @radRate = 1
    @maxDiameter = canvasSize / 3
    @hue = 50

  triggerBeat: ->
    @extraRad = 20
    @radRate = 1.3
    @hue = (@hue + 5) % 360

  draw: ->
    # @extraRad *= @radRate * @decayRate
    # @extraRad = constrain(@extraRad, 0.01, @maxDiameter)

    # @radRate *= 0.98
    # @radRate = constrain(@radRate, 0.9, 1.5)

    # dia = @diameter + @extraRad

    # fill(color(@hue, 50, 50, 50))
    # noStroke()
    # ellipse(windowWidth / 4, windowHeight / 4, dia, dia)


selectSong = (e) ->
  src = e.target.getAttribute('data-src')
  mp3 = "#{src}.mp3"
  json = "#{src}.json"

  loadJSON(json, jsonLoaded)

  audioEl.stop() if audioEl
  audioEl = createAudio(mp3)
  fft.setInput(audioEl)

triggerBeat = ->
  theBeat.triggerBeat()


renderWaveform = (waveform) ->
  noFill()
  # stroke(globalHue, 20, 32, 50)
  stroke('rgba(18, 57, 98, 0.7)')
  beginShape()
  strokeJoin(ROUND)
  strokeCap(ROUND)
  strokeWeight(canvasSize / 55)
  # drawingContext.shadowBlur = 0;
  for wave, i in waveform
    x = map(i, 0, waveform.length, 0, canvasSize + 60)
    y = map(wave, -1, 1, canvasSize - (canvasSize / 5), canvasSize + (canvasSize / 5))
    vertex(x, y)
  endShape()

renderBars = (waveform) ->
  # stroke(globalHue, 40, 40)
  stroke('rgba(68, 130, 162, 0.7)')
  strokeWeight(height / 280)

  for wave, i in waveform
    x = map(i, 0, waveform.length, 0, canvasSize)
    y = (-(r + wave * (canvasSize / 5))) * (wave * 1.2) + canvasSize
    x2 = x
    y2 = height + 5
    # console.log(x, y, x2, y2) if ~~(Math.random() * 1000) == 2
    line(x, y, x2, y2)

# beats cycle the global hue
scheduleBeats = (beats) ->
  for beat in beats
    # audioEl.addCue(beat.start, triggerBeat)
    audioEl.addCue beat.start, ->
      star.diameter += 3 for star in theNebula.stars

      globalHue = globalHue + globalHueModifier
      if globalHue > MAX_GLOBAL_HUE || globalHue < MIN_GLOBAL_HUE
        globalHueModifier = -globalHueModifier

# bars trigger shooting stars
# bars with a high confidence may spawn nebulae?
scheduleBars = (bars) ->
  for bar in bars
    audioEl.addCue bar.start, ->
      lum = map(globalHue, MIN_GLOBAL_HUE, MAX_GLOBAL_HUE, 12, 18)
      background(color(globalHue, 80, lum, 18))
      new ShootingStar(bar.duration * 3) for i in [0..1]

# sections will spawn nebulae
scheduleSections = (sections) ->
  for section in sections
    audioEl.addCue section.start, ->
      console.log 'section', section

jsonLoaded = (json) ->
  console.log('boom', json)
  scheduleBars(json.bars)
  scheduleBeats(json.beats)
  scheduleSections(json.sections)
  audioEl.elt.volume = 0.9
  audioEl.play()

theBeat = null
theNebula = null
window.setup = ->
  canvasSize = Math.min(window.innerWidth, window.innerHeight) * 0.92
  document.getElementById('album-art').style.width = "#{canvasSize}px"

  theBeat = new Beat()
  theNebula = new Nebula()

  background(2)
  fft = new p5.FFT(0.8, 128)

  angleMode(DEGREES)
  colorMode(HSB, 360, 100, 100, 100)
  createCanvas(canvasSize, canvasSize)

  for song in document.querySelectorAll('.song')
    song.addEventListener 'click', selectSong

window.draw = ->
  curDate = Date.now()

  lum = map(globalHue, MIN_GLOBAL_HUE, MAX_GLOBAL_HUE, 12, 18)
  background(color(globalHue, 80, lum, 6))

  waveform = fft.waveform()
  renderWaveform(waveform)
  renderBars(waveform)

  theBeat.draw()
  nebula?.draw() for nebula in nebulae
  shootingStar?.draw(curDate) for shootingStar in shootingStars
  return null

