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
	CLLocation			*oldLocation;
	NSInteger			index;
	NSTimeInterval		updateInterval;
	CLLocationDistance	distanceFilter;
	NSString			*purpose;
}

@property (nonatomic, retain) CLLocation *location;
@property (nonatomic, retain) CLLocation *oldLocation;
@property (nonatomic, assign) id<CLLocationManagerDelegate> delegate;
@property (nonatomic, retain) MKMapView *mapView;
@property (nonatomic, readonly) MKAnnotationView* fakeUserLocationView;

+ (FTLocationSimulator*)sharedInstance;
- (void)startUpdatingLocation;
- (void)stopUpdatingLocation;



// dummy methods to keep the CLLocationManager interface
+ (BOOL)locationServicesEnabled;
+ (BOOL)headingAvailable;
+ (BOOL)significantLocationChangeMonitoringAvailable;
+ (BOOL)regionMonitoringAvailable;
+ (BOOL)regionMonitoringEnabled;
+ (CLAuthorizationStatus)authorizationStatus;
@property(readonly, nonatomic) BOOL locationServicesEnabled;
@property(copy, nonatomic) NSString *purpose;
@property(assign, nonatomic) CLLocationDistance distanceFilter;
@property(assign, nonatomic) CLLocationAccuracy desiredAccuracy;
@property(readonly, nonatomic) BOOL headingAvailable;
@property(assign, nonatomic) CLLocationDegrees headingFilter;
@property(assign, nonatomic) CLDeviceOrientation headingOrientation;
@property(readonly, nonatomic) CLHeading *heading;
@property(readonly, nonatomic) CLLocationDistance maximumRegionMonitoringDistance;
@property(readonly, nonatomic) NSSet *monitoredRegions;
- (void)startUpdatingHeading;
- (void)stopUpdatingHeading;
- (void)dismissHeadingCalibrationDisplay;
- (void)startMonitoringSignificantLocationChanges;
- (void)stopMonitoringSignificantLocationChanges;
- (void)startMonitoringForRegion:(CLRegion*)region desiredAccuracy:(CLLocationAccuracy)accuracy;
- (void)stopMonitoringForRegion:(CLRegion*)region;

@end
