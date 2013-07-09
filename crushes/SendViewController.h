//
//  SendViewController.h
//  crushes
//
//  Created by Seth Hayward on 12/6/12.
//  Copyright (c) 2012 Seth Hayward. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GAITrackedViewController.h"

@interface SendViewController : GAITrackedViewController <UITextFieldDelegate>
{
}
- (IBAction)backgroundTapped:(id)sender;
- (IBAction)sendLetter:(id)sender;
@property (weak, nonatomic) IBOutlet UILabel *labelCallToAction;
@property (weak, nonatomic) IBOutlet UIButton *sendButton;
@property (weak, nonatomic) IBOutlet UITextView *messageText;
@property (nonatomic) BOOL *isEditing;
@property (weak, nonatomic) NSString *editingId;

@end
