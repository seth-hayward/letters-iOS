//
//  ChatNameViewController.h
//  crushes
//
//  Created by Seth Hayward on 9/6/13.
//  Copyright (c) 2013 Seth Hayward. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ChatNameViewController : UIViewController <UITextViewDelegate>
{
    UIBarButtonItem* _goChat;
}

@property (weak, nonatomic) IBOutlet UITextView *textChatName;
- (IBAction)btnGo:(id)sender;

@end
