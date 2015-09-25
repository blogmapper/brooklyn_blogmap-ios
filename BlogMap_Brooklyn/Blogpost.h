//
//  Blogpost.h
//  BlogMap
//
//  Created by Jacob Colleran on 3/25/15.
//  Copyright (c) 2015 blogMap. All rights reserved.
//
//  Portions of code below were copied or modified with permission from:
//
//  Stolperstein.h
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

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>

@class BlogpostComponents;

typedef NS_ENUM(NSInteger, BlogpostType) {
    BlogpostTypeBlogpost,
    BlogpostTypeBlogposts,
};

@interface Blogpost : NSObject<MKAnnotation, NSCoding, NSCopying>

@property (nonatomic, readonly, copy) NSString *ID;
@property (nonatomic, readonly) BlogpostType type;
@property (nonatomic, readonly, copy) NSString *sourceName;
@property (nonatomic, readonly, copy) NSString *category;
@property (nonatomic, readonly, copy) NSURL *sourceURL;
@property (nonatomic, readonly, copy) NSString *title;
@property (nonatomic, readonly, copy) NSString *author;
@property (nonatomic, readonly, copy) NSURL *imageURL;
@property (nonatomic, readonly, copy) NSString *address;
@property (nonatomic, readonly, copy) NSString *fullAddress;
@property (nonatomic, readonly, copy) NSString *neighborhood;
@property (nonatomic, readonly) CLLocationCoordinate2D locationCoordinate;

- (instancetype)initWithID:(NSString *)ID
                      type:(BlogpostType)type
                sourceName:(NSString *)sourceName
                  category:(NSString *)category
                 sourceURL:(NSURL *)sourceURL
                     title:(NSString *)title
                    author:(NSString *)author
                  imageURL:(NSURL *)imageURL
                   address:(NSString *)address
               fullAddress:(NSString *)fullAddress
              neighborhood:(NSString *)neighborhood
        locationCoordinate:(CLLocationCoordinate2D)locationCoordinate;
+ (instancetype)blogpostWithBuilderBlock:(void(^)(BlogpostComponents *builder))builderBlock;

- (instancetype)initWithCoder:(NSCoder *)decoder;
- (void)encodeWithCoder:(NSCoder *)coder;

- (BOOL)isEqualToBlogpost:(Blogpost *)blogpost;
- (BOOL)isExactMatchToBlogpost:(Blogpost *)blogpost;

@end

@interface BlogpostComponents : NSObject

@property (nonatomic, copy) NSString *ID;
@property (nonatomic) BlogpostType type;
@property (nonatomic, copy) NSString *sourceName;
@property (nonatomic, copy) NSURL *sourceURL;
@property (nonatomic, copy) NSString *category;
@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy) NSString *author;
@property (nonatomic, copy) NSURL *imageURL;
@property (nonatomic, copy) NSString *address;
@property (nonatomic, copy) NSString *fullAddress;
@property (nonatomic, copy) NSString *neighborhood;
@property (nonatomic) CLLocationCoordinate2D locationCoordinate;

- (Blogpost *)blogpost;

@end
