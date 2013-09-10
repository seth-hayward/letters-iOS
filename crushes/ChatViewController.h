//
//  ChatViewController.h
//  crushes
//
//  Created by Seth Hayward on 9/6/13.
//  Copyright (c) 2013 Seth Hayward. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SignalR.h"

@interface ChatViewController : UIViewController <UITextViewDelegate, UITableViewDelegate, UITableViewDataSource, SRConnectionDelegate>
- (void)addSimpleMessage:(NSString *)message;
- (IBAction)btnSend:(id)sender;
@property (weak, nonatomic) IBOutlet UITextView *textMessage;
@property (weak, nonatomic) IBOutlet UITableView *tableChats;
@property (strong, nonatomic) SRHubProxy *chatHub;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *loadingChat;

@end
