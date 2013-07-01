//
//  RKLetter.m
//  crushes
//
//  Created by Seth Hayward on 6/30/13.
//  Copyright (c) 2013 Seth Hayward. All rights reserved.
//

#import "RKLetter.h"

@implementation RKLetter
@synthesize lettertext, lettercountry;

- (id)initWithLetterMessage:(NSString *)message
{
    self = [super init];
    
    if (self) {
        [self setLettertext:message];
    }
    
    return self;
}

- (id)init
{
    return [self initWithLetterMessage:@" "];
}

@end

