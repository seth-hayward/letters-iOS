//
//  RKPostComment.h
//  crushes
//
//  Created by Seth Hayward on 9/15/13.
//  Copyright (c) 2013 Seth Hayward. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface RKPostComment : NSObject

@property (nonatomic) NSNumber *letterId;
@property (nonatomic) NSString *comment;
@property (nonatomic) NSString *commenterName;
@property (nonatomic) NSString *commenterEmail;

@end
