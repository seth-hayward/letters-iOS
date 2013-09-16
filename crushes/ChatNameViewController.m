//
//  ChatNameViewController.m
//  crushes
//
//  Created by Seth Hayward on 9/6/13.
//  Copyright (c) 2013 Seth Hayward. All rights reserved.
//

#import "ChatNameViewController.h"
#import "RODItemStore.h"
#import "MMDrawerBarButtonItem.h"
#import "WCAlertView.h"
#import "AppDelegate.h"

@implementation ChatNameViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        
        MMDrawerBarButtonItem * leftDrawerButton = [[MMDrawerBarButtonItem alloc] initWithTarget:self action:@selector(openDrawer:)];
        [self.navigationItem setLeftBarButtonItem:leftDrawerButton animated:YES];
        
        [[self navigationItem] setTitle:@"enter chat"];
                
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    [self.textChatName setText:[RODItemStore sharedStore].settings.chatName];
    
    [self.textChatName setBackgroundColor:[UIColor colorWithRed:245/255.0f green:150/255.0f blue:150/255.0f alpha:1.0f]];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
    
    if([text isEqualToString:@"\n"]) {
        [textView resignFirstResponder];
        [self enterChat];
        return NO;
    }
    
    return YES;
}

- (IBAction)btnGo:(id)sender {
    [self enterChat];
}

- (void)enterChat
{
    NSString *check_name = [self.textChatName text];
    
    if(check_name.length == 0) {

        [WCAlertView showAlertWithTitle:@"you need a name!" message:@"Please enter a name so we can say hi." customizationBlock:^(WCAlertView *alertView) {
            alertView.style = WCAlertViewStyleBlackHatched;
        } completionBlock:^(NSUInteger buttonIndex, WCAlertView *alertView) {
        } cancelButtonTitle:@"ok" otherButtonTitles: nil
         ];
        return;
    }
    
    [RODItemStore sharedStore].settings.chatName = check_name;
    [[RODItemStore sharedStore] saveSettings];


    AppDelegate *appDelegate = (AppDelegate *) [[UIApplication sharedApplication] delegate];
    [appDelegate.navigationController popViewControllerAnimated:NO];
    [appDelegate.navigationController pushViewController:appDelegate.chatViewController animated:YES];
    
}

- (void)openDrawer:(id)sender {
    
    // now tell the web view to change the page
    AppDelegate *appDelegate = (AppDelegate *) [[UIApplication sharedApplication] delegate];
    [appDelegate.drawer toggleDrawerSide:MMDrawerSideLeft animated:YES completion:nil];
    
}


@end
