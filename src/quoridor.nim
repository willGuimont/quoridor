import nimgl/[glfw, opengl]
import glm
import opengl/glut

import game/game

const screenWidth = 600
const screenHeight = 600

proc keyProc(window: GLFWWindow, key: int32, scancode: int32, action: int32,
    mods: int32): void {.cdecl.} =
    if key == GLFWKey.Escape and action == GLFWPress:
        window.setWindowShouldClose(true)
    if key == GLFWKey.Space:
        glPolygonMode(GL_FRONT_AND_BACK, if action !=
            GLFWRelease: GL_LINE else: GL_FILL)

proc toRGB(vec: Vec3[float32]): Vec3[float32] =
    return vec3(vec.x / 255, vec.y / 255, vec.z / 255)

proc toScreenSpace(x: SomeNumber): float {.inline.} =
    2 * x / boardSize - 1

const offset = 5.toScreenSpace

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
    q.putWall(horizontal, 0, 0)
    q.putWall(horizontal, 2, 0)
    # q.putWall(vertical, 1, 0)

    while not w.windowShouldClose:
        glClearColor(bg.r, bg.g, bg.b, 1f)
        glClear(GL_COLOR_BUFFER_BIT)

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

        w.swapBuffers
        glfwPollEvents()

    w.destroyWindow
    glfwTerminate()

main()
