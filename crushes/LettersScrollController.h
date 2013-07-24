//
//  LettersScrollController.h
//  crushes
//
//  Created by Seth Hayward on 7/24/13.
//  Copyright (c) 2013 Seth Hayward. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GAITrackedViewController.h"

@interface LettersScrollController : GAITrackedViewController <UIWebViewDelegate>
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (nonatomic) int current_receive;

-(void)loadLetterData;

@end
