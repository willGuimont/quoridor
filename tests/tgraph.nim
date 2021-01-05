import unittest

import game/graph

const numNode = 4

test "no edge in empty graph":
    const emptyGraph = makeGraph(numNode)
    for i in 0..<numNode:
        for j in 0..<numNode:
            check emptyGraph.hasEdge(i, j) == false

test "addEdge sets weight":
    var graph = makeGraph(numNode)
    graph.addEdge(0, 1)
    graph.addEdge(1, 2, 5)
    check graph.getWeightBetween(0, 1) == 1
    check graph.getWeightBetween(1, 2) == 5

test "addEdge then hasEdge":
    var graph = makeGraph(numNode)
    graph.addEdge(1, 2)
    check graph.hasEdge(1, 2)
    check graph.hasEdge(2, 1)

test "removeEdge then no longer hasEdge":
    var graph = makeGraph(numNode)
    graph.addEdge(1, 2)
    graph.removeEdge(1, 2)
    check graph.hasEdge(1, 2) == false
    check graph.hasEdge(2, 1) == false

test "hasPathBetween":
    var graph = makeGraph(numNode)
    graph.addEdge(0, 1)
    graph.addEdge(1, 2)
    check graph.hasPathBetween(0, 2)
    check graph.hasPathBetween(0, 3) == false

test "getPathLenght":
    var graph = makeGraph(numNode)
    graph.addEdge(0, 1, 3)
    graph.addEdge(1, 2, 5)
    check graph.getPathLenght(0, 2) == 8
