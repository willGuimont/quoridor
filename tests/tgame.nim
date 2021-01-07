import unittest
import options

import game/game

test "can move":
    var q = makeQuoridor()
    check q.currentTurn == player1
    q.move(north)
    check q.currentTurn == player2
    q.move(south)
    check q.currentTurn == player1

test "exception when bad move":
    var q = makeQuoridor()
    expect ValueError:
        q.move(south)
    check q.currentTurn == player1

test "exception when wall collision":
    var q = makeQuoridor()
    q.putWall(horizontal, 5, 0)
    expect ValueError:
        q.putWall(horizontal, 5, 0)
    check q.currentTurn == player2
    check q.players[q.currentTurn].walls == 20

test "wall boundary cases":
    var q = makeQuoridor()
    expect ValueError:
        q.putWall(horizontal, -1, 5)
    expect ValueError:
        q.putWall(horizontal, 5, -1)
    expect ValueError:
        q.putWall(horizontal, 8, 5)
    expect ValueError:
        q.putWall(horizontal, 5, 8)

    expect ValueError:
        q.putWall(vertical, -1, 5)
    expect ValueError:
        q.putWall(vertical, 5, -1)
    expect ValueError:
        q.putWall(vertical, 8, 5)
    expect ValueError:
        q.putWall(vertical, 5, 8)

test "exception when wall intersect wall":
    var q = makeQuoridor()
    q.putWall(horizontal, 4, 4)
    expect ValueError:
        q.putWall(vertical, 4, 4)

test "can put wall in between walls":
    var q = makeQuoridor()
    q.putWall(horizontal, 0, 0)
    q.putWall(horizontal, 2, 0)
    q.putWall(vertical, 1, 0)

    q = makeQuoridor()
    q.putWall(vertical, 0, 0)
    q.putWall(vertical, 0, 2)
    q.putWall(horizontal, 0, 1)

test "put wall block movement":
    var q = makeQuoridor()
    q.putWall(horizontal, 3, 7)
    expect ValueError:
        q.move(south)

test "cannot block players":
    var q = makeQuoridor()
    q.putWall(vertical, 2, 0)
    q.putWall(horizontal, 3, 1)
    expect ValueError:
        q.putWall(vertical, 4, 0)

test "put wall consummes wall":
    var q = makeQuoridor()
    q.putWall(horizontal, 2, 0)
    q.putWall(horizontal, 6, 6)
    q.putWall(horizontal, 5, 5)

    check q.players[player1].walls == 20 - 2

test "game end":
    var q = makeQuoridor()
    check q.winner == none[Turn]()
    q.move(north)
    q.move(east)
    q.move(north)
    q.move(east)
    q.move(north)
    q.move(west)
    q.move(north)
    q.move(east)
    q.move(north)
    q.move(west)
    q.move(north)
    q.move(east)
    q.move(north)
    q.move(west)
    q.move(north)
    check q.winner == some(player1)
