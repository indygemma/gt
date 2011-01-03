def enter(app):
    # float maxDepth, float volume, float waterHeight, float liquidDensity
    app.setBuoyancy(0, 0.1, -10, 1000)
    app.go()
