#NETXML FILTER#

Written to sort through Kismet NETXML data for YOLOcon 2018, using perl becuase I'm a scrub.

If you have NETXML data to sort through, you can use this to look for
Beacons and Probe Responses and associated security features (Encryption Level,
WPS enabled) as well as filter through duplicate BSSIDs to ensure there
isn't useless data points.

The guestfilter will parse through (most easily) the filtered data file, easily pulling out any  non-guest networks and presenting them to you line-by-line through STDOUT
