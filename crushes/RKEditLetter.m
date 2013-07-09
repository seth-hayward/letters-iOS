//
//  RKEditLetter.m
//  crushes
//
//  Created by Seth Hayward on 7/9/13.
//  Copyright (c) 2013 Seth Hayward. All rights reserved.
//

#import "RKEditLetter.h"

@implementation RKEditLetter
@synthesize letterText, id;

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
