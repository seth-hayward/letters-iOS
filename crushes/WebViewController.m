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

- (id)initWithType:(WebViewType)type
{
    self = [super init];
    
    if (self) {
        [self setViewType:type];
    }
    
    return self;
}

- (void)viewDidLoad
{
    
    NSURL *url;
    
    if ([self viewType] == WebViewTypeHome) {
        url = [NSURL URLWithString:@"http://www.letterstocrushes.com/home"];
        NSLog(@"Using home page...");
    } else if ([self viewType] == WebViewTypeMore) {
        url = [NSURL URLWithString:@"http://www.letterstocrushes.com/more"];
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
