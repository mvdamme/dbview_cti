# For dbview_cti, it is important that all classes are loaded, otherwise 
# methods like specialize return incorrect results.
# We can force Rails to load all classes in the CTI hierarchy by loading 
# the leaf classes
Rails.application.config.after_initialize do   # Needed so we can autoload the job classes below
  Car
  MotorCycle
  SpaceShuttle
end

