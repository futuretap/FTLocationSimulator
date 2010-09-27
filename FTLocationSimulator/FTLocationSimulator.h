//
//  FTLocationSimulator.h
//
//  Created by Ortwin Gentz on 23.09.2010.
//  Copyright 2010 FutureTap. All rights reserved.
//

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
