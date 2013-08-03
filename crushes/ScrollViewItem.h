//
//  ScrollViewItemViewController.h
//  crushes
//
//  Created by Seth Hayward on 7/24/13.
//  Copyright (c) 2013 Seth Hayward. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RKFullLetter.h"

@interface ScrollViewItem : UIViewController
{
    
}

@property (weak, nonatomic) IBOutlet UIWebView *webView;
@property (weak, nonatomic) IBOutlet UIButton *buttonHearts;
@property (weak, nonatomic) IBOutlet UIButton *buttonComments;
@property (nonatomic) int current_index;
@property (nonatomic) RKFullLetter *current_letter;
- (void)clickedHeart;

@end
