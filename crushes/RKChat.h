//
//  RKChat.h
//  crushes
//
//  Created by Seth Hayward on 9/6/13.
//  Copyright (c) 2013 Seth Hayward. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface RKChat : NSObject

@property (nonatomic) NSDate *ChatDate;
@property (nonatomic) NSString *IP;
@property (nonatomic) NSString *Message;
@property (nonatomic) NSString *Nick;
@property (nonatomic) NSString *Room;
@property (nonatomic) BOOL StoredInDB;

@end
