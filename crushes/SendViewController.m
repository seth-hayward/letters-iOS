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
#import "WCAlertView.h"
#import "RODSentLetter.h"
#import "RODItemStore.h"
#import "MMDrawerBarButtonItem.h"

@implementation SendViewController
@synthesize isEditing, editingId;

-(id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    
    if (self) {
        
    }
    
    return self;
}

- (void)viewDidLoad
{

    // PREVENT THE UNDERLAPPING THAT OCCURS WITH
    // IOS 7!!!!!
    self.edgesForExtendedLayout = UIRectEdgeNone;
    
    self.messageText.layer.borderWidth = 5.0f;
    self.messageText.layer.borderColor = [[UIColor grayColor] CGColor];
    
    UIBarButtonItem *btnSend = [[UIBarButtonItem alloc] initWithTitle:@"send" style:UIBarButtonItemStylePlain target:self action:@selector(sendLetter:)];
    [btnSend setTintColor:[UIColor blueColor]];
    
    [self.navigationItem setRightBarButtonItem:btnSend];

    UIButton *button_menu = [UIButton buttonWithType:UIButtonTypeCustom];
    [button_menu setFrame:CGRectMake(0, 0, 30, 30)];
    [button_menu setImage:[UIImage imageNamed:@"hamburger-150px.png"] forState:UIControlStateNormal];
    [button_menu addTarget:self action:@selector(didPressHamburger:) forControlEvents:UIControlEventTouchUpInside];
    
    UIBarButtonItem *leftDrawerButton = [[UIBarButtonItem alloc] initWithCustomView:button_menu];
    [self.navigationItem setLeftBarButtonItem:leftDrawerButton animated:YES];
    
    [[self navigationItem] setTitle:@"write your letter"];
    
    [self.messageText becomeFirstResponder];
    
}

- (void)viewDidUnload {
    self.messageText = nil;
    self.sendButton = nil;
    [super viewDidUnload];
}

- (void)didPressHamburger:(UIBarButtonItem *)button
{
    [self.messageText resignFirstResponder];
    [(NavigationController *)self.navigationController showMenu];
}

-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}
- (IBAction)backgroundTapped:(id)sender {
    [[self view] endEditing:YES];
   }

- (void)sendLetter:(id)sender {
    // Read the value from the text field
	NSString *letter_message = [self.messageText text];
    
	// Create a new letter and POST it to the server
	RKLetter* letter = [RKLetter new];
    letter.mobile = @"1";
	letter.letterText = letter_message;
    letter.letterCountry = @"US";
    
    NSURL *baseURL = [NSURL URLWithString:@"http://letterstocrushes.com"];
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
        
        [self.indicator startAnimating];

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
        
        real_url = @"http://letterstocrushes.com/home/mail";
        
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

                
                // clear send screen
                [self.messageText setText:@""];
                
                // add add RODSentLetter object to the settings object
                // We keep track of these o                                                                                                                                                                                                             bjects so we know which letters
                // to show the hide/edit buttons on, really this should be
                // done on the server....
                
                RODSentLetter *sent_letter = [[RODSentLetter alloc] init];
                sent_letter.guid = msg.guid;
                
                NSNumberFormatter *formatNumber = [[NSNumberFormatter alloc] init];
                [formatNumber setNumberStyle:NSNumberFormatterDecimalStyle];
                
                NSNumber *found_id = [formatNumber numberFromString:msg.message];
                sent_letter.letter_id = found_id;
                
                [[[[RODItemStore sharedStore] settings] sentLetters] addObject:sent_letter];
                [[RODItemStore sharedStore] saveSettings];
                
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
                
                appDelegate.navigationController.viewControllers = @[ appDelegate.lettersScrollController ];
                                
                [appDelegate.lettersScrollController clearLettersAndReset];
                [[RODItemStore sharedStore] loadLettersByPage:1 level:-1];
                
                [WCAlertView showAlertWithTitle:@"Success!" message:@"Your letter has been sent." customizationBlock:^(WCAlertView *alertView) {
                    alertView.style = WCAlertViewStyleBlackHatched;
                } completionBlock:^(NSUInteger buttonIndex, WCAlertView *alertView) {
                } cancelButtonTitle:@"Great!" otherButtonTitles:nil];
            }
            
            [self.indicator stopAnimating];
            
        } failure:^(RKObjectRequestOperation *operation, NSError *error) {
           
            [self.indicator stopAnimating];
            
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
        
        [self.indicator startAnimating];
        
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
        
        real_url = @"http://letterstocrushes.com/Home/EditLetter";
        
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

                // clear edit screen, reset to send screen
                self.labelCallToAction.text = @"Write your letter.";
                [self.sendButton setTitle:@"Send" forState:UIControlStateNormal];
                self.messageText.text = @"";
                self.isEditing = NO;
                
                // now display a webview with the letter...

                // reload the page
                AppDelegate *appDelegate = (AppDelegate *) [[UIApplication sharedApplication] delegate];
                
                [appDelegate.lettersScrollController clearLettersAndReset];
                [[RODItemStore sharedStore] loadLettersByPage:[RODItemStore sharedStore].current_page level:[RODItemStore sharedStore].current_load_level];

                appDelegate.navigationController.viewControllers = @[ appDelegate.lettersScrollController ];
                
                
                [WCAlertView showAlertWithTitle:@"Success!" message:@"Your letter was edited." customizationBlock:^(WCAlertView *alertView) {
                    alertView.style = WCAlertViewStyleBlackHatched;
                } completionBlock:^(NSUInteger buttonIndex, WCAlertView *alertView) {
                    
                } cancelButtonTitle:@"Great!" otherButtonTitles:nil];
                
                
                
            }                                                                                                                                                                                                           
            
            [self.indicator stopAnimating];
            
        } failure:^(RKObjectRequestOperation *operation, NSError *error) {
            
            
            [self.indicator stopAnimating];
            
            // this occurs when restkit can not send a post -- this could happen
            // if the user does not have internet connection at the time
            UIAlertView *alert_post_error = [[UIAlertView alloc] initWithTitle:@"iOS Post Error" message: [error description] delegate:nil cancelButtonTitle:@"Okay" otherButtonTitles: nil];
            [alert_post_error show];
        }];
        
        
    }
    
    
}
@end
