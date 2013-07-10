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
#import "RKEditLetter.h"
#import "RKEditMessage.h"
#import "RKMessage.h"
#import "AppDelegate.h"
#import "WebViewController.h"

@implementation SendViewController
@synthesize isEditing, editingId;

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
    self.messageText.layer.borderWidth = 5.0f;
    self.messageText.layer.borderColor = [[UIColor grayColor] CGColor];
}

- (void)viewDidUnload {
    self.messageText = nil;
    self.sendButton = nil;
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
	NSString *letter_message = [self.messageText text];
    
	// Create a new letter and POST it to the server
	RKLetter* letter = [RKLetter new];
    letter.mobile = @"1";
	letter.letterText = letter_message;
    letter.letterCountry = @"US";
    
    NSURL *baseURL = [NSURL URLWithString:@"http://www.letterstocrushes.com"];
    AFHTTPClient *client = [[AFHTTPClient alloc] initWithBaseURL:baseURL];
    
    [client setDefaultHeader:@"Accept" value:RKMIMETypeJSON];
    
    RKObjectManager *objectManager = [[RKObjectManager alloc] initWithHTTPClient:client];

    RKObjectMapping* responseObjectMapping;
    RKResponseDescriptor* responseDescriptor;
    RKRequestDescriptor* requestDescriptor;
    NSString *real_url;
    
    if(self.isEditing == NO) {
        
        //
        // send letter
        //

        responseObjectMapping = [RKObjectMapping mappingForClass:[RKMessage class]];
        
        [responseObjectMapping addAttributeMappingsFromDictionary:@{
         @"response": @"response",
         @"message": @"message",
         @"guid": @"guid"
         }];
        
        responseDescriptor = [RKResponseDescriptor responseDescriptorWithMapping:responseObjectMapping pathPattern:nil keyPath:nil statusCodes:RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful)];
        
        RKObjectMapping* letterRequestMapping = [RKObjectMapping requestMapping];
        [letterRequestMapping addAttributeMappingsFromDictionary:@{
         @"letterText": @"letterText",
         @"letterCountry" : @"letterCountry",
         @"mobile": @"mobile"}];
        
        requestDescriptor = [RKRequestDescriptor requestDescriptorWithMapping:letterRequestMapping objectClass:[RKLetter class] rootKeyPath:@""];
        [objectManager addRequestDescriptor:requestDescriptor];
        
        real_url = @"http://www.letterstocrushes.com/home/mail";
        
        [objectManager addResponseDescriptor:responseDescriptor];
        objectManager.requestSerializationMIMEType = RKMIMETypeJSON;
        
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
                
                // now display a webview with the letter...
                
                AppDelegate *appDelegate = (AppDelegate *) [[UIApplication sharedApplication] delegate];
                [appDelegate.tabBar setSelectedIndex:1];
                
                // load a blank page, so they don't see the previous page... good idea or not?
                [appDelegate.moreWebViewController.currentWebView loadHTMLString:@"" baseURL:[NSURL URLWithString:@"http://www.google.com"]];
                
                NSURL *url;
                url = [NSURL URLWithString:[NSString stringWithFormat:@"http://www.letterstocrushes.com/mobile/letter/%@", msg.message]];
                
                NSURLRequest *req = [NSURLRequest requestWithURL:url];
                [appDelegate.moreWebViewController.currentWebView loadRequest:req];
                
            }
        } failure:^(RKObjectRequestOperation *operation, NSError *error) {
            
            // this occurs when restkit can not send a post -- this could happen
            // if the user does not have internet connection at the time
            UIAlertView *alert_post_error = [[UIAlertView alloc] initWithTitle:@"iOS Post Error" message: [error description] delegate:nil cancelButtonTitle:@"Okay" otherButtonTitles: nil];
            [alert_post_error show];
        }];
        
    } else {
        
        //
        // edit letter
        //

        NSLog(@"editing letter: %@", editingId);
        
        RKEditLetter* edit_letter = [RKEditLetter new];
        edit_letter.mobile = @"1";
        edit_letter.letterText = letter_message;
        edit_letter.letterId = self.editingId;
        
        responseObjectMapping = [RKObjectMapping mappingForClass:[RKEditMessage class]];
        
        [responseObjectMapping addAttributeMappingsFromDictionary:@{
         @"response": @"response",
         @"message": @"message"
         }];
        
        responseDescriptor = [RKResponseDescriptor responseDescriptorWithMapping:responseObjectMapping pathPattern:nil keyPath:nil statusCodes:RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful)];
        
        RKObjectMapping* letterEditRequestMapping = [RKObjectMapping requestMapping];
        [letterEditRequestMapping addAttributeMappingsFromDictionary:@{
         @"letterText": @"letterText",
         @"letterId" : @"id",
         @"mobile": @"mobile"}];
        
        requestDescriptor = [RKRequestDescriptor requestDescriptorWithMapping:letterEditRequestMapping objectClass:[RKEditLetter class] rootKeyPath:@""];
        [objectManager addRequestDescriptor:requestDescriptor];
        
        real_url = @"http://www.letterstocrushes.com/Home/EditLetter";
        
        [objectManager addResponseDescriptor:responseDescriptor];
        objectManager.requestSerializationMIMEType = RKMIMETypeJSON;
        
        [objectManager postObject:edit_letter path:real_url parameters:nil success:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
            
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
                UIAlertView *alert_success = [[UIAlertView alloc] initWithTitle:@"Success!" message: @"Letter edited." delegate:nil cancelButtonTitle:@"Okay" otherButtonTitles: nil];
                [alert_success show];
                
                // set a cookie in UI web view manually, this used
                // to be done in javascript following the post...
                NSMutableDictionary *cookieProperties = [NSMutableDictionary dictionary];
                [cookieProperties setObject:msg.guid forKey:NSHTTPCookieName];
                [cookieProperties setObject:@"0" forKey:NSHTTPCookieValue];
                [cookieProperties setObject:@"letterstocrushes.com" forKey:NSHTTPCookieDomain];
                [cookieProperties setObject:@"letterstocrushes.com" forKey:NSHTTPCookieOriginURL];
                [cookieProperties setObject:@"/" forKey:NSHTTPCookiePath];
                [cookieProperties setObject:@"0" forKey:NSHTTPCookieVersion];

                // set expiration to be neeeever
                [cookieProperties setObject:[[NSDate date] dateByAddingTimeInterval:2629743] forKey:NSHTTPCookieExpires];
                
                NSHTTPCookie *cookie = [NSHTTPCookie cookieWithProperties:cookieProperties];
                [[NSHTTPCookieStorage sharedHTTPCookieStorage] setCookie:cookie];
                
                // now display a webview with the letter...
                
                AppDelegate *appDelegate = (AppDelegate *) [[UIApplication sharedApplication] delegate];
                [appDelegate.tabBar setSelectedIndex:1];
                
                // load a blank page, so they don't see the previous page... good idea or not?
                [appDelegate.moreWebViewController.currentWebView loadHTMLString:@"" baseURL:[NSURL URLWithString:@"http://www.google.com"]];
                
                NSURL *url;
                url = [NSURL URLWithString:[NSString stringWithFormat:@"http://www.letterstocrushes.com/mobile/letter/%@", self.editingId]];
                
                NSURLRequest *req = [NSURLRequest requestWithURL:url];
                [appDelegate.moreWebViewController.currentWebView loadRequest:req];
                
            }
        } failure:^(RKObjectRequestOperation *operation, NSError *error) {
            
            // this occurs when restkit can not send a post -- this could happen
            // if the user does not have internet connection at the time
            UIAlertView *alert_post_error = [[UIAlertView alloc] initWithTitle:@"iOS Post Error" message: [error description] delegate:nil cancelButtonTitle:@"Okay" otherButtonTitles: nil];
            [alert_post_error show];
        }];
        
        
    }
    
    
}
@end
