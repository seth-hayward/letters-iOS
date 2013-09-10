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
#import "RKChat.h"
#import "RODSettings.h"

@interface RODItemStore : NSObject
{
    NSMutableArray *_allMenuItems;
    NSMutableArray *_allLetters;
    NSMutableArray *_allComments;
    NSMutableArray *_allChats;
    NSMutableArray *_webviewReferences;
    RODSettings *_settings;
}

+ (RODItemStore *)sharedStore;

- (NSArray *)allMenuItems;
- (NSArray *)allLetters;
- (NSArray *)allComments;
- (NSArray *)allChats;

- (RODSettings *)settings;

- (NSString*)settingsArchivePath;

@property (nonatomic) ViewType current_viewtype;
@property (nonatomic) int current_page;
@property (nonatomic) int current_load_level;
@property (nonatomic) BOOL connected_to_chat;
@property (nonatomic) NSString *current_search_terms;
@property (nonatomic) NSNumber *loginStatus;
@property (nonatomic) UIDeviceOrientation last_device_orientation;

- (BOOL) shouldShowHideButton:(NSNumber *)letter_id;
- (BOOL) shouldShowEditButton:(NSNumber *)letter_id;
- (BOOL) isLetterInSentLetters:(NSNumber *)input_id;

- (void)goNextPage;
- (void)goBackPage;

- (void) addChat:(NSString *)chat;
- (void) generateLoginAlert;
- (void) logout;
- (void) login:(NSString *)email password:(NSString *)password;
- (void) hideLetter:(NSNumber *)letter_id;
- (void) editLetter:(NSNumber *)letter_id;
- (void) doLogin;
- (BOOL) saveSettings;
- (NSString *) cleanText:(NSString * )incoming;

- (void)updateLetterByIndex:(int)letter_index letter_height:(NSString *)height;
- (void)updateComment:(int)comment_index comment_height:(NSString *)height;
- (void)updateLetterHearts:(NSNumber *)letter_id hearts:(NSNumber *)l_hearts;


- (RODItem *)createItem:(ViewType) new_Type;
- (RKFullLetter *)addLetter:(RKFullLetter *) letter;
- (RKComment *)addComment:(RKComment *) comment;

- (void)loadLettersByPage:(NSInteger)page level:(NSInteger)load_level;
- (void)loadLettersByPage:(NSInteger)page level:(NSInteger)load_level terms:(NSString *)_terms;

- (void)addReference:(UIWebView *)watch_this;
- (void)removeReferences;

- (void)clearComments;
- (void)clearChats;

@end
