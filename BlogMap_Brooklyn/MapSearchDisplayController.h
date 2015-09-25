//
//  MapSearchDisplayController.h
//  Stumblr_Beta
//
//  Created by Jacob Colleran on 3/29/15.
//  Copyright (c) 2015 Stumblr. All rights reserved.
//

#import <UIKit/UIKit.h>

@class BlogpostNetworkService;
@class CCHMapClusterController;

@interface MapSearchDisplayController : UISearchController <UISearchControllerDelegate, UISearchBarDelegate, UITableViewDataSource, UITableViewDelegate>

@property (nonatomic) BlogpostNetworkService *networkService;
@property (nonatomic) CCHMapClusterController *mapClusterController;
@property (nonatomic) double zoomDistance;

@end
