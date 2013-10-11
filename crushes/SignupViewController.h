//
//  SignupViewController.h
//  crushes
//
//  Created by Seth Hayward on 10/11/13.
//  Copyright (c) 2013 Seth Hayward. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <GAITrackedViewController.h>

@interface SignupViewController : GAITrackedViewController <UITextFieldDelegate>
@property (weak, nonatomic) IBOutlet UITextField *textEmail;
@property (weak, nonatomic) IBOutlet UITextField *textPassword;

@end
