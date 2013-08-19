//
//  RKFullLetter.h
//  crushes
//
//  Created by Seth Hayward on 7/8/13.
//  Copyright (c) 2013 Seth Hayward. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface RKFullLetter : NSObject
- (id)initWithLetterMessage:(NSString *)message;

@property (nonatomic) NSString *letterText;
@property (nonatomic) NSString *letterCountry;
@property (nonatomic, copy) NSString *mobile;

@property (nonatomic) NSNumber *Id;
@property (nonatomic) NSString *letterMessage;
@property (nonatomic) NSString *letterTags;
@property (nonatomic) NSString *letterPostDate;
@property (nonatomic) NSNumber *letterUp;
@property (nonatomic) NSNumber *letterLevel;
@property (nonatomic) NSString *letterLanguage;
@property (nonatomic) NSString *senderIP;
@property (nonatomic) NSString *senderCountry;
@property (nonatomic) NSString *senderRegion;
@property (nonatomic) NSString *senderCity;
@property (nonatomic) NSNumber *letterComments;

@property (nonatomic) NSNumber *fromFacebookUID;
@property (nonatomic) NSNumber *toFacebookUID;

@end
