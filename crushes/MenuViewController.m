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
#import "WCAlertView.h"

@implementation MenuViewController

- (id) init {
    self = [super initWithStyle:UITableViewStylePlain];
    if (self) {
        
        // hard code the creation of the items...
        [[RODItemStore sharedStore] createItem:ViewTypeHome];
        [[RODItemStore sharedStore] createItem:ViewTypeMore];
        [[RODItemStore sharedStore] createItem:ViewTypeSearch];
        [[RODItemStore sharedStore] createItem:ViewTypeSend];
        [[RODItemStore sharedStore] createItem:ViewTypeChat];
        [[RODItemStore sharedStore] createItem:ViewTypeLogin];
        
        self.tableView.scrollEnabled = NO;
        
        // border
        
        [self.tableView.layer setBorderWidth: 1.0];
        [self.tableView.layer setMasksToBounds:YES];
        [self.tableView.layer setBorderColor:[[UIColor blackColor] CGColor]];
                
    }
    return self;
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.tableView reloadData];    
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

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    return [self loginView];
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
    UIView *little_blanky = [[UIView alloc] init];
    return little_blanky;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 10;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
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
    
    // if the previous view type was
    // the send screen, we want to pop
    // that one off the top
    
    if([RODItemStore sharedStore].current_viewtype == ViewTypeSearch) {
        [appDelegate.navigationController popViewControllerAnimated:NO];
    }
    
    if([RODItemStore sharedStore].current_viewtype == ViewTypeSend) {
        [appDelegate.navigationController popViewControllerAnimated:NO];
    }
    
    if([RODItemStore sharedStore].current_viewtype == ViewTypeChat) {
        [appDelegate.navigationController popViewControllerAnimated:NO];
    }

    RODItem *selected_item = [[[RODItemStore sharedStore] allMenuItems] objectAtIndex:[indexPath row]];
    
    // set all items to be checked=false
    for(int i = 0; i < [[[RODItemStore sharedStore] allMenuItems] count]; i++) {
        [[[[RODItemStore sharedStore] allMenuItems] objectAtIndex:i] setChecked:false];
    }
    
    selected_item.checked = true;
    [RODItemStore sharedStore].current_viewtype = selected_item.viewType;
        
    switch([selected_item viewType])
    {
        case ViewTypeHome:
            [appDelegate.lettersScrollController clearLettersAndReset];
            [[RODItemStore sharedStore] loadLettersByPage:1  level:0];
            break;
        case ViewTypeMore:
            [appDelegate.lettersScrollController clearLettersAndReset];            
            [[RODItemStore sharedStore] loadLettersByPage:1 level:-1];
            break;
        case ViewTypeBookmarks:
            [appDelegate.lettersScrollController clearLettersAndReset];
            [[RODItemStore sharedStore] loadLettersByPage:1 level:100];
            break;
        case ViewTypeSend:
            // now tell the web view to change the page
            [appDelegate.navigationController pushViewController:appDelegate.sendViewController animated:YES];
            break;
        case ViewTypeSearch:
            [appDelegate.navigationController pushViewController:appDelegate.searchViewController animated:YES];
            break;
        case ViewTypeLogin:
            [[RODItemStore sharedStore] generateLoginAlert];
            break;
        case ViewTypeLogout:
            [WCAlertView showAlertWithTitle:@"logout?" message:@"Are you sure you want to logout?" customizationBlock:^(WCAlertView *alertView) {
                alertView.style = WCAlertViewStyleBlackHatched;
            } completionBlock:^(NSUInteger buttonIndex, WCAlertView *alertView) {
                // reload the page
                
                if(buttonIndex == 1) {
                    [[RODItemStore sharedStore] logout];
                }
                                
            } cancelButtonTitle:@"cancel" otherButtonTitles:@"logout", nil];
            
            break;
        case ViewTypeChat:
            
            if([RODItemStore sharedStore].connected_to_chat == YES) {
                [appDelegate.navigationController pushViewController:appDelegate.chatViewController animated:YES];
            } else {
                [appDelegate.navigationController pushViewController:appDelegate.chatNameViewController animated:YES];
            }
            
            break;
            
        default:
            break;
    }
    
    // reload the data so the checkbox updates
    [tableView reloadData];
    
}

@end
