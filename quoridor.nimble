# Package
version = "0.1.0"
author = "William Guimont-Martin"
description = "A small Quoridor game"
license = "MIT"
backend = "cpp"
srcDir = "src"
bin = @["quoridor"]
binDir = "bin"

# Dependencies
requires "nim >= 1.0.6"
requires "nimgl >= 1.0.0"
requires "glm"
requires "opengl"

# Tasks
task res, "Copy ressources to bin directory":
    let resPath = "resources"
    cpDir(resPath, "$1/$2" % [binDir, resPath])
