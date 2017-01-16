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

+ (BOOL)isValidEmail:(NSString *)checkString;
- (void)logoutUser;
@end
