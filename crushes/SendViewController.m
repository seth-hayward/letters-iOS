//
//  SendViewController.m
//  crushes
//
//  Created by Seth Hayward on 12/6/12.
//  Copyright (c) 2012 Seth Hayward. All rights reserved.
//

#import "SendViewController.h"
#import <QuartzCore/QuartzCore.h>
#import "RKLetter.h"

@implementation SendViewController

-(id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    
    if (self) {
        UITabBarItem *tbi = [self tabBarItem];
        [tbi setTitle:@"Send"];
        [tbi setImage:[UIImage imageNamed:@"pencil.png"]];
    }
    
    NSLog(@"Hello from SendView.");
    
    NSURL *baseURL = [NSURL URLWithString:@"http://www.letterstocrushes.com/"];  //http://example.com/v1/"];
    [NSURL URLWithString:@"foo" relativeToURL:baseURL];                  // http://example.com/v1/foo
    [NSURL URLWithString:@"foo?bar=baz" relativeToURL:baseURL];          // http://example.com/v1/foo?bar=baz
    [NSURL URLWithString:@"/foo" relativeToURL:baseURL];                 // http://example.com/foo
    [NSURL URLWithString:@"foo/" relativeToURL:baseURL];                 // http://example.com/v1/foo
    [NSURL URLWithString:@"/foo/" relativeToURL:baseURL];                // http://example.com/foo/
    [NSURL URLWithString:@"http://example2.com/" relativeToURL:baseURL]; // http://example2.com/
    
    return self;
}

- (void)viewDidLoad
{
    messageText.layer.borderWidth = 5.0f;
    messageText.layer.borderColor = [[UIColor grayColor] CGColor];
}

- (void)viewDidUnload {
    messageText = nil;
    sendButton = nil;
    [super viewDidUnload];
}

-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}
- (IBAction)backgroundTapped:(id)sender {
    [[self view] endEditing:YES];
   }

- (IBAction)sendLetter:(id)sender {
    // Read the value from the text field
	NSString *letter_message = [messageText text];
    
	// Create a new letter and POST it to the server
	RKLetter* letter = [RKLetter new];
	letter.letterText = letter_message;
    letter.letterCountry = @" ";
    
	[[RKObjectManager sharedManager] postObject:letter path:@"http://www.letterstocrushes.com/Home/Mail" parameters:nil success:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
        UIAlertView *alert_success = [[UIAlertView alloc] initWithTitle:@"Success!" message: @"It was sent." delegate:nil cancelButtonTitle:@"Okay" otherButtonTitles: nil];
        [alert_success show];
    } failure:^(RKObjectRequestOperation *operation, NSError *error) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Send Error" message: [error description] delegate:nil cancelButtonTitle:@"Okay" otherButtonTitles: nil];
        [alert show];        
    }];
    
    NSLog(letter_message);
}
@end
