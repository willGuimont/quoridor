import unittest

import game/graph

const numNode = 4

test "no edge in empty graph":
    const emptyGraph = makeGraph(numNode)
    for i in 0..<numNode:
        for j in 0..<numNode:
            check emptyGraph.hasEdge(i, j) == false

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
