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
        
        MMDrawerBarButtonItem * leftDrawerButton = [[MMDrawerBarButtonItem alloc] initWithTarget:self action:@selector(openDrawer:)];
        [self.navigationItem setLeftBarButtonItem:leftDrawerButton animated:YES];
        
        [[self navigationItem] setTitle:@"chat"];

        self.tableChats.sectionHeaderHeight = 0;
        self.tableChats.sectionFooterHeight = 0;
        
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    [button setFrame:CGRectMake(0, 0, 30, 30)];
    [button setImage:[UIImage imageNamed:@"cog_2.png"] forState:UIControlStateNormal];
    [button addTarget:self action:@selector(leaveChat:) forControlEvents:UIControlEventTouchUpInside];
        
    _labelStatus = [[UIBarButtonItem alloc] initWithCustomView:button];

    [self.navigationItem setRightBarButtonItem:_labelStatus animated:YES];
    
    [self enterChat];

}

- (void)leaveChat:(UIBarButtonItem *)button
{
    if([RODItemStore sharedStore].chatConnection) {
        [[RODItemStore sharedStore].chatConnection disconnect];
    }
    
    //[[RODItemStore sharedStore] clearChats];

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
        [self addSimpleMessage:[NSString stringWithFormat:@"viewWillAppear: reconnecting, %d", [RODItemStore sharedStore].chatConnection.state]];
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
            
        case reconnecting:

            //[_labelStatus setEnabled:true];
            
            [self addSimpleMessage:@"Connection to the chat was lost, trying to reconnect... press the refresh button to try again."];
            break;
        case disconnected:
            
            //[_labelStatus setEnabled:true];
            [self addSimpleMessage:@"Disconnected. Press refresh button to enter chat again."];
            break;
        default:

            //[_labelStatus setEnabled:false];
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
    NSLog(@"chat backlog fired.");
    [refreshTimer invalidate];
    
    NSArray *simple_chat_backlog = [chat componentsSeparatedByCharactersInSet:[NSCharacterSet newlineCharacterSet]];
        
    for(NSString *chat_line in simple_chat_backlog) {
        
        
        if(chat_line.length > 0) {
            //NSLog(@"added: %@", chat_line);
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
    
    [self addSimpleMessage:@"Requesting backlog."];
    
    [self.tableChats reloadData];
    
    [self.loadingChat startAnimating];

    
}

- (void)openDrawer:(id)sender {
    // now tell the web view to change the page
    AppDelegate *appDelegate = (AppDelegate *) [[UIApplication sharedApplication] delegate];
    [appDelegate.drawer toggleDrawerSide:MMDrawerSideLeft animated:YES completion:nil];    
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
    
    [self.textMessage setBackgroundColor:[UIColor colorWithRed:245/255.0f green:150/255.0f blue:150/255.0f alpha:1.0f]];
        
    [RODItemStore sharedStore].chatHub = [[RODItemStore sharedStore].chatConnection createHubProxy:@"VisitorUpdate"];
    
    [RODItemStore sharedStore].chatConnection.error = ^(NSError * __strong err){
        [[RODItemStore sharedStore] addChat:[NSString stringWithFormat:@"Error: %@", err]];
        [self.tableChats reloadData];
        [self enterChat];
    };
                                          
    
    [RODItemStore sharedStore].chatConnection.reconnected = ^{
        NSLog(@"Reconnected.. hihihi");
        [self addSimpleMessage:@"chatConnection.reconnected fired."];
 //       [self askForBacklog];
    };
        
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
    
    NSLog(@"countDownTick: %d", self.countDown);
    
    [[RODItemStore sharedStore] addChat:[NSString stringWithFormat:@"Refreshing: %d", self.countDown]];
    [self.tableChats reloadData];
    
    if(self.countDown == 0) {
        [self.refreshTimer invalidate];
        self.refreshTimer = nil;
        [self enterChat];
    }
    
}

@end
