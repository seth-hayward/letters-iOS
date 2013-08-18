//
//  RODItemStore.h
//  crushes
//
//  Created by Seth Hayward on 7/22/13.
//  Copyright (c) 2013 Seth Hayward. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RODItem.h"
#import "RKFullLetter.h"
#import "RKComment.h"

@interface RODItemStore : NSObject
{
    NSMutableArray *allMenuItems;
    NSMutableArray *_allLetters;
    NSMutableArray *_allComments;
    NSMutableArray *_webviewReferences;
    NSNumber *_loginStatus;
    
}

+ (RODItemStore *)sharedStore;

- (NSArray *)allMenuItems;
- (NSArray *)allLetters;
- (NSArray *)allComments;

@property (nonatomic) int current_page;
@property (nonatomic) int current_load_level;
@property (nonatomic) NSNumber *loginStatus;

- (void)goNextPage;
- (void)goBackPage;

- (void) login:(NSString *)email password:(NSString *)password;
- (void) doLogin;

- (NSArray *)webviewReferences;

- (void)updateLetter:(NSNumber *)letter_id letter_height:(NSString *)height;
- (void)updateLetterByIndex:(int)letter_index letter_height:(NSString *)height;
- (void)updateComment:(int)comment_index comment_height:(NSString *)height;
- (void)updateLetterHearts:(NSNumber *)letter_id hearts:(NSNumber *)l_hearts;


- (RODItem *)createItem:(ViewType) new_Type;
- (RKFullLetter *)addLetter:(RKFullLetter *) letter;
- (RKComment *)addComment:(RKComment *) comment;

- (void)loadLettersByPage:(NSInteger)page level:(NSInteger)load_level;

- (void)addReference:(UIWebView *)watch_this;
- (void)removeReferences;

- (void)clearComments;

@end
