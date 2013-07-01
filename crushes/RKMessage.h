//
//  RKMessage.h
//  crushes
//
//  Created by Seth Hayward on 6/30/13.
//  Copyright (c) 2013 Seth Hayward. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface RKMessage : NSObject
- (id)initWithMessage:(int)new_message;

@property (nonatomic) int *response;
@property (nonatomic) int *message;
@property (nonatomic, copy) NSString *guid;

@end
