
FTLocationSimulator
===================

FTLocationSimulator allows simulating Core Location in the iPhone simulator on the desktop. It sends fake Core Location updates taken from a KML file that describes a predefined route.

Besides the simulated Core Location updates, it also updates the blue userLocation view on MapKit views.

The sample project shows how to integrate FTLocationSimulator into an existing app, in this case Apple's "Breadcrumb" sample application.


Integration Steps
-----------------
In a nutshell, these are the necessary steps:

1. Add the FTLocationSimulator directory to your project

2. Add -licucore to "Other Linker flags" in the project/target settings (this is needed for RegExKitLite)

3. `#ifdef` all `CMLocationManager` occurences like the following:

		#ifdef FAKE_CORE_LOCATION
			[FTLocationSimulator sharedInstance].mapView = self.map;
			[FTLocationSimulator sharedInstance].delegate = self;
			[[FTLocationSimulator sharedInstance] startUpdatingLocation];
		#else
		    self.locationManager = [[[CLLocationManager alloc] init] autorelease];
		    self.locationManager.delegate = self;    
  			[self.locationManager startUpdatingLocation];
		#endif

	

4. `#include "FTLocationSimulator.h"` where necessary.

5. Set the `mapView` and `delegate` properties as shown above.

6. If you're using MapKit, put the following into your `MKMapViewDelegate`:

		- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id <MKAnnotation>)annotation {
			if ([annotation isMemberOfClass:[MKUserLocation class]]) {
		#ifdef FAKE_CORE_LOCATION
				return [[FTLocationSimulator sharedInstance] fakeUserLocationView];
		#else
				return nil;
		#endif
			}
			// Your code for regular annotation views
		}
		
7. Adjust `FAKE_CORE_LOCATION_UPDATE_INTERVAL` in `FTLocationSimulator.h` if the location updates are too fast.

8. Change the `fakeLocations.kml` if needed (currently, it includes a route from Cupertino to San Francisco). To create a new fakeLocations.kml, use Google Earth and create a route. Send the route via email and take the "Route.kmz" file out of the draft mail. kmz is zipped kml. Then unzip that file using "unzip Route.kml" on the command line. The parser is not a generic KML parser but is only able to parse these specific Google Earth KML files.

Implemented methods and properties
----------------------------------

From CLLocationManager:

- delegate
- location (for polling updates)
- -startUpdatingLocations
- -stopUpdatingLocations

CLLocationManagerDelegate:

- -locationManager:didUpdateToLocation:fromLocation: (is messaged from FTLocationSimulator)

CLLocation objects:

- coordinate
- location
- timestamp


Known Issues
------------
- In Google's KML files the distance between waypoints varies. For straight roads it's larger than for curvy roads. FTLocationSimulator does not consider this difference, so the speed on the KML route varies.
- The faked userLocation view does not incorporate the GPS halo animation.
- distanceFilter, heading, course, altitude, speed and accuracy are not implemented (some of them might be technically possible)

Collaboration
-------------
We're happy if someone wants to contribute to the project or work on some of the issues. Just fork the project and send us a pull request.


Have fun!

-Ortwin
