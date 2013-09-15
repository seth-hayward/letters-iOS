//
//  LetterCommentsViewController.h
//  crushes
//
//  Created by Seth Hayward on 8/6/13.
//  Copyright (c) 2013 Seth Hayward. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GAITrackedViewController.h"
#import "AddCommentViewController.h"

@interface LetterCommentsViewController : GAITrackedViewController <UIWebViewDelegate>
{
    AddCommentViewController *addComment;
}

@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (nonatomic) int letter_id;
@property (nonatomic) int comment_index;
@property (weak, nonatomic) IBOutlet UIWebView *testWebView;

-(void)loadCommentData;

@end
