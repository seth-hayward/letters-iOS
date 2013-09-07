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


@implementation ChatViewController
@synthesize chatHub;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        
        MMDrawerBarButtonItem * leftDrawerButton = [[MMDrawerBarButtonItem alloc] initWithTarget:self action:@selector(openDrawer:)];
        [self.navigationItem setLeftBarButtonItem:leftDrawerButton animated:YES];
        
        [[self navigationItem] setTitle:@"CHAT"];
        
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    SRHubConnection *hubConnection = [SRHubConnection connectionWithURL:@"http://letterstocrushes.com"];
    
    chatHub = [hubConnection createHubProxy:@"VisitorUpdate"];
    
    hubConnection.started = ^{
        [chatHub invoke:@"join" withArgs:[NSArray arrayWithObject:[RODItemStore sharedStore].settings.chatName]];
        
        [chatHub on:@"addMessage" perform:self selector:@selector(addMessage:)];

    };
    
    [hubConnection start];
    
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (BOOL)textViewShouldEndEditing:(UITextView *)textView
{
    [textView resignFirstResponder];
    [self sendChat];
    return YES;
}

- (void)sendChat {
    NSString *txt = self.textMessage.text;
    [chatHub invoke:@"sendChat" withArgs:[NSArray arrayWithObject:txt]];
    [self.textMessage setText:@""];
}

- (IBAction)btnSend:(id)sender {
    [self sendChat];
}

- (void)addMessage:(NSString *)message {
    NSLog(@"Msg: %@", message);
    
    NSString* JSONString = @"{ \"name\": \"The name\", \"number\": 12345}";
    NSString* MIMEType = @"application/json";
    NSError* error;
    NSData *data = [JSONString dataUsingEncoding:NSUTF8StringEncoding];
    id parsedData = [RKMIMETypeSerialization objectFromData:data MIMEType:MIMEType error:&error];
    if (parsedData == nil && error) {
        // Parser error...
    }
    
    AppUser *appUser = [[AppUser alloc] init];
    
    NSDictionary *mappingsDictionary = @{ @"someKeyPath": someMapping };
    RKMapperOperation *mapper = [[RKMapperOperation alloc] initWithRepresentation:parsedData mappingsDictionary:mappingsDictionary];
    mapper.targetObject = appUser;
    NSError *mappingError = nil;
    BOOL isMapped = [mapper execute:&mappingError];
    if (isMapped && !mappingError) {
        // Yay! Mapping finished successfully
        NSLog(@"mapper: %@", [mapper representation]);
        NSLog(@"firstname is %@", appUser.firstName);
    }
    
    
    [[RODItemStore sharedStore] addChat:message];
    [self.tableChats reloadData];
    //self.textMessage.text = message;
}

- (void)openDrawer:(id)sender {
    
    // now tell the web view to change the page
    AppDelegate *appDelegate = (AppDelegate *) [[UIApplication sharedApplication] delegate];
    [appDelegate.drawer toggleDrawerSide:MMDrawerSideLeft animated:YES completion:nil];
    
}

@end
