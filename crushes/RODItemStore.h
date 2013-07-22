//
//  RODItemStore.h
//  crushes
//
//  Created by Seth Hayward on 7/22/13.
//  Copyright (c) 2013 Seth Hayward. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RODItem.h"


@interface RODItemStore : NSObject
{
    NSMutableArray *allMenuItems;
}

+ (RODItemStore *)sharedStore;

- (NSArray *)allMenuItems;
- (RODItem *)createItem:(ViewType) new_Type;

@end
