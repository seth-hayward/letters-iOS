//
//  PagerViewController.m
//  crushes
//
//  Created by Seth Hayward on 8/18/13.
//  Copyright (c) 2013 Seth Hayward. All rights reserved.
//

#import "PagerViewController.h"
#import "J1Button.h"

@interface PagerViewController ()

@end

@implementation PagerViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.

    self.buttonBack.color = J1ButtonColorGray;
    self.buttonNext.color = J1ButtonColorGray;

    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
