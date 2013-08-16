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

- (IBAction)attemptLogin:(id)sender
{
    NSLog(@"Hello login.");
}

-(id) initWithStyle:(UITableViewStyle)style
{
    return [self init];
}

- (UIView *)loginView
{
    if (!loginView) {
        [[NSBundle mainBundle] loadNibNamed:@"LoginView" owner:self options:nil];
    }
    
    return loginView;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
    return [self loginView];
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return [[self loginView] bounds].size.height;
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

    AppDelegate *appDelegate = (AppDelegate *) [[UIApplication sharedApplication] delegate];
    
    // set all items to be checked=false
    for(int i = 0; i < [[[RODItemStore sharedStore] allMenuItems] count]; i++) {
        [[[[RODItemStore sharedStore] allMenuItems] objectAtIndex:i] setChecked:false];
    }
    
    RODItem *selected_item = [[[RODItemStore sharedStore] allMenuItems] objectAtIndex:[indexPath row]];
    selected_item.checked = true;
    
    switch([selected_item viewType])
    {
        case ViewTypeHome:
            [[RODItemStore sharedStore] loadLettersByPage:1  level:0];
            break;
        case ViewTypeMore:
            [[RODItemStore sharedStore] loadLettersByPage:1 level:-1];
            break;
        case ViewTypeSend:
            // now tell the web view to change the page
            [appDelegate.navigationController pushViewController:appDelegate.sendViewController animated:true];
            break;
        default:
            break;
    }
    
    // reload the data so the checkbox updates
    [tableView reloadData];
    
    if([selected_item viewType] == ViewTypeHome || [selected_item viewType] == ViewTypeMore) {
        // now tell the letters view controller to change the page
        [appDelegate.lettersScrollController setLoaded:false];
        [appDelegate.lettersScrollController loadLetterData];
        
    }
    
}

@end
