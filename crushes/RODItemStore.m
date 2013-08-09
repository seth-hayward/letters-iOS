//
//  RODItemStore.m
//  crushes
//
//  Created by Seth Hayward on 7/22/13.
//  Copyright (c) 2013 Seth Hayward. All rights reserved.
//

#import "AppDelegate.h"
#import "RODItemStore.h"
#import "RODItem.h"
#import "RKFullLetter.h"
#import "RKComment.h"

@implementation RODItemStore

- (id)init {
    self = [super init];
    if(self) {
        allMenuItems = [[NSMutableArray alloc] init];
        _allLetters = [[NSMutableArray alloc] init];
        _allComments = [[NSMutableArray alloc] init];
    }
    
    return self;
}

- (NSArray *)allMenuItems
{
    return allMenuItems;
}

- (NSArray *)allLetters
{
    return _allLetters;
}

- (NSArray *)allComments
{
    return _allComments;
}

- (NSArray *)webviewReferences
{
    return _webviewReferences;
}

- (void)addReference:(UIWebView *)watch_this
{    
    [_webviewReferences addObject:watch_this];
}

- (void)removeReferences
{
    [_webviewReferences removeAllObjects];    
}

- (RODItem *)createItem:(ViewType) new_Type
{
    RODItem *p = [[RODItem alloc] initWithType:new_Type];
    [allMenuItems addObject:p];
    
    return p;
}


- (RKFullLetter *)addLetter:(RKFullLetter *)letter
{
    [_allLetters addObject:letter];
    return letter;
}

-(void)clearComments
{
    [_allComments removeAllObjects];
}

- (RKComment *)addComment:(RKComment *)comment
{
    [_allComments addObject:comment];
    return comment;
}

+ (RODItemStore *)sharedStore {
    static RODItemStore *sharedStore = nil;
    if(!sharedStore) {
        sharedStore = [[super allocWithZone:nil] init];
    }
    
    return sharedStore;
}

- (void)updateLetter:(NSNumber *)letter_id letter_height:(NSString *)height
{

    for(int i = 0; i<[_allLetters count]; i++) {
        RKFullLetter *current_letter = [_allLetters objectAtIndex:i];
        NSNumber *current_letter_id = current_letter.Id;

        if([current_letter_id isEqualToNumber:letter_id]) {
            current_letter.letterTags = @"1";
            current_letter.letterCountry = height;
        }
        
    }
    
}

- (void)loadLettersByPage:(NSInteger)page level:(NSInteger)load_level
{
    
    [_allLetters removeAllObjects];
    
    NSURL *baseURL = [NSURL URLWithString:@"http://www.letterstocrushes.com/api/get_letters"];
    AFHTTPClient *client = [[AFHTTPClient alloc] initWithBaseURL:baseURL];
    
    [client setDefaultHeader:@"Accept" value:RKMIMETypeJSON];
    
    RKObjectManager *objectManager = [[RKObjectManager alloc] initWithHTTPClient:client];
        
    RKObjectMapping* responseObjectMapping = [RKObjectMapping mappingForClass:[RKFullLetter class]];
    [responseObjectMapping addAttributeMappingsFromDictionary:@{
     @"Id": @"Id",
     @"letterMessage": @"letterMessage",
     @"letterTags": @"letterTags",
     @"letterPostDate": @"letterPostDate",
     @"letterUp": @"letterUp",
     @"letterLevel": @"letterLevel",
     @"letterLanguage": @"letterLanguage",
     @"senderIP": @"senderIP",
     @"senderCountry": @"senderCountry",
     @"senderRegion": @"senderRegion",
     @"senderCity": @"senderCity",
     @"letterComments": @"letterComments"
     }];
    
    RKResponseDescriptor *responseDescriptor = [RKResponseDescriptor responseDescriptorWithMapping:responseObjectMapping pathPattern:nil keyPath:nil statusCodes:RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful)];
    
    NSString *real_url = [NSString stringWithFormat:@"http://www.letterstocrushes.com/api/get_letters/%d/%d", load_level, page];
    
    [objectManager addResponseDescriptor:responseDescriptor];
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:real_url]];
    
    RKObjectRequestOperation *objectRequestOperation = [[RKObjectRequestOperation alloc] initWithRequest:request responseDescriptors:@[ responseDescriptor] ];
    
    [objectRequestOperation setCompletionBlockWithSuccess:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
        
        NSLog(@"Loaded letters: %d, %d", [mappingResult count], [_allLetters count]);

        AppDelegate *appDelegate = (AppDelegate *) [[UIApplication sharedApplication] delegate];
        
        // now loop through the result and add all of these
        for(int i = 0; i<[mappingResult count]; i++) {
            RKFullLetter *current_letter = mappingResult.array[i];
            
            
            NSString *hidden_id = [NSString stringWithFormat:@"<div id='letter_id' style='display: none'>%@</div>", current_letter.Id];
            
            NSString *letterHTML = [NSString stringWithFormat:@"<html> \n"
                                           "<head> \n"
                                           "<style type=\"text/css\"> \n"
                                           "body {font-family: \"%@\"; font-size: %@;}\n"
                                           "</style> \n"
                                           "</head> \n"
                                           "<body>%@%@</body> \n"
                                           "</html>", @"helvetica", [NSNumber numberWithInt:14], hidden_id, current_letter.letterMessage];
            
            current_letter.letterTags = @"0";            
            current_letter.letterCountry = @"100";
            current_letter.letterMessage = letterHTML;
            
            [_allLetters addObject:current_letter];
        }
        
        // now i need to tell the letters view controller that
        // it should reload the table view
        
        //[appDelegate.tabBar setSelectedIndex:1];
        
        //[appDelegate.lettersViewController.tableView reloadData];
        [appDelegate.lettersScrollController loadLetterData];
        
        
    } failure: ^(RKObjectRequestOperation *operation, NSError *error) {
        NSLog(@"Error loading: %@", error);
    }];
    
    [objectRequestOperation start];
    
}


+ (id)allocWithZone:(NSZone *)zone {
    return [self sharedStore];
}

@end
