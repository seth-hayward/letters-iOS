//
//  RKFullLetter.m
//  crushes
//
//  Created by Seth Hayward on 7/8/13.
//  Copyright (c) 2013 Seth Hayward. All rights reserved.
//

#import "RKFullLetter.h"

@implementation RKFullLetter
@synthesize Id, letterMessage, letterTags, letterPostDate, letterUp, letterLevel, letterLanguage,
            senderIP, senderCountry, senderRegion, senderCity, letterComments;

- (id)initWithLetterMessage:(NSString *)message
{
    self = [super init];
    
    if (self) {
        [self setLetterText:message];
    }
    
    return self;
}

- (id)init
{
    return [self initWithLetterMessage:@" "];
}

@end
