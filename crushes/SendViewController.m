//
//  SendViewController.m
//  crushes
//
//  Created by Seth Hayward on 12/6/12.
//  Copyright (c) 2012 Seth Hayward. All rights reserved.
//

#import "SendViewController.h"
#import <QuartzCore/QuartzCore.h>

@implementation SendViewController

-(id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    
    if (self) {
        UITabBarItem *tbi = [self tabBarItem];
        [tbi setTitle:@"Send"];
        [tbi setImage:[UIImage imageNamed:@"pencil.png"]];
    }
    
    return self;
}

- (void)viewDidLoad
{
    messageText.layer.borderWidth = 5.0f;
    messageText.layer.borderColor = [[UIColor grayColor] CGColor];
}

- (void)viewDidUnload {
    messageText = nil;
    sendButton = nil;
    [super viewDidUnload];
}

-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}
- (IBAction)backgroundTapped:(id)sender {
    [[self view] endEditing:YES];
   }
@end
