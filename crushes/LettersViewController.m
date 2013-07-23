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
#import "LetterItemCell.h"

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
        
        [[RODItemStore sharedStore] loadLettersByPage:1 level:0];

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
    
    RKFullLetter *p = [[[RODItemStore sharedStore] allLetters] objectAtIndex:[indexPath row]];
    
    LetterItemCell *cell = [tableView dequeueReusableCellWithIdentifier:@"letterCell"];

    [[cell littleWebView] loadHTMLString:[p letterMessage] baseURL:nil];
    [[cell buttonHeart] setTitle:[[p letterUp] stringValue] forState:UIControlStateNormal];
    
    return cell;
    
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // load the nib file
    UINib *nib = [UINib nibWithNibName:@"LetterItemCell" bundle:nil];
    
    // register this nib which contains the cell
    [[self tableView] registerNib:nib forCellReuseIdentifier:@"letterCell"];
    
}


@end
