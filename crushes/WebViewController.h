//
//  WebViewController.h
//  crushes
//
//  Created by Seth Hayward on 12/6/12.
//  Copyright (c) 2012 Seth Hayward. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GAITrackedViewController.h"

typedef enum {
    WebViewTypeHome,
    WebViewTypeMore,
    WebViewTypeBookmarks,
    WebViewTypeSearch
} WebViewType;

@interface WebViewController : GAITrackedViewController <UIWebViewDelegate, NSURLConnectionDelegate>
{
    __weak IBOutlet UIWebView *_webView;
}

-(id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil viewType:(WebViewType)type;

@property (nonatomic) WebViewType viewType;
@property (nonatomic) UIWebView *currentWebView;
@property (nonatomic) BOOL _sessionChecked;
@property (weak, nonatomic) IBOutlet UIToolbar *toolBar;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *loadingIndicator;

-(void)refreshWebView;
-(void)refreshOriginalPage;
-(void)cancelWeb;

@end
