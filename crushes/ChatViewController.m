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

    NSLog(@"viewDidLoad.");
    
    _labelStatus = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh target:self action:@selector(enterChat:)];
    [self.navigationItem setRightBarButtonItem:_labelStatus animated:YES];
    
    [[self navigationItem] setTitle:[NSString stringWithFormat:@"chat (%d)", [RODItemStore sharedStore].chatConnection.state]];
    
    [self enterChat];
            
}

- (void)chatReconnected;
{
    [self addSimpleMessage:@"The chat has reconnected."];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    if([RODItemStore sharedStore].chatConnection.state == reconnecting) {
        [[RODItemStore sharedStore].chatConnection stop];
        [self enterChat];
        [self addSimpleMessage:[NSString stringWithFormat:@"viewWillAppear: reconnecting, %d", [RODItemStore sharedStore].chatConnection.state]];
    }
    
    if([RODItemStore sharedStore].chatConnection.state == disconnected) {
        [[RODItemStore sharedStore].chatConnection stop];
        [self enterChat];
        [self addSimpleMessage:[NSString stringWithFormat:@"viewWillAppear: disconnected, %d", [RODItemStore sharedStore].chatConnection.state]];
        
    }
    
    [[self navigationItem] setTitle:[NSString stringWithFormat:@"chat (%d)", [RODItemStore sharedStore].chatConnection.state]];
    
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

    [refreshControl endRefreshing];
    [self askForBacklog];
    
}

- (void)askForBacklog {

    if([RODItemStore sharedStore].chatConnection.state == reconnecting || [RODItemStore sharedStore].chatConnection.state == disconnected) {
        [[RODItemStore sharedStore].chatConnection stop];
        
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

-(IBAction)refresChat:(id)sender
{
    [self enterChat];
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
    
    if([RODItemStore sharedStore].chatConnection.state == reconnecting) {
        //[chatConnection stop];
        [self addSimpleMessage:@"Reconnecting, not going to try just yet..."];
        return;
    }
    
    [self.loadingChat startAnimating];
    
    // add refresh control
    UIRefreshControl *refreshControl = [[UIRefreshControl alloc] init];
    [refreshControl addTarget:self action:@selector(requestBacklog:) forControlEvents:UIControlEventValueChanged];
    [self.tableChats addSubview:refreshControl];
    
    [RODItemStore sharedStore].chatConnection = [SRHubConnection connectionWithURL:@"http://letterstocrushes.com"];
    [RODItemStore sharedStore].chatConnection.delegate = self;
    
    [self.textMessage setBackgroundColor:[UIColor colorWithRed:245/255.0f green:150/255.0f blue:150/255.0f alpha:1.0f]];
    

//    if([RODItemStore sharedStore].chatHub) {
//        // chathub was already initialized prior, lets do cleanup
//        [self addSimpleMessage:@"chatHub was already initialized."];
//    }
    
    [RODItemStore sharedStore].chatHub = [[RODItemStore sharedStore].chatConnection createHubProxy:@"VisitorUpdate"];
    
    [RODItemStore sharedStore].chatConnection.reconnected = ^{
        NSLog(@"Reconnected.. hihihi");
        [self addSimpleMessage:@"chatConnection.reconnected fired."];
 //       [self askForBacklog];
    };
        
    [RODItemStore sharedStore].chatConnection.started = ^{
        [[RODItemStore sharedStore].chatHub invoke:@"join" withArgs:[NSArray arrayWithObject:[RODItemStore sharedStore].settings.chatName]];
        
        [[RODItemStore sharedStore].chatHub on:@"addSimpleMessage" perform:self selector:@selector(addSimpleMessage:)];
        [[RODItemStore sharedStore].chatHub on:@"addSimpleBacklog" perform:self selector:@selector(addSimpleBacklog:)];
        
        [RODItemStore sharedStore].connected_to_chat = true;
        
    };
    
    [[RODItemStore sharedStore].chatConnection start];

}

@end
