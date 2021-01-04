import strutils
import graph

const boardSize = 9
const middle = 5
const initialNumberWalls = 20

type
    Position = (int, int)
    Player = object
        walls: int
        position: Position
    Turn = enum
        PLAYER_1
        PLAYER_2
    Quoridor = object
        turn: Turn
        players: array[Turn, Player]
        board: Graph

proc xyToNodeIndex(x, y: int) : int =
    return x + boardSize * y

proc posToNodeIndex(pos: (int, int)) : int =
    let (x, y) = pos
    return xyToNodeIndex(x, y)

proc makeQuoridor*() : Quoridor =
    var players: array[Turn, Player]
    block:
        let player1 = Player(walls: initialNumberWalls, position: (middle, 0))
        let player2 = Player(walls: initialNumberWalls, position: (middle, boardSize-1))
        players[PLAYER_1] = player1
        players[PLAYER_2] = player2
    var board = makeGraph(boardSize*boardSize)
    for x in 0..<boardSize:
        for y in 0..<boardSize:
            let i = xyToNodeIndex(x, y)
            if x - 1 >= 0: 
                board.addEdge(i, xyToNodeIndex(x - 1, y))
            if x + 1 < boardSize: 
                board.addEdge(i, xyToNodeIndex(x + 1, y))
            if y - 1 >= 0: 
                board.addEdge(i, xyToNodeIndex(x, y - 1))
            if y + 1 < boardSize: 
                board.addEdge(i, xyToNodeIndex(x, y + 1))
    result = Quoridor(players:players, board:board, turn:PLAYER_1)

proc hasPathToEnd(board: var Graph, position: Position, turn: Turn): bool =
    let p = position.posToNodeIndex
    for x in 0..<boardSize:
        let endIndex = (case turn
            of PLAYER_1:
               (x, boardSize - 1)
            of PLAYER_2:
               (x, 0)).posToNodeIndex
        if board.hasPathBetween(p, endIndex):
            return true
    return false
    
        

proc move*(q: var Quoridor, turn: Turn, x, y: int) =
    var player = q.players[turn]
    var pos = (x, y)
    if q.board.hasEdge(player.position.posToNodeIndex, pos.posToNodeIndex) and hasPathToEnd(q.board, player.position, q.turn):
        player.position = pos
        q.players[turn] = player
        q.turn = case q.turn
            of PLAYER_1:
                PLAYER_2
            of PLAYER_2:
                PLAYER_1
    else:
        raise newException(ValueError, "player $1 cannot move to $2" % [$turn, $pos])    
