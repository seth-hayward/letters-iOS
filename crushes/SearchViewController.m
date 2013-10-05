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
#import <QuartzCore/QuartzCore.h>

@implementation SearchViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        
        [[self navigationItem] setTitle:@"what are you searching for?"];
        
    }
    return self;
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    self.edgesForExtendedLayout = UIRectEdgeNone;
    
    UIButton *button_menu = [UIButton buttonWithType:UIButtonTypeCustom];
    [button_menu setFrame:CGRectMake(0, 0, 30, 30)];
    [button_menu setImage:[UIImage imageNamed:@"hamburger-150px.png"] forState:UIControlStateNormal];
    [button_menu addTarget:self action:@selector(hamburger:) forControlEvents:UIControlEventTouchUpInside];
    
    UIBarButtonItem *leftDrawerButton = [[UIBarButtonItem alloc] initWithCustomView:button_menu];
    [self.navigationItem setLeftBarButtonItem:leftDrawerButton animated:YES];
    
    UIBarButtonItem *btnSearch = [[UIBarButtonItem alloc] initWithTitle:@"search" style:UIBarButtonItemStylePlain target:self action:@selector(clickedSearch:)];
    btnSearch.tintColor = [UIColor blueColor];
    [self.navigationItem setRightBarButtonItem:btnSearch];
    
    
    [[self.textSearchTerms layer] setBorderColor:[[UIColor blackColor] CGColor]];
    [[self.textSearchTerms layer] setBorderWidth:1.0f];
    [[self.textSearchTerms layer] setCornerRadius:1.0f];
    
    [self.textSearchTerms becomeFirstResponder];

}

- (void)hamburger:(id)sender
{
    [self.textSearchTerms resignFirstResponder];
    AppDelegate *appDelegate = (AppDelegate *) [[UIApplication sharedApplication] delegate];
    [appDelegate.navigationController showMenu];
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

- (void)clickedSearch:(id)sender {
    [self doSearch];
}

- (void)doSearch
{
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
