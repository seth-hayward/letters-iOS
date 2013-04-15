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
    if ([self viewType] == WebViewTypeHome) {
        [typeLabel setText:@"Home view"];
    } else if ([self viewType] == WebViewTypeMore) {
        [typeLabel setText:@"More view"];
    }
}

- (void)viewDidUnload {
    typeLabel = nil;
    [super viewDidUnload];
}
@end
