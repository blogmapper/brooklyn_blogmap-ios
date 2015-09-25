//
//  NSDictionary+BlogpostParser.m
//  BlogMap
//
//  Created by Jacob Colleran on 3/25/15.
//  Copyright (c) 2015 blogMap. All rights reserved.
//
//  Portions of code were copied or modified from below:
//
//  NSDictionary+StolpersteinParsing.m
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

#import "NSDictionary+BlogpostParser.h"
#import "Blogpost.h"

@implementation NSDictionary (BlogpostParser)

- (Blogpost *)newBlogpost
{
    Blogpost *blogpost = [Blogpost blogpostWithBuilderBlock:^(BlogpostComponents *builder) {
        builder.ID = [self valueForKeyPath:@"id"];
        builder.sourceName = [self valueForKeyPath:@"sourceName"];
        builder.category = [self valueForKey:@"category"];
        builder.sourceURL = [NSURL URLWithString:[self valueForKeyPath:@"url"]];
        builder.title = [self valueForKeyPath:@"title"];
        builder.author = [self valueForKeyPath:@"author"];
        builder.imageURL = [NSURL URLWithString:[self valueForKeyPath:@"imgUrl"]];
        builder.address = [self valueForKeyPath:@"address"];
        builder.fullAddress = [self valueForKeyPath:@"full_address"];
        builder.neighborhood = [self valueForKeyPath:@"neighborhood"];
        
        if ([[self valueForKey:@"type"] isEqualToString:@"blogposts"])
        {
            builder.type = BlogpostTypeBlogposts;
        } else {
            builder.type = BlogpostTypeBlogpost;
        }
        
        NSString *latitudeAsString = [self valueForKeyPath:@"lat"];
        NSString *longitudeAsString = [self valueForKeyPath:@"lng"];
        builder.locationCoordinate = CLLocationCoordinate2DMake(latitudeAsString.doubleValue, longitudeAsString.doubleValue);
    }];
    return blogpost;
}

@end
