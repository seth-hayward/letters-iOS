//
//  LetterCommentsViewController.m
//  crushes
//
//  Created by Seth Hayward on 8/6/13.
//  Copyright (c) 2013 Seth Hayward. All rights reserved.
//

#import "LetterCommentsViewController.h"
#import "RKComment.h"
#import "RKPostComment.h"
#import "CommentScrollViewItem.h"
#import "RODItemStore.h"
#import "AddCommentViewController.h"
#import "WCAlertView.h"
#import "AppDelegate.h"

@implementation LetterCommentsViewController
@synthesize letter_id, scrollView, page_number;

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
    // Do any additional setup after loading the view from its nib.
    
    [self setEdgesForExtendedLayout:UIRectEdgeNone];

    [[self navigationItem] setTitle:@"comments"];
    
    [self pullCommentData];
    [self setPage_number:1];

}

-(void)pullCommentData
{

    // clear previous comments
    [[RODItemStore sharedStore] clearComments];
    
    // scroll to top
    [self.scrollView setContentOffset:CGPointZero animated:YES];
    
    self.comment_index = 0;
    
    self.testWebView.delegate = self;
    
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    [button setFrame:CGRectMake(0, 0, 30, 30)];
    [button setImage:[UIImage imageNamed:@"add-comment.png"] forState:UIControlStateNormal];
    [button addTarget:self action:@selector(addCommentPlease:) forControlEvents:UIControlEventTouchUpInside];
    
    btnAddComment = [[UIBarButtonItem alloc] initWithCustomView:button];
    
    [self.navigationItem setRightBarButtonItem:btnAddComment animated:YES];

    UIButton *button_back = [UIButton buttonWithType:UIButtonTypeCustom];
    [button_back setFrame:CGRectMake(0, 0, 30, 30)];
    [button_back setImage:[UIImage imageNamed:@"back-150px.png"] forState:UIControlStateNormal];
    [button_back addTarget:self action:@selector(popControllerAndGoBack:) forControlEvents:UIControlEventTouchUpInside];
    
    UIBarButtonItem *btnGoBack = [[UIBarButtonItem alloc] initWithCustomView:button_back];
    
    [self.navigationItem setRightBarButtonItem:btnAddComment animated:YES];
    [self.navigationItem setLeftBarButtonItem:btnGoBack animated:YES];
    
    NSURL *baseURL = [NSURL URLWithString:@"http://letterstocrushes.com"];
    AFHTTPClient *client = [[AFHTTPClient alloc] initWithBaseURL:baseURL];
    
    [client setDefaultHeader:@"Accept" value:RKMIMETypeJSON];
    
    RKObjectManager *objectManager = [[RKObjectManager alloc] initWithHTTPClient:client];
    
    RKObjectMapping* responseObjectMapping = [RKObjectMapping mappingForClass:[RKComment class]];
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
    
    RKResponseDescriptor *responseDescriptor = [RKResponseDescriptor responseDescriptorWithMapping:responseObjectMapping pathPattern:nil keyPath:nil statusCodes:RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful)];
    
    
    NSString *real_url;
    
    if(self.letter_id > -10) {
        real_url = [NSString stringWithFormat:@"http://letterstocrushes.com/comment/getcomments/%d", letter_id];
    } else {
        real_url = [NSString stringWithFormat:@"http://letterstocrushes.com/api/get_comments/%d", page_number];
    }
    
    [objectManager addResponseDescriptor:responseDescriptor];
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:real_url]];
    
    RKObjectRequestOperation *objectRequestOperation = [[RKObjectRequestOperation alloc] initWithRequest:request responseDescriptors:@[ responseDescriptor] ];
    
    [objectRequestOperation setCompletionBlockWithSuccess:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
        
        NSLog(@"Loaded comments: %d", mappingResult.array.count);
                
        for(int i = 0; i < mappingResult.array.count; i++) {
            
            RKComment *com = mappingResult.array[i];
            
            com.commentMessage = [[RODItemStore sharedStore] cleanText:com.commentMessage];
            com.commenterName = [[RODItemStore sharedStore] cleanText:com.commenterName];
            
            if([com.commenterName isKindOfClass:[NSNull class]]) {
                com.commenterName = @"anonymous lover";
            }
            
            NSString *commentHTML = [NSString stringWithFormat:@"<html> \n"
                                     "<head> \n"
                                     "<style type=\"text/css\"> \n"
                                     "body {font-family: \"%@\"; font-size: %@;}\n"
                                     "</style> \n"
                                     "</head> \n"
                                     "<body>%@</body> \n"
                                     "</html>", @"helvetica", [NSNumber numberWithInt:14], com.commentMessage];
            com.commentMessage = commentHTML;
            
            [[RODItemStore sharedStore] addComment:com];
            
        }
        
        [self loadCommentData];
        
    } failure: ^(RKObjectRequestOperation *operation, NSError *error) {
        NSLog(@"Error loading comments: %@", error);
    }];
    
    [objectRequestOperation start];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)webViewDidFinishLoad:(UIWebView *)a_webView
{
            
    NSString *height = [a_webView stringByEvaluatingJavaScriptFromString:@"document.body.scrollHeight"];
    
    [[RODItemStore sharedStore] updateComment:self.comment_index comment_height:height];
    
    if(self.comment_index == [[[RODItemStore sharedStore] allComments] count] - 1) {
        [self drawComments];
        return;
    }
    
    self.comment_index++;
    
    RKComment *full_comment;
    full_comment = [[[RODItemStore sharedStore] allComments] objectAtIndex:self.comment_index];
    [self.testWebView loadHTMLString:full_comment.commentMessage baseURL:nil];
}

- (void)addCommentRequested
{
    // now tell the web view to change the page
    AppDelegate *appDelegate = (AppDelegate *) [[UIApplication sharedApplication] delegate];
    
    appDelegate.addCommentViewController.letter_id = letter_id;
    [appDelegate.navigationController pushViewController:appDelegate.addCommentViewController animated:true];
    
}

- (IBAction)addCommentPlease:(UIBarButtonItem *)button {
    [self addCommentRequested];
}

-(void)popControllerAndGoBack:(UIBarButtonItem *)button
{
    AppDelegate *appDelegate = (AppDelegate *) [[UIApplication sharedApplication] delegate];    
    [appDelegate.navigationController popViewControllerAnimated:YES];
}

-(void)loadCommentData
{
        
    if([[[RODItemStore sharedStore] allComments] count] == 0) {
        [self drawComments];
        return;
    }
    
    // do a preload to get the height
    // start the preload chain
    RKComment *full_comment;
    full_comment = [[[RODItemStore sharedStore] allComments] objectAtIndex:0];
    [self.testWebView loadHTMLString:full_comment.commentMessage baseURL:nil];
    
}

-(void)drawComments
{
    
    //[self.testWebView setHidden:true];
    int yOffset = 0;
    
    CommentScrollViewItem *scv;
    RKComment *full_comment;
    
    if([[[RODItemStore sharedStore] allComments] count] > 0) {

        for(int i = 0; i < [[[RODItemStore sharedStore] allComments] count]; i++) {
            
            full_comment = [[[RODItemStore sharedStore] allComments] objectAtIndex:i];
            
            int comment_height = 0;
            
            if([full_comment.commenterIP isEqualToString:@"1"]) {
                comment_height = [full_comment.commenterGuid integerValue];
            } else {
                comment_height = 100;
            }
            
            scv = [[CommentScrollViewItem alloc] init];
            
            // the height of the padding around the
            // heart button and the frame of the scrollviewitem is about 40px.
            
            scv.view.frame = CGRectMake(0, yOffset, self.view.bounds.size.width - 5, comment_height + 65);
            
            //        [scv.webView setDelegate:self];
            //        [scv.webView setDelegate:scv.view];
            
            [scv.webView loadHTMLString:full_comment.commentMessage baseURL:nil];
            [scv.webView setTag:[full_comment.Id integerValue]];
            
            [scv.labelCommenterName setText:full_comment.commenterName];
            
            [scv setCurrent_comment:full_comment];
            
            yOffset = yOffset + (comment_height + 65);
            
            [self.scrollView addSubview:scv.view];
            
        }

        
    }
    
    CGRect screenRect = [[UIScreen mainScreen] bounds];
    CGFloat screenHeight = screenRect.size.height;
    if(yOffset < screenHeight)
        yOffset = screenHeight;
    
    [self.scrollView setContentSize:CGSizeMake(self.view.bounds.size.width, yOffset)];
    
    
    // now try looping through and resetting everything?
    
    
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    if([[[RODItemStore sharedStore] allComments] count] == 0)
    {
        [self pullCommentData];
    }
}

@end
