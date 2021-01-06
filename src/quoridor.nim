import nimgl/[glfw, opengl]
import glm
import opengl/glut

import strutils

import game/game

const screenWidth = 600
const screenHeight = 600

proc toRGB(vec: Vec3[float32]): Vec3[float32] =
    return vec3(vec.x / 255, vec.y / 255, vec.z / 255)

proc toScreenSpace(x: SomeNumber): float {.inline.} =
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

    # players
    glPointSize(20)
    glBegin(GL_POINTS)
    for p in q.players:
        let (x, y) = p.position
        glVertex2f(x.toScreenSpace + offset, y.toScreenSpace + offset);
    glEnd()
    glColor3f(0, 0, 0)
    for i, p in q.players.pairs:
        let (x, y) = p.position
        glRasterPos2f(x.toScreenSpace + offset * 0.8, y.toScreenSpace +
                offset * 0.8)
        glutBitmapCharacter(GLUT_BITMAP_9_BY_15, int('1') + int(i))
    glPopMatrix()

proc drawLegend(q: Quoridor) =
    glPushMatrix()

    glColor3f(1, 1, 1)
    drawText(-0.9, 0.9, "Player 1   Walls: $1" % [$q.players[player1].walls], GLUT_BITMAP_TIMES_ROMAN_24)
    drawText(-0.9, 0.8, "Player 2   Walls: $1" % [$q.players[player2].walls], GLUT_BITMAP_TIMES_ROMAN_24)

    let (x, y) = case q.currentTurn:
        of player1: (-0.95, 0.9)
        of player2: (-0.95, 0.8)
    drawText(x, y, "*", GLUT_BITMAP_TIMES_ROMAN_24)

    glPopMatrix()

proc keyProc(window: GLFWWindow, key: int32, scancode: int32, action: int32,
    mods: int32): void {.cdecl.} =
    if key == GLFWKey.Escape and action == GLFWPress:
        window.setWindowShouldClose(true)
    if key == GLFWKey.Space:
        glPolygonMode(GL_FRONT_AND_BACK, if action !=
            GLFWRelease: GL_LINE else: GL_FILL)

proc main =
    # GLFW
    doAssert glfwInit()

    glfwWindowHint(GLFWContextVersionMajor, 2)
    glfwWindowHint(GLFWContextVersionMinor, 1)
    glfwWindowHint(GLFWResizable, GLFW_FALSE)

    let w: GLFWWindow = glfwCreateWindow(screenWidth, screenHeight, "Quoridor",
            nil, nil)
    doAssert w != nil

    discard w.setKeyCallback(keyProc)
    w.makeContextCurrent

    # Opengl
    doAssert glInit()

    glEnable(GL_BLEND)
    glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA)

    # GLUT
    glutInit()

    let bg = vec3(33f, 33f, 33f).toRgb()

    var q = makeQuoridor()
    while not w.windowShouldClose:
        glClearColor(bg.r, bg.g, bg.b, 1f)
        glClear(GL_COLOR_BUFFER_BIT)

        q.drawLegend()
        q.draw()

        w.swapBuffers
        glfwPollEvents()

    w.destroyWindow
    glfwTerminate()

main()
