//
//  LetterCommentsViewController.m
//  crushes
//
//  Created by Seth Hayward on 8/6/13.
//  Copyright (c) 2013 Seth Hayward. All rights reserved.
//

#import "LetterCommentsViewController.h"
#import "RKComment.h"
#import "CommentScrollViewItem.h"
#import "RODItemStore.h"


@implementation LetterCommentsViewController
@synthesize letter_id;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        
        [self.scrollView setDelegate:self];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    
    NSURL *baseURL = [NSURL URLWithString:@"http://www.letterstocrushes.com"];
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
     }];
    
    RKResponseDescriptor *responseDescriptor = [RKResponseDescriptor responseDescriptorWithMapping:responseObjectMapping pathPattern:nil keyPath:nil statusCodes:RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful)];
    
    NSString *real_url = [NSString stringWithFormat:@"http://www.letterstocrushes.com/comment/getcomments/%d", letter_id];
    
    [objectManager addResponseDescriptor:responseDescriptor];
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:real_url]];
    
    RKObjectRequestOperation *objectRequestOperation = [[RKObjectRequestOperation alloc] initWithRequest:request responseDescriptors:@[ responseDescriptor] ];
    
    [objectRequestOperation setCompletionBlockWithSuccess:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
        
        NSLog(@"Loaded comments: %d", mappingResult.array.count);
        
        for(int i = 0; i < mappingResult.array.count; i++) {
            
            RKComment *com = mappingResult.array[i];
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

-(void)loadCommentData
{
    
    int yOffset = 0;
    
    CommentScrollViewItem *scv;
    
    for(int i = 0; i < [[[RODItemStore sharedStore] allComments] count]; i++) {
        
        RKComment *full_comment = [[[RODItemStore sharedStore] allComments] objectAtIndex:i];
        
        int comment_height = 0;
        
        if([full_comment.commenterIP isEqualToString:@"1"]) {
            comment_height = [full_comment.commenterGuid integerValue];
        } else {
            comment_height = 100;
        }
        
        scv = [[CommentScrollViewItem alloc] init];
        
        // the height of the padding around the
        // heart button and the frame of the scrollviewitem is about 40px.
        
        scv.view.frame = CGRectMake(0, yOffset, self.view.bounds.size.width, comment_height + 40);
        
        [scv.webView setDelegate:self];
        
        [scv.webView loadHTMLString:full_comment.commentMessage baseURL:nil];
        [scv.webView setTag:[full_comment.Id integerValue]];

        [scv.commenterName setText:full_comment.commenterName];

        //[scv setCurrent_comment:full_comment];
        
        yOffset = yOffset + (comment_height + 40);
        
        [self.scrollView addSubview:scv.view];
        
    }
    
    CGRect screenRect = [[UIScreen mainScreen] bounds];
    CGFloat screenHeight = screenRect.size.height;
    if(yOffset < screenHeight)
        yOffset = screenHeight;
    
    [self.scrollView setContentSize:CGSizeMake(self.view.bounds.size.width, yOffset)];
    
    
    // now try looping through and resetting everything?
    
}

@end
