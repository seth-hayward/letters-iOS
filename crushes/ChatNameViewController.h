//
//  ChatNameViewController.h
//  crushes
//
//  Created by Seth Hayward on 9/6/13.
//  Copyright (c) 2013 Seth Hayward. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ChatNameViewController : UIViewController <UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UITextField *textChatName;
- (IBAction)btnGo:(id)sender;

@end
