import strutils
import options

import graph

const boardSize* = 9
const initialNumberWalls = 10

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
    Player* = object
        turn: Turn
        walls*: int
        position*: Position
    Wall* = object
        wallType*: WallType
        position*: Position
    Quoridor* = object
        turn: Turn
        players*: array[Turn, Player]
        board: Graph
        numPlacedWalls: int
        wallGraph: Graph
        walls*: seq[Wall]
    IllegalMoveError* = object of CatchableError

# helpers
func nextTurn(turn: Turn): Turn =
    case turn
        of player1:
            player2
        of player2:
            player1

func plusDirection(pos: Position, dir: Direction): Position =
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

func inBound(position: Position): bool =
    let (x, y) = position
    return 0 <= x and x < boardSize and 0 <= y and y < boardSize

func toNodeIndex(x, y: int): int =
    return x + boardSize * y

func toNodeIndex(pos: (int, int)): int =
    let (x, y) = pos
    return toNodeIndex(x, y)

func endPosition(t: Turn): seq[Position] =
    let y = case t
        of player1: 8
        of player2: 0
    for i in 0..<boardSize:
        result.add((i, y))

func hasPathToEnd(board: var Graph, position: Position, turn: Turn): bool =
    let p = position.toNodeIndex
    for e in turn.endPosition:
        let endIndex = e.toNodeIndex
        if board.hasPathBetween(p, endIndex):
            return true
    return false

func canPutWall(board: Graph, wallGraph: Graph, ha, hb, hc, hd, va, vb, vc,
        vd: int): bool =
    # (ha, hb) and (hc, hd) will be blocked by the wall
    # (va, vb) and (vc, vd) are the orthogonal edges, useful to check intersecting walls
    let canPutWall = board.hasEdge(ha, hb) and board.hasEdge(hc, hd)
    let wallBeside = not board.hasEdge(va, vb) and not board.hasEdge(vc, vd)
    let noGapBetweenOrthogonalWalls = (wallGraph.getWeightBetween(va, vb) !=
            infinity and wallGraph.getWeightBetween(va, vb) ==
                    wallGraph.getWeightBetween(vc, vd))
    let isOtherWallBlocking = wallBeside and noGapBetweenOrthogonalWalls

    return canPutWall and not isOtherWallBlocking

func hasOtherPlayerAt(q: Quoridor, t: Turn, pos: Position): bool =
    for turn in Turn:
        if turn != t:
            let player = q.players[turn]
            if player.position.toNodeIndex == pos.toNodeIndex:
                return true
    return false

func isMoveLegal(q: Quoridor, fromPos, toPos: Position): bool =
    return toPos.inBound and q.board.hasEdge(fromPos.toNodeIndex,
            toPos.toNodeIndex)

# quoridor
func currentTurn*(q: Quoridor): Turn {.inline.} =
    q.turn

func makeQuoridor*(): Quoridor =
    var players: array[Turn, Player]
    block buildPlayers:
        const middle = boardSize div 2
        let p1 = Player(walls: initialNumberWalls, position: (middle, 0), turn: player1)
        let p2 = Player(walls: initialNumberWalls, position: (middle,
                boardSize-1), turn: player2)
        players[player1] = p1
        players[player2] = p2

    # build board graph
    var board = makeGraph(boardSize * boardSize)
    for x in 0..<boardSize:
        for y in 0..<boardSize:
            let p = (x, y)
            let i = p.toNodeIndex
            for d in Direction:
                let dp = p.plusDirection(d)
                if dp.inBound:
                    board.addEdge(i, dp.toNodeIndex)

    # build wall graph
    let wallGraph = makeGraph(boardSize * boardSize)

    Quoridor(players: players, board: board, turn: player1, numPlacedWalls: 0,
            wallGraph: wallGraph)

func move*(q: var Quoridor, direction: Direction,
           jumpDir: Option[Direction] = none[Direction]()) =
    var player = q.players[q.turn]
    let turn = player.turn
    let playerPos = player.position
    var toPos = playerPos.plusDirection(direction)

    # can make move
    if q.isMoveLegal(playerPos, toPos):
        # is it moving onto another player?
        if q.hasOtherPlayerAt(turn, toPos):
            let jumpPos = toPos.plusDirection(direction)
            # can the player jump above the other player?
            if q.isMoveLegal(toPos, jumpPos) and not q.hasOtherPlayerAt(turn, jumpPos):
                player.position = jumpPos
            # otherwise can move in diagonal, if not blocked by walls
            else:
                if jumpDir.isNone:
                    raise newException(IllegalMoveError, "no jump direction specified")
                else:
                    # try to move diagonally
                    let diagPos = toPos.plusDirection(jumpDir.get)
                    if q.isMoveLegal(toPos, diagPos) and not q.hasOtherPlayerAt(
                            turn, diagPos):
                        player.position = diagPos
                    else:
                        raise newException(IllegalMoveError,
                                "player $1 move diagonally to $2" % [$q.turn, $toPos])
        # won't move onto another player
        else:
            player.position = toPos

        q.players[q.turn] = player
        q.turn = q.turn.nextTurn
    else:
        raise newException(IllegalMoveError, "player $1 cannot move to $2" % [
                $q.turn, $toPos])

func putWall*(q: var Quoridor, wallType: WallType, x, y: int) =
    if x < 0 or y < 0 or x >= boardSize - 1 or y >= boardSize - 1:
        raise newException(IllegalMoveError, "wall out of bounds")

    let player = q.players[q.turn]
    if player.walls == 0:
        raise newException(IllegalMoveError, "not enough walls")

    var ha = (x, y).toNodeIndex
    var hb = (x, y + 1).toNodeIndex
    var hc = (x + 1, y).toNodeIndex
    var hd = (x + 1, y + 1).toNodeIndex
    var va = (x, y).toNodeIndex
    var vb = (x + 1, y).toNodeIndex
    var vc = (x, y + 1).toNodeIndex
    var vd = (x + 1, y + 1).toNodeIndex

    var board = q.board
    var wallGraph = q.wallGraph

    #  put wall
    case wallType
    of horizontal:
        if not canPutWall(board, wallGraph, ha, hb, hc, hd, va, vb, vc, vd):
            raise newException(IllegalMoveError, "wall collision")
        board.removeEdge(ha, hb)
        board.removeEdge(hc, hd)
        wallGraph.addEdge(ha, hb, q.numPlacedWalls)
        wallGraph.addEdge(hc, hd, q.numPlacedWalls)
    of vertical:
        if not canPutWall(board, wallGraph, va, vb, vc, vd, ha, hb, hc, hd):
            raise newException(IllegalMoveError, "wall collision")
        board.removeEdge(va, vb)
        board.removeEdge(vc, vd)
        wallGraph.addEdge(va, vb, q.numPlacedWalls)
        wallGraph.addEdge(vc, vd, q.numPlacedWalls)

    # check if block path of a player
    for t in Turn:
        let player = q.players[t]
        if not hasPathToEnd(board, player.position, t):
            raise newException(IllegalMoveError, "blocked player $1" % $t)

    # update q
    q.board = board
    q.wallGraph = wallGraph
    q.players[q.turn].walls.dec()
    q.turn = q.turn.nextTurn
    q.walls.add(Wall(wallType: wallType, position: (x, y)))
    q.numPlacedWalls.inc()

func winner*(q: Quoridor): Option[Turn] =
    for t in Turn:
        let p = q.players[t]
        if p.position in t.endPosition:
            return some(t)
    return none[Turn]()
