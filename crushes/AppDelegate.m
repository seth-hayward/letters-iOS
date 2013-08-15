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
#import "MMDrawerController.h"
#import "MenuViewController.h"
#import "GAI.h"
#import "WCAlertView.h"
#import "RODItemStore.h"

@implementation AppDelegate
@synthesize tabBar, webViewController, sendViewController, drawer, lettersScrollController, navigationController;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    // Override point for customization after application launch.
    
    RKLogConfigureByName("RestKit/Network", RKLogLevelTrace);
    //RKLogConfigureByName("RestKit/ObjectMapping", RKLogLevelTrace);
    
    WebViewController *webVC = [[WebViewController alloc] initWithNibName:nil bundle:nil viewType: WebViewTypeHome];
    webViewController = webVC;
    webViewController.trackedViewName = @"WebView";
    
    SendViewController *sendVC = [[SendViewController alloc] init];
    sendViewController = sendVC;
    sendViewController.trackedViewName = @"Send Letter";
    
    MenuViewController * leftDrawer = [[MenuViewController alloc] init];
    
    LettersScrollController *lettersScrollVC = [[LettersScrollController alloc] init];
    lettersScrollController = lettersScrollVC;
    
    UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:lettersScrollVC];
    navigationController = navController;
    
    MMDrawerController * drawerController = [[MMDrawerController alloc]
                                             initWithCenterViewController:navController
                                             leftDrawerViewController:leftDrawer];
    drawer = drawerController;
    
    [drawerController setMaximumLeftDrawerWidth:200.0];
    [drawerController setOpenDrawerGestureModeMask:MMOpenDrawerGestureModeAll];
    [drawerController setCloseDrawerGestureModeMask:MMCloseDrawerGestureModeAll];
    
    [[self window] setRootViewController:drawerController];
    
    //
    // show login/welcome message
    //
    
    [WCAlertView setDefaultCustomiaztonBlock:^(WCAlertView *alertView) {
        alertView.labelTextColor = [UIColor colorWithRed:0.11f green:0.08f blue:0.39f alpha:1.00f];
        alertView.labelShadowColor = [UIColor whiteColor];
        
        UIColor *topGradient = [UIColor colorWithRed:1.0f green:1.0f blue:1.0f alpha:1.0f];
        UIColor *middleGradient = [UIColor colorWithRed:0.93f green:0.94f blue:0.96f alpha:1.0f];
        UIColor *bottomGradient = [UIColor colorWithRed:0.89f green:0.89f blue:0.92f alpha:1.00f];
        alertView.gradientColors = @[topGradient,middleGradient,bottomGradient];
        
        alertView.outerFrameColor = [UIColor colorWithRed:250.0f/255.0f green:250.0f/255.0f blue:250.0f/255.0f alpha:1.0f];
        
        alertView.buttonTextColor = [UIColor colorWithRed:0.11f green:0.08f blue:0.39f alpha:1.00f];
        alertView.buttonShadowColor = [UIColor whiteColor];
        
    }];
    
    
    [WCAlertView showAlertWithTitle:@"letters to crushes" message:@"Would you like to browse anonymously or log in?" customizationBlock:^(WCAlertView *alertView) {
        
        // You can also set different appearance for this alert using customization block
        
        alertView.style = WCAlertViewStyleBlackHatched;
        //        alertView.alertViewStyle = UIAlertViewStyleLoginAndPasswordInput;
    } completionBlock:^(NSUInteger buttonIndex, WCAlertView *alertView) {
        if (buttonIndex == 1) {
            
            // now show the login alert

            [WCAlertView showAlertWithTitle:@"letters to crushes" message:@"Please enter your password." customizationBlock:^(WCAlertView *alertView) {
                
                // You can also set different appearance for this alert using customization block
                
                alertView.style = WCAlertViewStyleBlackHatched;
                alertView.alertViewStyle = UIAlertViewStyleLoginAndPasswordInput;
            } completionBlock:^(NSUInteger buttonIndex, WCAlertView *alertView) {

                if (buttonIndex == 1) {
                
                    [[RODItemStore sharedStore] login:[alertView textFieldAtIndex:0].text password:[alertView textFieldAtIndex:1].text];
                    
                }
                
                if (buttonIndex == alertView.cancelButtonIndex) {
                    
                    // whatever, they cancelled
                    
                    
                    
                }
            } cancelButtonTitle:@"cancel" otherButtonTitles:@"login", nil];
            
            
        }
    } cancelButtonTitle:@"cancel" otherButtonTitles:@"login", nil];
    
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
                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                        
@end
