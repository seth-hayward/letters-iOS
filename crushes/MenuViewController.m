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
#import "AppDelegate.h"

@implementation MenuViewController

- (id) init {
    self = [super initWithStyle:UITableViewStyleGrouped];
    if (self) {

        // hard code the creation of the items...
        [[RODItemStore sharedStore] createItem:ViewTypeHome];
        [[RODItemStore sharedStore] createItem:ViewTypeMore];
        [[RODItemStore sharedStore] createItem:ViewTypeBookmarks];
        [[RODItemStore sharedStore] createItem:ViewTypeSearch];
        [[RODItemStore sharedStore] createItem:ViewTypeSend];
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
    
    if([p checked]) {
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    } else {
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{

    // set all items to be checked=false
    for(int i = 0; i < [[[RODItemStore sharedStore] allMenuItems] count]; i++) {
        [[[[RODItemStore sharedStore] allMenuItems] objectAtIndex:i] setChecked:false];
    }
    
    RODItem *selected_item = [[[RODItemStore sharedStore] allMenuItems] objectAtIndex:[indexPath row]];
    selected_item.checked = true;
    
    // set the selected item to be checked=true
    //[[[[RODItemStore sharedStore] allMenuItems] objectAtIndex:[indexPath row]] setChecked:true];

    // now tell the web view to change the page
    AppDelegate *appDelegate = (AppDelegate *) [[UIApplication sharedApplication] delegate];
    appDelegate.webViewController.viewType = selected_item.viewType;
    [appDelegate.webViewController refreshOriginalPage];
    
    [tableView reloadData];
}

@end
