//
//  MenuViewController.m
//  crushes
//
//  Created by Seth Hayward on 7/21/13.
//  Copyright (c) 2013 Seth Hayward. All rights reserved.
//

#import "MenuViewController.h"
#import "RODItem.h"

@implementation MenuViewController

- (id) init {
    self = [super initWithStyle:UITableViewStyleGrouped];
    if (self) {
        
        RODItem *test = [[RODItem alloc] initWithType:ViewTypeHome];
        NSLog(@"test: %@", [test caption]);
        
    }
    return self;
}

-(id) initWithStyle:(UITableViewStyle)style
{
    return [self init];
}

@end
