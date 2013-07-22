//
//  MenuViewController.m
//  crushes
//
//  Created by Seth Hayward on 7/21/13.
//  Copyright (c) 2013 Seth Hayward. All rights reserved.
//

#import "MenuViewController.h"
#import "RODItem.h"
#import "RODItemStore.h"

@implementation MenuViewController

- (id) init {
    self = [super initWithStyle:UITableViewStyleGrouped];
    if (self) {

        // hard code the creation of the items...
        [[RODItemStore sharedStore] createItem:ViewTypeHome];
        [[RODItemStore sharedStore] createItem:ViewTypeMore];
        [[RODItemStore sharedStore] createItem:ViewTypeBookmarks];
        [[RODItemStore sharedStore] createItem:ViewTypeSearch];
                
    }
    return self;
}

-(id) initWithStyle:(UITableViewStyle)style
{
    return [self init];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [[[RODItemStore sharedStore] allMenuItems] count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{

    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"UITableViewCell"];

    if(!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"UITableViewCell"];
    }
    
    RODItem *p = [[[RODItemStore sharedStore] allMenuItems] objectAtIndex:[indexPath row]];
    
    [[cell textLabel] setText:[p caption]];
    
    return cell;
}

@end
