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
#import <REFrostedViewController.h>
#import "LetterCommentsViewController.h"

@implementation MenuViewController
@synthesize tableView, navigationController;

-(void)viewDidLoad
{
    
    UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(oneTap:)];
    UITapGestureRecognizer *singleTap2 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(oneTap:)];
    
    [self.loginView addGestureRecognizer:singleTap];
    [[self footerView] addGestureRecognizer:singleTap2];
    
    [[RODItemStore sharedStore] createItem:ViewTypeHome];
    [[RODItemStore sharedStore] createItem:ViewTypeMore];
    [[RODItemStore sharedStore] createItem:ViewTypeSearch];
    [[RODItemStore sharedStore] createItem:ViewTypeSend];
    [[RODItemStore sharedStore] createItem:ViewTypeChat];
    [[RODItemStore sharedStore] createItem:ViewTypeLogin];
    
    self.view.opaque = NO;
    self.view.backgroundColor = [UIColor clearColor];
    self.view.alpha = 0.95f;
    
    [self setThreshold:150.0f];
    
    self.tableView = [[UITableView alloc] init]; // Frame will be automatically set
    self.tableView.separatorColor = [UIColor colorWithRed:150/255.0f green:161/255.0f blue:177/255.0f alpha:1.0f];
    self.tableView.separatorInset = UIEdgeInsetsZero;
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.opaque = NO;
    self.tableView.backgroundColor = [UIColor clearColor];
    self.tableView.tableHeaderView = ({
        UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 0, 29.0f)];
        view;
    });
    

    [self.view addSubview:self.tableView];
    [self.tableView reloadData];

    
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.tableView reloadData];
}

- (UIView *)loginView
{
    if (!loginView) {
        [[NSBundle mainBundle] loadNibNamed:@"LoginView" owner:self options:nil];
    }
    
    return loginView;
}

- (UIView *)footerView
{
    if (!footerView) {
        int height = self.view.bounds.size.height - tableView.bounds.size.height;
        height = 50;
        footerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 0, height)];
        [footerView setBackgroundColor:[UIColor whiteColor]];
    }
    return footerView;
}

- (void)oneTap:(UIGestureRecognizer *)gesture
{    
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    return [self loginView];
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
    return [self footerView];
}


- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return [[self loginView] bounds].size.height;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [[[RODItemStore sharedStore] allMenuItems] count];
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    cell.backgroundColor = [UIColor clearColor];
    cell.textLabel.textColor = [UIColor colorWithRed:62/255.0f green:68/255.0f blue:75/255.0f alpha:1.0f];
    cell.textLabel.font = [UIFont fontWithName:@"HelveticaNeue" size:17];
}

- (UITableViewCell *)tableView:(UITableView *)a_tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{

    UITableViewCell *cell = [a_tableView dequeueReusableCellWithIdentifier:@"UITableViewCell"];

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

- (void)tableView:(UITableView *)a_tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    AppDelegate *appDelegate = (AppDelegate *) [[UIApplication sharedApplication] delegate];

    RODItem *selected_item = [[[RODItemStore sharedStore] allMenuItems] objectAtIndex:[indexPath row]];
    
    if([[RODItemStore sharedStore] current_viewtype] == ViewTypeComments)
    {
//        [self.navigationController dismissViewControllerAnimated:appDelegate.letterCommentsViewController completion:nil];
//        self.navigationController.viewControllers = @[ appDelegate.lettersScrollController ];
//        [self.navigationController popToRootViewControllerAnimated:YES];
        
    }
    
    // set all items to be checked=false
    for(int i = 0; i < [[[RODItemStore sharedStore] allMenuItems] count]; i++) {
        [[[[RODItemStore sharedStore] allMenuItems] objectAtIndex:i] setChecked:false];
    }
    
    selected_item.checked = true;
    [RODItemStore sharedStore].current_viewtype = selected_item.viewType;
        
    switch([selected_item viewType])
    {
        case ViewTypeHome:
            self.navigationController.viewControllers = @[ appDelegate.lettersScrollController ];
            [appDelegate.lettersScrollController clearLettersAndReset];
            [[RODItemStore sharedStore] loadLettersByPage:1  level:0];
            break;
        case ViewTypeMore:
            self.navigationController.viewControllers = @[ appDelegate.lettersScrollController ];
            [appDelegate.lettersScrollController clearLettersAndReset];            
            [[RODItemStore sharedStore] loadLettersByPage:1 level:-1];
            break;
        case ViewTypeBookmarks:
            self.navigationController.viewControllers = @[ appDelegate.lettersScrollController ];
            [appDelegate.lettersScrollController clearLettersAndReset];
            [[RODItemStore sharedStore] loadLettersByPage:1 level:100];
            break;
        case ViewTypeModLetters:
            self.navigationController.viewControllers = @[ appDelegate.lettersScrollController ];
            [[RODItemStore sharedStore] loadLettersByPage:1 level:-10];
            break;
        case ViewTypeComments:
        {
            LetterCommentsViewController *comments = [[LetterCommentsViewController alloc] init];
            comments.letter_id = -10;
            
            // now tell the web view to change the page
            AppDelegate *appDelegate = (AppDelegate *) [[UIApplication sharedApplication] delegate];
            appDelegate.letterCommentsViewController = comments;
            //[appDelegate.navigationController pushViewController:comments animated:true];
            self.navigationController.viewControllers = @[ appDelegate.letterCommentsViewController ];
        }
            break;
        case ViewTypeSend:
            // now tell the web view to change the page
            self.navigationController.viewControllers = @[ appDelegate.sendViewController ];
            break;
        case ViewTypeSearch:
            self.navigationController.viewControllers = @[ appDelegate.searchViewController ];
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
                self.navigationController.viewControllers = @[ appDelegate.chatViewController ];
            } else {
                self.navigationController.viewControllers = @[ appDelegate.chatNameViewController ];
            }
            
            break;
            
        default:
            break;
    }
    
    // reload the data so the checkbox updates
    [a_tableView reloadData];
    [self dismissViewControllerAnimated:YES completion:nil];
    
}

@end
