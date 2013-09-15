//
//  SearchViewController.h
//  crushes
//
//  Created by Seth Hayward on 8/20/13.
//  Copyright (c) 2013 Seth Hayward. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GAITrackedViewController.h"

@interface SearchViewController : GAITrackedViewController <UITextViewDelegate>
- (IBAction)clickedSearch:(id)sender;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *indicator;
@property (weak, nonatomic) IBOutlet UITextView *textSearchTerms;

@end
