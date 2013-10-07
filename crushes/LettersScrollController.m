//
//  LettersScrollController.m
//  crushes
//
//  Created by Seth Hayward on 7/24/13.
//  Copyright (c) 2013 Seth Hayward. All rights reserved.
//

#import "LettersScrollController.h"
#import "LetterCommentsViewController.h"
#import "RODItemStore.h"
#import "RKFullLetter.h"
#import "ScrollViewItem.h"
#import "AppDelegate.h"
#import "PagerViewController.h"
#import "J1Button.h"
#import "NavigationController.h"

@implementation LettersScrollController
@synthesize current_receive, loaded, letter_index;

- (id)init
{
    self = [super init];
    if(self) {
        
        [[self navigationItem] setTitle:@"letters to crushes"];

        [[RODItemStore sharedStore] loadLettersByPage:1 level:0];
 
        [self.indicator startAnimating];
        
        [self.scrollView setDelegate:self];
        
        self.letter_index = 0;
        
        _items = [[NSMutableArray alloc] init];
        
        current_receive = 0;
        loaded = false;
        
    }
    return self;
}

- (void)viewDidAppear:(BOOL)animated
{
    [self.testWebView setDelegate:self];
    
    [self redrawNavigationTitle];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    UIBarButtonItem *button_refresh = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh target:self action:@selector(refreshOriginalPage)];
    [button_refresh setBackgroundImage:[UIImage new] forState:UIControlStateNormal barMetrics:UIBarMetricsDefault];
    [[self navigationItem] setRightBarButtonItem:button_refresh];
        
    UIButton *button_menu = [UIButton buttonWithType:UIButtonTypeCustom];
    [button_menu setFrame:CGRectMake(0, 0, 30, 30)];
    [button_menu setImage:[UIImage imageNamed:@"hamburger-150px.png"] forState:UIControlStateNormal];
    [button_menu addTarget:(NavigationController *)self.navigationController action:@selector(showMenu) forControlEvents:UIControlEventTouchUpInside];
    
    UIBarButtonItem *leftDrawerButton = [[UIBarButtonItem alloc] initWithCustomView:button_menu];
    [self.navigationItem setLeftBarButtonItem:leftDrawerButton animated:YES];

}

- (void) redrawNavigationTitle
{
 
    switch ([RODItemStore sharedStore].current_load_level) {
        case 100:
            [[self navigationItem] setTitle:[NSString stringWithFormat:@"your bookmarks, page %d", [RODItemStore sharedStore].current_page]];
            break;            
        case -1:
            [[self navigationItem] setTitle:[NSString stringWithFormat:@"more letters, page %d", [RODItemStore sharedStore].current_page]];
            break;
        case 0:
            if([RODItemStore sharedStore].current_page == 1) {
                [[self navigationItem] setTitle:@"letters to crushes"];
            } else {
                [[self navigationItem] setTitle:[NSString stringWithFormat:@"home, page %d", [RODItemStore sharedStore].current_page]];
            }
            break;
        case 120:
            [[self navigationItem] setTitle:[NSString stringWithFormat:@"searching '%@'", [RODItemStore sharedStore].current_search_terms]];
            break;
    }
        
}

-(void)loadLetterData
{
    
    [self redrawNavigationTitle];
    
    [_items removeAllObjects];
    
    NSLog(@"loadLetterData called.");
    
    int yOffset = 0;
    int letter_view_height = 0;
    
    ScrollViewItem *scv;
    
    for(int i = 0; i < [[[RODItemStore sharedStore] allLetters] count]; i++) {
        
        RKFullLetter *full_letter = [[[RODItemStore sharedStore] allLetters] objectAtIndex:i];
        
        int letter_height = 0;
        
        if([full_letter.letterTags isEqualToString:@"1"]) {
            letter_height = [full_letter.letterCountry integerValue];
        } else {
            letter_height = 100;
        }
        
        letter_view_height = letter_height + 90;
        
        scv = [[ScrollViewItem alloc] init];
        
        scv.current_index = i;
        // the height of the padding around the
        // heart button and the frame of the scrollviewitem is about 40px.
        
        
        scv.view.frame = CGRectMake(0, yOffset, self.view.bounds.size.width - 5, letter_view_height);
        
        //[scv.webView setDelegate:self];
        
        [scv.webView loadHTMLString:full_letter.letterMessage baseURL:nil];
        
        [scv.labelComments setUserInteractionEnabled:true];
        
        
        if(full_letter.letterComments == [NSNumber numberWithInt:0]) {
            UITapGestureRecognizer *tapComments = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(clickedAddComment:)];
            [scv.labelComments addGestureRecognizer:tapComments];            
        } else {
            UITapGestureRecognizer *tapComments = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(clickedComments:)];
            [scv.labelComments addGestureRecognizer:tapComments];
        }
        
        [scv.labelHearts setUserInteractionEnabled:true];
        
        UITapGestureRecognizer *tapHearts = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(clickedHeart:)];
        [scv.labelHearts addGestureRecognizer:tapHearts];
        
        [scv.btnHearts addTarget:self action:@selector(btnHeartClicked:) forControlEvents:UIControlEventTouchUpInside];
        
        [scv.labelEdit setUserInteractionEnabled:true];
        UITapGestureRecognizer *tapEdit = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(clickedEdit:)];
        [scv.labelEdit addGestureRecognizer:tapEdit];

        [scv.labelHide setUserInteractionEnabled:true];
        UITapGestureRecognizer *tapHide = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(clickedHide:)];
        [scv.labelHide addGestureRecognizer:tapHide];

        [scv.labelEdit setTag:([full_letter.Id integerValue] + 100000)];
        [scv.labelHide setTag:([full_letter.Id integerValue] + 200000)];
                
        [scv.labelComments setTag:([full_letter.Id integerValue] * 100)];
        [scv.labelHearts setTag:([full_letter.Id integerValue] * 1000)];
        
        [scv.btnHearts setTag:([full_letter.Id integerValue] + 300000)];
                
        [scv.view setTag:([full_letter.Id integerValue] * 10000)];
        
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];

        [formatter setTimeStyle:NSDateFormatterShortStyle];
        [formatter setDateStyle:NSDateFormatterMediumStyle];
                
        if([[RODItemStore sharedStore] current_load_level] == -1) {
            // more page
            [formatter setDateStyle:NSDateFormatterMediumStyle];
            [formatter setTimeStyle:NSDateFormatterShortStyle];
        }
        
        if([[RODItemStore sharedStore] current_load_level] == 0) {
            // home page
            [formatter setDateStyle:NSDateFormatterLongStyle];
            [formatter setTimeStyle:NSDateFormatterNoStyle];
        }
        
        [scv.labelDate setText:[formatter stringFromDate:[self getDateFromJSON:full_letter.letterPostDate]]];
        
        [scv.webView.scrollView setScrollEnabled:false];
        
        // OMG JUST PUT A FUCKING UNDERLINE IN THE LABEL JESUS
        
        NSMutableAttributedString *attributeStringHearts;
        
        if([full_letter.letterUp isEqualToNumber:[NSNumber numberWithInt:1]]) {
            attributeStringHearts = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@ hearts", [full_letter.letterUp stringValue]]];
        } else {
            attributeStringHearts = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@ hearts", [full_letter.letterUp stringValue]]];
        }
        
        NSMutableAttributedString *attributeStringComments;
        
        if([full_letter.letterComments isEqualToNumber:[NSNumber numberWithInt:1]]) {
            attributeStringComments = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@ comment", [full_letter.letterComments stringValue]]];
        } else {
            attributeStringComments = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@ comments", [full_letter.letterComments stringValue]]];
        }
        
        if([full_letter.letterComments isEqualToNumber:[NSNumber numberWithInt:0]]) {
            attributeStringComments = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"add comment"]];
        }
        
        NSMutableAttributedString *attributeStringEdit = [[NSMutableAttributedString alloc] initWithString:@"edit"];
        
        NSMutableAttributedString *attributeStringHide = [[NSMutableAttributedString alloc] initWithString:@"hide"];
        
        [attributeStringHearts addAttribute:NSUnderlineStyleAttributeName value:[NSNumber numberWithInt:1] range:(NSRange){0,[attributeStringHearts length]}];
        [attributeStringComments addAttribute:NSUnderlineStyleAttributeName value:[NSNumber numberWithInt:1] range:(NSRange){0,[attributeStringComments length]}];

        [attributeStringEdit addAttribute:NSUnderlineStyleAttributeName value:[NSNumber numberWithInt:1] range:(NSRange){0,[attributeStringEdit length]}];
        [attributeStringHide addAttribute:NSUnderlineStyleAttributeName value:[NSNumber numberWithInt:1] range:(NSRange){0,[attributeStringHide length]}];
        
        UIFont *normalFont = [UIFont systemFontOfSize:13];
        
        NSDictionary *attrs = [NSDictionary dictionaryWithObjectsAndKeys: normalFont, NSFontAttributeName,
                               [UIColor colorWithRed:0/255.0
                                               green:51/255.0
                                                blue:255/255.0
                                               alpha:1.0], NSForegroundColorAttributeName, nil];
        
        [attributeStringHearts addAttributes:attrs range:(NSRange){0, [attributeStringHearts length]}];
        [attributeStringComments addAttributes:attrs range:(NSRange){0, [attributeStringComments length]}];
        [attributeStringEdit addAttributes:attrs range:(NSRange){0, [attributeStringEdit length]}];
        [attributeStringHide addAttributes:attrs range:(NSRange){0, [attributeStringHide length]}];
        
        [scv.labelHearts setAttributedText:attributeStringHearts];
        [scv.labelComments setAttributedText:attributeStringComments];
        [scv.labelEdit setAttributedText:attributeStringEdit];
        [scv.labelHide setAttributedText:attributeStringHide];
        
        // JESUS CHRIST
        
        //if([full_letter.letterComments isEqualToNumber:[NSNumber numberWithInt:0]]) {
        //    [scv.labelComments  setHidden:true];
        //}
        
        [scv setCurrent_letter:full_letter];
        
        if([[RODItemStore sharedStore] shouldShowEditButton:full_letter.Id] == NO)
        {
            [scv.labelEdit setHidden:YES];
        }
        
        if ([[RODItemStore sharedStore] shouldShowHideButton:full_letter.Id] == NO) {
            [scv.labelHide setHidden:YES];
        }
        
        yOffset = yOffset + letter_view_height;
                
        [self.scrollView addSubview:scv.view];
        
        [_items addObject:scv];
    }
    
    // now add the pager control
    PagerViewController *pager = [[PagerViewController alloc] init];
    pager.view.frame = CGRectMake(0, yOffset, self.view.bounds.size.width, pager.view.frame.size.height);
    
    if([[RODItemStore sharedStore] current_page] > 1) {
        [pager.buttonBack setHidden:false];
        [pager.buttonBack addTarget:self action:@selector(backButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
        
    } else {
        [pager.buttonBack setHidden:true];
    }
    
    [pager.buttonNext addTarget:self action:@selector(nextButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    
    pager.view.tag = 7;
    
    if([[[RODItemStore sharedStore] allLetters] count] > 9) {
        // got rejected for this!
        // hide the buttons if there are no letters
        
        [self.scrollView addSubview:pager.view];
        yOffset = yOffset + pager.view.frame.size.height;
        
    }
    
    [self.scrollView setContentSize:CGSizeMake(self.view.bounds.size.width, yOffset)];
        
    if([[RODItemStore sharedStore] current_load_level] == 120) {
        AppDelegate *appDelegate = (AppDelegate *) [[UIApplication sharedApplication] delegate];
        [appDelegate.navigationController popViewControllerAnimated:true];
    }
    
    // now try looping through and resetting everything?
    
}

- (void)clickedComments:(UITapGestureRecognizer *)tapGesture
{
    
    int letter_id = [tapGesture.view tag] / 100;
    
    LetterCommentsViewController *comments = [[LetterCommentsViewController alloc] init];
    comments.letter_id = letter_id;
    
    // now tell the web view to change the page
    AppDelegate *appDelegate = (AppDelegate *) [[UIApplication sharedApplication] delegate];
    [appDelegate.navigationController pushViewController:comments animated:true];
    
}

- (void)clickedAddComment:(UITapGestureRecognizer *)tapGesture
{
    
    int letter_id = [tapGesture.view tag] / 100;
    
    // now tell the web view to change the page
    AppDelegate *appDelegate = (AppDelegate *) [[UIApplication sharedApplication] delegate];
    appDelegate.addCommentViewController.letter_id = letter_id;
    [appDelegate.navigationController pushViewController:appDelegate.addCommentViewController animated:true];
    
}

-(void)clickedEdit:(UITapGestureRecognizer *)tapGesture
{
    NSNumber *letter_id = [NSNumber numberWithInt:[tapGesture.view tag] - 100000];
    [[RODItemStore sharedStore] editLetter:letter_id];
    
}

-(void)clickedHide:(UITapGestureRecognizer *)tapGesture
{
    NSNumber *letter_id = [NSNumber numberWithInt:[tapGesture.view tag] - 200000];
    [[RODItemStore sharedStore] hideLetter:letter_id];
}

-(void)clickedHeart:(UITapGestureRecognizer *)tapGesture;
{
    
    NSInteger tag_int = [tapGesture.view tag];
    
    int letter_id = tag_int / 1000;
        
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
    
    NSString *real_url = [NSString stringWithFormat:@"http://letterstocrushes.com/home/vote/%d", letter_id];
    
    [objectManager addResponseDescriptor:responseDescriptor];
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:real_url]];
    
    RKObjectRequestOperation *objectRequestOperation = [[RKObjectRequestOperation alloc] initWithRequest:request responseDescriptors:@[ responseDescriptor] ];

    // run update interface code before calling web service    
    for(int z = 0; z < [_items count]; z++) {
        ScrollViewItem *lil_b = [_items objectAtIndex:z];
        
        if([lil_b.current_letter.Id isEqualToNumber:[NSNumber numberWithInt:letter_id]]) {
            
            NSMutableAttributedString *attributeStringHearts = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"%d hearts", [lil_b.current_letter.letterUp integerValue] + 1]];
            
            [attributeStringHearts addAttribute:NSUnderlineStyleAttributeName value:[NSNumber numberWithInt:1] range:(NSRange){0,[attributeStringHearts length]}];
            
            UIFont *normalFont = [UIFont systemFontOfSize:13];
            
            NSDictionary *attrs = [NSDictionary dictionaryWithObjectsAndKeys: normalFont, NSFontAttributeName,
                                   [UIColor colorWithRed:0/255.0
                                                   green:51/255.0
                                                    blue:255/255.0
                                                   alpha:1.0], NSForegroundColorAttributeName, nil];
            
            [attributeStringHearts addAttributes:attrs range:(NSRange){0, [attributeStringHearts length]}];
            [lil_b.labelHearts setAttributedText:attributeStringHearts];
            
            break;
        }
    }
    
    [objectRequestOperation setCompletionBlockWithSuccess:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {

        RKFullLetter *letter = mappingResult.array[0];
        NSLog(@"Voted on letter %d, hearts: %@", letter_id, letter.letterUp);

        [[RODItemStore sharedStore] updateLetterHearts:[NSNumber numberWithInt:letter_id] hearts:letter.letterUp];
        
        
    } failure: ^(RKObjectRequestOperation *operation, NSError *error) {
        NSLog(@"Error voting: %@", error);
    }];
    
    [objectRequestOperation start];

}

//- (void)openDrawer:(id)sender {
//    
//    // now tell the web view to change the page
//    AppDelegate *appDelegate = (AppDelegate *) [[UIApplication sharedApplication] delegate];
//    [appDelegate.drawer toggleDrawerSide:MMDrawerSideLeft animated:YES completion:nil];
//    
//}

-(void)refreshOriginalPage
{
    NSLog(@"refreshOriginalPage");
    [self clearLettersAndReset];
    [self loadLetterData];
}

-(void)webViewDidFinishLoad:(UIWebView *)a_webView {
    
    NSString *height = [a_webView stringByEvaluatingJavaScriptFromString:@"document.body.scrollHeight"];
    [[RODItemStore sharedStore] updateLetterByIndex:self.letter_index letter_height:height];
    
    if(self.letter_index == [[[RODItemStore sharedStore] allLetters] count] - 1) {
        self.loaded = true;
        [self loadLetterData];
        return;
    }
    
    self.letter_index++;
    
    RKFullLetter *full_letter;
    full_letter = [[[RODItemStore sharedStore] allLetters] objectAtIndex:self.letter_index];
    [self.testWebView loadHTMLString:full_letter.letterMessage baseURL:nil];
        
}

- (void)nextButtonClicked:(UIButton *)button
{
    [self clearLettersAndReset];
    [[RODItemStore sharedStore] goNextPage];
}

-(void)backButtonClicked:(UIButton *)button
{
    if([[RODItemStore sharedStore] current_page] > 1) {
        [self clearLettersAndReset];
        [[RODItemStore sharedStore] goBackPage];
    }
}

-(void)clearLettersAndReset
{
    
    for (UIView *subview in self.scrollView.subviews) {
        if([subview tag] > 0) {
            [subview performSelector:@selector(removeFromSuperview)];
        }
    }
    
    self.scrollView.contentSize = CGSizeMake(0,0);
    
    [self.scrollView setNeedsDisplay];
    
    [self.indicator startAnimating];
    
    self.loaded = false;
    self.letter_index = 0;
}

- (NSDate*) getDateFromJSON:(NSString *)dateString
{
    // Expect date in this format "/Date(1268123281843)/"
    int startPos = [dateString rangeOfString:@"("].location+1;
    int endPos = [dateString rangeOfString:@")"].location;
    NSRange range = NSMakeRange(startPos,endPos-startPos);
    unsigned long long milliseconds = [[dateString substringWithRange:range] longLongValue];
    NSTimeInterval interval = milliseconds/1000;
        
    // convert to the local time
    int offset = [NSTimeZone systemTimeZone].secondsFromGMT;
    
    NSDate *resulting_date = [NSDate dateWithTimeIntervalSince1970:interval];
    resulting_date = [resulting_date dateByAddingTimeInterval:offset];
    
    return resulting_date;
}


@end