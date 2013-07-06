//
//  WebViewController.m
//  crushes
//
//  Created by Seth Hayward on 12/6/12.
//  Copyright (c) 2012 Seth Hayward. All rights reserved.
//

#import "WebViewController.h"

@implementation WebViewController
@synthesize viewType, currentWebView, _sessionChecked, toolBar, loadingIndicator, timeoutTimer;

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
    
    NSString *current_url = _webView.request.URL.absoluteString;
    
    if([current_url isEqualToString:@"about:blank"]) {
        [self refreshOriginalPage];
        return;
    }
    
    [_webView stopLoading];
    
    NSURL *url = [NSURL URLWithString: current_url];
    
    NSURLRequest *request = [NSURLRequest requestWithURL:url cachePolicy:NSURLCacheStorageAllowed timeoutInterval:20];
    [NSURLConnection connectionWithRequest:request delegate:self];
    [loadingIndicator startAnimating];
    
}

- (void)refreshOriginalPage
{

    [_webView setDelegate:self];

    
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

    [_webView stopLoading];
        
    self.originalUrl = [NSURL URLWithString:url];
    currentWebView = _webView;
    
    NSURLRequest *request = [NSURLRequest requestWithURL:self.originalUrl cachePolicy:NSURLCacheStorageAllowed timeoutInterval:20];
    
    [NSURLConnection connectionWithRequest:request delegate:self];
    [loadingIndicator startAnimating];
    NSLog(@"refreshOriginalPage.");
    
    timeoutTimer = [NSTimer scheduledTimerWithTimeInterval:2000.0 target:self selector:@selector(cancelWeb) userInfo:nil repeats:NO];

    
}

- (void)viewDidLoad
{
    [self refreshOriginalPage];
}

- (void)viewDidUnload {
    _webView = nil;
    [super viewDidUnload];
}

- (void)viewDidDisappear:(BOOL)animated
{
    
    [_webView stopLoading];
}

// this is where you could, intercept HTML requests and route them through
// NSURLConnection, to see if the server responds successfully.

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
    if (navigationType != UIWebViewNavigationTypeLinkClicked)
        return YES;
    
    // if user clicked on a link and we haven't validated it yet, let's do so
    
    self.originalUrl = request.URL;
    
    [NSURLConnection connectionWithRequest:request delegate:self];
    
    // and if we're validating, don't bother to have the web view load it yet ...
    // the `didReceiveResponse` will do that for us once the connection has been validated
    
    return NO;
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
    NSLog(@"%s error=%@", __FUNCTION__, error);
    //[_webView stopLoading];
    //[self refreshWebView];
    if([error code] == NSURLErrorCancelled) {
        
        return;
    }
}

-(void)webViewDidFinishLoad:(UIWebView *)webView
{
//    NSLog(@"Hiding...");
    [loadingIndicator stopAnimating];
    [timeoutTimer invalidate];
    
}

-(void)webViewDidStartLoad:(UIWebView *)webView
{
//    NSLog(@"Showing...");
//    [loadingIndicator startAnimating];
}

-(void)cancelWeb
{
    NSLog(@"Timed out after 20 seconds. Forcing refresh.");
    [_webView stopLoading];
    [self refreshWebView];    
}

// This code inspired by http://www.ardalahmet.com/2011/08/18/how-to-detect-and-handle-http-status-codes-in-uiwebviews/
// Given that some ISPs do redirects that one might otherwise prefer to see handled as errors, I'm also checking
// to see if the original URL's host matches the response's URL. This logic may be too restrictive (some valid redirects
// will be rejected, such as www.adobephotoshop.com which redirects you to www.adobe.com), but does capture the ISP
// redirect problem I am concerned about.

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
    NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;
    
    NSString *originalUrlHostName = self.originalUrl.host;
    NSString *responseUrlHostName = response.URL.host;
    
    NSRange originalInResponse = [responseUrlHostName rangeOfString:originalUrlHostName]; // handle where we went to "apple.com" and got redirected to "www.apple.com"
    NSRange responseInOriginal = [originalUrlHostName rangeOfString:responseUrlHostName]; // handle where we went to "www.stackoverflow.com" and got redirected to "stackoverflow.com"
    
    if (originalInResponse.location == NSNotFound && responseInOriginal.location == NSNotFound)
    {
        NSLog(@"%s you were redirected from %@ to %@", __FUNCTION__, self.originalUrl.absoluteString, response.URL.absoluteString);
    }
    else if (httpResponse.statusCode < 200 || httpResponse.statusCode >= 300)
    {
        NSLog(@"%s request to %@ failed with statusCode=%d", __FUNCTION__, response.URL.absoluteString, httpResponse.statusCode);
    }
    else
    {
        [connection cancel];
        
        [_webView loadRequest:connection.originalRequest];
        
        return;
    }
    
    [connection cancel];
}

-(void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
    NSLog(@"Error: %@", error);
}


@end
