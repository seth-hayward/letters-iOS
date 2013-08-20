//
//  RODSentLetter.m
//  crushes
//
//  Created by Seth Hayward on 8/20/13.
//  Copyright (c) 2013 Seth Hayward. All rights reserved.
//

#import "RODSentLetter.h"

@implementation RODSentLetter
@synthesize letter_id, guid;

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super init];
    
    if (self) {
        [self setLetter_id:[aDecoder decodeObjectForKey:@"letter_id"]];
        [self setGuid:[aDecoder decodeObjectForKey:@"guid"]];
    }
    
    return self;
}

- (void) encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject:letter_id forKey:@"letter_id"];
    [aCoder encodeObject:guid forKey:@"guid"];
}

@end
