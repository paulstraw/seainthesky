MIN_GLOBAL_HUE = 210
MAX_GLOBAL_HUE = 290

audioEl = null
shootingStars = []
globalHue = MIN_GLOBAL_HUE
globalHueModifier = 4
fft = null
r = 1

class StarParticle
  constructor: ->


  draw: (starX, starY) =>
    # TODO: bias toward the opposite direction the star is moving, to create a tail?

    x = randomGaussian(starX, 4)
    y = randomGaussian(starY, 4)

    fill(color(230, 10, 95, 12))
    ellipse(x, y, 1, 1)


class ShootingStar
  constructor: (maxAge) ->
    @maxAge = maxAge * 1000 # convert maxAge to milliseconds
    @birth = Date.now()
    shootingStars.push(this)

    @x = ~~(Math.random() * width) + (width / 10)
    @y = -(~~(Math.random() * 100) + 20)
    # @velX = -(Math.random() * 1.1) - 0.4
    @velY = (Math.random() * 2) + 0.6
    @velX = -@velY
    @alpha = 40
    @diameter = 9

    @starParticles = []
    @starParticles.push new StarParticle() for i in [1..50]

  draw: =>
    @alpha -= 1 if Date.now() - @birth > @maxAge
    if @alpha == 0
      @kill()
      return

    @x += @velX
    @y += @velY
    @diameter -= 0.02

    fill(color(230, 10, 95, @alpha))
    noStroke()
    ellipse(@x, @y, @diameter, @diameter)
    # drawingContext.shadowOffsetX = 0;
    # drawingContext.shadowOffsetY = 0;
    # drawingContext.shadowBlur = 5;
    # drawingContext.shadowColor = 'rgba(255, 255, 255, 0.75)';

    particle.draw(@x, @y) for particle in @starParticles

  kill: =>
    @starParticles = []
    shootingStars.splice(shootingStars.indexOf(this), 1)

class Nebula
  constructor: ->



class Beat
  constructor: ->
    @diameter = 60
    @decayRate = 1.3
    @extraRad = 1
    @radRate = 1
    @maxDiameter = Math.min(window.innerWidth, window.innerHeight) / 3
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

theBeat = new Beat()


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
  beginShape()
  stroke(globalHue, 20, 32, 50)
  strokeJoin(ROUND)
  strokeCap(ROUND)
  strokeWeight(height / 55)
  # drawingContext.shadowBlur = 0;
  for wave, i in waveform
    x = map(i, 0, waveform.length, 0, width + 60)
    y = map(wave, -1, 1, 0, height / 3)
    vertex(x, y + (height / 3))
  endShape()

renderBars = (waveform) ->
  stroke(globalHue, 40, 40)
  strokeWeight(height / 280)

  for wave, i in waveform
    x = map(i, 0, waveform.length, 0, width)
    y = (-(r + wave * 200)) * (wave * 1.2) + height / 2
    x2 = x
    y2 = (r + wave * 200) * (wave * 1.2) + height / 2
    # console.log(x, y, x2, y2) if ~~(Math.random() * 1000) == 2
    line(x, y, x2, y2)

# beats cycle the global hue
scheduleBeats = (beats) ->
  for beat in beats
    # audioEl.addCue(beat.start, triggerBeat)
    audioEl.addCue beat.start, ->
      globalHue = globalHue + globalHueModifier
      if globalHue > MAX_GLOBAL_HUE || globalHue < MIN_GLOBAL_HUE
        globalHueModifier = -globalHueModifier

# bars with a high enough confidence will trigger shooting stars
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
  audioEl.play()

window.setup = ->
  background(2)
  fft = new p5.FFT(0.8, 128)

  angleMode(DEGREES)
  colorMode(HSB, 360, 100, 100, 100)
  createCanvas(windowWidth, windowHeight)

  for song in document.querySelectorAll('.song')
    song.addEventListener 'click', selectSong

window.draw = ->
  lum = map(globalHue, MIN_GLOBAL_HUE, MAX_GLOBAL_HUE, 12, 18)
  background(color(globalHue, 80, lum, 6))

  waveform = fft.waveform()
  renderWaveform(waveform)
  renderBars(waveform)

  theBeat.draw()
  shootingStar?.draw() for shootingStar in shootingStars
  return null

