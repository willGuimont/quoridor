import sequtils
import options

const infinity* = high(int)

type
    Graph* = object
        graph: seq[seq[int]]
        floyd: Option[seq[seq[int]]]

func makeGraph*(numNode: int): Graph =
    let g = newSeqWith(numNode, repeat(infinity, numNode))
    result = Graph(graph: g, floyd: none(seq[seq[int]]))

func addEdge*(graph: var Graph, a, b: int, weight: int = 1) =
    graph.graph[a][b] = weight
    graph.graph[b][a] = weight
    graph.floyd = none(seq[seq[int]])

func removeEdge*(graph: var Graph, a, b: int) =
    graph.graph[a][b] = infinity
    graph.graph[b][a] = infinity
    graph.floyd = none(seq[seq[int]])

func getWeightBetween*(graph: Graph, a, b: int): int =
    return graph.graph[a][b]

func hasEdge*(graph: Graph, a, b: int): bool =
    graph.getWeightBetween(a, b) != infinity

func createFloydIfNone(graph: var Graph) =
    if isNone(graph.floyd):
        var D = graph.graph
        let n = len(graph.graph) - 1

        for k in 0..n: # intermediate node
            for i in 0..n: # starting node
                for j in 0..n: # end node
                    let otherPath = if D[i][k] == infinity or D[k][j] == infinity:
                            infinity
                        else:
                            D[i][k] + D[k][j]
                    D[i][j] = min(D[i][j], otherPath)
        graph.floyd = some(D)

func getPathLenght*(graph: var Graph, a, b: int): int =
    createFloydIfNone(graph)
    return graph.floyd.get[a][b]

func hasPathBetween*(graph: var Graph, a, b: int): bool =
    graph.getPathLenght(a, b) != infinity
