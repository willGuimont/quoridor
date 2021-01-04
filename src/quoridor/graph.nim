import sequtils
import options

type
    Graph* = object
        graph: seq[seq[int]]
        floyd: Option[seq[seq[int]]]

proc makeGraph*(numNode: int) : Graph =
    let g = newSeqWith(numNode, newSeq[int](numNode))
    result = Graph(graph:g, floyd:none(seq[seq[int]]))

proc addEdge*(graph: var Graph, a, b: int) =
    graph.graph[a][b] = 1
    graph.graph[b][a] = 1
    graph.floyd = none(seq[seq[int]])

proc hasEdge*(graph: Graph, a, b: int) : bool =
    return graph.graph[a][b] > 0

const infinity = high(int)
proc createFloydIfNone(graph: var Graph) =
    if isNone(graph.floyd):
        var D = graph.graph
        let n = len(graph.graph) - 1
        
        for i in 0..n:
            for j in 0..n:
                if D[i][j] == 0:
                    D[i][j] = infinity
        
        for k in 0..n:
            for i in 0..n:
                for j in 0..n:
                    let otherPath = if D[i][k] == infinity or D[k][j] == infinity:
                            infinity
                        else:
                            D[i][k] + D[k][j]
                    D[i][j] = min(D[i][j], otherPath)
        graph.floyd = some(D)

proc hasPathBetween*(graph: var Graph, a, b: int) : bool =
    createFloydIfNone(graph)
    
    echo graph.floyd
    return graph.floyd.get[a][b] != infinity
