//
//  PagerViewController.h
//  crushes
//
//  Created by Seth Hayward on 8/18/13.
//  Copyright (c) 2013 Seth Hayward. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "J1Button.h"

@interface PagerViewController : UIViewController
@property (weak, nonatomic) IBOutlet J1Button *buttonNext;
@property (weak, nonatomic) IBOutlet J1Button *buttonBack;

@end
