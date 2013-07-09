//
//  RKEditMessage.m
//  crushes
//
//  Created by Seth Hayward on 7/9/13.
//  Copyright (c) 2013 Seth Hayward. All rights reserved.
//

#import "RKEditMessage.h"

@implementation RKEditMessage
@synthesize response, message;

- (id)initWithMessage:(NSString *)new_message
{
    self = [super init];
    
    if (self) {
        [self setMessage:new_message];
    }
    
    return self;
}

- (id)init
{
    return [self initWithMessage:0];
}

@end
