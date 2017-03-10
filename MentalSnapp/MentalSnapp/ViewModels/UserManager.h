//
//  UserManager.h
//  MentalSnapp
//

#import <Foundation/Foundation.h>
#import "RecordViewController.h"

@class UserModel;

@interface UserManager : NSObject

@property (strong, nonatomic) UserModel *userModel;
@property (strong, nonatomic) NSString *authorizationToken;
@property (assign, nonatomic) BOOL isFirstTime;
@property (strong, nonatomic) RecordViewController *recordViewController;

+ (UserManager *)sharedManager;

- (void)saveLoggedinUserInfoInUserDefault;
- (void)setValueInLoggedInUserObjectFromUserDefault;
- (void)updateProfileURL:(NSString *)profileURL;
- (void)removeUserFromUserDefault;
- (void)showLoginViewController;
- (void)showSignupViewController;
- (void)showTutorialScreen:(BOOL)isFirstTutorial;
- (void)openTabBar;

+ (BOOL)isValidEmail:(NSString *)checkString;
- (void)logoutUser;

- (void)sendAnalyticsForGenderAndDOBforUser:(UserModel *)user;
@end
