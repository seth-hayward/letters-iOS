//
//  RKLetter.h
//  crushes
//
//  Created by Seth Hayward on 6/30/13.
//  Copyright (c) 2013 Seth Hayward. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface RKLetter : NSObject
{
}

- (id)initWithLetterMessage:(NSString *)message;

@property (nonatomic, copy) NSString *lettertext;
@property (nonatomic, copy) NSString *lettercountry;

@end
