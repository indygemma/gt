import sys

env = Environment()

Export("env")

final_makefile = "_".join(["SConstruct", sys.platform])
SConscript(final_makefile)