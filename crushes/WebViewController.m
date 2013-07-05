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
        
        UIBarButtonItem *refresh_button = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh target:self action:@selector(refreshWebView)];
        
        UIBarButtonItem *flexible = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];

        // adding the flexible item allows us to right align the button
        // add another flexible after refresh_button and it will center it
        
        [items addObject:flexible];
        [items addObject:refresh_button];
        
        [default_toolbar setItems:items animated:NO];
        [self.view addSubview:default_toolbar];
        
        toolBar = default_toolbar;
    }
    
    return self;
}

- (void)refreshWebView
{
    [webView reload];
}

- (void)viewDidLoad
{
    
    NSURL *url;
    
    if ([self viewType] == WebViewTypeHome) {
        url = [NSURL URLWithString:@"http://www.letterstocrushes.com/mobile/page/1"];
//        [titleBar topItem].title = @"letters to crushes - home";
    } else if ([self viewType] == WebViewTypeMore) {
        url = [NSURL URLWithString:@"http://www.letterstocrushes.com/mobile/more/page/1"];
//        [titleBar topItem].title = @"letters to crushes - more";
    } else if ([self viewType] == WebViewTypeBookmarks) {
        url = [NSURL URLWithString:@"http://www.letterstocrushes.com/mobile/bookmarks"];
//        [titleBar topItem].title = @"letters to crushes - bookmarks";
    }
    
    [webView setDelegate:self];
    currentWebView = webView;
    
    NSURLRequest *req = [NSURLRequest requestWithURL:url];
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
@end
