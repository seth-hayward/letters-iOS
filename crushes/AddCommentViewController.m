//
//  AddCommentViewController.m
//  crushes
//
//  Created by Seth Hayward on 9/15/13.
//  Copyright (c) 2013 Seth Hayward. All rights reserved.
//

#import "AddCommentViewController.h"

@implementation AddCommentViewController
@synthesize textComment, textCommenterEmail, textCommenterName;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    [self.textCommenterName setBackgroundColor:[UIColor colorWithRed:245/255.0f green:150/255.0f blue:150/255.0f alpha:1.0f]];
    [self.textComment setBackgroundColor:[UIColor colorWithRed:245/255.0f green:150/255.0f blue:150/255.0f alpha:1.0f]];
    [self.textCommenterEmail setBackgroundColor:[UIColor colorWithRed:245/255.0f green:150/255.0f blue:150/255.0f alpha:1.0f]];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
