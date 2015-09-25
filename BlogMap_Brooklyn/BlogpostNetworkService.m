//
//  BlogpostNetworkService.m
//  BlogMap
//
//  Created by Jacob Colleran on 3/25/15.
//  Copyright (c) 2015 blogMap. All rights reserved.
//
//  Portions of code were copied or modified from below:
//
//  StolpersteineNetworkService.m
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

#import "BlogpostNetworkService.h"

#import "AFJSONRequestOperation.h"
#import "AFImageRequestOperation.h"
#import "AFHTTPClient.h"
#import "AFNetworkActivityIndicatorManager.h"
#import "Blogpost.h"
#import "BlogpostsSearchData.h"
#import "BlogpostNetworkServiceDelegate.h"
#import "NSDictionary+BlogpostParser.h"

//static NSString * const API_URL = @"http://localhost/~jakecoll/phpmyadmin/stumblrPhilly_con.php";
static NSString * const API_URL = @"http://stumblr-api.elasticbeanstalk.com";

@interface BlogpostNetworkService ()

@property (nonatomic, strong) AFHTTPClient *httpClient;
@property (nonatomic, strong) NSString *encodedClientCredentials;

@end

@implementation BlogpostNetworkService

- (instancetype)initWithClientUser:(NSString *)clientUser clientPassword:(NSString *)clientPassword
{
    self = [super init];
    if (self) {
        _httpClient = [[AFHTTPClient alloc] initWithBaseURL:[NSURL URLWithString:API_URL]];
        _httpClient.parameterEncoding = AFJSONParameterEncoding;
        [_httpClient registerHTTPOperationClass:AFJSONRequestOperation.class];
        
        if (clientUser && clientPassword) {
            NSString *clientCredentials = [NSString stringWithFormat:@"%@:%@", clientUser, clientPassword];
            _encodedClientCredentials = [[clientCredentials dataUsingEncoding:NSUTF8StringEncoding] base64EncodedStringWithOptions:0];
        }
        
        AFNetworkActivityIndicatorManager.sharedManager.enabled = YES;
    }
    
    return self;
}

- (void)setAllowInvalidSSLCertificate:(BOOL)allowInvalidSSLCertificate
{
    self.httpClient.allowsInvalidSSLCertificate = allowInvalidSSLCertificate;
}

- (BOOL)allowInvalidSSLCertificate
{
    return self.httpClient.allowsInvalidSSLCertificate;
}

- (void)addBasicAuthHeaderToRequest:(NSMutableURLRequest *)request
{
    if (self.encodedClientCredentials) {
        NSString *basicHeader = [NSString stringWithFormat:@"Basic %@", self.encodedClientCredentials];
        [request setValue:basicHeader forHTTPHeaderField:@"Authorization"];
    }
}

- (void)handleGlobalError:(NSError *)error
{
    if ([self.delegate respondsToSelector:@selector(blogpostNetworkService:handleError:)])
    {
            if ([error.domain isEqualToString:AFNetworkingErrorDomain] && error.code != NSURLErrorCancelled)
            {
                [self.delegate blogpostNetworkService:self handleError:error];
            }
    }
}

- (NSOperation *)retrieveBlogpostsWithSearchData:(BlogpostsSearchData *)searchData range:(NSRange)range completionHandler:(BOOL (^)(NSArray *, NSError *))completionHandler
{
    NSMutableDictionary *parameters = [[NSMutableDictionary alloc] init];
    
    //optional parameters
    NSString *keyword = searchData.keywordsString ? searchData.keywordsString : self.defaultSearchData.keywordsString;
    if (keyword) {
        [parameters setObject:keyword forKey:@"q"];
    }
    NSString *address = searchData.address ? searchData.address : self.defaultSearchData.address;
    if (address) {
        [parameters setObject:address forKey:@"address"];
    }
    NSString *city = searchData.city ? searchData.city : self.defaultSearchData.city;
    if (city) {
        [parameters setObject:city forKey:@"city"];
    }
    
    //mandatory parameters
    [parameters setObject:@(range.length) forKey:@"limit"];
    [parameters setObject:@(range.location) forKey:@"offset"];

    //issue report
    NSMutableURLRequest *request = [self.httpClient requestWithMethod:@"GET" path:@"" parameters:parameters];
    [self addBasicAuthHeaderToRequest:request];
    
    AFJSONRequestOperation *operation = [AFJSONRequestOperation JSONRequestOperationWithRequest:request success:^(NSURLRequest *request, NSHTTPURLResponse *response, NSArray *blogpostsAsJSON) {
        //Parse on background Thread
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
            NSMutableArray *blogposts = [NSMutableArray arrayWithCapacity:blogpostsAsJSON.count];
            for (NSDictionary *blogpostAsJSON in blogpostsAsJSON) {
                Blogpost *blogpost = [blogpostAsJSON newBlogpost];
                [blogposts addObject:blogpost];
                //NSLog(@"%@", blogpostsAsJSON);
            }
            
            if (completionHandler) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    completionHandler (blogposts, nil);
                });
            }
        });
        
    } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON) {
        if (error) {
            NSLog(@"Error: %@", error);
        }
        
        BOOL shouldRunGlobalErrorHandler = YES;
        if (completionHandler) {
            shouldRunGlobalErrorHandler = completionHandler(nil, error);
        }
        
        if (shouldRunGlobalErrorHandler) {
            [self handleGlobalError:error];
        }
    }];
    
    operation.allowsInvalidSSLCertificate = self.httpClient.allowsInvalidSSLCertificate;
    [self.httpClient enqueueHTTPRequestOperation:operation];
    NSLog(@"%@", operation);
    
    return operation;
}

@end
