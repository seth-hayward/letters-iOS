//
//  SendViewController.h
//  crushes
//
//  Created by Seth Hayward on 12/6/12.
//  Copyright (c) 2012 Seth Hayward. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SendViewController : UIViewController <UITextFieldDelegate>
{
    __weak IBOutlet UITextView *messageText;
    __weak IBOutlet UIButton *sendButton;    
}
- (IBAction)backgroundTapped:(id)sender;
- (IBAction)sendLetter:(id)sender;

@end
