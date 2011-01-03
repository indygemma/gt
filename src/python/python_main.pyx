cdef extern from "app.h":
    cdef cppclass SampleApp:
        SampleApp()
        void go()
        void setBuoyancy(float maxDepth, float volume, float waterHeight, float liquidDensity)

cdef class PySampleApp:
    cdef SampleApp *thisptr
    def __cinit__(self):
        self.thisptr = new SampleApp()
    def __dealloc__(self):
        del self.thisptr
    def go(self):
        self.thisptr.go()
    def setBuoyancy(self, maxDepth, volume, waterHeight, liquidDensity=1000.0):
        self.thisptr.setBuoyancy(maxDepth, volume, waterHeight, liquidDensity)

if __name__ == "__main__":
    # call out to an external module to control the behaviour called "main"
    import main
    app = PySampleApp()
    main.enter(app)
else:
    pass # imported
