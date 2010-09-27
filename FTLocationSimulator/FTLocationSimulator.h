//
//  FTLocationSimulator.h
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

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>
#import <TargetConditionals.h>

#if TARGET_IPHONE_SIMULATOR
#define FAKE_CORE_LOCATION 1
#endif

#define FAKE_CORE_LOCATION_UPDATE_INTERVAL 0.3

@interface FTLocationSimulator : NSObject {
@private
	id<CLLocationManagerDelegate> delegate;
	MKMapView			*mapView;
	FTLocationSimulator	*sharedInstance;
	BOOL				updatingLocation;
	NSArray				*fakeLocations;
	CLLocation			*location;
	NSInteger			index;
}

@property (nonatomic, retain) CLLocation *location;
@property (nonatomic, assign) id<CLLocationManagerDelegate> delegate;
@property (nonatomic, retain) MKMapView *mapView;

+ (FTLocationSimulator*)sharedInstance;
- (void)startUpdatingLocation;
- (void)stopUpdatingLocation;
- (MKAnnotationView*)fakeUserLocationView;
@end
