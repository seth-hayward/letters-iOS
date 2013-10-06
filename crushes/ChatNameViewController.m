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
#import <KxMenu.h>

@implementation ChatNameViewController

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
    
    // PREVENT THE UNDERLAPPING THAT OCCURS WITH
    // IOS 7!!!!!
    self.edgesForExtendedLayout = UIRectEdgeNone;
        
    [self.textChatName setText:[RODItemStore sharedStore].settings.chatName];
    
    UIBarButtonItem *btnChat = [[UIBarButtonItem alloc] initWithTitle:@"chat" style:UIBarButtonItemStylePlain target:self action:@selector(btnGo:)];
    [btnChat setTintColor:[UIColor blueColor]];
    [self.navigationItem setRightBarButtonItem:btnChat animated:YES];
    
//    UIButton *button_set = [UIButton buttonWithType:UIButtonTypeCustom];
//    [button_set setFrame:CGRectMake(0, 0, 30, 30)];
//    [button_set setImage:[UIImage imageNamed:@"cog-black.png"] forState:UIControlStateNormal];
//    [button_set addTarget:self action:@selector(popupMenu:event:) forControlEvents:UIControlEventTouchUpInside];
//    UIBarButtonItem *rightDrawerButton = [[UIBarButtonItem alloc] initWithCustomView:button_set];
//    [self.navigationItem setRightBarButtonItem:rightDrawerButton animated:YES];

    UIButton *button_menu = [UIButton buttonWithType:UIButtonTypeCustom];
    [button_menu setFrame:CGRectMake(0, 0, 30, 30)];
    [button_menu setImage:[UIImage imageNamed:@"hamburger-150px.png"] forState:UIControlStateNormal];
    [button_menu addTarget:self action:@selector(hamburger:) forControlEvents:UIControlEventTouchUpInside];
    
    UIBarButtonItem *leftDrawerButton = [[UIBarButtonItem alloc] initWithCustomView:button_menu];
    _goChat = leftDrawerButton;
    
    [self.navigationItem setLeftBarButtonItem:leftDrawerButton animated:YES];
    
    
    [[self navigationItem] setTitle:@"enter nickname"];
    
    [[self.textChatName layer] setBorderColor:[[UIColor blackColor] CGColor]];
    [[self.textChatName layer] setBorderWidth:1.0f];
    [[self.textChatName layer] setCornerRadius:1.0f];
    
    [self.textChatName becomeFirstResponder];
    
}

- (void)hamburger:(id)sender
{
    [self.textChatName resignFirstResponder];
    AppDelegate *appDelegate = (AppDelegate *) [[UIApplication sharedApplication] delegate];
    [appDelegate.navigationController showMenu];
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

- (void)btnGo:(id)sender {
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

//- (void)openDrawer:(id)sender {
//    
//    // now tell the web view to change the page
//    AppDelegate *appDelegate = (AppDelegate *) [[UIApplication sharedApplication] delegate];
//    [appDelegate.drawer toggleDrawerSide:MMDrawerSideLeft animated:YES completion:nil];
//    
//}


@end
