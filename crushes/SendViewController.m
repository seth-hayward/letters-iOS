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
#import "RKMessage.h"

@implementation SendViewController

-(id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    
    if (self) {
        UITabBarItem *tbi = [self tabBarItem];
        [tbi setTitle:@"Send"];
        [tbi setImage:[UIImage imageNamed:@"envelope.png"]];
    }
    
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
    letter.letterCountry = @"US";
    
    NSURL *baseURL = [NSURL URLWithString:@"http://www.letterstocrushes.com"];
    AFHTTPClient *client = [[AFHTTPClient alloc] initWithBaseURL:baseURL];
    
    [client setDefaultHeader:@"Accept" value:RKMIMETypeJSON];
    
    RKObjectManager *objectManager = [[RKObjectManager alloc] initWithHTTPClient:client];
    
//    RKObjectMapping *requestMapping = [RKObjectMapping requestMapping];
//    [requestMapping addAttributeMappingsFromArray:@[@"message", @"response", @"guid"]];
//    
//    RKRequestDescriptor *requestDescriptor = [RKRequestDescriptor requestDescriptorWithMapping:requestMapping objectClass:[RKMessage class] rootKeyPath:@""];
//    
//    [objectManager addRequestDescriptor:requestDescriptor];
    
    
    // begin github sample
    
    RKObjectMapping* responseObjectMapping = [RKObjectMapping mappingForClass:[RKMessage class]];
    [responseObjectMapping addAttributeMappingsFromDictionary:@{
        @"response": @"response",
        @"message": @"message",
        @"guid": @"guid"
     }];
    
    RKResponseDescriptor *responseDescriptor = [RKResponseDescriptor responseDescriptorWithMapping:responseObjectMapping pathPattern:nil keyPath:nil statusCodes:RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful)];
    
    NSString *url = [NSString stringWithFormat:@"%@%@%@", @"http://www.letterstocrushes.com/Home/Mail?letterText=", letter_message, @"&letterCountry=US"];
    NSString *safe_url = [url stringByAddingPercentEscapesUsingEncoding:NSASCIIStringEncoding];
    NSString *real_url = @"http://www.letterstocrushes.com/home/mail";
    
    [objectManager addResponseDescriptor:responseDescriptor];
    
    [objectManager postObject:letter path:real_url parameters:nil success:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
        
        // now we just need to check the response
        // there may have been an error on the server that
        // we want to check for
        RKMessage* msg = mappingResult.array[0];
       
        if([msg.response isEqualToNumber:[NSNumber numberWithInt:0]]) {
            // there was an error on the server
            
            UIAlertView *alert_error = [[UIAlertView alloc] initWithTitle:@"Error" message:msg.message delegate:nil cancelButtonTitle:@"Okay" otherButtonTitles: nil];
            [alert_error show];
            
        } else {
            // we good
            UIAlertView *alert_success = [[UIAlertView alloc] initWithTitle:@"Success!" message: @"It was sent." delegate:nil cancelButtonTitle:@"Okay" otherButtonTitles: nil];
            [alert_success show];
            
        }
    } failure:^(RKObjectRequestOperation *operation, NSError *error) {
        
        // this occurs when restkit can not send a post -- this could happen
        // if the user does not have internet connection at the time
        UIAlertView *alert_post_error = [[UIAlertView alloc] initWithTitle:@"iOS Post Error" message: [error description] delegate:nil cancelButtonTitle:@"Okay" otherButtonTitles: nil];
        [alert_post_error show];
    }];
    
}
@end
