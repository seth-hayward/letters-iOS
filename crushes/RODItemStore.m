//
//  RODItemStore.m
//  crushes
//
//  Created by Seth Hayward on 7/22/13.
//  Copyright (c) 2013 Seth Hayward. All rights reserved.
//

#import "AppDelegate.h"
#import "RODSentLetter.h"
#import "RODItemStore.h"
#import "RODItem.h"
#import "RKFullLetter.h"
#import "RKMessage.h"
#import "RKLogin.h"
#import "RKComment.h"
#import "RKChat.h"
#import "WCAlertView.h"

@implementation RODItemStore
@synthesize loginStatus, current_load_level, current_page, last_device_orientation, current_viewtype, current_search_terms, connected_to_chat;

- (id)init {
    self = [super init];
    if(self) {
        _allMenuItems = [[NSMutableArray alloc] init];
        _allLetters = [[NSMutableArray alloc] init];
        _allComments = [[NSMutableArray alloc] init];
        _allChats = [[NSMutableArray alloc] init];
        loginStatus = [NSNumber numberWithInt:0];
        
        NSString *path = [self settingsArchivePath];
        
        _settings = [NSKeyedUnarchiver unarchiveObjectWithFile:path];
        
        UIDevice *device = [UIDevice currentDevice];
        last_device_orientation = device.orientation;
        
        current_viewtype = ViewTypeHome;
        
        connected_to_chat = false;
        
        // If we were unable to load the object,
        // then we can assume it's a new user and
        // they are logged out.
        if(!_settings) {
            _settings = [[RODSettings alloc] init];
            _settings.loginStatus = [NSNumber numberWithInt:0];
            _settings.sentLetters = [[NSMutableArray alloc] init];
            _settings.chatName = @"anonymous lover";
        } else {
            // they have some saved settings, so let's try logging in with
            // their stuff
            
            if(([_settings.userName length] > 0) && ([_settings.password length] > 0))
            {
                [self login:_settings.userName password:_settings.password];
            } else {
                [self doLogin];                
            }
            
        }
        
    }
    
    return self;
}

- (NSArray *)allMenuItems
{
    return _allMenuItems;
}

- (NSArray *)allLetters
{
    return _allLetters;
}

- (NSArray *)allComments
{
    return _allComments;
}

- (NSArray *)allChats
{
    return _allChats;
}

- (NSArray *)webviewReferences
{
    return _webviewReferences;
}

- (RODSettings *)settings
{
    return _settings;
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
    
    for(int i = 0; i < [_allMenuItems count]; i++) {
        
        RODItem *exist = [_allMenuItems objectAtIndex:i];
        if(exist.viewType == new_Type) {
            return p;
        }
    }
    
    [_allMenuItems addObject:p];
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

-(void)clearChats
{
    [_allChats removeAllObjects];
}

- (RKComment *)addComment:(RKComment *)comment
{
    [_allComments addObject:comment];
    return comment;
}

- (void)addChat:(NSString *)chat
{
    [_allChats insertObject:chat atIndex:0];
}

+ (RODItemStore *)sharedStore {
    static RODItemStore *sharedStore = nil;
    if(!sharedStore) {
        sharedStore = [[super allocWithZone:nil] init];
    }
    
    return sharedStore;
}

- (void)updateLetterHearts:(NSNumber *)letter_id hearts:(NSNumber *)l_hearts
{

    for(int i = 0; i<[_allLetters count]; i++) {
        RKFullLetter *current_letter = [_allLetters objectAtIndex:i];
        NSNumber *current_letter_id = current_letter.Id;

        if([current_letter_id isEqualToNumber:letter_id]) {
            current_letter.letterUp = l_hearts;
            return;
        }
        
    }
    
}

- (void)updateComment:(int)comment_index comment_height:(NSString *)height
{
    RKComment *comment = [_allComments objectAtIndex:comment_index];
    comment.commenterIP = @"1";
    comment.commenterGuid = height;
}


- (void)updateLetterByIndex:(int)letter_index letter_height:(NSString *)height
{
    RKFullLetter *letter = [_allLetters objectAtIndex:letter_index];
    letter.letterTags = @"1";
    letter.letterCountry = height;
}

- (void)loadLettersByPage:(NSInteger)page level:(NSInteger)load_level terms:(NSString *)_terms
{
    NSLog(@"Load letters by page called.");
    
    current_load_level = load_level;
    current_page = page;
    
    [_allLetters removeAllObjects];
        
    // if load_level = 100, we're looking for loading the bookmarks
    // this should be refactored, but for now we'll go with this...
    // TODO
    
    NSURL *baseURL;
    baseURL = [NSURL URLWithString:@"http://letterstocrushes.com/api/get_letters"];
    
    NSString *real_url;
    
    if(load_level == 120) {
        real_url = [NSString stringWithFormat:@"http://letterstocrushes.com/api/search/%@/%d", [_terms stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding], page];
        baseURL = [NSURL URLWithString:@"http://letterstocrushes.com/api/search"];
        current_search_terms = _terms;
    }
    
    if(load_level == 100) {
        real_url = [NSString stringWithFormat:@"http://letterstocrushes.com/account/getbookmarks/%d", page];
        baseURL = [NSURL URLWithString:@"http://letterstocrushes.com/account/getbookmarks"];
    }
    
    if(load_level == 0 || load_level == -1)
    {
        real_url = [NSString stringWithFormat:@"http://letterstocrushes.com/api/get_letters/%d/%d", load_level, page];
    }
    
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
     @"letterComments": @"letterComments",
     @"fromFacebookUID": @"fromFacebookUID",
     @"toFacebookUID": @"toFacebookUID"
     }];
    
    RKResponseDescriptor *responseDescriptor = [RKResponseDescriptor responseDescriptorWithMapping:responseObjectMapping pathPattern:nil keyPath:nil statusCodes:RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful)];
    
    [objectManager addResponseDescriptor:responseDescriptor];
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:real_url]];
    
    RKObjectRequestOperation *objectRequestOperation = [[RKObjectRequestOperation alloc] initWithRequest:request responseDescriptors:@[ responseDescriptor] ];
    
    [objectRequestOperation setCompletionBlockWithSuccess:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
        
        NSLog(@"Loaded letters: %d, %d", [mappingResult count], [_allLetters count]);
        
        AppDelegate *appDelegate = (AppDelegate *) [[UIApplication sharedApplication] delegate];
        
        // now loop through the result and add all of these
        for(int i = 0; i<[mappingResult count]; i++) {
            RKFullLetter *current_letter = mappingResult.array[i];
            
            current_letter.letterMessage = [self cleanText:current_letter.letterMessage];
            
            NSString *letterHTML = [NSString stringWithFormat:@"<html> \n"
                                    "<head> \n"
                                    "<style type=\"text/css\"> \n"
                                    "body {font-family: \"%@\"; font-size: %@;}\n"
                                    "</style> \n"
                                    "</head> \n"
                                    "<body>%@</body> \n"
                                    "</html>", @"helvetica", [NSNumber numberWithInt:14], current_letter.letterMessage];
            
            current_letter.letterTags = @"0";
            current_letter.letterCountry = @"100";
            current_letter.letterMessage = letterHTML;
            
            [_allLetters addObject:current_letter];
        }
        
        // now i need to tell the letters view controller that
        // it should reload the table view
        
        // first, i clear it for the search function though...
        if(current_load_level == 120) {
            AppDelegate *appDelegate = (AppDelegate *) [[UIApplication sharedApplication] delegate];
            [appDelegate.lettersScrollController clearLettersAndReset];
        }
        
        RKFullLetter *full_letter;
        full_letter = [[[RODItemStore sharedStore] allLetters] objectAtIndex:0];
        [appDelegate.lettersScrollController.testWebView loadHTMLString:full_letter.letterMessage baseURL:nil];
        
        
    } failure: ^(RKObjectRequestOperation *operation, NSError *error) {
        NSLog(@"Error loading: %@", error);
    }];
    
    [objectRequestOperation start];

}

- (void)loadLettersByPage:(NSInteger)page level:(NSInteger)load_level
{
    [self loadLettersByPage:page level:load_level terms:nil];
}

-(void) didFinishComputation:(int)valid {
    self.loginStatus = [NSNumber numberWithInt:valid];
}

- (void)login:(NSString *)email password:(NSString *)password
{
    NSLog(@"Plz login '%@' with password '%@'", email, password);
    
	// Create a new login object and POST it to the server
	RKLogin* login = [RKLogin new];
    login.email = email;
    login.password = password;
    
    _settings.userName = email;
    _settings.password = password;
        
    NSURL *baseURL = [NSURL URLWithString:@"http://letterstocrushes.com"];
    AFHTTPClient *client = [[AFHTTPClient alloc] initWithBaseURL:baseURL];
    
    [client setDefaultHeader:@"Accept" value:RKMIMETypeJSON];
    
    RKObjectManager *objectManager = [[RKObjectManager alloc] initWithHTTPClient:client];
    
    RKObjectMapping* responseObjectMapping;
    RKResponseDescriptor* responseDescriptor;
    RKRequestDescriptor* requestDescriptor;
    
    responseObjectMapping = [RKObjectMapping mappingForClass:[RKMessage class]];
    [responseObjectMapping addAttributeMappingsFromDictionary:@{
     @"response": @"response",
     @"message": @"message",
     @"guid": @"guid"
     }];
    
    responseDescriptor = [RKResponseDescriptor responseDescriptorWithMapping:responseObjectMapping pathPattern:nil keyPath:nil statusCodes:RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful)];
    
    RKObjectMapping* letterRequestMapping = [RKObjectMapping requestMapping];
    [letterRequestMapping addAttributeMappingsFromDictionary:@{
     @"email": @"email",
     @"password" : @"password"}];
    
    requestDescriptor = [RKRequestDescriptor requestDescriptorWithMapping:letterRequestMapping objectClass:[RKLogin class] rootKeyPath:@""];
    [objectManager addRequestDescriptor:requestDescriptor];
    
    NSString *real_url = [NSString stringWithFormat:@"http://letterstocrushes.com/account/mobilelogin?a=%@&b=%@", login.email, login.password];
    
    [objectManager addResponseDescriptor:responseDescriptor];
    objectManager.requestSerializationMIMEType = RKMIMETypeJSON;
    
    AppDelegate *appDelegate = (AppDelegate *) [[UIApplication sharedApplication] delegate];
    [appDelegate.menuViewController.tableView reloadData];
    
    [objectManager postObject:nil path:real_url parameters:nil success:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
        
        // now we just need to check the response
        // there may have been an error on the server that
        // we want to check for
        
        //NSLog("Mapping result: %@", mappingResult.);
        
        RKMessage *server_says = (RKMessage *)mappingResult.array[0];
        
        if([server_says.response isEqualToNumber:[NSNumber numberWithInt:1]]) {
            // correct login
            _settings.loginStatus = [NSNumber numberWithInt:1];
            
            [[RODItemStore sharedStore] saveSettings];
            
            // remove login item
            [_allMenuItems removeLastObject];
            
            [self createItem:ViewTypeBookmarks];
            [self createItem:ViewTypeLogout];
            
            AppDelegate *appDelegate = (AppDelegate *) [[UIApplication sharedApplication] delegate];
            [appDelegate.menuViewController.tableView reloadData];
            
            [WCAlertView showAlertWithTitle:@"letters to crushes" message:@"You have logged in. Welcome back!" customizationBlock:^(WCAlertView *alertView) {
                alertView.style = WCAlertViewStyleBlackHatched;
            } completionBlock:^(NSUInteger buttonIndex, WCAlertView *alertView) {
                if(buttonIndex == 1) {
                    [self generateLoginAlert];
                }
            } cancelButtonTitle:@"ok" otherButtonTitles: nil
             ];
            
            
        } else {
            self.loginStatus = [NSNumber numberWithInt:0];
            // show the alert agian, give them another chance
            [WCAlertView showAlertWithTitle:@"letters to crushes" message:@"Invalid login, please try again." customizationBlock:^(WCAlertView *alertView) {
                alertView.style = WCAlertViewStyleBlackHatched;
            } completionBlock:^(NSUInteger buttonIndex, WCAlertView *alertView) {
                if(buttonIndex == 1) {
                    [self generateLoginAlert];
                }
            } cancelButtonTitle:@"cancel" otherButtonTitles:@"try again", nil
             ];
            
            
            
        }
        
    } failure:^(RKObjectRequestOperation *operation, NSError *error) {
        
        // this occurs when restkit can not send a post -- this could happen
        // if the user does not have internet connection at the time
        //UIAlertView *alert_post_error = [[UIAlertView alloc] initWithTitle:@"iOS Post Error" message: [error description] delegate:nil cancelButtonTitle:@"Okay" otherButtonTitles: nil];
        //[alert_post_error show];
        
        self.loginStatus = [NSNumber numberWithInt:0];
    }];
    
}

- (void) logout
{
    
    NSURL *baseURL = [NSURL URLWithString:@"http://letterstocrushes.com"];
    AFHTTPClient *client = [[AFHTTPClient alloc] initWithBaseURL:baseURL];
    
    [client setDefaultHeader:@"Accept" value:RKMIMETypeJSON];
    
    RKObjectManager *objectManager = [[RKObjectManager alloc] initWithHTTPClient:client];
    
    RKObjectMapping* responseObjectMapping;
    
    responseObjectMapping = [RKObjectMapping mappingForClass:[RKMessage class]];
    [responseObjectMapping addAttributeMappingsFromDictionary:@{
     @"response": @"response",
     @"message": @"message",
     @"guid": @"guid"
     }];
    
    RKResponseDescriptor *responseDescriptor = [RKResponseDescriptor responseDescriptorWithMapping:responseObjectMapping pathPattern:nil keyPath:nil statusCodes:RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful)];
    
    NSString *real_url = @"http://letterstocrushes.com/account/mobilelogout";
    
    [objectManager addResponseDescriptor:responseDescriptor];
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:real_url]];
    
    RKObjectRequestOperation *objectRequestOperation = [[RKObjectRequestOperation alloc] initWithRequest:request responseDescriptors:@[ responseDescriptor] ];
    
    [objectRequestOperation setCompletionBlockWithSuccess:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
        
        // display wcalert saying they logged out
        [WCAlertView showAlertWithTitle:@"bye, come back soon" message:@"You have logged out." customizationBlock:^(WCAlertView *alertView) {
            alertView.style = WCAlertViewStyleBlackHatched;
        } completionBlock:^(NSUInteger buttonIndex, WCAlertView *alertView) {
        } cancelButtonTitle:@"okay" otherButtonTitles:nil];
        
        // rebuild the menu table
        // remove Logout item and Bookmark item, add login
        [_allMenuItems removeLastObject];
        [_allMenuItems removeLastObject];
        [self createItem:ViewTypeLogin];
        
        AppDelegate *appDelegate = (AppDelegate *) [[UIApplication sharedApplication] delegate];
        [appDelegate.menuViewController.tableView reloadData];
        
        // update settings object
        _settings.loginStatus = [NSNumber numberWithInt:0];
        _settings.userName = @"";
        _settings.password = @"";
        [self saveSettings];
        
        
    } failure: ^(RKObjectRequestOperation *operation, NSError *error) {
        NSLog(@"Error voting: %@", error);
    }];
    
    [objectRequestOperation start];
    
}

- (void) setWCAlertDefaults
{

    [WCAlertView setDefaultCustomiaztonBlock:^(WCAlertView *alertView) {
        alertView.labelTextColor = [UIColor colorWithRed:0.11f green:0.08f blue:0.39f alpha:1.00f];
        alertView.labelShadowColor = [UIColor whiteColor];
        
        UIColor *topGradient = [UIColor colorWithRed:1.0f green:1.0f blue:1.0f alpha:1.0f];
        UIColor *middleGradient = [UIColor colorWithRed:0.93f green:0.94f blue:0.96f alpha:1.0f];
        UIColor *bottomGradient = [UIColor colorWithRed:0.89f green:0.89f blue:0.92f alpha:1.00f];
        alertView.gradientColors = @[topGradient,middleGradient,bottomGradient];
        
        alertView.outerFrameColor = [UIColor colorWithRed:250.0f/255.0f green:250.0f/255.0f blue:250.0f/255.0f alpha:1.0f];
        
        alertView.buttonTextColor = [UIColor colorWithRed:0.11f green:0.08f blue:0.39f alpha:1.00f];
        alertView.buttonShadowColor = [UIColor whiteColor];
        
        
    }];
    
}

- (void) doLogin
{
    //
    // show login/welcome message
    //
    
    
    [self setWCAlertDefaults];
    
    [WCAlertView showAlertWithTitle:@"letters to crushes" message:@"Would you like to browse anonymously or log in?" customizationBlock:^(WCAlertView *alertView) {
        
        // You can also set different appearance for this alert using customization block
        
        alertView.style = WCAlertViewStyleBlackHatched;
        //        alertView.alertViewStyle = UIAlertViewStyleLoginAndPasswordInput;
    } completionBlock:^(NSUInteger buttonIndex, WCAlertView *alertView) {
        if (buttonIndex == 0) {
            // they pressed cancel, setup the anon interface
            // it should already be set up
        }
        if (buttonIndex == 1) {
            // now show the login alert            
            [self generateLoginAlert];
        }
    } cancelButtonTitle:@"anon" otherButtonTitles:@"login", nil];

    
}

- (void) editLetter:(NSNumber *)letter_id
{
    // setup the send view with the edit screen

    AppDelegate *appDelegate = (AppDelegate *) [[UIApplication sharedApplication] delegate];
        
    NSURL *baseURL = [NSURL URLWithString:@"http://letterstocrushes.com"];
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
    
    NSString *real_url = [NSString stringWithFormat:@"http://letterstocrushes.com/home/getletter/%@", letter_id];
    
    [objectManager addResponseDescriptor:responseDescriptor];
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:real_url]];
    
    RKObjectRequestOperation *objectRequestOperation = [[RKObjectRequestOperation alloc] initWithRequest:request responseDescriptors:@[ responseDescriptor] ];
    
    [objectRequestOperation setCompletionBlockWithSuccess:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
        
        [appDelegate.navigationController pushViewController:appDelegate.sendViewController animated:YES];

        [RODItemStore sharedStore].current_viewtype = ViewTypeSend;
                
        RKFullLetter *letter = mappingResult.array[0];
        NSLog(@"Loaded letter: %@", letter.letterMessage);
        appDelegate.sendViewController.messageText.text = letter.letterMessage;
        
        appDelegate.sendViewController.labelCallToAction.text = @"Edit your letter.";
        [appDelegate.sendViewController.sendButton setTitle:@"Edit" forState:UIControlStateNormal];
        
        appDelegate.sendViewController.isEditing = YES;
        appDelegate.sendViewController.editingId = [NSString stringWithFormat:@"%@", letter.Id];
        
        appDelegate.sendViewController.tabBarItem.title = @"Edit";
        
        
    } failure: ^(RKObjectRequestOperation *operation, NSError *error) {
        NSLog(@"Error loading: %@", error);
    }];
    
    [objectRequestOperation start];

}

- (void) hideLetter:(NSNumber *)letter_id
{

    [WCAlertView showAlertWithTitle:@"letters to crushes" message:@"Are you sure you want to hide this letter? This cannot be undone." customizationBlock:^(WCAlertView *alertView) {
        alertView.style = WCAlertViewStyleBlackHatched;
    } completionBlock:^(NSUInteger buttonIndex, WCAlertView *alertView) {
        if (buttonIndex == 1) {
            
            // now show the login alert
            NSLog(@"Hide letter %@", letter_id);

            
            NSURL *baseURL;
            baseURL = [NSURL URLWithString:@"http://letterstocrushes.com/home/hideletter"];
            
            NSString *real_url;
            real_url = [NSString stringWithFormat:@"http://letterstocrushes.com/home/hideletter/%@", letter_id];
            
            AFHTTPClient *client = [[AFHTTPClient alloc] initWithBaseURL:baseURL];
            
            [client setDefaultHeader:@"Accept" value:RKMIMETypeJSON];
            
            RKObjectManager *objectManager = [[RKObjectManager alloc] initWithHTTPClient:client];
            
            RKObjectMapping* responseObjectMapping = [RKObjectMapping mappingForClass:[RKMessage class]];
            [responseObjectMapping addAttributeMappingsFromDictionary:@{
             @"response": @"response",
             @"message": @"message",
             @"guid": @"guid"
             }];
            
            RKResponseDescriptor *responseDescriptor = [RKResponseDescriptor responseDescriptorWithMapping:responseObjectMapping pathPattern:nil keyPath:nil statusCodes:RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful)];
            
            [objectManager addResponseDescriptor:responseDescriptor];
            NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:real_url]];
            
            RKObjectRequestOperation *objectRequestOperation = [[RKObjectRequestOperation alloc] initWithRequest:request responseDescriptors:@[ responseDescriptor] ];
            
            [objectRequestOperation setCompletionBlockWithSuccess:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
                
                RKMessage *server_says = (RKMessage *)mappingResult.array[0];
                NSLog(@"hideletter result, msg: %@, %@", server_says.response, server_says.message);
                
                // now show a wcalert with the result
                
                [WCAlertView showAlertWithTitle:@"letters to crushes" message:server_says.message customizationBlock:^(WCAlertView *alertView) {
                    alertView.style = WCAlertViewStyleBlackHatched;
                } completionBlock:^(NSUInteger buttonIndex, WCAlertView *alertView) {
                        // reload the page
                    
                    AppDelegate *appDelegate = (AppDelegate *) [[UIApplication sharedApplication] delegate];
                    [appDelegate.lettersScrollController clearLettersAndReset];
                    [[RODItemStore sharedStore] loadLettersByPage:current_page level:current_load_level];
                    
                    
                } cancelButtonTitle:@"okay" otherButtonTitles:nil];
                
            } failure: ^(RKObjectRequestOperation *operation, NSError *error) {
                NSLog(@"Error loading: %@", error);
            }];
            
            [objectRequestOperation start];

            
        }
    } cancelButtonTitle:@"cancel" otherButtonTitles:@"hide letter", nil];
    
}

- (void) generateLoginAlert
{

    [WCAlertView showAlertWithTitle:@"letters to crushes" message:@"Please enter your password." customizationBlock:^(WCAlertView *alertView) {
        
        // You can also set different appearance for this alert using customization block
        
        alertView.style = WCAlertViewStyleBlackHatched;
        alertView.alertViewStyle = UIAlertViewStyleLoginAndPasswordInput;
    } completionBlock:^(NSUInteger buttonIndex, WCAlertView *alertView) {
        
        if (buttonIndex == 1) {
            
            // keep showing a login view until they get it, or
            // press cancel
            [[RODItemStore sharedStore] login:[alertView textFieldAtIndex:0].text password:[alertView textFieldAtIndex:1].text];
            
        }
        
        if (buttonIndex == 0) {
            
            // whatever, they cancelled
            loginStatus = [NSNumber numberWithInt:0];
            [self addLoginMenuOption];
            
        }
    } cancelButtonTitle:@"cancel" otherButtonTitles:@"login", nil];
    
}

- (void)addLoginMenuOption
{
    [self createItem:ViewTypeLogin];
    
    AppDelegate *appDelegate = (AppDelegate *) [[UIApplication sharedApplication] delegate];
    [appDelegate.menuViewController.tableView reloadData];
}

- (void)goBackPage
{
    self.current_page--;
    [self loadLettersByPage:self.current_page level:self.current_load_level terms:current_search_terms];
}

- (void)goNextPage
{
    self.current_page++;
    [self loadLettersByPage:self.current_page level:self.current_load_level terms:current_search_terms];
}

- (NSString *)settingsArchivePath
{
    NSArray *documentDirectories = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    
    // get one and only docuent directory from that list
    NSString *documentDirectory = [documentDirectories objectAtIndex:0];
    
    return [documentDirectory stringByAppendingPathComponent:@"settings.archive"];
}

- (BOOL) saveSettings
{
    NSString *path = [self settingsArchivePath];
    return [NSKeyedArchiver archiveRootObject:[self settings] toFile:path];
}

- (BOOL) shouldShowHideButton:(NSNumber *)letter_id
{
    BOOL result = [self isLetterInSentLetters:letter_id];
    return result;
}

- (BOOL) shouldShowEditButton:(NSNumber *)letter_id
{
    BOOL result = [self isLetterInSentLetters:letter_id];
    return result;
}

- (BOOL) isLetterInSentLetters:(NSNumber *)input_id
{
    
    for(int i = 0; i < [self.settings.sentLetters count]; i++) {
     
        RODSentLetter *current = [self.settings.sentLetters objectAtIndex:i];
        if([current.letter_id isEqualToNumber:input_id]) {
            return YES;
        }
    }
    
    
    return NO;
}

- (NSString *) cleanText:(NSString * )incoming
{
    
    incoming = [incoming stringByReplacingOccurrencesOfString:@"shit" withString:@"s___" options:NSCaseInsensitiveSearch range:NSMakeRange(0, [incoming length])];
    incoming = [incoming stringByReplacingOccurrencesOfString:@"piss" withString:@"p___" options:NSCaseInsensitiveSearch range:NSMakeRange(0, [incoming length])];
    incoming = [incoming stringByReplacingOccurrencesOfString:@"fuck" withString:@"f___" options:NSCaseInsensitiveSearch range:NSMakeRange(0, [incoming length])];
    incoming = [incoming stringByReplacingOccurrencesOfString:@"cunt" withString:@"c___" options:NSCaseInsensitiveSearch range:NSMakeRange(0, [incoming length])];
    incoming = [incoming stringByReplacingOccurrencesOfString:@"cocksucker" withString:@"c________" options:NSCaseInsensitiveSearch range:NSMakeRange(0, [incoming length])];
    incoming = [incoming stringByReplacingOccurrencesOfString:@"motherfucker" withString:@"m___________" options:NSCaseInsensitiveSearch range:NSMakeRange(0, [incoming length])];
    incoming = [incoming stringByReplacingOccurrencesOfString:@"tits" withString:@"t___" options:NSCaseInsensitiveSearch range:NSMakeRange(0, [incoming length])];

    return incoming;
}

+ (id)allocWithZone:(NSZone *)zone {
    return [self sharedStore];
}

@end
