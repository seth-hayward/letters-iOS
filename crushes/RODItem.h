//
//  RODItem.h
//  crushes
//
//  Created by Seth Hayward on 7/22/13.
//  Copyright (c) 2013 Seth Hayward. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum {
    ViewTypeHome,
    ViewTypeMore,
    ViewTypeBookmarks,
    ViewTypeSearch
} ViewType;

@interface RODItem : NSObject


- (id) initWithType:(ViewType)new_viewType;

@property (nonatomic) NSString *caption;
@property (nonatomic) ViewType viewType;
@property (nonatomic) Boolean checked;

@end
