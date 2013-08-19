//
//  LettersScrollController.h
//  crushes
//
//  Created by Seth Hayward on 7/24/13.
//  Copyright (c) 2013 Seth Hayward. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GAITrackedViewController.h"

@interface LettersScrollController : GAITrackedViewController <UIWebViewDelegate, UIScrollViewDelegate>
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *indicator;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (nonatomic) int current_receive;
@property (nonatomic) Boolean loaded;
@property (nonatomic) int letter_index;
@property (weak, nonatomic) IBOutlet UIWebView *testWebView;

-(void)loadLetterData;
-(void)clearLettersAndReset;
-(void)refreshOriginalPage;

@end
