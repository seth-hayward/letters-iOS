//
//  AppDelegate.h
//  crushes
//
//  Created by Seth Hayward on 12/6/12.
//  Copyright (c) 2012 Seth Hayward. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SendViewController.h"
#import "LettersScrollController.h"
#import "SearchViewController.h"
#import "MenuViewController.h"
#import "ChatNameViewController.h"
#import "ChatViewController.h"
#import "AddCommentViewController.h"
#import <REFrostedViewController.h>
#import "NavigationController.h"

@interface AppDelegate : UIResponder <UIApplicationDelegate, UITabBarControllerDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic) SendViewController *sendViewController;
@property (strong, nonatomic) SearchViewController *searchViewController;
@property (strong, nonatomic) REFrostedViewController *drawer;
@property (strong, nonatomic) LettersScrollController *lettersScrollController;
@property (strong, nonatomic) MenuViewController *menuViewController;
@property (strong, nonatomic) ChatNameViewController *chatNameViewController;
@property (strong, nonatomic) ChatViewController *chatViewController;
@property (strong, nonatomic) AddCommentViewController *addCommentViewController;
@property (strong, nonatomic) NavigationController *navigationController;

@end
