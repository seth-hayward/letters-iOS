//
//  AppDelegate.m
//  crushes
//
//  Created by Seth Hayward on 12/6/12.
//  Copyright (c) 2012 Seth Hayward. All rights reserved.
//

#import "AppDelegate.h"
#import "SendViewController.h"
#import "WebViewController.h"
#import "GAI.h"

@implementation AppDelegate
@synthesize tabBar, moreWebViewController, homeWebViewController,bookmarksWebViewController,
            searchWebViewController, sendViewController, home_last_click, more_last_click,
            bookmarks_last_click, search_last_click;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    // Override point for customization after application launch.
    
    RKLogConfigureByName("RestKit/Network", RKLogLevelTrace);
    RKLogConfigureByName("RestKit/ObjectMapping", RKLogLevelTrace);
    
    WebViewController *homeVC = [[WebViewController alloc] initWithNibName:nil bundle:nil viewType: WebViewTypeHome];
    homeWebViewController = homeVC;
    homeWebViewController.trackedViewName = @"Home";
        
    WebViewController *moreVC = [[WebViewController alloc] initWithNibName:nil bundle:nil viewType: WebViewTypeMore];
    moreWebViewController = moreVC;
    moreWebViewController.trackedViewName = @"More";

    WebViewController *bookmarksVC = [[WebViewController alloc] initWithNibName:nil bundle:nil viewType: WebViewTypeBookmarks];
    bookmarksWebViewController = bookmarksVC;
    bookmarksWebViewController.trackedViewName = @"Bookmarks";
    
    WebViewController *searchVC = [[WebViewController alloc] initWithNibName:nil bundle:nil viewType:WebViewTypeSearch];
    searchWebViewController = searchVC;
    searchWebViewController.trackedViewName = @"Search";
    
    SendViewController *sendVC = [[SendViewController alloc] init];
    sendViewController = sendVC;
    sendViewController.trackedViewName = @"Send Letter";
    
    UITabBarController *tabBarController = [[UITabBarController alloc] init];
    [tabBarController setDelegate:self];
        
    tabBar = tabBarController;
    
    NSArray *viewControllers = [NSArray arrayWithObjects:homeVC, moreVC, bookmarksVC, searchVC, sendVC, nil];
    [tabBarController setViewControllers:viewControllers];
        
    [[self window] setRootViewController:tabBarController];
    
    // setup double tap on tabs
    NSDate *now = [[NSDate alloc] init];
    home_last_click = now;
    more_last_click = now;
    bookmarks_last_click = now;
    
    //
    // integrate with google analytics
    //
    
    // Optional: automatically send uncaught exceptions to Google Analytics.
    [GAI sharedInstance].trackUncaughtExceptions = YES;
    // Optional: set Google Analytics dispatch interval to e.g. 20 seconds.
    [GAI sharedInstance].dispatchInterval = 20;
    // Optional: set debug to YES for extra debugging information.
    [GAI sharedInstance].debug = YES;
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
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

- (void)tabBarController:(UITabBarController *)theTabBarController didSelectViewController:(UIViewController *)viewController {
    NSUInteger indexOfTab = [theTabBarController.viewControllers indexOfObject:viewController];
    NSLog(@"Tab index = %u", indexOfTab);
    
    double time_since_last_click = 0;
    
    NSDate *now = [[NSDate alloc] init];
    
    switch(indexOfTab) {
        case 0:
            time_since_last_click = fabs([home_last_click timeIntervalSinceDate:now]);
            home_last_click = now;
            break;
        case 1:
            time_since_last_click = fabs([more_last_click timeIntervalSinceDate:now]);
            more_last_click = now;
            break;
        case 2:
            time_since_last_click = fabs([bookmarks_last_click  timeIntervalSinceDate:now]);
            bookmarks_last_click = now;
            break;
        case 3:
            time_since_last_click = fabs([search_last_click timeIntervalSinceDate:now]);
            search_last_click = now;
            break;
            
    }
    
    NSLog(@"time since: %f", time_since_last_click);

    if(time_since_last_click < 0.5 && indexOfTab < 4) {
        // force browser to reload        
        if(indexOfTab == 0) {
            [homeWebViewController refreshOriginalPage];
        }
        
        if(indexOfTab == 1) {
            [moreWebViewController refreshOriginalPage];
        }
        
        if(indexOfTab == 2) {
            [bookmarksWebViewController refreshOriginalPage];                              
        }
        
        if(indexOfTab == 3) {
            [searchWebViewController refreshOriginalPage];            
        }
    }

}

@end
