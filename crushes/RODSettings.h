//
//  RODSettings.h
//  crushes
//
//  Created by Seth Hayward on 8/19/13.
//  Copyright (c) 2013 Seth Hayward. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface RODSettings : NSObject <NSCoding>
{
    NSMutableArray *_sentLetters;    
}

- (NSArray *)sentLetters;

@property (nonatomic) NSNumber *loginStatus;
@property (nonatomic) NSString *userName;
@property (nonatomic) NSString *password;


@end
