import game, reader

import sdl2, sdl2/gfx

import unsigned, os, streams, sets

const
  rectSize = 50

proc renderGame(game: Game, render: var RendererPtr) =
  render.setDrawColor(255, 255, 255, 255)
  render.clear()

  render.setDrawColor(0, 0, 0, 255)
  for wall in game.walles.items():
    var rect = (x: cint(wall.x * rectSize), y: cint(wall.y * rectSize), w: cint(rectSize), h: cint(rectSize))
    render.fillRect(rect)

  render.setDrawColor(150, 150, 255, 255)
  for goal in game.goals.items():
    var rect = (x: cint(goal.x * rectSize), y: cint(goal.y * rectSize), w: cint(rectSize), h: cint(rectSize))
    render.fillRect(rect)

  render.setDrawColor(255, 150, 255, 255)
  for box in game.boxes.items():
    var rect = (x: cint(box.x * rectSize), y: cint(box.y * rectSize), w: cint(rectSize), h: cint(rectSize))
    render.fillRect(rect)

  render.setDrawColor(150, 255, 150, 255)
  var rect = (x: cint(game.playerPos.x * rectSize), y: cint(game.playerPos.y * rectSize), w: cint(rectSize), h: cint(rectSize))
  render.fillRect(rect)

  render.present()

proc main(game: var Game) =
  discard sdl2.init(INIT_EVERYTHING)

  let
    windowWidth = cint(game.width * rectSize)
    windowHeight = cint(game.height * rectSize)

  var
    window: WindowPtr
    render: RendererPtr

  window = createWindow("SDL Skeleton", 100, 100, windowWidth, windowHeight, SDL_WINDOW_SHOWN)
  render = createRenderer(window, -1, Renderer_Accelerated or Renderer_PresentVsync or Renderer_TargetTexture)
  defer:
    window.destroy()
    render.destroy()

  var
    evt = sdl2.defaultEvent
    runGame = true
    fpsman: FpsManager
  fpsman.init

  render.setDrawColor(255, 255, 255, 255)
  render.clear()
  render.present()

  while runGame:
    while pollEvent(evt):
      case evt.kind
      of QuitEvent:
        runGame = false
        break
      of KeyDown:
        let kv = key(evt)
        case kv.keysym.sym:
        of K_ESCAPE:
          runGame = false
          break
        of K_UP:
          game.move(dirUp)
        of K_DOWN:
          game.move(dirDown)
        of K_LEFT:
          game.move(dirLeft)
        of K_RIGHT:
          game.move(dirRight)
        else:
          discard
      else:
        discard

    renderGame(game, render)

    if game.isGameClear():
      break

    fpsman.delay()

when isMainModule:
  if paramCount() < 1:
    quit("no given filename")
  let filename = paramStr(1)
  var
    stream = newFileStream(string(filename), fmRead)
    parser: GameParser
  parser.open(stream)
  defer: parser.close

  var game = parser.parse()

  main(game)
