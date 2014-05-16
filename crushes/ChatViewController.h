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
{
    UIBarButtonItem* _labelStatus;
    UIButton* _buttonStatus;
}
- (void)addSimpleMessage:(NSString *)message;
-(void)setCogColor:(NSString*)color;
- (IBAction)btnSend:(id)sender;
@property (weak, nonatomic) IBOutlet UITextView *textMessage;
@property (weak, nonatomic) IBOutlet UITableView *tableChats;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *loadingChat;
@property (weak, nonatomic) NSTimer *refreshTimer;
@property (nonatomic) int countDown;

@end
