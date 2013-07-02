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

@property (nonatomic) NSString *letterText;
@property (nonatomic) NSString *letterCountry;
@property (nonatomic, copy) NSString *mobile;

@end
