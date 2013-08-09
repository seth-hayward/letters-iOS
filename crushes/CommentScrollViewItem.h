//
//  CommentScrollViewItem.h
//  crushes
//
//  Created by Seth Hayward on 8/8/13.
//  Copyright (c) 2013 Seth Hayward. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RKComment.h"

@interface CommentScrollViewItem : UIViewController
{
    
}
@property (weak, nonatomic) IBOutlet UILabel *labelCommenterName;
@property (weak, nonatomic) IBOutlet UIWebView *webView;
@property (nonatomic) RKComment *current_comment;

@end
