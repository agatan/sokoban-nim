import sets

type
  Direction* = enum
    dirUp,
    dirDown,
    dirLeft,
    dirRight

  # left and up origin
  Position* = tuple[row: int, col: int]

  Game* = ref object
    playerPos*: Position
    playerDir*: Direction
    walles*: HashSet[Position]
    boxes*: HashSet[Position]
    goals*: HashSet[Position]

const
  diroffset: array[Direction, (int, int)] = [
    (0, -1),
    (0, 1),
    (-1, 0),
    (1, 0)
  ]

proc nextTo(pos: Position, dir: Direction): Position =
  let (dx, dy) = diroffset[dir]
  result = (row: pos.row + dx, col: pos.col + dy)

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
