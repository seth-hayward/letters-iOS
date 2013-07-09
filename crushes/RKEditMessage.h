//
//  RKEditMessage.h
//  crushes
//
//  Created by Seth Hayward on 7/9/13.
//  Copyright (c) 2013 Seth Hayward. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface RKEditMessage : NSObject
{
}
- (id)initWithMessage:(NSString *)new_message;

@property (nonatomic) NSNumber *response;
@property (nonatomic) NSString *message;

@end
