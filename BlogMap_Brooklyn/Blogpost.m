//
//  Blogpost.m
//  BlogMap
//
//  Created by Jacob Colleran on 3/25/15.
//  Copyright (c) 2015 blogMap. All rights reserved.
//
//  Portions of code below were copied or modified with permission from:
//
//  Stolperstein.m
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

#import "Blogpost.h"

@implementation Blogpost

- (id)initWithID:(NSString *)ID type:(BlogpostType)type sourceName:(NSString *)sourceName category:(NSString *)category sourceURL:(NSURL *)sourceURL title:(NSString *)title author:(NSString *)author imageURL:(NSURL *)imageURL address:(NSString *)address fullAddress:(NSString *)fullAddress neighborhood:(NSString *)neighborhood locationCoordinate:(CLLocationCoordinate2D)locationCoordinate
{
    self = [super init];
    if (self) {
        _ID = ID;
        _type = type;
        _sourceName = sourceName;
        _category = category;
        _sourceURL = sourceURL;
        _title = title;
        _author = author;
        _imageURL = imageURL;
        _address = address;
        _fullAddress = fullAddress;
        _neighborhood = neighborhood;
        _locationCoordinate = locationCoordinate;
    }
    
    return self;
}

- (id)initWithCoder:(NSCoder *)decoder
{
    self = [super init];
    if (self) {
        _ID = [decoder decodeObjectForKey:@"ID"];
        _type = [decoder decodeIntegerForKey:@"type"];
        _sourceName = [decoder decodeObjectForKey:@"sourceName"];
        _category = [decoder decodeObjectForKey:@"category"];
        _sourceURL = [decoder decodeObjectForKey:@"sourceURL"];
        _title = [decoder decodeObjectForKey:@"title"];
        _author = [decoder decodeObjectForKey:@"author"];
        _imageURL = [decoder decodeObjectForKey:@"imageUrl"];
        _address = [decoder decodeObjectForKey:@"address"];
        _fullAddress = [decoder decodeObjectForKey:@"fullAddress"];
        _neighborhood = [decoder decodeObjectForKey:@"neighborhood"];
        _locationCoordinate.latitude = [decoder decodeDoubleForKey:@"locationCoordinate.latitude"];
        _locationCoordinate.longitude = [decoder decodeDoubleForKey:@"locationCoordinate.longitude"];
        
    }
    return self;
}

+ (instancetype)blogpostWithBuilderBlock:(void (^)(BlogpostComponents *builder))builderBlock
{
    NSParameterAssert(builderBlock);
    
    BlogpostComponents *builder = [[BlogpostComponents alloc] init];
    builderBlock(builder);
    
    return [builder blogpost];
}


- (void)encodeWithCoder:(NSCoder *)coder
{
    [coder encodeObject:self.ID forKey:@"ID"];
    [coder encodeInteger:self.type forKey:@"type"];
    [coder encodeObject:self.sourceName forKey:@"sourceName"];
    [coder encodeObject:self.category forKey:@"category"];
    [coder encodeObject:self.sourceURL forKey:@"sourceURL"];
    [coder encodeObject:self.title forKey:@"title"];
    [coder encodeObject:self.author forKey:@"author"];
    [coder encodeObject:self.imageURL forKey:@"imageUrl"];
    [coder encodeObject:self.address forKey:@"address"];
    [coder encodeObject:self.fullAddress forKey:@"fullAddress"];
    [coder encodeObject:self.neighborhood forKey:@"neighborhood"];
    [coder encodeDouble:self.locationCoordinate.latitude forKey:@"locationCoordinate.latitude"];
    [coder encodeDouble:self.locationCoordinate.longitude forKey:@"locationCoordinate.longitude"];
}

- (id)copyWithZone:(NSZone *)zone
{
    return self; //immutable
}

- (BOOL)isEqual:(id)other
{
    BOOL isEqual;
    
    if (![other isKindOfClass:self.class]) {
        isEqual = NO;
    } else {
        isEqual = [self isEqualToBlogpost:other];
    }
    
    return isEqual;
}

- (BOOL)isEqualToBlogpost:(Blogpost *)blogpost
{
    BOOL isEqual;
    
    if (blogpost == self) {
        isEqual = YES;
    } else if (blogpost == nil) {
        isEqual = NO;
    } else {
        isEqual = ((_ID == blogpost->_ID) || [_ID isEqualToString:blogpost->_ID]);
    }
    return isEqual;
}

- (BOOL)isExactMatchToBlogpost:(Blogpost *)blogpost
{
    BOOL isExactMatch;
    
    if (blogpost == nil) {
        isExactMatch = NO;
    } else {
        isExactMatch = ((_ID == blogpost->_ID) || [_ID isEqualToString:blogpost->_ID]) && (_type == blogpost->_type ) && ((_sourceName == blogpost->_sourceName) || [_sourceName isEqualToString:blogpost->_sourceName]) && ((_sourceURL == blogpost->_sourceURL) || [_sourceURL isEqual:blogpost->_sourceURL]) && ((_title == blogpost->_title) || [_title isEqualToString:blogpost->_title]) && ((_author == blogpost->_author) || [_author isEqualToString:blogpost->_author]) && ((_imageURL == blogpost->_imageURL) || [_imageURL isEqual:blogpost->_imageURL]) && ((_address == blogpost->_address) || [_address isEqualToString:blogpost->_address]) && ((_fullAddress == blogpost->_fullAddress) || [_fullAddress isEqualToString:blogpost->_fullAddress]) && ((_neighborhood == blogpost->_neighborhood) || [_neighborhood isEqualToString:blogpost->_neighborhood]) && (_locationCoordinate.latitude == blogpost->_locationCoordinate.latitude) && (_locationCoordinate.longitude == blogpost->_locationCoordinate.longitude);
    }
    return isExactMatch;
}

- (NSUInteger)hash
{
    return self.ID.hash;
}

- (CLLocationCoordinate2D)coordinate
{
    return self.locationCoordinate;
}

@end

@implementation BlogpostComponents

- (Blogpost *)blogpost
{
    return [[Blogpost alloc] initWithID:self.ID
                                  type:self.type
                            sourceName:self.sourceName
                              category:self.category
                             sourceURL:self.sourceURL
                                 title:self.title
                                author:self.author
                              imageURL:self.imageURL
                               address:self.address
                           fullAddress:self.fullAddress
                          neighborhood:self.neighborhood
                    locationCoordinate:self.locationCoordinate];
}



@end
