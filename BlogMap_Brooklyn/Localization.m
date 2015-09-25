//
//  Localization.m
//  BlogMap
//
//  Created by Jacob Colleran on 3/25/15.
//  Copyright (c) 2015 blogMap. All rights reserved.
//
//  Portions of code below were copied or modified with permission from:
//
//  Localization.m
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


#import "Localization.h"

#import "Blogpost.h"
#import "CCHMapClusterAnnotation.h"

@implementation Localization

+ (NSString *)newTitleFromBlogpst:(Blogpost *)blogpost
{
    NSMutableString *title = [NSMutableString stringWithCapacity:blogpost.title.length + 1];
    if (blogpost.title.length > 0) {
        [title appendString:blogpost.title];
    }
    
    return title;
}

+ (NSString *)newShortTitleFromBlogpost:(Blogpost *)blogpost
{
    NSInteger stringCapacity = 60;
    NSMutableString *newTitle = [NSMutableString stringWithCapacity:stringCapacity];
    if (blogpost.title.length > 0) {
        NSInteger subtringIndex = stringCapacity - 3;
        if (blogpost.title.length > subtringIndex - 1) {
        [newTitle appendFormat:@"%@...", [blogpost.title substringToIndex:subtringIndex]];
        } else {
            [newTitle appendFormat:@"%@", blogpost.title];
        }
    }
    
    return newTitle;
}

+ (NSString *)newSourceFromBlogpost:(Blogpost *)blogpost
{
    NSMutableString *source = [NSMutableString stringWithCapacity:blogpost.sourceName.length + 1];
    if (blogpost.sourceName.length > 0) {
        [source appendString:blogpost.sourceName];
    }
    
    return source;
}

+ (NSString *)newAddressFromBlogpost:(Blogpost *)blogpost
{
    NSRange range = [blogpost.address rangeOfCharacterFromSet:NSCharacterSet.decimalDigitCharacterSet];
    NSString *locationAddress = blogpost.address;
    if (range.location != NSNotFound) {
        locationAddress = [locationAddress substringToIndex:range.location];
        locationAddress = [locationAddress stringByTrimmingCharactersInSet:NSCharacterSet.whitespaceCharacterSet];
    }
    
    return locationAddress;
}

+ (NSString *)newNeighborhoodFromBlogpost:(Blogpost *)blogpost
{
    NSMutableString *neighborhood = [NSMutableString stringWithCapacity:blogpost.neighborhood.length + 1];
    if (blogpost.neighborhood.length > 0) {
        [neighborhood appendString:blogpost.neighborhood];
    }
    
    return neighborhood;
}

+ (NSString *)newLongAddressFromBlogpost:(Blogpost *)blogpost
{
    NSMutableString *address = [NSMutableString stringWithString:blogpost.address];
    if (blogpost.neighborhood) {
        [address appendFormat:@", %@", blogpost.neighborhood];
    }
    return address;
}

+ (NSString *)newPasteboardStringFromBlogpost:(Blogpost *)blogpost
{
    NSString *title = [Localization newTitleFromBlogpst:blogpost];
    NSString *address = [Localization newAddressFromBlogpost:blogpost];
    NSString *source = [Localization newSourceFromBlogpost:blogpost];
    NSMutableString *string = [NSMutableString stringWithFormat:@"%@\n%@\n%@", title, address, source];
    NSString *localizedSourceURLString = [[self.class newSourceURLFromBlogpost:blogpost] absoluteString];
    if (localizedSourceURLString) {
        [string appendString:@"\n"];
        [string appendString:localizedSourceURLString];
    }
    
    return string;
}

+ (NSURL *)newSourceURLFromBlogpost:(Blogpost *)blogpost
{
    NSString *sourceURLString = blogpost.sourceURL.absoluteString;
    
    return [NSURL URLWithString:sourceURLString];
    //NSLog(@"%@", sourceURLString);
}

+ (NSURL *)newImageURLFromBlogpost:(Blogpost *)blogpost
{
    NSString *imageURLString = blogpost.imageURL.absoluteString;
    
    return [NSURL URLWithString:imageURLString];
}

+ (NSURL *)newThumbnailImageFromMapClusterAnnotation:(CCHMapClusterAnnotation *)mapClusterAnnotation
{
    
    Blogpost *blogpost = [mapClusterAnnotation.annotations anyObject];
    return [Localization newImageURLFromBlogpost:blogpost];
}

+ (NSString *)newTitleFromMapClusterAnnotation:(CCHMapClusterAnnotation *)mapClusterAnnotation
{
    NSString *title;
    if (mapClusterAnnotation.isCluster) {
        NSUInteger numBlogposts = MIN(mapClusterAnnotation.annotations.count, 1);
        NSArray *blogposts = [mapClusterAnnotation.annotations.allObjects subarrayWithRange:NSMakeRange(0, numBlogposts)];
        NSMutableArray *neighborhoods = [NSMutableArray arrayWithCapacity:numBlogposts];
        for (Blogpost *blogpost in blogposts) {
            [neighborhoods addObject:[Localization newNeighborhoodFromBlogpost:blogpost]];
        }
        title = [neighborhoods componentsJoinedByString:@", "];
    }   else {
        Blogpost *blogpost = [mapClusterAnnotation.annotations anyObject];
        title = [Localization newLongAddressFromBlogpost:blogpost];
    }
    
    return title;
}

+ (NSString *)newSubtitleFromMapClusterAnnotation:(CCHMapClusterAnnotation *)mapClusterAnnotation
{
    NSString *subtitle;
    if (mapClusterAnnotation.isUniqueLocation && (mapClusterAnnotation.annotations.count < 2)) {
        Blogpost *blogpost = [mapClusterAnnotation.annotations anyObject];
        subtitle = [NSString stringWithFormat:@"Blog: %@", [Localization newSourceFromBlogpost:blogpost]];
    } else {
        subtitle = [Localization newBlogpostsCountFromCount:mapClusterAnnotation.annotations.count];
    }
    
    return subtitle;
}

+ (NSString *)newBlogpostsCountFromCount:(NSUInteger)count 
{
    NSString *localizedKey = count > 1 ? @"Blog Posts" : @"Blog Post";
    NSString *localizedName = localizedKey;
    return [NSString stringWithFormat:@"%tu %@", count, localizedName];
}

@end
