//
//  SearchViewController.h
//  crushes
//
//  Created by Seth Hayward on 8/20/13.
//  Copyright (c) 2013 Seth Hayward. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SearchViewController : UIViewController
- (IBAction)clickedSearch:(id)sender;
@property (weak, nonatomic) IBOutlet UITextField *searchTerms;

@end
