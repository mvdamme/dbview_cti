# For dbview_cti, it is important that all classes are loaded, otherwise 
# methods like specialize return incorrect results.
# We can force Rails to load all classes in the CTI hierarchy by loading 
# the leaf classes
Car
MotorCycle
SpaceShuttle

