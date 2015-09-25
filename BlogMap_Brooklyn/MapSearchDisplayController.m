//
//  MapSearchDisplayController.m
//  Stumblr_Beta
//
//  Created by Jacob Colleran on 3/29/15.
//  Copyright (c) 2015 Stumblr. All rights reserved.
//

#import "MapSearchDisplayController.h"

#import "AppDelegate.h"
//#import "DiagnosticsService.h"
#import "Localization.h"

#import "Blogpost.h"
#import "BlogpostsSearchData.h"
#import "BlogpostNetworkService.h"

#import "CCHMapClusterController.h"

#define REQUEST_DELAY 0.3
#define REQUEST_SIZE 20

@interface MapSearchDisplayController()

@property (nonatomic, copy) NSArray *searchedBlogposts;
@property (nonatomic, copy) NSOperation *searchBlogpostsOperation;
@property (nonatomic, copy) UIBarButtonItem *originalBarButtonItem;
@property (strong, nonatomic) UISearchController *searchController;

@end

@implementation MapSearchDisplayController

#pragma mark - Search controller

- (void)searchBar:(UISearchBar *)searchBar selectedScopeButtonIndexDidChange:(NSInteger)selectedScope
{
    [self updateSearchResultsForSearchController:self.searchController];
    //[NSObject cancelPreviousPerformRequestsWithTarget:self];
    //[self performSelector:@selector(updateSearchData:) withObject:searchString afterDelay:REQUEST_DELAY];
}

- (void)updateSearchResultsForSearchController:(UISearchController *)searchController
{
    NSString *searchString = searchController.searchBar.text;
    [self searchForText:searchString scope:searchController.searchBar.selectedScopeButtonIndex];
    [self.tableView reloadData];
}

@end
