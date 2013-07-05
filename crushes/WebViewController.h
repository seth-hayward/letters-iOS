//
//  WebViewController.h
//  crushes
//
//  Created by Seth Hayward on 12/6/12.
//  Copyright (c) 2012 Seth Hayward. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum {
    WebViewTypeHome,
    WebViewTypeMore,
    WebViewTypeBookmarks
} WebViewType;

@interface WebViewController : UIViewController <UIWebViewDelegate, NSURLConnectionDelegate>
{
    __weak IBOutlet UIWebView *webView;
}

-(id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil viewType:(WebViewType)type;

@property (nonatomic) WebViewType viewType;
@property (nonatomic) UIWebView *currentWebView;
@property (nonatomic) BOOL _sessionChecked;
@property (weak, nonatomic) IBOutlet UIToolbar *toolBar;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *loadingIndicator;

-(void)refreshWebView;
-(void)refreshOriginalPage;

@end
