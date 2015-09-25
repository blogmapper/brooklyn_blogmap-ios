//
//  ViewController.m
//  BlogMap
//
//  Created by Jacob Colleran on 3/25/15.
//  Copyright (c) 2015 blogMap. All rights reserved.
//
//  Portions of code below were copied or modified with permission from:
//
//  ViewController.m
//  Stolpersteine
//
//  Copyright (C) 2013 Option-U Software
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.
//

#import "ViewController.h"

#import "AppDelegate.h"
#import "ConfigurationService.h"
#import "MapClusterAnnotationView.h"
#import "Localization.h"


#import "BlogpostSynchronizationController.h"
#import "BlogpostSynchronizationControllerDelegate.h"
#import "BlogpostWebViewController.h"
#import "BlogpostNetworkService.h"
#import "InfoViewController.h"

#import "CCHMapClusterController.h"
#import "CCHMapClusterControllerDelegate.h"
#import "CCHMapClusterAnnotation.h"


static const double ZOOM_DISTANCE_USER = 400;
static const double ZOOM_DISTANCE_STUMBLR = ZOOM_DISTANCE_USER * 0.25;

@interface ViewController () <MKMapViewDelegate, CLLocationManagerDelegate, CCHMapClusterControllerDelegate, BlogpostSynchronizationControllerDelegate>

@property (weak, nonatomic) IBOutlet MKMapView *mapView;
@property (weak, nonatomic) IBOutlet UIButton *infoButton;
@property (nonatomic) MBXRasterTileOverlay *rasterOverlay;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *locationBarButtonItem;
@property (nonatomic) CLLocationManager *locationManager;
@property (nonatomic) BOOL displayRegionIcon;
@property (nonatomic) BlogpostSynchronizationController *blogpostSyncController;
@property (nonatomic) CCHMapClusterController *mapClusterController;


@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    //background image
    UIImageView *backgroundImage;
    backgroundImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"ios-linen"]];
    [[self view] addSubview:backgroundImage];
    [backgroundImage.superview sendSubviewToBack:backgroundImage];
    
    //custom title
    UILabel *labelTitle = [[UILabel alloc] initWithFrame:CGRectZero];
    labelTitle.backgroundColor = [UIColor clearColor];
    labelTitle.font = [UIFont fontWithName:@"Bauhaus 93" size:30];
    labelTitle.textAlignment = NSTextAlignmentCenter;
    labelTitle.textColor = [UIColor colorWithRed:28.0/255.0 green:154.0/255.0 blue:28.0/255.0 alpha:1.0];
    self.navigationItem.titleView = labelTitle;
    labelTitle.text = @"blogMap";
    [labelTitle sizeToFit];
    
    NSMutableAttributedString *text = [[NSMutableAttributedString alloc] initWithAttributedString:labelTitle.attributedText];
    [text addAttribute:NSForegroundColorAttributeName
                 value:[UIColor colorWithRed:193.0/255.0 green:35.0/255.0 blue:35.0/255.0 alpha:1.0]
                 range:NSMakeRange(4, 3)];
    [labelTitle setAttributedText:text];
    
    //clear navigation bar
    [self.navigationController.navigationBar setBackgroundImage:[UIImage new] forBarMetrics:UIBarMetricsDefault];
    self.navigationController.navigationBar.shadowImage = [UIImage new];
    self.navigationController.navigationBar.translucent = YES;
    self.navigationController.view.backgroundColor = [UIColor clearColor];
    self.navigationController.navigationBar.backgroundColor = [UIColor clearColor];
    
    [MBXMapKit setAccessToken:@"pk.eyJ1IjoiamFrZWNvbGwiLCJhIjoiQW1QeS1kRSJ9.Ai2eq-OOBHH3ZDjzLqWWbw"];
    //caching
    NSUInteger memoryCapacity = 4 * 1024 * 1024;
    NSUInteger diskCapacity = 40 * 1024 * 1024;
    NSURLCache *urlCache = [[NSURLCache alloc] initWithMemoryCapacity:memoryCapacity diskCapacity:diskCapacity diskPath:nil];
    [urlCache removeAllCachedResponses];
    [NSURLCache setSharedURLCache:urlCache];
    
    self.infoButton.accessibilityLabel = @"Map";
    
    self.mapView.layer.cornerRadius = 10.0;
    self.mapView.delegate = self;
    
    //nav bar back button customizations
    UIBarButtonItem *backButton = [[UIBarButtonItem alloc] initWithTitle:@"Map" style:UIBarButtonItemStylePlain target:nil action:nil];
    backButton.title = @"Map";
    [backButton setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:
                                        [UIFont fontWithName:@"Futura-Medium" size:16], NSFontAttributeName,
                                        [UIColor whiteColor], NSForegroundColorAttributeName,
                                        nil]
                              forState:UIControlStateNormal];
    
    self.navigationItem.backBarButtonItem = backButton;
    self.navigationController.toolbarHidden = YES;
    self.mapView.showsBuildings = NO;
    self.mapView.showsPointsOfInterest = NO;
    self.mapView.rotateEnabled = NO;
    self.mapView.pitchEnabled = NO;
    
    //custom mapbox map overlay
    _rasterOverlay = [[MBXRasterTileOverlay alloc] initWithMapID:@"jakecoll.c0364365" includeMetadata:YES includeMarkers:YES];
    _rasterOverlay.delegate = self;
    _rasterOverlay.canReplaceMapContent = YES;
    [_mapView addOverlay:_rasterOverlay];
    
    //Clustering
    self.mapClusterController = [[CCHMapClusterController alloc] initWithMapView:self.mapView];
    self.mapClusterController.delegate = self;
    
    //User location
    self.locationManager = [[CLLocationManager alloc] init];
    self.locationManager.delegate = self;
    if ([self.locationManager respondsToSelector:@selector(requestWhenInUseAuthorization)]) {
        [self.locationManager requestWhenInUseAuthorization];
    }
    
    // Start loading data from API
    self.blogpostSyncController = [[BlogpostSynchronizationController alloc] initWithNetworkService:AppDelegate.networkService];
    self.blogpostSyncController.delegate = self;
    
    //initialize map region
    float latitude = 40.673850;
    float longitude = -73.970064;
    float latMeters = 2240;
    float lonMeters = 2240;
    
    CLLocationCoordinate2D coordinates = CLLocationCoordinate2DMake(latitude,longitude);
    MKCoordinateRegion region = MKCoordinateRegionMakeWithDistance(coordinates, latMeters, lonMeters);
    [self.mapView setRegion:region animated:NO];

}

- (void)mapView:(MKMapView *)mapView regionDidChangeAnimated:(BOOL)animated{
    
   if ((mapView.region.center.latitude > 40.774326) || (mapView.region.center.latitude < 40.4744138)) {
        
        [mapView setRegion:[AppDelegate.configurationService coordinateRegionConfigurationForKey:ConfigurationServiceKeyVisibleRegion] animated: YES];
        
    }
    
    if ((mapView.region.center.longitude > -73.746214) || (mapView.region.center.longitude < -74.193220)) {
        [mapView setRegion:[AppDelegate.configurationService coordinateRegionConfigurationForKey:ConfigurationServiceKeyVisibleRegion] animated: YES];
    }
}


#pragma mark Mapbox overlay

- (MKOverlayRenderer*)mapView:(MKMapView *)mapView rendererForOverlay:(id<MKOverlay>)overlay
{
    if ([overlay isKindOfClass:[MBXRasterTileOverlay class]])
    {
        MBXRasterTileRenderer *renderer = [[MBXRasterTileRenderer alloc] initWithTileOverlay:overlay];
        return renderer;
    }
    return nil;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    if (self.mapClusterController.annotations.count < 4600) {
        [self.blogpostSyncController synchronize];
    }
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    //update data when app becomes active
    [NSNotificationCenter.defaultCenter addObserver:self.blogpostSyncController selector:@selector(synchronize) name:UIApplicationWillEnterForegroundNotification object:nil];
    
}


- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    
    [NSNotificationCenter.defaultCenter removeObserver:self.blogpostSyncController];

}

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{

}


- (void)updateLocationBarButtonItem
{
    // Force region mode if locations aren't available
    BOOL isAuthorized = [CLLocationManager authorizationStatus] == kCLAuthorizationStatusAuthorizedAlways || [CLLocationManager authorizationStatus] == kCLAuthorizationStatusAuthorizedWhenInUse;
    if (![CLLocationManager locationServicesEnabled] || !isAuthorized) {
        self.displayRegionIcon =YES;
    }
    
    UIImage *image;
    NSString *accessibilityLabel;
    if (self.displayRegionIcon) {
        image = [UIImage imageNamed:@"IconRegion"];
        accessibilityLabel = @"Zoom to region";
    } else {
        image = [UIImage imageNamed:@"IconLocation"];
        accessibilityLabel = @"Zoom to current location";
    }
    self.locationBarButtonItem.accessibilityLabel = accessibilityLabel;
    [self.locationBarButtonItem setImage:image];
}

- (IBAction)centerMap:(UIBarButtonItem *)sender
{
   self.displayRegionIcon = !self.displayRegionIcon;
    
    //NSString *diagnosticsLabel;
    if (self.displayRegionIcon) {
        if (self.mapView.userLocation.location)
        {
            MKCoordinateRegion region = MKCoordinateRegionMakeWithDistance(self.mapView.userLocation.coordinate, ZOOM_DISTANCE_USER, ZOOM_DISTANCE_STUMBLR);
            if ((region.center.latitude > 40.774326) || (region.center.latitude < 40.4744138) || (region.center.longitude > -73.746214) || (region.center.longitude < -74.193220)) {
                UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Your location is not within the bounds of the map." message:@"Press OK to continue." preferredStyle:UIAlertControllerStyleAlert];
                
                UIAlertAction* ok = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil];
                
                [alertController addAction:ok];
                [self presentViewController:alertController animated:YES completion:nil];
                
                //deprecated alert
                /*UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Your location is not within the bounds of the map."
                                                                message:@"Press OK to continue."
                                                               delegate:self
                                                      cancelButtonTitle:@"OK"
                                                      otherButtonTitles:nil];
                [alert show];*/
                
                } else {
        
                    [self.mapView setRegion:region animated:YES];
        
                }}
        
        } else {
        MKCoordinateRegion region = [AppDelegate.configurationService coordinateRegionConfigurationForKey:ConfigurationServiceKeyVisibleRegion];
        
        [self.mapView setRegion:region animated:YES];
        
        
        
    }
    [self updateLocationBarButtonItem];

}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"showTVC"]) {
        id<MKAnnotation> selectedAnnotation = self.mapView.selectedAnnotations.lastObject;
        CCHMapClusterAnnotation *mapClusterAnnotation = (CCHMapClusterAnnotation *)selectedAnnotation;
        BlogpostWebViewController *webViewController = (BlogpostWebViewController *)segue.destinationViewController;
        webViewController.blogposts = mapClusterAnnotation.annotations.allObjects;
        //webViewController.title = [Localization newBlogpostsCountFromCount:mapClusterAnnotation.annotations.count];
        
    }
    
    if ([segue.identifier isEqualToString:@"showInfoView"]) {
        InfoViewController *infoViewController = (InfoViewController *)segue.destinationViewController;
        infoViewController.title = @"stumblr";
    }
}


#pragma mark - Blogpost synchronization controller

-(void)blogpostSynchronizationController:(BlogpostSynchronizationController *)blogpostSynchronizationController didAddBlogposts:(NSArray *)blogposts
{
    [self.mapClusterController addAnnotations:blogposts withCompletionHandler:NULL];
}

#pragma mark - Map view

- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id<MKAnnotation>)annotation
{
    MKAnnotationView *annotationView;
    
    if ([annotation isKindOfClass:CCHMapClusterAnnotation.class]) {
        static NSString *identifier = @"blogpostCluster";
        
        MapClusterAnnotationView *mapClusterAnnotationView = (MapClusterAnnotationView *)[mapView dequeueReusableAnnotationViewWithIdentifier:identifier];
        if (mapClusterAnnotationView) {
            mapClusterAnnotationView.annotation = annotation;
        } else {
            mapClusterAnnotationView = [[MapClusterAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:identifier];
            mapClusterAnnotationView.canShowCallout = YES;
            
            UIButton *rightButton = [UIButton buttonWithType:UIButtonTypeCustom];
            [rightButton setImage:[UIImage imageNamed:@"DetailArrow.png"] forState:UIControlStateNormal];
            if (NSFoundationVersionNumber > NSFoundationVersionNumber_iOS_7_1) {
                //workaround for misaligned button, see http://stackoverflow.com/questions/25484608/ios-8-mkannotationview-rightcalloutaccessoryview-misaligned
                CGRect frame = rightButton.frame;
                frame.size.height = 55;
                frame.size.width = 55;
                rightButton.frame = frame;

            }
            mapClusterAnnotationView.rightCalloutAccessoryView = rightButton;
            
        }
        CCHMapClusterAnnotation *mapClusterAnnotation = (CCHMapClusterAnnotation *)annotation;
        mapClusterAnnotationView.count = mapClusterAnnotation.annotations.count;
        mapClusterAnnotationView.oneLocation = mapClusterAnnotation.isUniqueLocation;
        
        if (mapClusterAnnotation.isCluster) {
            mapClusterAnnotationView.leftCalloutAccessoryView = nil;
        } else {
            mapClusterAnnotationView.leftCalloutAccessoryView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 55, 55)];
            
        }
        
        annotationView = mapClusterAnnotationView;
    }
    
    return annotationView;
}

- (void)mapView:(MKMapView *)mapView didSelectAnnotationView:(MKAnnotationView *)annotationView
{
    [self updateLeftCalloutAccesoryViewInAnnotationView:annotationView];
}

- (void)mapView:(MKMapView *)mapView didDeselectAnnotationView:(MKAnnotationView *)annotationView
{
    [self updateLeftCalloutAccesoryViewInAnnotationView:nil];
}

- (void)updateLeftCalloutAccesoryViewInAnnotationView:(MKAnnotationView *)annotationView
{
    UIImageView *imageView = nil;
    if ([annotationView.leftCalloutAccessoryView isKindOfClass:[UIImageView class]]) {
        imageView = (UIImageView *)annotationView.leftCalloutAccessoryView;
    }
    if (imageView) {
        CCHMapClusterAnnotation *mapClusterAnnotation;
        if ([annotationView.annotation isKindOfClass:[CCHMapClusterAnnotation class]]) {
            mapClusterAnnotation = (CCHMapClusterAnnotation *)annotationView.annotation;
        }
        if (mapClusterAnnotation.isCluster) {
            imageView = nil;
        } else {
            dispatch_queue_t downloadThumbnailQueue = dispatch_queue_create("Get Photo Thumbnail", NULL);
            dispatch_async(downloadThumbnailQueue, ^{
                UIImage *originalImage = nil;
                UIImage *thumbnail = nil;
                NSData *imageData = [[NSData alloc] initWithContentsOfURL:[Localization newThumbnailImageFromMapClusterAnnotation:mapClusterAnnotation]];
                originalImage = [[UIImage alloc] initWithData:imageData];
                //NSLog(@"%@", imageData);
                CGSize destinationSize = CGSizeMake(90, 90);
                UIGraphicsBeginImageContext(destinationSize);
                [originalImage drawInRect:CGRectMake(0,0,destinationSize.width,destinationSize.height)];
                thumbnail = UIGraphicsGetImageFromCurrentImageContext();
                UIGraphicsEndImageContext();
                dispatch_async(dispatch_get_main_queue(), ^{
                    imageView.image = thumbnail;
                    
                               
                });
            });
        }
    }
}

- (void)mapView:(MKMapView *)mapView annotationView:(MKAnnotationView *)view calloutAccessoryControlTapped:(UIControl *)control
{
    if ([view.annotation isKindOfClass:CCHMapClusterAnnotation.class]) {
        [self performSegueWithIdentifier:@"showTVC" sender:self];
    }
}

- (void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status
{
    if (status == kCLAuthorizationStatusAuthorizedAlways || status == kCLAuthorizationStatusAuthorizedWhenInUse) {
        self.mapView.showsUserLocation = YES;
        [self.locationManager startUpdatingLocation];
    } else {
        self.mapView.showsUserLocation = NO;
        [self.locationManager stopUpdatingLocation];
    }
    [self updateLocationBarButtonItem];
}

#pragma mark - Map cluster controller


- (NSString *)mapClusterController:(CCHMapClusterController *)mapClusterController titleForMapClusterAnnotation:(CCHMapClusterAnnotation *)mapClusterAnnotation
{
    return [Localization newTitleFromMapClusterAnnotation:mapClusterAnnotation];
}

- (NSString *)mapClusterController:(CCHMapClusterController *)mapClusterController subtitleForMapClusterAnnotation:(CCHMapClusterAnnotation *)mapClusterAnnotation
{
    return [Localization newSubtitleFromMapClusterAnnotation:mapClusterAnnotation];
}

- (void)mapClusterController:(CCHMapClusterController *)mapClusterController willReuseMapClusterAnnotation:(CCHMapClusterAnnotation *)mapClusterAnnotation
{
    MapClusterAnnotationView *mapClusterAnnotationView = (MapClusterAnnotationView *)[self.mapClusterController.mapView viewForAnnotation:mapClusterAnnotation];
    mapClusterAnnotationView.count = mapClusterAnnotation.annotations.count;
    mapClusterAnnotationView.oneLocation = mapClusterAnnotation.isUniqueLocation;
    
}

@end
