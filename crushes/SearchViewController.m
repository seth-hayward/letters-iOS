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
    
    [self.textSearchTerms setBackgroundColor:[UIColor colorWithRed:245/255.0f green:150/255.0f blue:150/255.0f alpha:1.0f]];
    
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    [self.indicator stopAnimating];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)clickedSearch:(id)sender {
    [self doSearch];
}

- (void)doSearch {
    NSLog(@"Please search for %@", [self.textSearchTerms text]);
    [self.indicator startAnimating];
    [self.view setNeedsDisplay];
    [self.textSearchTerms resignFirstResponder];
    
    [[RODItemStore sharedStore] loadLettersByPage:1 level:120 terms:[self.textSearchTerms text]];
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
    
    if([text isEqualToString:@"\n"]) {
        [self doSearch];
        return NO;
    }
    
    return YES;
}
@end
