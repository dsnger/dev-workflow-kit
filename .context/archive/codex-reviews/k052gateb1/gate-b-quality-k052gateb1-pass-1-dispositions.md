1 | fixed | case 46 reads the mode with perl stat (07777, octal), the same on macOS and Ubuntu
2 | fixed | same cause as spec 1: a selected job without a numeric check run id now refuses 64
3 | fixed | the walk's test seam prints "test pause after checking <dir>" before it sleeps; case 53 waits for that line (bounded) before the swap
