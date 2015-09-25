//
//  BlogpostSynchronizationController.m
//  BlogMap
//
//  Created by Jacob Colleran on 3/25/15.
//  Copyright (c) 2015 blogMap. All rights reserved.
//
//  Portions of code were copied or modified from below:
//
//  StolpersteineSynchronizationController.m
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

#import "BlogpostSynchronizationController.h"

#import "BlogpostNetworkService.h"
#import "BlogpostSynchronizationControllerDelegate.h"

#define NETWORK_BATCH_SIZE 500

@interface BlogpostSynchronizationController()

@property (nonatomic) BlogpostNetworkService *networkService;
@property (nonatomic, weak) NSOperation *retrieveBlogpostsOperation;
@property (nonatomic, getter = isSynchronizing) BOOL synchronizing;
@property (nonatomic) NSMutableSet *blogposts;

@end

@implementation BlogpostSynchronizationController

- (instancetype)initWithNetworkService:(BlogpostNetworkService *)networkService
{
    self = [super init];
    if (self) {
        _networkService = networkService;
        _blogposts = [NSMutableSet setWithCapacity:NETWORK_BATCH_SIZE];
    }
    
    return self;
}

- (void)synchronize
{
    if (!self.isSynchronizing) {
        [self didStartSynchronization];
        
        NSRange range = NSMakeRange(0, NETWORK_BATCH_SIZE);
        [self retrieveBlogpostsWithRange:range];
    }
}


- (void)retrieveBlogpostsWithRange:(NSRange)range //API retrieval
{
    [self.retrieveBlogpostsOperation cancel];
    self.retrieveBlogpostsOperation = [self.networkService retrieveBlogpostsWithSearchData:nil range:range completionHandler:^BOOL(NSArray *blogposts, NSError *error) {
        if (error == nil) {
            [self didAddBlogposts:blogposts];
            
            if (blogposts.count == range.length) {
                //next batch of data
                NSRange nextRange = NSMakeRange(NSMaxRange(range), range.length);
                [self retrieveBlogpostsWithRange:nextRange];
            } else {
                [self didEndSynchronization];
            }
        } else {
            [self didFailSynchronization];
        }
        
        return (self.blogposts.count == 0);
    }];
}

- (void)didAddBlogposts:(NSArray *)blogposts
{
    //filter out items that are already on map
    NSMutableSet *additionalBlogpostsAsSet = [NSMutableSet setWithArray:blogposts];
    [additionalBlogpostsAsSet minusSet:self.blogposts];
    NSArray *additionalBlogposts = additionalBlogpostsAsSet.allObjects;
    [self.blogposts addObjectsFromArray:additionalBlogposts];
    
    //tell delegate about additional items
    if (additionalBlogposts.count > 0 && [self.delegate respondsToSelector:@selector(blogpostSynchronizationController:didAddBlogposts:)]) {
        [self.delegate blogpostSynchronizationController:self didAddBlogposts:additionalBlogposts];
    }
    
    // Formula for storing locally
    //    [self.readWriteDataService createStolpersteine:additionalStolpersteine completionHandler:^{
    //        // Tell delegate about additional items
    //        if (additionalStolpersteine.count > 0 && [self.delegate respondsToSelector:@selector(stolpersteinSynchronizationController:didAddStolpersteine:)]) {
    //            [self.delegate stolpersteinSynchronizationController:self didAddStolpersteine:additionalStolpersteine];
    //        }
    //    }];
}

- (void)didStartSynchronization
{
    self.synchronizing = YES;
}

- (void)didEndSynchronization
{
    self.synchronizing = NO;
}

- (void)didFailSynchronization;
{
    self.synchronizing = NO;
}

@end
