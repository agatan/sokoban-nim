import sets

type
  Direction* = enum
    dirUp,
    dirDown,
    dirLeft,
    dirRight

  # left and up origin
  Position* = tuple[y: int, x: int]

  Game* = object
    playerPos*: Position
    playerDir*: Direction
    walles*: HashSet[Position]
    boxes*: HashSet[Position]
    goals*: HashSet[Position]
    width*, height*: int

const
  diroffset: array[Direction, (int, int)] = [
    (-1, 0),
    (1, 0),
    (0, -1),
    (0, 1)
  ]

proc newGame*(playerPos: Position, walles, boxes, goals: HashSet[Position], width, height: int): Game =
  result.playerPos = playerPos
  result.walles = walles
  result.boxes = boxes
  result.goals = goals
  result.playerDir = dirDown
  result.width = width
  result.height = height

proc nextTo(pos: Position, dir: Direction): Position =
  let (dx, dy) = diroffset[dir]
  result = (y: pos.y + dx, x: pos.x + dy)

proc isFree(game: Game, pos: Position): bool =
  result = not game.boxes.contains(pos) and not game.walles.contains(pos) and game.playerPos != pos

proc changePlayerDir(game: var Game, dir: Direction) =
  game.playerDir = dir

proc movePlayer(game: var Game, pos: Position) =
  game.playerPos = pos

proc moveBox(game: var Game, frm, to: Position) =
  game.boxes.incl(to)
  game.boxes.excl(frm)

proc move*(game: var Game, dir: Direction) =
  game.changePlayerDir(dir)
  let nextPos = nextTo(game.playerPos, dir)
  if game.walles.contains(nextPos):
    return
  if game.boxes.contains(nextPos):
    let nextBoxPos = nextTo(nextPos, dir)
    if not game.isFree(nextBoxPos):
      return
    game.moveBox(nextPos, nextBoxPos)
  game.movePlayer(nextPos)

proc isGameClear*(game: Game): bool =
  result = game.boxes == game.goals
