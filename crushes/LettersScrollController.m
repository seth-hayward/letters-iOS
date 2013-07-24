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

@implementation LettersScrollController

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
        
    }
    return self;
}

-(void)loadLetterData
{
    
    int yOffset = 0;
    
    for(int i = 0; i < [[[RODItemStore sharedStore] allLetters] count]; i++) {
        
        RKFullLetter *full_letter = [[[RODItemStore sharedStore] allLetters] objectAtIndex:i];
        
        int from_letter = [full_letter.letterCountry integerValue];
        int yOrigin = i * 100;
        
        ScrollViewItem *scv = [[ScrollViewItem alloc] init];
        scv.view.frame = CGRectMake(0, yOffset, self.view.bounds.size.width, from_letter);
        [scv updateViewConstraints];
        
        [scv.webView loadHTMLString:full_letter.letterMessage baseURL:nil];
        
        yOffset = yOffset + scv.view.bounds.size.height;
        [self.scrollView addSubview:scv.view];
        
        NSLog(@"Size, offset: %@, %i", full_letter.letterCountry, yOffset);
    
    }
    
    [self.scrollView setContentSize:CGSizeMake(self.view.bounds.size.width, yOffset)];
    
    
    // now try looping through and resetting everything?
    
}

@end
