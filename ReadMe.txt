### Breadcrumb ###

===========================================================================
DESCRIPTION:

Demonstrates how to draw a path using the Map Kit overlay, MKOverlayView, that follows and tracks the user's current location.  The included CrumbPath and CrumbPathView overlay and overlay view classes can be used for any path of points that are expected to change over time.

It also demonstrates how to properly operate while running as a background process.
This application receives location events while in the background by including the "UIBackgroundModes" key (with the location value) in its Info.plist file.

It also takes advantage of a desired accurage of "kCLLocationAccuracyBestForNavigation".  This level of accuracy is intended for use in navigation applications that require precise position information.  

===========================================================================
BUILD REQUIREMENTS:

iOS 4.0 SDK

===========================================================================
RUNTIME REQUIREMENTS:

iOS 4.0 or later

===========================================================================
PACKAGING LIST:

CrumbPath
- Implements a mutable path of locations.

CrumbPathView
- MKOverlayView subclass that renders a CrumbPath.  Demonstrates the best way to create and render a list of points as a path in an MKOverlayView.
    
BreadcrumbViewController
- Uses MKMapView delegate messages to track the user location and update the displayed path of the user on an MKMapView.

===========================================================================
CHANGES FROM PREVIOUS VERSIONS:

Version 1.1
- Updated to support background processing in tracking the user's location, now uses kCLLocationAccuracyBestForNavigation.

Version 1.0
- First version.

===========================================================================
Copyright (C) 2010 Apple Inc. All rights reserved.
