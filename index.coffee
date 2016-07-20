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
isMobile = (/Android|webOS|iPhone|iPad|iPod|BlackBerry|IEMobile|Opera Mini/i).test(navigator.userAgent)
playing = false
paused = false

songs = [
  {
    title: 'Tread Lightly',
    path: './songs/treadlightly'
  },
  {
    title: 'Tamagotchi',
    path: './songs/tamagotchi'
  },
  {
    title: 'Visions',
    path: './songs/visions'
  },
  {
    title: 'Krill',
    path: './songs/krill'
  },
  {
    title: 'Serenity',
    path: './songs/serenity'
  }
]
songIndex = 0

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
    @y = -(~~(Math.random() * (canvasSize / 12)) + 20)
    @velY = ((Math.random() * 2) + 0.6) * canvasSize / 1500
    @velX = -@velY
    @alpha = 40
    maxDiameter = canvasSize / 100
    minDiameter = canvasSize / 150
    @diameter = (Math.random() * (maxDiameter - minDiameter) + minDiameter);

    @starParticles = []
    maxParticles = if isMobile then 18 else 50
    @starParticles.push new StarParticle() for i in [1..maxParticles]

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

    particle.draw(@x, @y, @diameter * 0.6) for particle in @starParticles

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
    # console.log(minRad, maxRad)
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

nextSong = ->
  songIndex += 1
  paused = false

  if songIndex >= songs.length
    songIndex = 0

  setSongTitle()

  if playing
    play()

setSongTitle = ->
  document.querySelector('.song-title').innerText = songs[songIndex].title

play = ->
  playing = true
  document.querySelector('.big-dumb-play-button').classList.add('playing')
  document.querySelector('.play-pause').classList.add('playing')

  if paused
    paused = false
    audioEl.play()
    return


  song = songs[songIndex]
  src = song.path
  mp3 = "#{src}.mp3"
  json = "#{src}.json"

  if audioEl
    audioEl.clearCues()
    audioEl.stop()
  audioEl = createAudio(mp3)

  audioEl.elt.addEventListener 'ended', nextSong, false
  audioEl.elt.addEventListener 'timeupdate', handleTimeChange, false

  audioEl.play()
  setTimeout ->
    audioEl.pause()
    fft.setInput(audioEl) unless isMobile

    setTimeout ->
      loadJSON(json, jsonLoaded)
    , 150
  , 150

minuteSecondStringFromNumber = (num) ->
  minutes = Math.floor(num / 60)
  seconds = Math.round(num % 60)
  seconds = '0' + seconds if seconds < 10

  "#{minutes}:#{seconds}"


handleTimeChange = ->
  percentComplete = 0
  if audioEl.elt.currentTime > 0
    percentComplete = (100 / audioEl.elt.duration) * audioEl.elt.currentTime

  curTime = minuteSecondStringFromNumber(audioEl.elt.currentTime)
  duration = minuteSecondStringFromNumber(audioEl.elt.duration)

  if audioEl.elt.duration
    document.querySelector('.timer').textContent = "#{curTime}/#{duration}"
  else
    document.querySelector('.timer').textContent = ''

  document.querySelector('.progress').style.width = "#{percentComplete}%"

pause = ->
  playing = false
  document.querySelector('.big-dumb-play-button').classList.remove('playing')
  paused = true
  document.querySelector('.play-pause').classList.remove('playing')
  audioEl.pause() if audioEl

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
# scheduleSections = (sections) ->
#   for section in sections
#     audioEl.addCue section.start, ->
#       console.log 'section', section

jsonLoaded = (json) ->
  # console.log('boom', json)
  scheduleBars(json.bars)
  scheduleBeats(json.beats)
  # scheduleSections(json.sections)
  audioEl.elt.volume = 0.9
  audioEl.play()

theNebula = null
document.getElementById('canvas-wrapper').style.opacity = 0
console.log('hi')
window.setup = ->
  document.getElementById('canvas-wrapper').style.opacity = 1
  canvasSize = Math.min(window.innerWidth, window.innerHeight)
  document.getElementById('canvas-wrapper').style.width = "#{canvasSize}px"

  theNebula = new Nebula()

  background(2)
  fft = new p5.FFT(0.8, 128) unless isMobile

  angleMode(DEGREES)
  colorMode(HSB, 360, 100, 100, 100)
  cnv = createCanvas(canvasSize, canvasSize)
  cnv.parent('canvas-wrapper')

  for song in document.querySelectorAll('.song')
    song.addEventListener 'click', selectSong

window.windowResized = ->
  canvasSize = Math.min(window.innerWidth, window.innerHeight) * 0.92
  document.getElementById('canvas-wrapper').style.width = "#{canvasSize}px"
  resizeCanvas(canvasSize, canvasSize)
  theNebula = new Nebula()

window.draw = ->
  curDate = Date.now()

  lum = map(globalHue, MIN_GLOBAL_HUE, MAX_GLOBAL_HUE, 12, 18)
  background(color(globalHue, 80, lum, 6))

  unless isMobile
    waveform = fft.waveform()
    renderWaveform(waveform)
    renderBars(waveform)


  theNebula?.draw()
  shootingStar?.draw(curDate) for shootingStar in shootingStars
  return null

setSongTitle()
document.querySelector('.next-song').addEventListener('click', nextSong, false)
document.querySelector('.play-pause').addEventListener 'click', ->
  if playing then pause() else play()
, false

document.querySelector('.big-dumb-play-button').addEventListener 'click', ->
  if playing then pause() else play()
, false
