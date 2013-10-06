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
    
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    [button setFrame:CGRectMake(0, 0, 30, 30)];
    [button setImage:[UIImage imageNamed:@"cog.png"] forState:UIControlStateNormal];
    [button addTarget:self action:@selector(leaveChat:) forControlEvents:UIControlEventTouchUpInside];
    
    [[self.textMessage layer] setBorderColor:[[UIColor blackColor] CGColor]];
    [[self.textMessage layer] setBorderWidth:1.0f];
    [[self.textMessage layer] setCornerRadius:1.0f];
        
    _labelStatus = [[UIBarButtonItem alloc] initWithCustomView:button];

    [self.navigationItem setRightBarButtonItem:_labelStatus animated:YES];
    
    
    UIButton *button_menu = [UIButton buttonWithType:UIButtonTypeCustom];
    [button_menu setFrame:CGRectMake(0, 0, 30, 30)];
    [button_menu setImage:[UIImage imageNamed:@"hamburger-150px.png"] forState:UIControlStateNormal];
    [button_menu addTarget:self action:@selector(hamburger:) forControlEvents:UIControlEventTouchUpInside];
    
    UIBarButtonItem *leftDrawerButton = [[UIBarButtonItem alloc] initWithCustomView:button_menu];
    [self.navigationItem setLeftBarButtonItem:leftDrawerButton animated:YES];
    
    [[self navigationItem] setTitle:@"chat"];
    
    
    [self enterChat];

}

- (void)leaveChat:(UIBarButtonItem *)button
{
    if([RODItemStore sharedStore].chatConnection) {
        [[RODItemStore sharedStore].chatConnection disconnect];
    }
    
    AppDelegate *appDelegate = (AppDelegate *) [[UIApplication sharedApplication] delegate];
    [appDelegate.navigationController popViewControllerAnimated:NO];
    [appDelegate.navigationController pushViewController:appDelegate.chatNameViewController animated:YES];
    
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
}

-(void)viewDidAppear:(BOOL)animated {

    [super viewDidAppear:animated];
    
    if([RODItemStore sharedStore].chatConnection.state == reconnecting || [RODItemStore sharedStore].chatConnection.state == disconnected) {
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

- (void)SRConnectionDidOpen:(id<SRConnectionInterface>)connection
{
    [self addSimpleMessage:@"Connecting to the chat, please wait."];
}

- (void)SRConnectionDidClose:(id<SRConnectionInterface>)connection
{
    [self addSimpleMessage:@"Connection to the chat was closed."];
}

- (void)SRConnectionDidReconnect:(id<SRConnectionInterface>)connection
{
    [self addSimpleMessage:@"You are reconnected to the chat."];
}

-(void)SRConnection:(id<SRConnectionInterface>)connection didReceiveError:(NSError *)error
{
    [self addSimpleMessage:[NSString stringWithFormat:@"Connection error: %@", error.localizedDescription]];
}

-(void)SRConnection:(id<SRConnectionInterface>)connection didChangeState:(connectionState)oldState newState:(connectionState)newState
{
    
    switch (newState) {
        case connected:
            [refreshTimer invalidate];
        default:
            break;
    }
    
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
        [self enterChat];
        return;
    }
    
    [refreshControl endRefreshing];
    [self askForBacklog];
    
}

- (void)askForBacklog {

    self.countDown = 20;
    
    refreshTimer = [NSTimer scheduledTimerWithTimeInterval:1.0f target:self selector:@selector(countDownTick:) userInfo:nil repeats:YES];

    if([RODItemStore sharedStore].chatConnection.state == reconnecting || [RODItemStore sharedStore].chatConnection.state == disconnected) {
        [[RODItemStore sharedStore].chatConnection disconnect];
        
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
    [RODItemStore sharedStore].chatConnection.delegate = self;
    
    [RODItemStore sharedStore].chatHub = [[RODItemStore sharedStore].chatConnection createHubProxy:@"VisitorUpdate"];
    
    [RODItemStore sharedStore].chatConnection.error = ^(NSError * __strong err){
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
