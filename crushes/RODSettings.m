//
//  RODSettings.m
//  crushes
//
//  Created by Seth Hayward on 8/19/13.
//  Copyright (c) 2013 Seth Hayward. All rights reserved.
//

#import "RODSettings.h"

@implementation RODSettings
@synthesize loginStatus;

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super init];
    
    if (self) {
        [self setLoginStatus:[aDecoder decodeObjectForKey:@"loginStatus"]];
    }
    
    return self;
}

- (void) encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject:loginStatus forKey:@"loginStatus"];
}

@end
