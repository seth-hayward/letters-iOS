//
//  LettersViewController.m
//  crushes
//
//  Created by Seth Hayward on 7/23/13.
//  Copyright (c) 2013 Seth Hayward. All rights reserved.
//

#import "LettersViewController.h"
#import "MMDrawerBarButtonItem.h"
#import "AppDelegate.h"
#import "RKFullLetter.h"
#import "RODItemStore.h"

@implementation LettersViewController

- (id)init
{
    self = [super initWithStyle:UITableViewStyleGrouped];
    if(self) {

        UIBarButtonItem *button_refresh = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh target:self action:@selector(refreshOriginalPage)];
        [[self navigationItem] setRightBarButtonItem:button_refresh];
        
        MMDrawerBarButtonItem * leftDrawerButton = [[MMDrawerBarButtonItem alloc] initWithTarget:self action:@selector(openDrawer:)];
        [self.navigationItem setLeftBarButtonItem:leftDrawerButton animated:YES];
        
        [[self navigationItem] setTitle:@"letters to crushes"];
        
        for(int i = 0; i < 10; i++) {
            [[RODItemStore sharedStore] createLetter:[NSString stringWithFormat:@"New letter %d", i]];
        }

    }
    return self;
}

- (id)initWithStyle:(UITableViewStyle)style
{
    return [self init];
}

- (void)openDrawer:(id)sender {
    
    // now tell the web view to change the page
    AppDelegate *appDelegate = (AppDelegate *) [[UIApplication sharedApplication] delegate];
    [appDelegate.drawer toggleDrawerSide:MMDrawerSideLeft animated:YES completion:nil];
    
}

- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [[[RODItemStore sharedStore] allLetters] count];
}

- (UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"letterCell"];
    
    if(!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"letterCell"];
    }
    
    RKFullLetter *p = [[[RODItemStore sharedStore] allLetters] objectAtIndex:[indexPath row]];
    
    [[cell textLabel] setText:[p letterMessage]];
        
    return cell;
    
}


@end
