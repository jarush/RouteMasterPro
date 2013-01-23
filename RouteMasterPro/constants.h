//
//  constants.h
//  RouteMasterPro
//
//  Created by Jason Rush on 1/12/13.
//  Copyright (c) 2013 Flush Software LLC. All rights reserved.
//

#ifndef RouteMasterPro_constants_h
#define RouteMasterPro_constants_h

// Factor to convert from meters to miles
#define METER_TO_MILES 0.000621371

// Factor to convert from meters/second to miles/hour
#define MPS_TO_MIPH 2.23694

// Radians to degrees
#define RAD2DEG (180.0 / M_PI)

// Minimum distance in meters to collect locations
#define LOCATION_DISTANCE_FILTER 10.0

// Maximum distance in meters to accept for horizontal accuracy
#define MAX_HORIZONTAL_ACCURACY 20.0

// Maximum number of seconds old a location update can be and still be recorded
#define MAX_LOCATION_AGE 4

// Maximum distance in meters to consider two trips to belong to the same route
#define MAX_TRIP_MATCH_DISTANCE 25.0

// Radius in meters to the stop coordinate that monitoring will automatically stop
#define RADIUS_STOP_MONITORING 100.0

#endif
