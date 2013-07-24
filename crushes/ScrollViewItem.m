//
//  ScrollViewItemViewController.m
//  crushes
//
//  Created by Seth Hayward on 7/24/13.
//  Copyright (c) 2013 Seth Hayward. All rights reserved.
//

#import "ScrollViewItem.h"
#import "RODItemStore.h"
#import "RKFullLetter.h"

@implementation ScrollViewItem
@synthesize current_index, webView;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        NSLog(@"Initialized...");
        //self.webView.delegate = self;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
//
//-(void)webViewDidStartLoad:(UIWebView *)a_webView
//{
//    NSLog(@"Started load.");
//}
//
//-(void)webViewDidFinishLoad:(UIWebView *)a_webView {
//    
////    RKFullLetter *current_letter = [[[RODItemStore sharedStore] allLetters] objectAtIndex:current_index];
//    
//    NSString *height = [a_webView stringByEvaluatingJavaScriptFromString:@"document.body.scrollHeight"];
//
//    NSLog(@"Height: %@", height);
//    
//    //current_letter.letterTags = @"1";
//    
//}

@end
