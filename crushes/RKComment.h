//
//  RKComment.h
//  crushes
//
//  Created by Seth Hayward on 8/7/13.
//  Copyright (c) 2013 Seth Hayward. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface RKComment : NSObject
{
    
}

@property (nonatomic) NSNumber *Id;
@property (nonatomic) NSString *commentMessage;
@property (nonatomic) NSString *commenterName;
@property (nonatomic) NSString *letterId;
@property (nonatomic) NSString *sendEmail;
@property (nonatomic) NSDate *commentDate;
@property (nonatomic) NSNumber *hearts;
@property (nonatomic) NSString *commenterEmail;
@property (nonatomic) NSString *commenterGuid;
@property (nonatomic) NSNumber *level;
@property (nonatomic) NSString *commenterIP;

@end
