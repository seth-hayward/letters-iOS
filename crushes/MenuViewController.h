//
//  MenuViewController.h
//  crushes
//
//  Created by Seth Hayward on 7/21/13.
//  Copyright (c) 2013 Seth Hayward. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>

@interface MenuViewController : UITableViewController <UITableViewDelegate>
{
    IBOutlet UIView *loginView;
}

- (UIView *)loginView;

@end
