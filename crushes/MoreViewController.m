//
//  MoreViewController.m
//  crushes
//
//  Created by Seth Hayward on 12/6/12.
//  Copyright (c) 2012 Seth Hayward. All rights reserved.
//

#import "MoreViewController.h"

@implementation MoreViewController

-(id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    
    if (self) {        
        UITabBarItem *tbi = [self tabBarItem];
        [tbi setTitle:@"More"];
        [tbi setImage:[UIImage imageNamed:@"heart.png"]];
    }
    
    return self;
}

@end
