//
//  RODItem.m
//  crushes
//
//  Created by Seth Hayward on 7/22/13.
//  Copyright (c) 2013 Seth Hayward. All rights reserved.
//

#import "RODItem.h"

@implementation RODItem
@synthesize viewType, caption;

- (id) init {
    self = [super init];
    
    if(self) {
        
        
    }
    return self;
}

- (id) initWithType:(ViewType)new_viewType {
 
    self = [super init];
    
    viewType = new_viewType;
    
    switch(new_viewType) {
        case ViewTypeHome:
            caption = @"Home";
            break;
        case ViewTypeMore:
            caption = @"More";
            break;
        case ViewTypeBookmarks:
            caption = @"Bookmarks";
            break;
        case ViewTypeSearch:
            caption = @"Search";
            break;
    }
    
    return self;
    
}

@end
