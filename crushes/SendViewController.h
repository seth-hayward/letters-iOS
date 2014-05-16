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
}
- (IBAction)backgroundTapped:(id)sender;
- (IBAction)sendLetter:(id)sender;
@property (weak, nonatomic) IBOutlet UILabel *labelCallToAction;
@property (weak, nonatomic) IBOutlet UIButton *sendButton;
@property (weak, nonatomic) IBOutlet UITextView *messageText;
@property (nonatomic) BOOL *isEditing;
@property (strong, nonatomic) NSString *editingId;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *indicator;

@end
