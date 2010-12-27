//
//  FTLocationSimulator.m
//
//  Created by Ortwin Gentz on 23.09.2010.
//  Copyright 2010 FutureTap http://www.futuretap.com
//  All rights reserved.
//
//  Permission is given to use this source code file without charge in any
//  project, commercial or otherwise, entirely at your risk, with the condition
//  that any redistribution (in part or whole) of source code must retain
//  this copyright and permission notice. Attribution in compiled projects is
//  appreciated but not required.

#import "FTLocationSimulator.h"
#import "RegexKitLite.h"


static FTLocationSimulator *sharedInstance = nil;

@implementation FTLocationSimulator

@synthesize location;
@synthesize delegate;
@synthesize mapView;

- (void)dealloc
{
	[mapView release];
	mapView = nil;

	[location release];
	location = nil;

	[super dealloc];
}

- (void)fakeNewLocation {
	// read and parse the KML file
	if (!fakeLocations) {
		NSString *fakeLocationsFile = [[NSString alloc] initWithContentsOfFile:[[NSBundle mainBundle]
																				pathForResource:@"fakeLocations"
																				ofType:@"kml"]];
		NSString *coordinatesString = [fakeLocationsFile stringByMatching:@"<coordinates>[^-0-9]*(.+?)[^-0-9]*</coordinates>"
																  options:RKLMultiline|RKLDotAll
																  inRange:NSMakeRange(0, fakeLocationsFile.length)
																  capture:1
																	error:NULL];
		fakeLocations = [[coordinatesString componentsSeparatedByString:@" "] retain];
		[fakeLocationsFile release];
	}

	// select a new fake location
	NSArray *latLong = [[fakeLocations objectAtIndex:index] componentsSeparatedByString:@","];
	CLLocationDegrees lat = [[latLong objectAtIndex:1] doubleValue];
	CLLocationDegrees lon = [[latLong objectAtIndex:0] doubleValue];
	CLLocation *oldLocation = [[self.location retain] autorelease];
	self.location = [[[CLLocation alloc] initWithCoordinate:CLLocationCoordinate2DMake(lat, lon)
												   altitude:0
										 horizontalAccuracy:0
										   verticalAccuracy:0
												  timestamp:[NSDate date]] autorelease];

	// update the userlocation view
	if (self.mapView) {
		MKAnnotationView *userLocationView = [self.mapView viewForAnnotation:self.mapView.userLocation];
		[userLocationView.superview sendSubviewToBack:userLocationView];

 		CGRect frame = userLocationView.frame;
		frame.origin = [self.mapView convertCoordinate:self.location.coordinate toPointToView:userLocationView.superview];
		frame.origin.x -= 10;
		frame.origin.y -= 10;
		[UIView beginAnimations:@"fakeUserLocation" context:nil];
		[UIView setAnimationDuration:FAKE_CORE_LOCATION_UPDATE_INTERVAL];
		userLocationView.frame = frame;
		[UIView commitAnimations];

		[self.mapView.userLocation setCoordinate:self.location.coordinate];

	}

	// inform the locationManager delegate
	if([self.delegate respondsToSelector:@selector(locationManager:didUpdateToLocation:fromLocation:)]) {
		[self.delegate locationManager:nil
				   didUpdateToLocation:self.location
						  fromLocation:oldLocation];
	}

	// iterate to the next fake location
	if (updatingLocation) {
		index++;
		if (index == fakeLocations.count) {
			index = 0;
		}

		[self performSelector:@selector(fakeNewLocation) withObject:nil afterDelay:FAKE_CORE_LOCATION_UPDATE_INTERVAL];
	}
}

- (void)startUpdatingLocation {
	updatingLocation = YES;
	[self fakeNewLocation];
}

- (void)stopUpdatingLocation {
	updatingLocation = NO;
}

- (MKAnnotationView*)fakeUserLocationView {
	if (!self.mapView) {
		return nil;
	}

	[self.mapView.userLocation setCoordinate:self.location.coordinate];
	MKAnnotationView *userLocationView = [[MKAnnotationView alloc] initWithAnnotation:self.mapView.userLocation reuseIdentifier:nil];
	[userLocationView addSubview:[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"TrackingDot.png"]]];
	userLocationView.centerOffset = CGPointMake(-10, -10);
	return userLocationView;
}


// ==================================================================
#pragma mark -
#pragma mark Singleton Definitions
// ==================================================================

+ (FTLocationSimulator *)sharedInstance {
	@synchronized(self) {
		if (sharedInstance == nil) {
			sharedInstance = [[self alloc] init];
		}
	}

	return sharedInstance;
}

+ (id)allocWithZone:(NSZone *)zone {
	@synchronized(self) {
		if (sharedInstance == nil) {
			sharedInstance = [super allocWithZone:zone];
			return sharedInstance;
		}
	}

	return nil;
}

- (id)copyWithZone:(NSZone *)zone {
	return self;
}

- (id)retain {
	return self;
}

- (NSUInteger)retainCount {
	return NSUIntegerMax;
}

- (void)release {
}

- (id)autorelease {
	return self;
}


@end
