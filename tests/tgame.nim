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

test "can jump over":
    var q = makeQuoridor()
    for _ in 1..7:
        q.move(north)
        q.move(south)
    check q.winner == some(player2)

test "cannot jump if wall":
    var q = makeQuoridor()
    for _ in 1..3:
        q.move(north)
        q.move(south)
    q.move(north)
    q.putWall(horizontal, 3, 5)
    expect ValueError:
        q.move(north)

test "cannot jump but can go diagonal":
    var q = makeQuoridor()
    for _ in 1..3:
        q.move(north)
        q.move(south)
    q.move(north)
    q.putWall(horizontal, 3, 5)
    q.move(north, some(east))

test "cannot jump wall in way of diagonal":
    var q = makeQuoridor()
    for _ in 1..3:
        q.move(north)
        q.move(south)
    q.move(north)
    q.putWall(horizontal, 3, 5)
    q.putWall(vertical, 4, 5)
    q.putWall(horizontal, 0, 0)
    expect ValueError:
        q.move(north, some(east))

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
    check q.players[q.currentTurn].walls == 10

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

    check q.players[player1].walls == 10 - 2

test "cannot put walls when 0 wall":
    var q = makeQuoridor()
    for i in 0..7:
        q.putWall(vertical, i, 0)
        q.putWall(vertical, i, 7)
    for i in 1..2:
        q.putWall(vertical, i, 2)
        q.putWall(vertical, i, 5)
    expect ValueError:
        q.putWall(vertical, 3, 2)
    check q.currentTurn == player1

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
