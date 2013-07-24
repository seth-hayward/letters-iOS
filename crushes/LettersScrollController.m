//
//  LettersScrollController.m
//  crushes
//
//  Created by Seth Hayward on 7/24/13.
//  Copyright (c) 2013 Seth Hayward. All rights reserved.
//

#import "LettersScrollController.h"
#import "MMDrawerBarButtonItem.h"
#import "RODItemStore.h"
#import "RKFullLetter.h"
#import "ScrollViewItem.h"
#import "AppDelegate.h"

@implementation LettersScrollController
@synthesize current_receive;

- (id)init
{
    self = [super init];
    if(self) {
        
        UIBarButtonItem *button_refresh = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh target:self action:@selector(refreshOriginalPage)];
        [[self navigationItem] setRightBarButtonItem:button_refresh];
        
        MMDrawerBarButtonItem * leftDrawerButton = [[MMDrawerBarButtonItem alloc] initWithTarget:self action:@selector(openDrawer:)];
        [self.navigationItem setLeftBarButtonItem:leftDrawerButton animated:YES];
        
        [[self navigationItem] setTitle:@"letters to crushes"];

        [[RODItemStore sharedStore] loadLettersByPage:1 level:0];
        
        current_receive = 0;
        
    }
    return self;
}

-(void)loadLetterData
{
    
    int yOffset = 0;
    
    ScrollViewItem *scv;
    
    for(int i = 0; i < [[[RODItemStore sharedStore] allLetters] count]; i++) {
        
        RKFullLetter *full_letter = [[[RODItemStore sharedStore] allLetters] objectAtIndex:i];
        
        int from_letter = [full_letter.letterCountry integerValue];
        int yOrigin = i * 100;
        
        scv = [[ScrollViewItem alloc] init];
        
        scv.current_index = i;
        scv.view.frame = CGRectMake(0, yOffset, self.view.bounds.size.width, from_letter);
        [scv.webView setDelegate:self];

        [scv.webView loadHTMLString:full_letter.letterMessage baseURL:nil];
        
        yOffset = yOffset + scv.view.bounds.size.height;
        
        [self.scrollView addSubview:scv.view];
        
        NSLog(@"%i (%@) Size, offset: %@, %i", i, full_letter.Id, full_letter.letterCountry, yOffset);
    
    }
    
    [self.scrollView setContentSize:CGSizeMake(self.view.bounds.size.width, yOffset)];
    
    
    // now try looping through and resetting everything?
    
}

-(void)redrawScroll
{
    
}


- (void)openDrawer:(id)sender {
    
    // now tell the web view to change the page
    AppDelegate *appDelegate = (AppDelegate *) [[UIApplication sharedApplication] delegate];
    [appDelegate.drawer toggleDrawerSide:MMDrawerSideLeft animated:YES completion:nil];
    
}

-(void)webViewDidStartLoad:(UIWebView *)a_webView
{
    NSLog(@"Started load.");
}

-(void)webViewDidFinishLoad:(UIWebView *)a_webView {

    RKFullLetter *current_letter = [[[RODItemStore sharedStore] allLetters] objectAtIndex:current_receive];

    NSString *height = [a_webView stringByEvaluatingJavaScriptFromString:@"document.body.scrollHeight"];

    NSLog(@"Height: %@ id - %@", height, [a_webView request] );
    
    current_letter.letterTags = @"1";
    current_receive++;
    
//    if(current_receive == 10) {
//        AppDelegate *appDelegate = (AppDelegate *) [[UIApplication sharedApplication] delegate];
//        [appDelegate.lettersScrollController loadLetterData];        
//    }

}

@end
