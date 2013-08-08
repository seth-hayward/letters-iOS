//
//  LetterCommentsViewController.m
//  crushes
//
//  Created by Seth Hayward on 8/6/13.
//  Copyright (c) 2013 Seth Hayward. All rights reserved.
//

#import "LetterCommentsViewController.h"
#import "RKComment.h"

@implementation LetterCommentsViewController
@synthesize letter_id, scrollView;

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
            
            
        }
        
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

@end
