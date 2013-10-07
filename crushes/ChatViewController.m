//
//  ChatViewController.m
//  crushes
//
//  Created by Seth Hayward on 9/6/13.
//  Copyright (c) 2013 Seth Hayward. All rights reserved.
//

#import "ChatViewController.h"
#import "RODItemStore.h"
#import "SignalR.h"
#import "AppDelegate.h"
#import "MMDrawerBarButtonItem.h"
#import "RKChat.h"
#import <KxMenu.h>

#define FONT_SIZE 10.0f
#define CELL_CONTENT_WIDTH 320.0f
#define CELL_CONTENT_MARGIN 5.0f

@implementation ChatViewController
@synthesize refreshTimer, countDown;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        
        self.tableChats.sectionHeaderHeight = 0;
        self.tableChats.sectionFooterHeight = 0;
        
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    self.edgesForExtendedLayout = UIRectEdgeNone;

    self.tableChats.separatorInset = UIEdgeInsetsZero;
    
    [[self.textMessage layer] setBorderColor:[[UIColor blackColor] CGColor]];
    [[self.textMessage layer] setBorderWidth:1.0f];
    [[self.textMessage layer] setCornerRadius:1.0f];
    
    UIButton *button_menu = [UIButton buttonWithType:UIButtonTypeCustom];
    [button_menu setFrame:CGRectMake(0, 0, 30, 30)];
    [button_menu setImage:[UIImage imageNamed:@"hamburger-150px.png"] forState:UIControlStateNormal];
    [button_menu addTarget:self action:@selector(hamburger:) forControlEvents:UIControlEventTouchUpInside];
    
    UIBarButtonItem *leftDrawerButton = [[UIBarButtonItem alloc] initWithCustomView:button_menu];
    [self.navigationItem setLeftBarButtonItem:leftDrawerButton animated:YES                                                                                                                                                                            ];
    
    UIButton *button_set = [UIButton buttonWithType:UIButtonTypeCustom];
    [button_set setFrame:CGRectMake(0, 0, 30, 30)];
    [button_set setImage:[UIImage imageNamed:@"cog-black.png"] forState:UIControlStateNormal];
    [button_set addTarget:self action:@selector(popupMenu:event:) forControlEvents:UIControlEventTouchUpInside];
    
    UIBarButtonItem *rightDrawerButton = [[UIBarButtonItem alloc] initWithCustomView:button_set];
    [self.navigationItem setRightBarButtonItem:rightDrawerButton animated:YES];
    
    [[self navigationItem] setTitle:@"chat"];
    
    [self enterChat];

}

-(void)popupMenu:(UIBarButtonItem*)sender event:(UIEvent*)event;
{
    
    [KxMenu showMenuInView:self.view
                  fromRect:[[event.allTouches anyObject] view].frame
                 menuItems:@[
                             [KxMenuItem menuItem:@"Refresh"
                                            image:[UIImage imageNamed:@"refresh.png"]
                                           target:self
                                           action:@selector(askForBacklog)],
                             [KxMenuItem menuItem:@"Leave"
                                            image:nil
                                           target:self
                                           action:@selector(leaveChat)],
                             ]
                ];
    
}

- (void)leaveChat
{
    
    if([RODItemStore sharedStore].chatConnection) {
        [[RODItemStore sharedStore].chatConnection disconnect];
    }
        
    AppDelegate *appDelegate = (AppDelegate *) [[UIApplication sharedApplication] delegate];
    [appDelegate.lettersScrollController clearLettersAndReset];
    appDelegate.navigationController.viewControllers = @[ appDelegate.chatNameViewController ];
    
}

- (void)setCogColor:(NSString *)color
{

    NSLog(@"setCogColor: %@", color);
    
    UIButton *button_set = [UIButton buttonWithType:UIButtonTypeCustom];
    [button_set setFrame:CGRectMake(0, 0, 30, 30)];
    [button_set addTarget:self action:@selector(popupMenu:event:) forControlEvents:UIControlEventTouchUpInside];
    [button_set setImage:[UIImage imageNamed:[NSString stringWithFormat:@"cog-%@.png", color]] forState:UIControlStateNormal];
    UIBarButtonItem *rightDrawerButton = [[UIBarButtonItem alloc] initWithCustomView:button_set];
    [self.navigationItem setRightBarButtonItem:rightDrawerButton animated:YES];

    
}

- (void)viewWillAppear:(BOOL)animated
{
    
    [super viewWillAppear:animated];
    
    NSLog(@"viewWillAppear");
    
    if([RODItemStore sharedStore].chatConnection.state == reconnecting || [RODItemStore sharedStore].chatConnection.state == disconnected) {
        [self setCogColor:@"red"];
        [self enterChat];
        return;
    }
    
}

-(void)viewDidAppear:(BOOL)animated {

    [super viewDidAppear:animated];

    NSLog(@"viewWillAppear");
    
    if([RODItemStore sharedStore].chatConnection.state == reconnecting || [RODItemStore sharedStore].chatConnection.state == disconnected) {
        [self setCogColor:@"red"];
        [self enterChat];
        return;
    }
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self.textMessage resignFirstResponder];
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
    
    if([text isEqualToString:@"\n"]) {
        [self sendChat];
        return NO;
    }
    
    return YES;
}


- (void)sendChat {
    NSString *txt = self.textMessage.text;
    [self.textMessage resignFirstResponder];
    [[RODItemStore sharedStore].chatHub invoke:@"sendChat" withArgs:[NSArray arrayWithObject:txt]];
    [self.textMessage setText:@""];
}

- (IBAction)btnSend:(id)sender {
    [self sendChat];
}

- (void)addSimpleBacklog:(NSString *)chat
{
    [refreshTimer invalidate];
    
    NSArray *simple_chat_backlog = [chat componentsSeparatedByCharactersInSet:[NSCharacterSet newlineCharacterSet]];
        
    for(NSString *chat_line in simple_chat_backlog) {
        
        
        if(chat_line.length > 0) {
            [[RODItemStore sharedStore] addChat:chat_line];
            NSIndexPath *ip = [NSIndexPath indexPathForRow:0 inSection:0];
            [self.tableChats insertRowsAtIndexPaths:[NSArray arrayWithObject:ip] withRowAnimation:UITableViewRowAnimationNone];
        }
        
    }
    
    [self.loadingChat stopAnimating];
    [self setCogColor:@"green"];
    
}

- (void)addSimpleMessage:(NSString *)chat
{ 
    [[RODItemStore sharedStore] addChat:chat];
    
    [self.tableChats reloadData];
    
//    NSIndexPath *ip = [NSIndexPath indexPathForRow:0 inSection:0];
//    [self.tableChats insertRowsAtIndexPaths:[NSArray arrayWithObject:ip] withRowAnimation:UITableViewRowAnimationTop];
    
}

- (void)requestBacklog:(UIRefreshControl *)refreshControl
{
    
    
    if([RODItemStore sharedStore].chatConnection.state == disconnected || [RODItemStore sharedStore].chatConnection.state == reconnecting) {
        [self setCogColor:@"black"];
        [self enterChat];
        return;
    }
    
    [refreshControl endRefreshing];
    [self askForBacklog];
    
}

- (void)askForBacklog {

    [self setCogColor:@"purple"];
    
    self.countDown = 10;
    
    refreshTimer = [NSTimer scheduledTimerWithTimeInterval:1.0f target:self selector:@selector(countDownTick:) userInfo:nil repeats:YES];

    if([RODItemStore sharedStore].chatConnection.state == reconnecting || [RODItemStore sharedStore].chatConnection.state == disconnected) {
        [[RODItemStore sharedStore].chatConnection disconnect];
        
        [self setCogColor:@"red"];
        
        [self addSimpleMessage:@"Chat connection had disconnected or was stalled, entering chat again."];
        [self enterChat];
        
        return;
    }
    
    [[RODItemStore sharedStore].chatHub invoke:@"RequestSimpleBacklog" withArgs:[NSArray arrayWithObject:@"hi"] completionHandler:^(id response) {
        NSLog(@"Backlog completion handler fired.");
        [self addSimpleMessage:@"Backlog request completed."];
        
    }];
    
    [[RODItemStore sharedStore] clearChats];
    
    [self addSimpleMessage:@"Refreshing chat, one moment please."];
    
    [self.tableChats reloadData];
    
    [self.loadingChat startAnimating];

    
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [[RODItemStore sharedStore] allChats].count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"UITableViewCell"];
    
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"UITableViewCell"];
    }
    
    NSString *c = [[[RODItemStore sharedStore] allChats] objectAtIndex:[indexPath row]];
    
    [[cell textLabel] setText:c];
    [[cell textLabel] setLineBreakMode:NSLineBreakByWordWrapping];
    [[cell textLabel] setNumberOfLines:0];
    [[cell textLabel] setFont:[UIFont systemFontOfSize:10]];
        
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath;
{
    NSString *text = [[[RODItemStore sharedStore] allChats] objectAtIndex:[indexPath row]];
    
    UIFont *cellFont = [UIFont systemFontOfSize:10];
    CGSize constraintSize = CGSizeMake(self.view.bounds.size.width, MAXFLOAT);
    CGSize labelSize = [text sizeWithFont:cellFont constrainedToSize:constraintSize lineBreakMode:NSLineBreakByWordWrapping];
    
    return labelSize.height + 20;
        
}

-(void)enterChat:(UIBarButtonItem *)button
{
    [self enterChat];
}

-(void)enterChat
{
    
    if([RODItemStore sharedStore].chatConnection) {
        [[RODItemStore sharedStore].chatConnection disconnect];
    }
    
    [self.loadingChat startAnimating];
    
    // add refresh control
    UIRefreshControl *refreshControl = [[UIRefreshControl alloc] init];
    [refreshControl addTarget:self action:@selector(requestBacklog:) forControlEvents:UIControlEventValueChanged];
    [self.tableChats addSubview:refreshControl];
    
    [RODItemStore sharedStore].chatConnection = [SRHubConnection connectionWithURL:@"http://letterstocrushes.com"];
    [RODItemStore sharedStore].chatConnection.delegate = [[RODItemStore sharedStore] self];
    
    [RODItemStore sharedStore].chatHub = [[RODItemStore sharedStore].chatConnection createHubProxy:@"VisitorUpdate"];
    
    [RODItemStore sharedStore].chatConnection.error = ^(NSError * __strong err){
        [_labelStatus setImage:[UIImage imageNamed:@"cog-black.png"]];
        [[RODItemStore sharedStore] addChat:[NSString stringWithFormat:@"Error: %@", err]];
        [self.tableChats reloadData];
        [self enterChat];
    };
                                          
    
//    [RODItemStore sharedStore].chatConnection.reconnected = ^{
//        NSLog(@"Reconnected.. hihihi");
//        [self addSimpleMessage:@"chatConnection.reconnected fired."];
// //       [self askForBacklog];
//    };
    
    [RODItemStore sharedStore].chatConnection.started = ^{
        NSLog(@"Connection started.");
        [[RODItemStore sharedStore].chatHub invoke:@"join" withArgs:[NSArray arrayWithObject:[RODItemStore sharedStore].settings.chatName]];
        
        [[RODItemStore sharedStore].chatHub on:@"addSimpleMessage" perform:self selector:@selector(addSimpleMessage:)];
        [[RODItemStore sharedStore].chatHub on:@"addSimpleBacklog" perform:self selector:@selector(addSimpleBacklog:)];
        
        [RODItemStore sharedStore].connected_to_chat = true;
        [_labelStatus setImage:[UIImage imageNamed:@"cog-green.png"]];
        
        
    };
        
    [[RODItemStore sharedStore].chatConnection start];

}

- (void) countDownTick:(NSTimer *)timer
{
    
    self.countDown--;
        
    [[RODItemStore sharedStore] addChat:[NSString stringWithFormat:@"Refreshing: %d seconds", self.countDown]];
    [self.tableChats reloadData];
    
    if(self.countDown == 0) {
        [self.refreshTimer invalidate];
        self.refreshTimer = nil;
        [self enterChat];
    }
    
}

- (void)hamburger:(id)sender
{
    [self.textMessage resignFirstResponder];
    AppDelegate *appDelegate = (AppDelegate *) [[UIApplication sharedApplication] delegate];
    [appDelegate.navigationController showMenu];
}

@end
