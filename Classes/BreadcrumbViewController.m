/*
     File: BreadcrumbViewController.m 
 Abstract: 
    Main view controller for the application.
    Displays the user location along with the path traveled on an MKMapView.
    Implements the MKMapViewDelegate messages for tracking user location and managing overlays.
     
  Version: 1.1 
  
 Disclaimer: IMPORTANT:  This Apple software is supplied to you by Apple 
 Inc. ("Apple") in consideration of your agreement to the following 
 terms, and your use, installation, modification or redistribution of 
 this Apple software constitutes acceptance of these terms.  If you do 
 not agree with these terms, please do not use, install, modify or 
 redistribute this Apple software. 
  
 In consideration of your agreement to abide by the following terms, and 
 subject to these terms, Apple grants you a personal, non-exclusive 
 license, under Apple's copyrights in this original Apple software (the 
 "Apple Software"), to use, reproduce, modify and redistribute the Apple 
 Software, with or without modifications, in source and/or binary forms; 
 provided that if you redistribute the Apple Software in its entirety and 
 without modifications, you must retain this notice and the following 
 text and disclaimers in all such redistributions of the Apple Software. 
 Neither the name, trademarks, service marks or logos of Apple Inc. may 
 be used to endorse or promote products derived from the Apple Software 
 without specific prior written permission from Apple.  Except as 
 expressly stated in this notice, no other rights or licenses, express or 
 implied, are granted by Apple herein, including but not limited to any 
 patent rights that may be infringed by your derivative works or by other 
 works in which the Apple Software may be incorporated. 
  
 The Apple Software is provided by Apple on an "AS IS" basis.  APPLE 
 MAKES NO WARRANTIES, EXPRESS OR IMPLIED, INCLUDING WITHOUT LIMITATION 
 THE IMPLIED WARRANTIES OF NON-INFRINGEMENT, MERCHANTABILITY AND FITNESS 
 FOR A PARTICULAR PURPOSE, REGARDING THE APPLE SOFTWARE OR ITS USE AND 
 OPERATION ALONE OR IN COMBINATION WITH YOUR PRODUCTS. 
  
 IN NO EVENT SHALL APPLE BE LIABLE FOR ANY SPECIAL, INDIRECT, INCIDENTAL 
 OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF 
 SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS 
 INTERRUPTION) ARISING IN ANY WAY OUT OF THE USE, REPRODUCTION, 
 MODIFICATION AND/OR DISTRIBUTION OF THE APPLE SOFTWARE, HOWEVER CAUSED 
 AND WHETHER UNDER THEORY OF CONTRACT, TORT (INCLUDING NEGLIGENCE), 
 STRICT LIABILITY OR OTHERWISE, EVEN IF APPLE HAS BEEN ADVISED OF THE 
 POSSIBILITY OF SUCH DAMAGE. 
  
 Copyright (C) 2010 Apple Inc. All Rights Reserved. 
  
 */

#import "BreadcrumbViewController.h"

#define kTransitionDuration	0.75    // for the flip view animation

#pragma mark -

@implementation BreadcrumbViewController

@synthesize flipButton, doneButton, containerView, map,
            instructionsView, toggleBackgroundButton,
            locationManager;

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Note: we are using Core Location directly to get the user location updates.
    // We could normally use MKMapView's user location update delegation but this does not work in
    // the background.  Plus we want "kCLLocationAccuracyBestForNavigation" which gives us a better accuracy.
    //
    self.locationManager = [[[CLLocationManager alloc] init] autorelease];
    self.locationManager.delegate = self; // Tells the location manager to send updates to this object
    
    // Use the highest possible accuracy and combine it with additional sensor data.
    // This level of accuracy is intended for use in navigation applications that require precise
    // position information at all times and are intended to be used only while the device is plugged in.
    //
    self.locationManager.desiredAccuracy = kCLLocationAccuracyBestForNavigation;
    
    [self.locationManager startUpdatingLocation];
    
    // create the container view which we will use for flip animation (centered horizontally)
	containerView = [[UIView alloc] initWithFrame:self.view.bounds];
	[self.view addSubview:self.containerView];
    
    [self.containerView addSubview:self.map];
    
    // add our custom flip button as the nav bar's custom right view
	UIButton* infoButton = [UIButton buttonWithType:UIButtonTypeInfoLight];
    CGRect frame = infoButton.frame;
    frame.size.width = 40.0;
    infoButton.frame = frame;
	[infoButton addTarget:self action:@selector(flipAction:) forControlEvents:UIControlEventTouchUpInside];
	flipButton = [[UIBarButtonItem alloc] initWithCustomView:infoButton];
	self.navigationItem.rightBarButtonItem = flipButton;
	
	// create our done button as the nav bar's custom right view for the flipped view (used later)
	doneButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone
                                                               target:self action:@selector(flipAction:)];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    
    self.map = nil;
    self.instructionsView = nil;
    
    self.containerView = nil;
    
    self.locationManager.delegate = nil;
    self.locationManager = nil;
    
    [flipButton release];
    [doneButton release];
}

- (void)dealloc
{
    [crumbView release];
    [crumbs release];
    
    [containerView release];
    [map release];
    [instructionsView release];
    
    [flipButton release];
    [doneButton release];
    
    self.locationManager.delegate = nil;
    [locationManager release];
    
    [super dealloc];
}


#pragma mark -
#pragma mark Actions

// called them the app is moved to the background (user presses the home button) or to the foreground 
//
- (void)switchToBackgroundMode:(BOOL)background
{
    if (background)
    {
        if (!self.toggleBackgroundButton.isOn)
        {
            [self.locationManager stopUpdatingLocation];
            self.locationManager.delegate = nil;
        }
    }
    else
    {
        if (!self.toggleBackgroundButton.isOn)
        {
            self.locationManager.delegate = self;
            [self.locationManager startUpdatingLocation];
        }
    }
}

- (IBAction)toggleBestAccuracy:(id)sender
{
    UISwitch *accuracySwitch = (UISwitch *)sender;
    if (accuracySwitch.isOn)
        self.locationManager.desiredAccuracy = kCLLocationAccuracyBestForNavigation;
    else
        self.locationManager.desiredAccuracy = kCLLocationAccuracyBest;
}

// called when the user presses the 'i' icon to change the app settings
//
- (void)flipAction:(id)sender
{
	[UIView setAnimationDelegate:self];
	[UIView setAnimationDidStopSelector:@selector(animationDidStop:animationIDfinished:finished:context:)];
	[UIView beginAnimations:nil context:nil];
	[UIView setAnimationDuration:kTransitionDuration];
	
	[UIView setAnimationTransition:([self.map superview] ?
									UIViewAnimationTransitionFlipFromLeft : UIViewAnimationTransitionFlipFromRight)
                           forView:containerView cache:YES];
	if ([instructionsView superview])
	{
		[instructionsView removeFromSuperview];
		[containerView addSubview:self.map];
	}
	else
	{
		[self.map removeFromSuperview];
		[containerView addSubview:instructionsView];
	}
	
	[UIView commitAnimations];
	
	// adjust our done/info buttons accordingly
	if ([instructionsView superview])
		self.navigationItem.rightBarButtonItem = doneButton;
	else
		self.navigationItem.rightBarButtonItem = flipButton;
}


#pragma mark -
#pragma mark MapKit

- (void)locationManager:(CLLocationManager *)manager
    didUpdateToLocation:(CLLocation *)newLocation
           fromLocation:(CLLocation *)oldLocation
{
    if (newLocation)
    {
        // make sure the old and new coordinates are different
        if ((oldLocation.coordinate.latitude != newLocation.coordinate.latitude) &&
            (oldLocation.coordinate.longitude != newLocation.coordinate.longitude))
        {    
            if (!crumbs)
            {
                // This is the first time we're getting a location update, so create
                // the CrumbPath and add it to the map.
                //
                crumbs = [[CrumbPath alloc] initWithCenterCoordinate:newLocation.coordinate];
                [map addOverlay:crumbs];
                
                // On the first location update only, zoom map to user location
                MKCoordinateRegion region = 
                MKCoordinateRegionMakeWithDistance(newLocation.coordinate, 2000, 2000);
                [map setRegion:region animated:YES];
            }
            else
            {
                // This is a subsequent location update.
                // If the crumbs MKOverlay model object determines that the current location has moved
                // far enough from the previous location, use the returned updateRect to redraw just
                // the changed area.
                //
                // note: iPhone 3G will locate you using the triangulation of the cell towers.
                // so you may experience spikes in location data (in small time intervals)
                // due to 3G tower triangulation.
                // 
                MKMapRect updateRect = [crumbs addCoordinate:newLocation.coordinate];
                
                if (!MKMapRectIsNull(updateRect))
                {
                    // There is a non null update rect.
                    // Compute the currently visible map zoom scale
                    MKZoomScale currentZoomScale = map.bounds.size.width / map.visibleMapRect.size.width;
                    // Find out the line width at this zoom scale and outset the updateRect by that amount
                    CGFloat lineWidth = MKRoadWidthAtZoomScale(currentZoomScale);
                    updateRect = MKMapRectInset(updateRect, -lineWidth, -lineWidth);
                    // Ask the overlay view to update just the changed area.
                    [crumbView setNeedsDisplayInMapRect:updateRect];
                }
            }
        }
    }
}

- (MKOverlayView *)mapView:(MKMapView *)mapView viewForOverlay:(id <MKOverlay>)overlay
{
    if (!crumbView)
    {
        crumbView = [[CrumbPathView alloc] initWithOverlay:overlay];
    }
    return crumbView;
}

@end
