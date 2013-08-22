//
//  ScrollViewItemViewController.h
//  crushes
//
//  Created by Seth Hayward on 7/24/13.
//  Copyright (c) 2013 Seth Hayward. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RKFullLetter.h"
#import "J1Button.h"

@interface ScrollViewItem : UIViewController
{
    
}
@property (weak, nonatomic) IBOutlet UILabel *labelHearts;
@property (weak, nonatomic) IBOutlet UILabel *labelComments;
@property (weak, nonatomic) IBOutlet UILabel *labelDate;
@property (weak, nonatomic) IBOutlet UILabel *labelEdit;
@property (weak, nonatomic) IBOutlet UILabel *labelHide;
@property (weak, nonatomic) IBOutlet J1Button *btnHearts;

@property (weak, nonatomic) IBOutlet UIWebView *webView;
@property (weak, nonatomic) IBOutlet UIButton *buttonHearts;
@property (nonatomic) int current_index;
@property (nonatomic) RKFullLetter *current_letter;

@end
