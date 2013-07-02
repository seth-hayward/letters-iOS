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
            UITabBarItem *tbi_home = [self tabBarItem];
            [tbi_home setTitle:@"Home"];
            [tbi_home setImage:[UIImage imageNamed:@"home.png"]];
        } else if ([self viewType] == WebViewTypeMore) {
            UITabBarItem *tbi_more = [self tabBarItem];
            [tbi_more setTitle:@"More"];
            [tbi_more setImage:[UIImage imageNamed:@"medical.png"]];
        } else if ([self viewType] == WebViewTypeBookmarks) {
            UITabBarItem *tbi_bookmarks = [self tabBarItem];
            [tbi_bookmarks setTitle:@"Bookmarks"];
            [tbi_bookmarks setImage:[UIImage imageNamed:@"bookmark.png"]];
        }
    
    }
    
    return self;
}

- (void)viewDidLoad
{
    
    NSURL *url;
    
    if ([self viewType] == WebViewTypeHome) {
        url = [NSURL URLWithString:@"http://www.letterstocrushes.com/mobile"];
    } else if ([self viewType] == WebViewTypeMore) {
        url = [NSURL URLWithString:@"http://www.letterstocrushes.com/mobile/more"];
    } else if ([self viewType] == WebViewTypeBookmarks) {
        url = [NSURL URLWithString:@"http://www.letterstocrushes.com/mobile/bookmarks"];
    }
    
    [webView setDelegate:self];
    
    NSURLRequest *req = [NSURLRequest requestWithURL:url];
    [webView loadRequest:req];
    
}

- (void)viewDidUnload {
    webView = nil;
    [super viewDidUnload];
}

- (BOOL) webView:(UIWebView *)webViewActive shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
    NSString *urlString = [[request URL] absoluteString];
    
    if([urlString rangeOfString:@"http://www.letterstocrushes.com/letter/"].length > 0 &&
       [urlString rangeOfString:@"/mobile"].location == NSNotFound) {
        
        // on all letter pages, we want to use the mobile url:
        // http://www.letterstocrushes.com/letter/150150 becomes
        // http://www.letterstocrushes.com/mobile/letter/150150
        
        urlString = [urlString stringByReplacingOccurrencesOfString:@"/letter/" withString:@"/mobile/letter/"];
        
        NSURL *url;
        url = [NSURL URLWithString:urlString];
        
        NSURLRequest *req = [NSURLRequest requestWithURL:url];
        [webViewActive loadRequest:req];
        
    }
    return YES;
}
@end
