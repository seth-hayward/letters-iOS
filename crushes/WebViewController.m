//
//  WebViewController.m
//  crushes
//
//  Created by Seth Hayward on 12/6/12.
//  Copyright (c) 2012 Seth Hayward. All rights reserved.
//

#import "WebViewController.h"

@implementation WebViewController
@synthesize viewType;

-(id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil viewType:(WebViewType)type
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    
    if (self) {
        
        [self setViewType:type];
        
        if ([self viewType] == WebViewTypeHome) {
            UITabBarItem *tbi = [self tabBarItem];
            [tbi setTitle:@"Home"];
            [tbi setImage:[UIImage imageNamed:@"home.png"]];
        } else if ([self viewType] == WebViewTypeMore) {
            UITabBarItem *tbi2 = [self tabBarItem];
            [tbi2 setTitle:@"More"];
            [tbi2 setImage:[UIImage imageNamed:@"medical.png"]];
        }
        
    }
    
    return self;
}

- (void)viewDidLoad
{
    
    NSURL *url;
    
    if ([self viewType] == WebViewTypeHome) {
        url = [NSURL URLWithString:@"http://www.letterstocrushes.com/home?mobile=1"];
        NSLog(@"Using home page...");
    } else if ([self viewType] == WebViewTypeMore) {
        url = [NSURL URLWithString:@"http://www.letterstocrushes.com/more?mobile=1"];
        NSLog(@"Using more page...");
    }
    
    [webView setScalesPageToFit:YES];
    
    NSURLRequest *req = [NSURLRequest requestWithURL:url];
    [webView loadRequest:req];
    
}

- (void)viewDidUnload {
    webView = nil;
    [super viewDidUnload];
}
@end
