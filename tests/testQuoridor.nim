import unittest

import quoridor/quoridor

test "can move":
    var q = makeQuoridor()
    check q.currentTurn == PLAYER_1
    q.move(5, 1)
    check q.currentTurn == PLAYER_2
    q.move(6, 8)
    check q.currentTurn == PLAYER_1

test "exception when bad move":
    var q = makeQuoridor()
    expect ValueError:
        q.move(6, 1)
  
