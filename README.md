
FTLocationSimulator
===================

FTLocationSimulator allows simulating Core Location in the iPhone simulator on the desktop. It sends fake Core Location updates taken from a KML file that describes a predefined route.

Besides the simulated Core Location updates, it also updates the blue userLocation view on MapKit views.

The sample project shows how to integrate FTLocationSimulator into an existing app, in this case Apple's "Breadcrumb" sample application.


Integration Steps
-----------------
In a nutshell, these are the necessary steps:

1. Add the FTLocationSimulator directory to your project

2. Add `-licucore` to "Other Linker flags" in the project/target settings (this is needed for RegExKitLite)

3. `#ifdef` all occurences of "`CLLocationManager`"  like the following:

		#ifdef FAKE_CORE_LOCATION
		    self.locationManager = [[[FTLocationSimulator alloc] init] autorelease];
		#else
		    self.locationManager = [[[CLLocationManager alloc] init] autorelease];
		#endif

   Only the alloc/init call has to be ifdef'ed. All further occurences of your locationManager object don't need to be changed since `FTLocationSimulator` uses the same interface as `CLLocationManager`.

4. `#include "FTLocationSimulator.h"` where necessary.

5. If you're using MapKit, set the `mapView` property with your `MKMapView` and set it to nil if you're done with the map. Then, put the following into your `MKMapViewDelegate`:

		- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id <MKAnnotation>)annotation {
			if ([annotation isMemberOfClass:[MKUserLocation class]]) {
		#ifdef FAKE_CORE_LOCATION
				return self.locationManager.fakeUserLocationView;
		#else
				return nil;
		#endif
			}
			// Your code for regular annotation views
		}
		
6. Adjust `FAKE_CORE_LOCATION_UPDATE_INTERVAL` in `FTLocationSimulator.h` if the location updates are too fast.

7. Change the `fakeLocations.kml` if needed (currently, it includes a route from Cupertino to San Francisco). To create a new fakeLocations.kml, use Google Earth and create a route. Send the route via email and take the "Route.kmz" file out of the draft mail. The kmz format is zipped kml. So unzip that file using "unzip Route.kml" on the command line.

    The parser is not a generic KML parser but is only able to parse these specific Google Earth KML files.


Implemented methods and properties
----------------------------------

From `CLLocationManager`:

- `delegate`
- `location` (for polling updates)
- `distanceFilter`
- `-startUpdatingLocations`
- `-stopUpdatingLocations`


`CLLocationManagerDelegate`:

- `-locationManager:didUpdateToLocation:fromLocation:` (is sent by FTLocationSimulator)


`CLLocation` objects:

- `coordinate`
- `location`
- `timestamp`


Known Issues
------------
- In Google's KML files the distance between waypoints varies. For straight roads it's larger than for curvy roads. FTLocationSimulator does not consider this difference, so the speed on the KML route varies.
- The faked userLocation view does not incorporate the GPS halo animation.
- heading, course, altitude, speed and accuracy are not implemented (some of them might be technically possible)

Collaboration
-------------
We're happy if someone wants to contribute to the project or work on some of the issues. Just fork the project and send us a pull request.


Have fun!

-Ortwin
