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

@synthesize letter, loaded;

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
    NSLog(@"Error: %@", error);
}

- (void)webViewDidStartLoad:(UIWebView *)webView {
    loaded = false;
    letter.letterTags = @"0";
}

- (void)webViewDidFinishLoad:(UIWebView *)webView {

    NSString *update_height = @"0";
    
    CGRect frame = webView.frame;
    frame.size.height = 1;
    webView.frame = frame;
    CGSize fittingSize = [webView sizeThatFits:CGSizeZero];
    frame.size = fittingSize;
    webView.frame = frame;
    
    if(fittingSize.height > 2000) {
        update_height = @"2000";       
    } else {
        update_height = [NSString stringWithFormat:@"%i", (int)fittingSize.height];
    }
    
    
    letter.letterCountry = update_height;
    letter.letterTags = @"1";
    
    
    NSLog(@"Height set: %@", letter.letterCountry);
    loaded = true;
}

@end
