import nimgl/[glfw, opengl]
import glm
import opengl/glut

import strutils
import options

import game/game

const screenWidth = 600
const screenHeight = 600

func toRGB(vec: Vec3[float32]): Vec3[float32] =
    return vec3(vec.x / 255, vec.y / 255, vec.z / 255)

func toScreenSpace(x: SomeNumber): float {.inline.} =
    2 * x / boardSize - 1

const offset = 5.toScreenSpace

proc drawText(x, y: float, text: string, font: pointer) =
    glRasterPos2f(x, y)
    for c in text:
        glutBitmapCharacter(font, int(c))

proc draw(q: Quoridor) =
    glPushMatrix()
    glScalef(0.75, 0.75, 1)

    # grid
    glLineWidth(1.0)
    glBegin(GL_LINES);
    glColor3f(1.0, 1.0, 1.0)
    for i in 0..boardSize:
        let x = 2 * i / boardSize - 1

        # vertical lines
        glVertex2f(x, -1.1);
        glVertex2f(x, 1);

        # horizontal lines
        glVertex2f(-1.1, x);
        glVertex2f(1, x);

    glEnd();

    # text
    for i in 1..<boardSize:
        let x = 2 * i / boardSize - 0.975
        glRasterPos2f(x, -1.1)
        glutBitmapCharacter(GLUT_BITMAP_9_BY_15, int('A') + i - 1)
        glRasterPos2f(-1.1, x)
        glutBitmapCharacter(GLUT_BITMAP_9_BY_15, int('1') + i - 1)

    # walls
    glLineWidth(5.0)
    glBegin(GL_LINES);
    glColor3f(1.0, 1.0, 1.0)
    for w in q.walls:
        let (px, py) = w.position
        let (x, y) = (px.float, py.float)
        let t = w.wallType

        var a, b, c, d: float
        case t
        of horizontal:
            (a, b) = (x + 0.1, y + 1)
            (c, d) = (x + 2 - 0.1, y + 1)
        of vertical:
            (a, b) = (x + 1, y + 0.1)
            (c, d) = (x + 1, y + 2 - 0.1)
        glVertex2f(a.toScreenSpace, b.toScreenSpace);
        glVertex2f(c.toScreenSpace, d.toScreenSpace);

    glEnd()

    # players shape
    glPointSize(20)
    glBegin(GL_POINTS)
    for p in q.players:
        let (x, y) = p.position
        glVertex2f(x.toScreenSpace + offset, y.toScreenSpace + offset);

    glEnd()

    # player number
    glColor3f(0, 0, 0)
    for i, p in q.players.pairs:
        let (x, y) = p.position
        glRasterPos2f(x.toScreenSpace + offset * 0.8, y.toScreenSpace + offset * 0.8)
        glutBitmapCharacter(GLUT_BITMAP_9_BY_15, int('1') + int(i))

    glPopMatrix()

proc drawLegend(q: Quoridor, input: string) =
    # legend
    glColor3f(1, 1, 1)
    drawText(-0.9, 0.9, "Player 1   Walls: $1" % [$q.players[player1].walls], GLUT_BITMAP_TIMES_ROMAN_24)
    drawText(-0.9, 0.8, "Player 2   Walls: $1" % [$q.players[player2].walls], GLUT_BITMAP_TIMES_ROMAN_24)

    # turn indicator
    let y = case q.currentTurn:
        of player1: 0.9
        of player2: 0.8
    drawText(-0.95, y, "*", GLUT_BITMAP_TIMES_ROMAN_24)

    # user input
    drawText(-0.9, -0.95, input, GLUT_BITMAP_TIMES_ROMAN_24)

func parseMove(input: string, i: int): Option[Direction] =
    if i >= input.len:
        none[Direction]()
    else:
        case input[i]
        of 'N': some(north)
        of 'S': some(south)
        of 'E': some(east)
        of 'W': some(west)
        else: none[Direction]()

func play(q: var Quoridor, input: string) =
    let n = input.len
    if n == 2 or n == 3 and input[0] == 'M':
        let direction = input.parseMove(1)
        if direction.isNone:
            return
        let jumpDir = input.parseMove(2)

        q.move(direction.get, jumpDir)
    elif n == 3:
        let orientation = case input[0]
            of 'H': horizontal
            of 'V': vertical
            else: return

        let col = input[1]
        let row = input[2]

        if col in 'A'..'H' and row in '1'..'8':
            let x = int(col) - int('A')
            let y = int(row) - int('1')

            q.putWall(orientation, x, y)

var q = makeQuoridor()
var input: string
proc keyfunc(window: GLFWWindow, key: int32, scancode: int32, action: int32,
        mods: int32): void {.cdecl.} =
    if key == GLFWKey.Enter and action == GLFWPress:
        try:
            q.play(input)
        except IllegalMoveError:
            discard
        finally:
            input = ""
    elif key == GLFWKey.Backspace and action == GLFWPress:
        if len(input) > 0:
            input = input[0..^2] # erase character
    elif ((GLFWKey.A <= key and key <= GLFWKey.Z) or (GLFWKey.K1 <= key and
            key <= GLFWKey.K8)) and input.len <= 2 and action == GLFWPress:
        input.add(char(key))

proc main =
    echo "Move: \t\t\tM{N | S | E | W}"
    echo "Horizontal wall: \tH{A-H}{1-8}"
    echo "Vertical wall: \t\tH{A-H}{1-8}"

    # glfw
    doAssert glfwInit()

    glfwWindowHint(GLFWContextVersionMajor, 2)
    glfwWindowHint(GLFWContextVersionMinor, 1)
    glfwWindowHint(GLFWResizable, GLFW_FALSE)

    let w: GLFWWindow = glfwCreateWindow(screenWidth, screenHeight, "Quoridor",
            nil, nil)
    doAssert w != nil

    discard w.setKeyCallback(keyfunc)
    w.makeContextCurrent

    # opengl
    doAssert glInit()

    glEnable(GL_BLEND)
    glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA)

    # glut
    glutInit()

    # game loop
    let bg = vec3(33f, 33f, 33f).toRgb()
    while not w.windowShouldClose:
        # update
        let winner = q.winner
        if winner.isSome:
            w.setWindowShouldClose(true)
            echo "-----"
            echo "Winner is $1" % [$winner.get]

        # draw
        glClearColor(bg.r, bg.g, bg.b, 1f)
        glClear(GL_COLOR_BUFFER_BIT)

        q.drawLegend(input)
        q.draw()

        w.swapBuffers
        glfwPollEvents()

    w.destroyWindow
    glfwTerminate()

when isMainModule:
    main()
