//
//  AppDelegate.h
//  crushes
//
//  Created by Seth Hayward on 12/6/12.
//  Copyright (c) 2012 Seth Hayward. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WebViewController.h"
#import "SendViewController.h"

@interface AppDelegate : UIResponder <UIApplicationDelegate, UITabBarControllerDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic) UITabBarController *tabBar;
@property (strong, nonatomic) WebViewController *webViewController;
@property (strong, nonatomic) SendViewController *sendViewController;

@property (strong, nonatomic) NSDate *home_last_click;
@property (strong, nonatomic) NSDate *more_last_click;
@property (strong, nonatomic) NSDate *bookmarks_last_click;
@property (strong, nonatomic) NSDate *search_last_click;

@end
