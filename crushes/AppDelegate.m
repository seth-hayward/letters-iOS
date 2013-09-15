//
//  AppDelegate.m
//  crushes
//
//  Created by Seth Hayward on 12/6/12.
//  Copyright (c) 2012 Seth Hayward. All rights reserved.
//

#import "AppDelegate.h"
#import "SendViewController.h"
#import "MMDrawerController.h"
#import "MenuViewController.h"
#import "GAI.h"
#import "RODItemStore.h"
#import "SearchViewController.h"

@implementation AppDelegate
@synthesize sendViewController, drawer, lettersScrollController, navigationController, searchViewController, menuViewController, chatViewController, chatNameViewController;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    // Override point for customization after application launch.
    
    RKLogConfigureByName("RestKit/Network", RKLogLevelTrace);
    //RKLogConfigureByName("RestKit/ObjectMapping", RKLogLevelTrace);
    
    SearchViewController *searchVC = [[SearchViewController alloc] init];
    searchViewController = searchVC;
    searchViewController.trackedViewName = @"Search";
    
    SendViewController *sendVC = [[SendViewController alloc] init];
    sendViewController = sendVC;
    sendViewController.trackedViewName = @"Send Letter";
    
    MenuViewController * leftDrawer = [[MenuViewController alloc] init];
    menuViewController = leftDrawer;
    
    ChatNameViewController *_chatNameVC = [[ChatNameViewController alloc] init];
    chatNameViewController = _chatNameVC;
    chatNameViewController.trackedViewName = @"Chat Name";
    
    ChatViewController *_chatVC = [[ChatViewController alloc] init];
    chatViewController = _chatVC;
    chatViewController.trackedViewName = @"Chat";
    
    LettersScrollController *lettersScrollVC = [[LettersScrollController alloc] init];
    lettersScrollController = lettersScrollVC;
    lettersScrollController.trackedViewName = @"Letters";
    
    UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:lettersScrollVC];
    navController.navigationBar.tintColor = [UIColor blackColor];
    [navController.navigationBar setBackgroundImage:[[UIImage alloc] init] forBarMetrics:UIBarMetricsDefault];
    [navController.navigationBar setBackgroundColor:[UIColor blackColor]];
    
    NSDictionary *new_font = [NSDictionary dictionaryWithObjectsAndKeys:
                              [UIColor whiteColor], UITextAttributeTextColor,
                              [UIFont systemFontOfSize:12.0], UITextAttributeFont, nil];
    
    [navController.navigationBar setTitleVerticalPositionAdjustment:5 forBarMetrics:UIBarMetricsDefault];
    [navController.navigationBar setTitleTextAttributes:new_font];
    
    navigationController = navController;
    
    MMDrawerController * drawerController = [[MMDrawerController alloc]
                                             initWithCenterViewController:navController
                                             leftDrawerViewController:leftDrawer];
    drawer = drawerController;
    
    [drawerController setMaximumLeftDrawerWidth:150.0];
    [drawerController setOpenDrawerGestureModeMask:MMOpenDrawerGestureModeAll];
    [drawerController setCloseDrawerGestureModeMask:MMCloseDrawerGestureModeAll];
    [drawerController setShowsShadow:false];
    
    [[self window] setRootViewController:drawerController];

    //
    // hook up rotation notification listeners
    //
    
    UIDevice *device = [UIDevice currentDevice];
    [device beginGeneratingDeviceOrientationNotifications];
    NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
    
    [nc addObserver:self selector:@selector(orientationChanged:) name:UIDeviceOrientationDidChangeNotification object:device];
        
    //
    // integrate with google analytics
    //
    
    // Optional: automatically send uncaught exceptions to Google Analytics.
    [GAI sharedInstance].trackUncaughtExceptions = YES;
    // Optional: set Google Analytics dispatch interval to e.g. 20 seconds.
    [GAI sharedInstance].dispatchInterval = 20;
    // Optional: set debug to YES for extra debugging information.
    [GAI sharedInstance].debug = NO;
    // Create tracker instance.
    id<GAITracker> tracker = [[GAI sharedInstance] trackerWithTrackingId:@"UA-42351224-1"];
        
    self.window.backgroundColor = [UIColor whiteColor];
    [self.window makeKeyAndVisible];
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    
    BOOL success = [[RODItemStore sharedStore] saveSettings];
    if (success) {
        NSLog(@"Saved settings.");
    } else {
        NSLog(@"Error saving settings.");
    }
    
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    [[NSHTTPCookieStorage sharedHTTPCookieStorage] setCookieAcceptPolicy:NSHTTPCookieAcceptPolicyAlways];
    
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

- (void)orientationChanged:(NSNotification *)note
{
    // tell the letters scroll controller to recalculate
    // everything
    
    UIDeviceOrientation current = [UIDevice currentDevice].orientation;
    UIDeviceOrientation previously = [RODItemStore sharedStore].last_device_orientation;

    if(UIDeviceOrientationIsPortrait(current) == UIDeviceOrientationIsPortrait(previously)) {
        if(lettersScrollController.loaded == true) {
            NSLog(@"Refreshed page.");            
            [lettersScrollController refreshOriginalPage];
        }
        [RODItemStore sharedStore].last_device_orientation = current;
    }
    
}

@end
