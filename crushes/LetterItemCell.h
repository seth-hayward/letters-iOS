//
//  LetterItemCell.h
//  crushes
//
//  Created by Seth Hayward on 7/23/13.
//  Copyright (c) 2013 Seth Hayward. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RKFullLetter.h"

@interface LetterItemCell : UITableViewCell <UIWebViewDelegate>

@property (weak, nonatomic) IBOutlet UIWebView *littleWebView;
@property (weak, nonatomic) IBOutlet UIButton *buttonHeart;

@property (weak, nonatomic) RKFullLetter *letter;

@end
