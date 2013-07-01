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
    WebViewTypeMore
} WebViewType;

@interface WebViewController : UIViewController
{
    __weak IBOutlet UIWebView *webView;
}

-(id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil viewType:(WebViewType)type;

@property (nonatomic) WebViewType viewType;

@end
