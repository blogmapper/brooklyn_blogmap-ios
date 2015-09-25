//
//  BlogpostWebViewController.m
//  BlogMap
//
//  Created by Jacob Colleran on 3/25/15.
//  Copyright (c) 2015 blogMap. All rights reserved.
//
//  Portions of code below were copied or modified with permission from:
//
//  WebViewController.m
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

#import "BlogpostWebViewController.h"

#import "Blogpost.h"
#import "TUSafariActivity.h"
#import "CCHMapsActivity.h"
#import "AFNetworkActivityIndicatorManager.h"
#import "AppDelegate.h"
#import "Localization.h"

#import <AddressBook/AddressBook.h>

@interface BlogpostWebViewController ()

@property (weak, nonatomic) IBOutlet UIWebView *webView;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *activityBarButtonItem;

@property (nonatomic) UIBarButtonItem *activityIndicatorBarButtonItem;
@property (nonatomic) UIActivityIndicatorView *activityIndicatorView;
@property (nonatomic, getter = isNetworkActivityIndicatorVisible) BOOL networkActivityIndicatorVisible;
@property (nonatomic, copy) NSString *webViewTitle;

@end

@implementation BlogpostWebViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    //custom background
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
    
    // Display progress in navigation bar
    UIActivityIndicatorView * activityIndicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
    self.activityIndicatorView = activityIndicatorView;
    self.activityIndicatorBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:activityIndicatorView];
    [self.activityIndicatorBarButtonItem setStyle:UIBarButtonItemStylePlain];
    self.progressViewVisible = YES;
 
    //Load website
    self.webView.scalesPageToFit = YES;
    self.webView.contentMode = UIViewContentModeScaleAspectFit;
    NSURL *url = [Localization newSourceURLFromBlogpost:self.blogpost];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    self.webView.contentMode = UIViewContentModeScaleAspectFit;
    [self.webView loadRequest:request];
    //NSLog(@"%@", request);
    
    self.webView.delegate = self;
    
    //rounded corners for webview
    [[self.webView layer] setCornerRadius:10];
    [self.webView setClipsToBounds:YES];
}


- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self updateActivityButton];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    self.networkActivityIndicatorVisible = NO;
}

- (void)setProgressViewVisible:(BOOL)progressViewVisible
{
    if (progressViewVisible) {
        [self.activityIndicatorView startAnimating];
        self.navigationItem.rightBarButtonItem = self.activityIndicatorBarButtonItem;
    } else {
        [self.activityIndicatorView stopAnimating];
        self.navigationItem.rightBarButtonItem = self.activityBarButtonItem;
    }
}

- (void)setNetworkActivityIndicatorVisible:(BOOL)networkActivityIndicatorVisible
{
    if (networkActivityIndicatorVisible != _networkActivityIndicatorVisible) {
        if (networkActivityIndicatorVisible) {
            [AFNetworkActivityIndicatorManager.sharedManager incrementActivityCount];
        } else {
            [AFNetworkActivityIndicatorManager.sharedManager decrementActivityCount];
        }
        _networkActivityIndicatorVisible = networkActivityIndicatorVisible;
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)webViewDidStartLoad:(UIWebView *)webView
{
    self.webViewTitle = nil;
    [self updateActivityButton];
    self.progressViewVisible = YES;
}

- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    
    self.webViewTitle = [self.webView stringByEvaluatingJavaScriptFromString:@"document.title"];
    [self updateActivityButton];
    self.progressViewVisible = NO;
}

- (void)updateActivityButton
{
    self.activityBarButtonItem.enabled = (self.webViewTitle && self.webView.request.URL);
    
}

- (IBAction)showActivities:(UIBarButtonItem *)sender
{
    //create an MKMapItem to pass to the maps app
    NSMutableDictionary *addressDictionary = [NSMutableDictionary dictionaryWithCapacity:3];
    if (self.blogpost.address) {
        [addressDictionary setObject:self.blogpost.address forKey:(NSString *) kABPersonAddressStreetKey];
    }
    if (self.blogpost.neighborhood) {
        [addressDictionary setObject:self.blogpost.neighborhood forKey:(NSString *)kABPersonAddressCityKey];
    }
    CLLocationCoordinate2D coordinate = self.blogpost.locationCoordinate;
    MKPlacemark *placemark = [[MKPlacemark alloc] initWithCoordinate:coordinate addressDictionary:addressDictionary];
    MKMapItem *mapItem = [[MKMapItem alloc] initWithPlacemark:placemark];
    mapItem.name = [Localization newTitleFromBlogpst:self.blogpost];
    
    //configure activity items
    NSArray *itemToShare = @[self.webViewTitle, self.webView.request.URL, mapItem];
    TUSafariActivity *safariActivity = [[TUSafariActivity alloc] init];
    CCHMapsActivity *mapsActivity = [[CCHMapsActivity alloc] init];
    UIActivityViewController *activityViewController = [[UIActivityViewController alloc] initWithActivityItems:itemToShare applicationActivities:@[safariActivity, mapsActivity]];
    [self presentViewController:activityViewController animated:YES completion:nil];
}

@end
