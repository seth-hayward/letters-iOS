//
//  AddCommentViewController.m
//  crushes
//
//  Created by Seth Hayward on 9/15/13.
//  Copyright (c) 2013 Seth Hayward. All rights reserved.
//

#import "AddCommentViewController.h"
#import "RKComment.h"
#import "RKPostComment.h"
#import "RODItemStore.h"
#import "AppDelegate.h"
#import "WCAlertView.h"
#import <QuartzCore/QuartzCore.h>

@implementation AddCommentViewController
@synthesize textComment, textCommenterEmail, textCommenterName, letter_id;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    // PREVENT THE UNDERLAPPING THAT OCCURS WITH
    // IOS 7!!!!!
    self.edgesForExtendedLayout = UIRectEdgeNone;
    
    // Do any additional setup after loading the view from its nib.
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHideHandler:) name:UIKeyboardWillHideNotification object:nil];

    UIButton *button_back = [UIButton buttonWithType:UIButtonTypeCustom];
    [button_back setFrame:CGRectMake(0, 0, 30, 30)];
    [button_back setImage:[UIImage imageNamed:@"back-150px.png"] forState:UIControlStateNormal];
    [button_back addTarget:self action:@selector(popControllerAndGoBack:) forControlEvents:UIControlEventTouchUpInside];
    
    UIBarButtonItem *btnGoBack = [[UIBarButtonItem alloc] initWithCustomView:button_back];
    
    [self.navigationItem setLeftBarButtonItem:btnGoBack animated:YES];

    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    [button setFrame:CGRectMake(0, 0, 30, 30)];
    [button setImage:[UIImage imageNamed:@"add-comment.png"] forState:UIControlStateNormal];
    [button addTarget:self action:@selector(addCommentPlease:) forControlEvents:UIControlEventTouchUpInside];
    
    UIBarButtonItem *btnAddComment = [[UIBarButtonItem alloc] initWithCustomView:button];
    
    [self.navigationItem setRightBarButtonItem:btnAddComment animated:YES];
    
    [[self navigationItem] setTitle:@"add comment"];
    
    [[self.textComment layer] setBorderColor:[[UIColor blackColor] CGColor]];
    [[self.textComment layer] setBorderWidth:1.0f];
    [[self.textComment layer] setCornerRadius:1.0f];

    [[self.textCommenterName layer] setBorderColor:[[UIColor blackColor] CGColor]];
    [[self.textCommenterName layer] setBorderWidth:1.0f];
    [[self.textCommenterName layer] setCornerRadius:1.0f];
    
    [[self.textCommenterEmail layer] setBorderColor:[[UIColor blackColor] CGColor]];
    [[self.textCommenterEmail layer] setBorderWidth:1.0f];
    [[self.textCommenterEmail layer] setCornerRadius:1.0f];
        
}

- (void) keyboardWillHideHandler: (NSNotification *)notification {

    [self resignResponders];
}

- (void) resignResponders
{
    
    [self.textCommenterName resignFirstResponder];
    [self.textComment resignFirstResponder];
    [self.textCommenterEmail resignFirstResponder];
    
}

- (void)textViewDidEndEditing:(UITextView *)textView
{
    [textView resignFirstResponder];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
        
    if([text isEqualToString:@"\n"] && [textView tag] != 142) {
        [textView resignFirstResponder];
        return NO;
    }
    
    return YES;
}

- (IBAction)btnAddComment:(id)sender {

    // Create a new comment and POST it to the server
	RKPostComment* comment = [RKPostComment new];
    comment.letterId = [NSNumber numberWithInt:letter_id];
    comment.comment = [textComment text];
    comment.commenterEmail = [textCommenterEmail text];
    comment.commenterName = [textCommenterName text];
    
    NSURL *baseURL = [NSURL URLWithString:@"http://letterstocrushes.com"];
    AFHTTPClient *client = [[AFHTTPClient alloc] initWithBaseURL:baseURL];
    
    [client setDefaultHeader:@"Accept" value:RKMIMETypeJSON];
    
    RKObjectManager *objectManager = [[RKObjectManager alloc] initWithHTTPClient:client];
    
    RKObjectMapping* responseObjectMapping;
    RKResponseDescriptor* responseDescriptor;
    RKRequestDescriptor* requestDescriptor;
    NSString *real_url;
    
    //
    // send comment
    //
    
    responseObjectMapping = [RKObjectMapping mappingForClass:[RKComment class]];
    
    [responseObjectMapping addAttributeMappingsFromDictionary:@{
     @"Id": @"Id",
     @"commentMessage": @"commentMessage",
     @"letterId": @"letterId",
     @"sendEmail": @"sendEmail",
     @"commentDate": @"commentDate",
     @"hearts": @"hearts",
     @"commenterEmail": @"commenterEmail",
     @"commenterGuid": @"commenterGuid",
     @"commenterIP": @"commenterIP",
     @"commenterName": @"commenterName"
     }];
    
    responseDescriptor = [RKResponseDescriptor responseDescriptorWithMapping:responseObjectMapping pathPattern:nil keyPath:nil statusCodes:RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful)];
    
    RKObjectMapping* letterRequestMapping = [RKObjectMapping requestMapping];
    [letterRequestMapping addAttributeMappingsFromDictionary:@{
     @"letterId": @"letterId",
     @"comment" : @"comment",
     @"commenterName" : @"commenterName",
     @"commenterEmail" : @"commenterEmail"}];
    
    requestDescriptor = [RKRequestDescriptor requestDescriptorWithMapping:letterRequestMapping objectClass:[RKPostComment class] rootKeyPath:@""];
    [objectManager addRequestDescriptor:requestDescriptor];
    
    real_url = @"http://letterstocrushes.com/api/add_comment";
    
    [objectManager addResponseDescriptor:responseDescriptor];
    objectManager.requestSerializationMIMEType = RKMIMETypeJSON;
    
    [objectManager postObject:comment path:real_url parameters:nil success:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
        
        // now we just need to check the response
        // there may have been an error on the server that
        // we want to check for
        RKComment* msg = mappingResult.array[0];
        
        // save the cId for future references
        // we use this id to know if we can hide the comment or not
        [RODItemStore sharedStore].settings.cId = msg.commenterGuid;
        [[RODItemStore sharedStore] saveSettings];
        
        // we good
        // .. now reload this screen somehow
        
        [[RODItemStore sharedStore] clearComments];
        
        // now tell the web view to change the page
        AppDelegate *appDelegate = (AppDelegate *) [[UIApplication sharedApplication] delegate];
        
        appDelegate.addCommentViewController = [[AddCommentViewController alloc] init];
        appDelegate.addCommentViewController.letter_id = letter_id;
        
        [appDelegate.navigationController popViewControllerAnimated:YES];
        
        [WCAlertView showAlertWithTitle:@"Success!" message:@"Your comment was sent." customizationBlock:^(WCAlertView *alertView) {
            alertView.style = WCAlertViewStyleBlackHatched;
        } completionBlock:^(NSUInteger buttonIndex, WCAlertView *alertView) {
        } cancelButtonTitle:@"Great!" otherButtonTitles:nil];
        
    } failure:^(RKObjectRequestOperation *operation, NSError *error) {
        
        // this occurs when restkit can not send a post -- this could happen
        // if the user does not have internet connection at the time
        UIAlertView *alert_post_error = [[UIAlertView alloc] initWithTitle:@"iOS Post Error" message: [error description] delegate:nil cancelButtonTitle:@"Okay" otherButtonTitles: nil];
        [alert_post_error show];
    }];

    
}

- (IBAction)tapGesture:(id)sender {
    NSLog(@"tapGesture fired.");
    [self resignResponders];
}

-(void)popControllerAndGoBack:(UIBarButtonItem *)button
{
    AppDelegate *appDelegate = (AppDelegate *) [[UIApplication sharedApplication] delegate];
    [appDelegate.navigationController popViewControllerAnimated:YES];
}

@end
