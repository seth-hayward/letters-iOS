//
//  AddCommentViewController.h
//  crushes
//
//  Created by Seth Hayward on 9/15/13.
//  Copyright (c) 2013 Seth Hayward. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AddCommentViewController : UIViewController
@property (weak, nonatomic) IBOutlet UITextView *textCommenterName;
@property (weak, nonatomic) IBOutlet UITextView *textCommenterEmail;
@property (weak, nonatomic) IBOutlet UITextView *textComment;
@property (weak, nonatomic) IBOutlet UIButton *btnAdd;

@end
