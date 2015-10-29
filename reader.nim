import game
import lexbase, streams, sets

type
  InvalidCharacter* = object of Exception
  GameParser* = object of BaseLexer
    player: Position
    walles: HashSet[Position]
    boxes: HashSet[Position]
    goals: HashSet[Position]

proc open*(p: var GameParser, input: Stream) =
  lexbase.open(p, input)
  p.walles.init()
  p.boxes.init()
  p.goals.init()

proc close*(p: var GameParser) {.inline.} =
  lexbase.close(p)

proc getColumn(p: GameParser): int {.inline.} =
  result = getColNumber(p, p.bufpos)

proc getLine(p: GameParser): int {.inline.} =
  result = p.lineNumber

proc parse*(p: var GameParser): Game =
  var playerInitialized = false
  while true:
    let pos = (row: p.getLine(), col: p.getColumn())
    case p.buf[p.bufpos]
    of '\0':
      break
    of '#':
      p.walles.incl(pos)
    of '.':
      p.goals.incl(pos)
    of '$':
      p.boxes.incl(pos)
    of '@':
      if playerInitialized:
        raise newException(InvalidCharacter, "ambiguous player position.")
      p.player = pos
      playerInitialized = true
    of '+':
      if playerInitialized:
        raise newException(InvalidCharacter, "ambiguous player position.")
      p.player = pos
      playerInitialized = true
      p.goals.incl(pos)
    of '*':
      p.boxes.incl(pos)
      p.goals.incl(pos)
    of ' ':
      discard
    else:
      raise newException(InvalidCharacter, "invalid character: " & $p.buf[p.bufpos])

    inc(p.bufpos)

  result = newGame(p.player, p.walles, p.boxes, p.goals)
