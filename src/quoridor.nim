# Copyright 2018, NimGL contributors.

import nimgl/glfw
import nimgl/opengl
import glm

proc keyProc(window: GLFWWindow, key: int32, scancode: int32, action: int32,
    mods: int32): void {.cdecl.} =
  if key == GLFWKey.Escape and action == GLFWPress:
    window.setWindowShouldClose(true)
  if key == GLFWKey.Space:
    glPolygonMode(GL_FRONT_AND_BACK, if action !=
        GLFWRelease: GL_LINE else: GL_FILL)

proc toRGB(vec: Vec3[float32]): Vec3[float32] =
  return vec3(vec.x / 255, vec.y / 255, vec.z / 255)

proc main =
  # GLFW
  doAssert glfwInit()

  glfwWindowHint(GLFWContextVersionMajor, 2)
  glfwWindowHint(GLFWContextVersionMinor, 1)
  glfwWindowHint(GLFWResizable, GLFW_FALSE)

  let w: GLFWWindow = glfwCreateWindow(800, 600, "Quoridor", nil, nil)
  doAssert w != nil

  discard w.setKeyCallback(keyProc)
  w.makeContextCurrent

  # Opengl
  doAssert glInit()

  glEnable(GL_BLEND)
  glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA)

  var
    bg = vec3(33f, 33f, 33f).toRgb()

  while not w.windowShouldClose:
    glClearColor(bg.r, bg.g, bg.b, 1f)
    glClear(GL_COLOR_BUFFER_BIT)

    glBegin(GL_QUADS);
    glVertex2f( -0.5f, -0.5f);
    glVertex2f(0.5f, -0.5f);
    glVertex2f(0.5f, 0.5f);
    glVertex2f( -0.5f, 0.5f);
    glEnd();

    w.swapBuffers
    glfwPollEvents()

  w.destroyWindow

  glfwTerminate()

main()
