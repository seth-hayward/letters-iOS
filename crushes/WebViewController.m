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
    
    [webView setDelegate:self];
    
    NSURLRequest *req = [NSURLRequest requestWithURL:url];
    [webView loadRequest:req];
    
}

- (void)viewDidUnload {
    webView = nil;
    [super viewDidUnload];
}

- (BOOL) webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
    NSString *urlString = [[request URL] absoluteString];
    
    if([urlString rangeOfString:@"http://www.letterstocrushes.com/letter/"].length > 0 &&
       [urlString rangeOfString:@"/mobile"].location == NSNotFound) {
        
        // on all letter pages, we want to append /mobile to the url
        urlString = [urlString stringByAppendingString:@"/mobile"];
        
        NSURL *url;
        url = [NSURL URLWithString:urlString];
        
        NSURLRequest *req = [NSURLRequest requestWithURL:url];
        [webView loadRequest:req];
        
    }
    return YES;
}
@end
