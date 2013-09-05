//
//  SearchViewController.m
//  crushes
//
//  Created by Seth Hayward on 8/20/13.
//  Copyright (c) 2013 Seth Hayward. All rights reserved.
//

#import "SearchViewController.h"
#import "MMDrawerBarButtonItem.h"
#import "AppDelegate.h"
#import "RODItemStore.h"

@implementation SearchViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        
        MMDrawerBarButtonItem * leftDrawerButton = [[MMDrawerBarButtonItem alloc] initWithTarget:self action:@selector(openDrawer:)];
        [self.navigationItem setLeftBarButtonItem:leftDrawerButton animated:YES];
        
        [[self navigationItem] setTitle:@"search"];
        
    }
    return self;
}

- (void)openDrawer:(id)sender {
    
    // now tell the web view to change the page
    AppDelegate *appDelegate = (AppDelegate *) [[UIApplication sharedApplication] delegate];
    [appDelegate.drawer toggleDrawerSide:MMDrawerSideLeft animated:YES completion:nil];
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)clickedSearch:(id)sender {
    NSLog(@"Please search for %@", [self.searchTerms text]);

    AppDelegate *appDelegate = (AppDelegate *) [[UIApplication sharedApplication] delegate];
    [appDelegate.lettersScrollController clearLettersAndReset];
    [[RODItemStore sharedStore] loadLettersByPage:1 level:120 terms:[self.searchTerms text]];
}
@end
