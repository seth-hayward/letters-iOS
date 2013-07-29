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
@synthesize current_receive, loaded;

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
        loaded = false;
        
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
        
        NSLog(@"id: %@, tag: %@, height: %d", full_letter.Id, full_letter.letterTags, letter_height);
        
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
    NSLog(@"Refresh.");
    [self.scrollView.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    [self loadLetterData];
}


-(void)webViewDidStartLoad:(UIWebView *)a_webView
{
    NSLog(@"Started load.");
}

-(void)webViewDidFinishLoad:(UIWebView *)a_webView {
    
    if(loaded == true) {        
        return;
    }
    
    NSString *height = [a_webView stringByEvaluatingJavaScriptFromString:@"document.body.scrollHeight"];
    NSString *hidden_id = [a_webView stringByEvaluatingJavaScriptFromString:@"document.getElementById('letter_id').innerHTML"];
    
    NSLog(@"Found height for id %@: %@", hidden_id, height);
    
    // now loop through the data store
    // assign the value
    // then check to see if th eothers have finished loading
    // if so, then ask the panel to redraw itself

    Boolean found_default = false;
    
    for(int i = 0; i < [[[RODItemStore sharedStore] allLetters] count]; i++)
    {
        
        RKFullLetter *letter = [[[RODItemStore sharedStore] allLetters] objectAtIndex:i];
        if([[letter.Id stringValue] isEqualToString:hidden_id]) {
            NSLog(@"in lettersScrollCOntainer, id is %@", letter.Id);
            [[RODItemStore sharedStore] updateLetter:letter.Id letter_height:height];
        }
        
        if([letter.letterTags isEqualToString:@"0"]) {
            found_default = true;
        }
        
    }
    
    if(found_default == false) {
        loaded = true;
        [self loadLetterData];
    }
    // now, see if the rest of the letters have received
    // their height settings, which will allow us to reload
    
    
}



@end
