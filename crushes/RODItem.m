//
//  RODItem.m
//  crushes
//
//  Created by Seth Hayward on 7/22/13.
//  Copyright (c) 2013 Seth Hayward. All rights reserved.
//

#import "RODItem.h"

@implementation RODItem
@synthesize viewType, caption, checked;

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
            checked = true;
            break;
        case ViewTypeMore:
            caption = @"More";
            checked = false;
            break;
        case ViewTypeBookmarks:
            caption = @"Bookmarks";
            checked = false;
            break;
        case ViewTypeSearch:
            caption = @"Search";
            checked = false;
            break;
        case ViewTypeSend:
            caption = @"Send";
            checked = false;
    }
    
    return self;
    
}

@end
