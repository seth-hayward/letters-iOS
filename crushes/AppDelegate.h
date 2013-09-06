//
//  AppDelegate.h
//  crushes
//
//  Created by Seth Hayward on 12/6/12.
//  Copyright (c) 2012 Seth Hayward. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SendViewController.h"
#import "MMDrawerController.h"
#import "LettersScrollController.h"
#import "SearchViewController.h"
#import "MenuViewController.h"
#import "ChatNameViewController.h"

@interface AppDelegate : UIResponder <UIApplicationDelegate, UITabBarControllerDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic) SendViewController *sendViewController;
@property (strong, nonatomic) SearchViewController *searchViewController;
@property (strong, nonatomic) MMDrawerController *drawer;
@property (strong, nonatomic) LettersScrollController *lettersScrollController;
@property (strong, nonatomic) MenuViewController *menuViewController;
@property (strong, nonatomic) ChatNameViewController *chatNameViewController;
@property (strong, nonatomic) UINavigationController *navigationController;

@end
