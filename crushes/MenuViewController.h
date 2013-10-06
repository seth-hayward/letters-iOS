//
//  MenuViewController.h
//  crushes
//
//  Created by Seth Hayward on 7/21/13.
//  Copyright (c) 2013 Seth Hayward. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>
#import <REFrostedViewController.h>

@interface MenuViewController : REFrostedViewController <UITableViewDelegate, UITableViewDataSource>
{
    IBOutlet UIView *loginView;
    IBOutlet UIView *footerView;
}

- (UIView *)loginView;

@property (weak, readwrite, nonatomic) UINavigationController *navigationController;
@property (strong, readwrite, nonatomic) UITableView *tableView;

@end
