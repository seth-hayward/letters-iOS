//
//  CommentScrollViewItem.m
//  crushes
//
//  Created by Seth Hayward on 8/8/13.
//  Copyright (c) 2013 Seth Hayward. All rights reserved.
//

#import "CommentScrollViewItem.h"

@implementation CommentScrollViewItem
@synthesize current_comment;

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
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
