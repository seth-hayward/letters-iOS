//
//  RODItemStore.h
//  crushes
//
//  Created by Seth Hayward on 7/22/13.
//  Copyright (c) 2013 Seth Hayward. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RODItem.h"
#import "RKFullLetter.h"

@interface RODItemStore : NSObject
{
    NSMutableArray *allMenuItems;
    NSMutableArray *allLetters;
}

+ (RODItemStore *)sharedStore;

- (NSArray *)allMenuItems;
- (NSArray *)allLetters;

- (RODItem *)createItem:(ViewType) new_Type;
- (RKFullLetter *)createLetter:(NSString *) letter;

@end
