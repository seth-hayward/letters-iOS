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
        
        UIWebView *real_letter = [[UIWebView alloc] initWithFrame:CGRectMake(0, yOffset, self.view.bounds.size.width, from_letter)];
        
        [real_letter loadHTMLString:full_letter.letterMessage baseURL:nil];
        
        yOffset += from_letter;
        [self.scrollView addSubview:real_letter.scrollView];
        
        NSLog(@"Size, offset: %@, %i", full_letter.letterCountry, yOffset);
    
    }
    
    [self.scrollView setContentSize:CGSizeMake(self.view.bounds.size.width, yOffset)];
    
}

@end
