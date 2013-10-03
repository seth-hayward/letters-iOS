//
//  NavigationController.h
//  crushes
//
//  Created by Seth Hayward on 10/2/13.
//  Copyright (c) 2013 Seth Hayward. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MenuViewController.h"

@interface NavigationController : UINavigationController

@property (strong, readwrite, nonatomic) MenuViewController *menuViewController;

- (void)showMenu;

@end
