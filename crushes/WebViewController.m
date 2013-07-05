//
//  WebViewController.m
//  crushes
//
//  Created by Seth Hayward on 12/6/12.
//  Copyright (c) 2012 Seth Hayward. All rights reserved.
//

#import "WebViewController.h"

@implementation WebViewController
@synthesize viewType, currentWebView, _sessionChecked, toolBar;

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
        

        UIToolbar *default_toolbar = [[UIToolbar alloc] init];
        default_toolbar.frame = CGRectMake(0, 0, self.view.frame.size.width, 44);
        
        // make toolbar transparent
        [default_toolbar setBackgroundImage:[[UIImage alloc] init] forToolbarPosition:UIToolbarPositionAny barMetrics:UIBarMetricsDefault];
        
        NSMutableArray *items = [[NSMutableArray alloc] init];
        
        UIBarButtonItem *refresh_button_v2 = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStyleBordered target:self action:@selector(refreshWebView)];

        UIImage *refresh_img = [[UIImage imageNamed:@"refresh.png"]
                                resizableImageWithCapInsets:UIEdgeInsetsMake(0, 5, 0, 5)];
        
        UIButton *refresh_button = [UIButton buttonWithType:UIButtonTypeInfoDark];
        refresh_button.bounds = CGRectMake(0,0, refresh_img.size.width + 10, refresh_img.size.height+10);
        
        [refresh_button addTarget:self action:@selector(refreshWebView) forControlEvents:UIControlEventTouchDown];
        
        [refresh_button setImage:refresh_img forState:UIControlStateNormal];
        
        [refresh_button_v2 setBackgroundImage:refresh_img forState:UIControlStateNormal barMetrics:UIBarMetricsDefault];

        UIBarButtonItem *refresh_button_v3 = [[UIBarButtonItem alloc] initWithCustomView:refresh_button];
               
        UIBarButtonItem *flexible = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];

        // adding the flexible item allows us to right align the button
        // add another flexible after refresh_button and it will center it
        
        [items addObject:flexible];
        [items addObject:refresh_button_v3];
        
        [default_toolbar setItems:items animated:NO];
        [self.view addSubview:default_toolbar];
        
        toolBar = default_toolbar;
    }
    
    return self;
}

- (void)refreshWebView
{
    NSLog(@"Forcing refresh.");
    
    NSString *current_url = webView.request.URL.absoluteString;
    
    [webView stopLoading];
    
    // send to a blank page
    NSURL *blank_url = [NSURL URLWithString:@"about:blank"];
    NSURLRequest *blank_req = [NSURLRequest requestWithURL:blank_url];
    [webView loadRequest:blank_req];
    
    NSURL *url = [NSURL URLWithString: current_url];
    NSURLRequest *req = [NSURLRequest requestWithURL:url];
    
    [webView loadRequest:req];
}

- (void)refreshOriginalPage
{

    NSString *url = @"http://www.letterstocrushes.com/mobile";

    switch(viewType) {
        case WebViewTypeHome:
            url = [url stringByAppendingString:@"/"];
            break;
        case WebViewTypeMore:
            url = [url stringByAppendingString:@"/more"];
            break;
        case WebViewTypeBookmarks:
            url = [url stringByAppendingString:@"/bookmarks"];
            break;
    }

    [webView stopLoading];
    
    // send to a blank page
    NSURL *blank_url = [NSURL URLWithString:@"about:blank"];
    NSURLRequest *blank_req = [NSURLRequest requestWithURL:blank_url];
    [webView loadRequest:blank_req];
    
    NSURLRequest *req = [NSURLRequest requestWithURL:[NSURL URLWithString:url]];
    
    [webView loadRequest:req];

}

- (void)viewDidLoad
{
    
    NSURL *url;
    
    if ([self viewType] == WebViewTypeHome) {
        url = [NSURL URLWithString:@"http://www.letterstocrushes.com/mobile/"];
    } else if ([self viewType] == WebViewTypeMore) {
        url = [NSURL URLWithString:@"http://www.letterstocrushes.com/mobile/more/"];
    } else if ([self viewType] == WebViewTypeBookmarks) {
        url = [NSURL URLWithString:@"http://www.letterstocrushes.com/mobile/bookmarks"];
    }
    
    [webView setDelegate:self];
    currentWebView = webView;
    
    NSURLRequest *req = [NSURLRequest requestWithURL:url cachePolicy:NSURLCacheStorageAllowed timeoutInterval:10];
    [webView loadRequest:req];
        
}

- (void)viewDidUnload {
    webView = nil;
    [super viewDidUnload];
}

- (void)viewDidDisappear:(BOOL)animated
{    
    [webView stopLoading];
}

- (BOOL) webView:(UIWebView *)webViewActive shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
    
    NSString *urlString = [[request URL] absoluteString];
        
    NSString *msg = [NSString stringWithFormat:@"Loading...%@", urlString];
    
    NSLog(msg);

    return YES;
}

- (void) webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
    NSLog(@"Error: %@", error);
}

@end
