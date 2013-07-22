//
//  RODItemStore.m
//  crushes
//
//  Created by Seth Hayward on 7/22/13.
//  Copyright (c) 2013 Seth Hayward. All rights reserved.
//

#import "RODItemStore.h"
#import "RODItem.h"

@implementation RODItemStore

- (id)init {
    self = [super init];
    if(self) {
        allMenuItems = [[NSMutableArray alloc] init];
    }
    
    return self;
}

- (NSArray *)allMenuItems
{
    return allMenuItems;
}

- (RODItem *)createItem:(ViewType) new_Type
{
    RODItem *p = [[RODItem alloc] initWithType:new_Type];
    [allMenuItems addObject:p];
    
    return p;
}

+ (RODItemStore *)sharedStore {
    static RODItemStore *sharedStore = nil;
    if(!sharedStore) {
        sharedStore = [[super allocWithZone:nil] init];
    }
    
    return sharedStore;
}

+ (id)allocWithZone:(NSZone *)zone {
    return [self sharedStore];
}

@end