//
//  ChatViewController.m
//  crushes
//
//  Created by Seth Hayward on 9/6/13.
//  Copyright (c) 2013 Seth Hayward. All rights reserved.
//

#import "ChatViewController.h"
#import "SignalR.h"

@implementation ChatViewController
@synthesize chatHub;

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
    
    NSLog(@"Hello, let's try to connect to the chat server.");
    SRHubConnection *hubConnection = [SRHubConnection connectionWithURL:@"http://letterstocrushes.com"];
    
    chatHub = [hubConnection createHubProxy:@"VisitorUpdate"];
    [chatHub on:@"addMessage" perform:self selector:@selector(addMessage:)];
        
    hubConnection.started = ^{
        NSLog(@"Tried to invoke the event.");
        [self addMessage:@"hi "];
        [chatHub invoke:@"admin" withArgs:[NSArray arrayWithObject:@"lolcats"]];
        
    };
    
    [hubConnection start];
    
    NSLog(@"started.");
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)btnSend:(id)sender {
    [chatHub invoke:@"admin" withArgs:[NSArray arrayWithObject:@"lolcats"]];
    
}

- (void)addMessage:(NSString *)message {
    NSLog(@"Msg: %@", message);
    self.textMessage.text = message;
}
@end
