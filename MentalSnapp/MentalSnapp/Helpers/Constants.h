//
//  Constants.h
//  Skeleton
//
//  Created by Systango on 12/22/15.
//  Copyright © 2016 Systango. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum {
    Gallery,
    Camera,
    DeleteImage
} ImagePickerType;

#define exNS extern NSString

#define ApplicationDelegate ((AppDelegate *)[UIApplication sharedApplication].delegate)
#define UserDefaults [NSUserDefaults standardUserDefaults]

typedef void (^completionBlock)(BOOL success, id response);

#pragma mark - Constant

exNS *kEmptyString;
exNS *keyDeviceToken;
exNS *kPlistFileName;
exNS *kBoolTrue;

#pragma mark - Network keys

exNS *kInsecureProtocol;
exNS *kSecureProtocol;
exNS *kLocalEnviroment;
exNS *kStagingEnviroment;
exNS *kLiveEnviroment;

#pragma mark - Json

exNS *kJsonKeyName;
exNS *kJsonKeyId;

#pragma mark - Numerical Constants

static const int kStatusSuccess = 1;
static const int kResponseStatusSuccess = 200;
static const int kResponseStatusCreated = 201;
static const int kResponseStatusAccepted = 202;
static const int kResponseStatusForbidden = 401;
#pragma mark - Enum

typedef NS_ENUM(NSInteger, RequestType){
    RequestGET,
    RequestPOST,
    RequestMutiPartPost,
    RequestDELETE,
    RequestPUT
};

typedef NS_ENUM(NSInteger, genderType){
    MaleGender,
    FemaleGender
  };

typedef NS_ENUM(NSInteger, ExerciseType){
    mainExcercise = 0,
    subcategoryExcercise
};

#pragma mark - Other constants
exNS *kAfter;
exNS *kBefore;
exNS *kJPage;
exNS *kJPerPage;
exNS *kJlimit;

#pragma mark - Session keys
exNS *kSessionCookies;

#pragma mark - Push Notifications
exNS *kAPSKey;

#pragma mark - Userdefault keys
exNS *kUserEmail;
exNS *kUserPassword;
exNS *kRememberMe;
exNS *kIsUserLoggedIn;

#pragma mark - StoryBboard Identifier
exNS *KProfileViewControllerIdentifier;
exNS *KProfileStoryboard;
exNS *KChangePasswordViewController;
exNS *KSupportScreenViewController;
exNS *kGuidedExcerciseViewController;
exNS *kExcerciseSubCategoryViewController;

#pragma mark - API URL
exNS *KUserAPI;
exNS *kLoginAPI;
exNS *kSignUpAPI;
exNS *kForgotPassAPI;
exNS *kChangePassword;
exNS *kDeactivateUser;
exNS  *KPostSupportLog;
exNS *KGetGuidedExcercise;
exNS *KGetSubCategoryExcercise;

#pragma mark - StoryBoard segue identifiers
#pragma mark Main
exNS *kGoToReportIssueScreen;
exNS *kGoToQueuedExercisesScreen;
exNS *kGoToSignUp;
exNS *kGoToForgotPasswordFirstScreen;
exNS *kGoToForgotPasswordSecondScreen;
exNS *kPickerViewController;

#pragma mark - TableViewCell identifiers
exNS *kMoreScreenTableViewCellIdentifier;
exNS *kguidedExcerciseCellCollectionViewCell;
exNS *kSubCategoryExcerciseTableViewCell;


#pragma mark - S3Buckets

exNS *kLiveProfileImageBucket;
exNS *kLiveVideoBucket;

exNS *kStagingProfileImageBucket;
exNS *kStagingVideoBucket;


