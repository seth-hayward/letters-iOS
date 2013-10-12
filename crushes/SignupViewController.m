//
//  SignupViewController.m
//  crushes
//
//  Created by Seth Hayward on 10/11/13.
//  Copyright (c) 2013 Seth Hayward. All rights reserved.
//

#import "SignupViewController.h"
#import "NavigationController.h"
#import "RODItemStore.h"
#import "WCAlertView.h"

@implementation SignupViewController

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
    
    self.edgesForExtendedLayout = UIRectEdgeNone;
    
    
    UIButton *button_menu = [UIButton buttonWithType:UIButtonTypeCustom];
    [button_menu setFrame:CGRectMake(0, 0, 30, 30)];
    [button_menu setImage:[UIImage imageNamed:@"hamburger-150px.png"] forState:UIControlStateNormal];
    [button_menu addTarget:(NavigationController *)self.navigationController action:@selector(showMenu) forControlEvents:UIControlEventTouchUpInside];
    
    UIBarButtonItem *leftDrawerButton = [[UIBarButtonItem alloc] initWithCustomView:button_menu];
    [self.navigationItem setLeftBarButtonItem:leftDrawerButton animated:YES];

    self.textPassword.secureTextEntry = YES;

    [[self navigationItem] setTitle:@"sign up"];
    
}

- (IBAction)signUp:(id)sender
{
    [self.textPassword resignFirstResponder];
    [self.textEmail resignFirstResponder];
    
    if([self.textEmail.text length] == 0) {
        [WCAlertView showAlertWithTitle:@"Signup error" message:@"Please enter an email address." customizationBlock:nil completionBlock:nil cancelButtonTitle:@"ok" otherButtonTitles:nil];
        return;
    }

    if([self.textPassword.text length] == 0) {
        [WCAlertView showAlertWithTitle:@"Signup error" message:@"Please enter a password." customizationBlock:nil completionBlock:nil cancelButtonTitle:@"ok" otherButtonTitles:nil];
        return;
    }

    
    [[RODItemStore sharedStore] signup:self.textEmail.text password:self.textPassword.text];
}

-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
