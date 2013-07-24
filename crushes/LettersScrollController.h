//
//  LettersScrollController.h
//  crushes
//
//  Created by Seth Hayward on 7/24/13.
//  Copyright (c) 2013 Seth Hayward. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GAITrackedViewController.h"

@interface LettersScrollController : GAITrackedViewController
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;

-(void)loadLetterData;

@end
