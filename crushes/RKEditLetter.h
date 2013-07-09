//
//  RKEditLetter.h
//  crushes
//
//  Created by Seth Hayward on 7/9/13.
//  Copyright (c) 2013 Seth Hayward. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface RKEditLetter : NSObject
{

}
- (id)initWithLetterMessage:(NSString *)message;

@property (nonatomic) NSString *letterText;
@property (nonatomic) NSString *letterId;
@property (nonatomic) NSString *mobile;

@end
