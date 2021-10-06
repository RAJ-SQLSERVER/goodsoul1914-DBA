# Clear the console window
CLS;

# Load the Snapins for SqlServer if they aren't currently loaded 
Import-Module SqlPs;

# Change to the XEvent path and change to our server and instance
CD \XEvent\PS-SQL2K12\DEFAULT;

# List the available objects
LS;

# Change to packages
CD Packages;

# List the available packages
LS;

# Change to the sqlos package
CD 5b2da06d-898a-43c8-9309-39bbbe93ebbd.sqlos

# List the available children
LS;

# Change to the events
CD EventInfoSet;

# List the available events
LS;

# Change to the XEvent path and change to our server and instance and open sessions
CD \XEvent\PS-SQL2K12\DEFAULT\Sessions;

# List the available event sessions
LS;

# Open the system_health session
CD system_health;

# List the available options
LS;

# Open the events
CD Events;

# List the events
LS;