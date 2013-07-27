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
        

        int letter_height = 0;
        
        if([full_letter.letterTags isEqualToString:@"1"]) {
            letter_height = [full_letter.letterCountry integerValue];
        } else {
            letter_height = 100;
        }
        
        scv = [[ScrollViewItem alloc] init];
        
        scv.current_index = i;
        // the height of the padding around the
        // heart button and the frame of the scrollviewitem is about 40px.
                
        scv.view.frame = CGRectMake(0, yOffset, self.view.bounds.size.width, letter_height + 80);
        
        [scv.webView setDelegate:self];
        
        [scv.webView loadHTMLString:full_letter.letterMessage baseURL:nil];
        
        yOffset = yOffset + (letter_height + 80);
        
        [self.scrollView addSubview:scv.view];
        
        //[[RODItemStore sharedStore] addReference:scv.webView];
        
        NSLog(@"%i (%@) Size, offset: %@, %i", i, full_letter.Id, full_letter.letterCountry, yOffset);
    
    }
    
    [self.scrollView setContentSize:CGSizeMake(self.view.bounds.size.width, yOffset)];
    
    
    // now try looping through and resetting everything?
    
}

-(void)redrawScroll
{
    [[RODItemStore sharedStore] removeReferences];
    [self.scrollView.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    [self loadLetterData];
}


- (void)openDrawer:(id)sender {
    
    // now tell the web view to change the page
    AppDelegate *appDelegate = (AppDelegate *) [[UIApplication sharedApplication] delegate];
    [appDelegate.drawer toggleDrawerSide:MMDrawerSideLeft animated:YES completion:nil];
    
}

-(void)refreshOriginalPage
{
    [self.scrollView.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    [self loadLetterData];
}


-(void)webViewDidStartLoad:(UIWebView *)a_webView
{
    NSLog(@"Started load.");
}

-(void)webViewDidFinishLoad:(UIWebView *)a_webView {
    
    
    NSString *height = [a_webView stringByEvaluatingJavaScriptFromString:@"document.body.scrollHeight"];
    NSString *hidden_id = [a_webView stringByEvaluatingJavaScriptFromString:@"document.getElementById('letter_id').innerHTML"];
    
    NSLog(@"Found height for id %@: %@", hidden_id, height);
    
}



@end
