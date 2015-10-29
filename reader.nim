import game
import lexbase, streams, sets

type
  InvalidCharacter* = object of Exception
  GameParser* = object of BaseLexer
    player: Position
    walles: HashSet[Position]
    boxes: HashSet[Position]
    goals: HashSet[Position]
    width: int

proc open*(p: var GameParser, input: Stream) =
  lexbase.open(p, input)
  p.walles.init()
  p.boxes.init()
  p.goals.init()

proc close*(p: var GameParser) {.inline.} =
  lexbase.close(p)

proc parse*(p: var GameParser): Game =
  var playerInitialized = false
  var pos = p.bufpos
  while true:
    let item = (y: p.lineNumber - 1, x: p.getColNumber(pos))
    case p.buf[pos]
    of '\0':
      break
    of '#':
      p.walles.incl(item)
    of '.':
      p.goals.incl(item)
    of '$':
      p.boxes.incl(item)
    of '@':
      if playerInitialized:
        raise newException(InvalidCharacter, "ambiguous player itemition.")
      p.player = item
      playerInitialized = true
    of '+':
      if playerInitialized:
        raise newException(InvalidCharacter, "ambiguous player itemition.")
      p.player = item
      playerInitialized = true
      p.goals.incl(item)
    of '*':
      p.boxes.incl(item)
      p.goals.incl(item)
    of ' ':
      discard
    of '\c':
      pos = p.handleCR(pos)
      if p.width < item.x:
        p.width = item.x
      continue
    of '\L':
      pos = p.handleLF(pos)
      if p.width < item.x:
        p.width = item.x
      continue
    else:
      raise newException(InvalidCharacter, "invalid character: " & $p.buf[pos])

    inc(pos)

  result = newGame(p.player, p.walles, p.boxes, p.goals, p.width, p.lineNumber - 1)
