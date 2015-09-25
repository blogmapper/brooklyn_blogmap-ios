//
//  AppDelegate.m
//  BlogMap
//
//  Created by Jacob Colleran on 3/25/15.
//  Copyright (c) 2015 blogMap. All rights reserved.
//
//  Portions of code below were copied or modified with permission from:
//
//  AppDelegate.m
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

#import "AppDelegate.h"

#import "BlogpostNetworkService.h"
#import "BlogpostsSearchData.h"
#import "ConfigurationService.h"


@interface AppDelegate()

@property (nonatomic) BlogpostNetworkService *networkService;
@property (nonatomic) ConfigurationService *configurationService;

@end

@implementation AppDelegate

+ (BlogpostNetworkService *)networkService
{
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    return appDelegate.networkService;
}

+ (ConfigurationService *)configurationService
{
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    return appDelegate.configurationService;
}

#pragma mark - Application


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{

    //early out when running unit tests
    BOOL runningTests = NSClassFromString(@"XCTestCase") != nil;
    if (runningTests) {
        return YES;
    }
    
    //app version info
    NSLog(@"Stumblr_beta %@ (%@)", [ConfigurationService appShortVersion], [ConfigurationService appVersion]);
    
    //configuration service
    NSString *configurationsFile = [NSBundle.mainBundle pathForResource:@"Stumblr_Beta-Config" ofType:@"plist"];
    self.configurationService = [[ConfigurationService alloc] initWithConfigurationsFile:configurationsFile];
    
    //network service
    NSString *clientUser = [self.configurationService stringConfigurationForKey:ConfigurationServiceKeyAPIUser];
    NSString *clientPassword = [self.configurationService stringConfigurationForKey:ConfigurationServiceKeyAPIUser];
    self.networkService = [[BlogpostNetworkService alloc] initWithClientUser:clientUser clientPassword:clientPassword];
    NSString *city = [self.configurationService stringConfigurationForKey:ConfigurationServiceKeyFilterCity];
    self.networkService.defaultSearchData = [[BlogpostsSearchData alloc] initWithKeywordString:nil address:nil city:city];
    self.networkService.delegate = self;
    
#ifdef DEBUG
    //this allow invalid certificates so that proxies can decrypt the network traffic
    self.networkService.allowInvalidSSLCertificate = YES;
#endif

    // Override point for customization after application launch.
    return YES;
}

#pragma mark - Blogpost network service

- (void)blogpostNetworkService:(BlogpostNetworkService *)blogpostNetworkService handleError:(NSError *)error
{
    NSString *errorTitle = @"Network Error";
    NSString *errorMessage = @"Couldn't load data. Please try again later.";
    NSString *errorButtonTitle = @"OK";
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:errorTitle message:errorMessage delegate:nil cancelButtonTitle:errorButtonTitle otherButtonTitles:nil];
    [alert show];
}

@end

