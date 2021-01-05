import strutils
import graph

const boardSize = 9
const middle = 5
const initialNumberWalls = 20

type
    Position = (int, int)
    Turn* = enum
        player1
        player2
    WallType* = enum
        horizontal
        vertical
    Direction* = enum
        north
        south
        east
        west
    Player = object
        walls: int
        position: Position
    Quoridor = object
        turn: Turn
        players: array[Turn, Player]
        board: Graph

# Helper
proc nextTurn(turn: Turn) : Turn =
    case turn
        of player1:
            player2
        of player2:
            player1

proc plusDirection(pos: Position, dir: Direction) : Position =
    let (x, y) = pos
    case dir
    of north:
        (x, y + 1)
    of south:
        (x, y - 1)
    of east:
        (x + 1, y)
    of west:
        (x - 1, y)

proc inBound(position: Position) : bool =
    let (x, y) = position
    return 0 <= x and x < boardSize and 0 <= y and y < boardSize

proc toNodeIndex(x, y: int) : int =
    return x + boardSize * y

proc toNodeIndex(pos: (int, int)) : int =
    let (x, y) = pos
    return toNodeIndex(x, y)

proc hasPathToEnd(board: var Graph, position: Position, turn: Turn): bool =
    let p = position.toNodeIndex
    for x in 0..<boardSize:
        let endIndex = (case turn
            of player1:
               (x, boardSize - 1)
            of player2:
               (x, 0)).toNodeIndex
        if board.hasPathBetween(p, endIndex):
            return true
    return false

# Quoridor
proc currentTurn*(q: Quoridor): Turn {.inline.} =
    q.turn

proc makeQuoridor*() : Quoridor =
    var players: array[Turn, Player]
    block:
        let p1 = Player(walls: initialNumberWalls, position: (middle, 0))
        let p2 = Player(walls: initialNumberWalls, position: (middle, boardSize-1))
        players[player1] = p1
        players[player2] = p2
    var board = makeGraph(boardSize*boardSize)
    for x in 0..<boardSize:
        for y in 0..<boardSize:
            let p = (x, y)
            let i = p.toNodeIndex
            for d in Direction:
                let dp = p.plusDirection(d)
                if dp.inBound:
                    board.addEdge(i, dp.toNodeIndex)
    result = Quoridor(players:players, board:board, turn:player1)

proc move*(q: var Quoridor, direction: Direction) =
    # TODO handle Face To Face
    var player = q.players[q.turn]
    var pos = player.position.plusDirection(direction)
    if pos.inBound and q.board.hasEdge(player.position.toNodeIndex, pos.toNodeIndex):
        player.position = pos
        q.players[q.turn] = player
        q.turn = q.turn.nextTurn
    else:
        raise newException(ValueError, "player $1 cannot move to $2" % [$q.turn, $pos])    

proc putWall*(q: var Quoridor, wallType: WallType, x, y: int) =
    if x < 0 or y < 0 or x >= boardSize - 1 or y >= boardSize - 1:
        raise newException(ValueError, "wall out of bounds")
    var ha = (x, y).toNodeIndex
    var hb = (x, y + 1).toNodeIndex
    var hc = (x + 1, y).toNodeIndex
    var hd = (x + 1, y + 1).toNodeIndex
    var va = (x, y).toNodeIndex
    var vb = (x + 1, y).toNodeIndex
    var vc = (x, y + 1).toNodeIndex
    var vd = (x + 1, y + 1).toNodeIndex

    var board = q.board
    case wallType
    of horizontal:
        if not board.hasEdge(ha, hb) or not board.hasEdge(hc, hd) or (not board.hasEdge(va, vb) and not board.hasEdge(vc, vd)):
            raise newException(ValueError, "wall collision")
        board.removeEdge(ha, hb)
        board.removeEdge(hc, hd)
    of vertical:
        if not board.hasEdge(va, vb) or not board.hasEdge(vc, vd) or (not board.hasEdge(ha, hb) and not board.hasEdge(hc, hd)):
            raise newException(ValueError, "wall collision")
        board.removeEdge(va, vb)
        board.removeEdge(vc, vd)
    
    for t in Turn:
        let player = q.players[t]
        if not hasPathToEnd(q.board, player.position, t):
            raise newException(ValueError, "blocked player $1" % $t)

    q.board = board
    q.turn = q.turn.nextTurn
