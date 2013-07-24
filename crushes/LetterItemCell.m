//
//  LetterItemCell.m
//  crushes
//
//  Created by Seth Hayward on 7/23/13.
//  Copyright (c) 2013 Seth Hayward. All rights reserved.
//

#import "LetterItemCell.h"
#import "RKFullLetter.h"

@implementation LetterItemCell

@synthesize letter;

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
    NSLog(@"Error: %@", error);
}

- (void)webViewDidFinishLoad:(UIWebView *)webView {

    NSString *update_height = @"0";
    
    CGRect frame = webView.frame;
    frame.size.height = 1;
    webView.frame = frame;
    CGSize fittingSize = [webView sizeThatFits:CGSizeZero];
    frame.size = fittingSize;
    webView.frame = frame;
    
    update_height = [NSString stringWithFormat:@"%i", (int)fittingSize.height];
    
    letter.letterCountry = update_height;
    
//    NSLog(@"Height set: %@", letter.letterCountry, letter.letterMessage);
}

@end
