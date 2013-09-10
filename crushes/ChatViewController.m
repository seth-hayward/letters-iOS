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
@synthesize chatHub;

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
    
    [self.loadingChat startAnimating];
    
    // add refresh control
    UIRefreshControl *refreshControl = [[UIRefreshControl alloc] init];
    [refreshControl addTarget:self action:@selector(requestBacklog:) forControlEvents:UIControlEventValueChanged];
    [self.tableChats addSubview:refreshControl];
        
    SRHubConnection *hubConnection = [SRHubConnection connectionWithURL:@"http://letterstocrushes.com"];
    
    chatHub = [hubConnection createHubProxy:@"VisitorUpdate"];
    
    hubConnection.started = ^{
        [chatHub invoke:@"join" withArgs:[NSArray arrayWithObject:[RODItemStore sharedStore].settings.chatName]];
        
        [chatHub on:@"addSimpleMessage" perform:self selector:@selector(addSimpleMessage:)];
        [chatHub on:@"addSimpleBacklog" perform:self selector:@selector(addSimpleBacklog:)];
        
        [RODItemStore sharedStore].connected_to_chat = true;
        
    };
    
    [hubConnection start];
    
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
    [chatHub invoke:@"sendChat" withArgs:[NSArray arrayWithObject:txt]];
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
            NSLog(@"added: %@", chat_line);
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
    
    NSIndexPath *ip = [NSIndexPath indexPathForRow:0 inSection:0];
    [self.tableChats insertRowsAtIndexPaths:[NSArray arrayWithObject:ip] withRowAnimation:UITableViewRowAnimationTop];
    
}

- (void)requestBacklog:(UIRefreshControl *)refreshControl
{
    NSLog(@"Requesting backlog.");
    [refreshControl endRefreshing];
        
    [chatHub invoke:@"RequestSimpleBacklog" withArgs:[NSArray arrayWithObject:@"hi"] completionHandler:^(id response) {
    }];
        
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

@end
