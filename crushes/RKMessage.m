//
//  RKMessage.m
//  crushes
//
//  Created by Seth Hayward on 6/30/13.
//  Copyright (c) 2013 Seth Hayward. All rights reserved.
//

#import "RKMessage.h"

@implementation RKMessage
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
    return [self initWithMessage:@" "];
}

@end
