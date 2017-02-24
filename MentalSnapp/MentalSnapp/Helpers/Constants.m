//
//  Constants.m
//  Skeleton
//
//  Created by Systango on 12/22/15.
//  Copyright © 2016 Systango. All rights reserved.
//

#import "Constants.h"
#define ns NSString

#pragma mark - Constant

ns * kEmptyString = @"";
ns * keyDeviceToken = @"DeviceToken";
ns * kPlistFileName = @"AppSettings";
ns *kBoolTrue = @"true";

#pragma mark - Network keys

ns * kInsecureProtocol = @"http://";
ns * kSecureProtocol = @"https://";
ns * kLocalEnviroment = @"LOCAL";
ns * kStagingEnviroment = @"STAGING";
ns * kLiveEnviroment = @"LIVE";

#pragma mark - Json key

ns * kJsonKeyName = @"name";
ns * kJsonKeyId = @"id";

#pragma mark - Session keys

ns * kSessionCookies = @"session_cookies"; // application session

#pragma mark - Push Notifications

ns * kAPSKey = @"aps";

#pragma mark - Local Notifications
ns *kCleanRecordViewControllerNotification = @"CleanRecordViewController";
ns *kRefreshVideosViewControllerNotification = @"RefreshVideosViewController";

#pragma mark - Other constants
ns *kAfter = @"after";
ns *kBefore = @"before";
ns *kJPage = @"page";
ns *kJPerPage = @"per_page";
ns *kJlimit = @"limit";
ns *kJSearchText = @"search_text";
ns *kJExerciseId = @"exercise_ids";

#pragma mark - Userdefault keys
ns *kUserEmail = @"UserEmail";
ns *kUserPassword = @"UserPassword";
ns *kRememberMe = @"RememberMe";
ns *kIsUserLoggedIn = @"IsUserLoggedIn";
ns *kIsTutorialShownBefore = @"IsTutorialShownBefore";
ns *kIsCameraDurationAlertShown = @"IsCameraDurationAlertShown";

#pragma mark - StoryBboard
ns *KProfileStoryboard = @"ProfileStoryboard";
ns *KPlayerStoryboard = @"PlayerStoryboard";
ns *kTutorialStoryboard = @"TutorialStoryboard";

#pragma mark - StoryBboard Identifier
ns * KProfileViewControllerIdentifier  = @"ProfileViewController";
ns *kTutorialPageViewControllerIdentifier = @"TutorialPageViewController";
ns *kTutorialViewControllerIdentifier = @"TutorialViewController";
ns * KChangePasswordViewController = @"ChangePasswordViewController";
ns * KSupportScreenViewController  = @"SupportScreenViewController";
ns *kGuidedExcerciseViewController = @"GuidedExcerciseViewController";
ns *kExcerciseSubCategoryViewController = @"ExcerciseSubCategoryViewController";
ns *kSubCategoryDetailViewController = @"SubCategoryDetailViewController";
ns *kSubCategoryPageViewController = @"SubCategoryPageViewController";
ns *kRecordAlertViewController = @"RecordAlertViewController";
ns *kMoodViewController = @"MoodViewController";
ns *kFeelingListViewController = @"FeelingListViewController";
ns *kDownloadAllVideoViewController = @"DownloadAllVideoViewController";
ns *kPlayerViewController = @"PlayerViewController";
ns *kLineStatViewController = @"LineStatViewController";
ns *kRecordViewController = @"RecordViewController";

#pragma mark - API URL
ns *kLoginAPI = @"api/v1/authenticate";
ns *kSignUpAPI = @"api/v1/users";
ns *kForgotPassAPI = @"api/v1/users/forgot_password";
ns *KUserAPI = @"api/v1/users/%@";
ns *kChangePassword = @"api/v1/users/update_password";
ns *kDeactivateUser = @"api/v1/users/deactivate_account";
ns *KPostSupportLog = @"api/v1/supports/record";
ns *KGetGuidedExcercise = @"api/v1/guided_exercise";
ns *KGetSubCategoryExcercise = @"api/v1/guided_exercise/%@/sub_categories";
ns *KFeelingList = @"api/v2/feelings";
ns *kRecordPostAPI = @"api/v1/posts";
ns *kSearchRecordPostAPI = @"api/v1/posts/search_posts";
ns *kFilterListAPI = @"api/v1/filters/get_filters_list";
ns *kFilteredRecordPosts = @"api/v1/filters/get_filter_posts";
ns *kSchedulesAPI = @"api/v1/schedules";
ns *kEditSchedulesAPI = @"api/v1/schedules/%@";
ns *kGetStatsAPI = @"api/v1/statics/get_stats";
ns *KGetSubCategoryQuestionsExcercise = @"/api/v1/sub_categories/%@/get_questions";

#pragma mark - StoryBoard segue identifiers
#pragma mark Main
ns *kGoToReportIssueScreen = @"goToReportIssueScreen";
ns *kGoToQueuedExercisesScreen = @"goToQueuedExercisesScreen";
ns *kGoToSignUp = @"toSignUp";
ns *kGoToForgotPasswordFirstScreen = @"GoToForgotPasswordFirstViewController";
ns *kGoToForgotPasswordSecondScreen = @"GoToForgotPasswordSecondViewController";
ns *kPickerViewController = @"PickerViewController";
ns *kMonthYearPickerViewController = @"MonthYearPickerViewController";

#pragma mark - TableViewCell identifiers

ns *kMoreScreenTableViewCellIdentifier = @"MoreScreenTableViewCellIdentifier";
ns *kguidedExcerciseCellCollectionViewCell = @"guidedExcerciseCellCollectionViewCell";
ns *kSubCategoryExcerciseTableViewCell = @"SubCategoryTableViewCell";
ns *kFeelingTableViewCell = @"FeelingTableViewCell";
ns *kVideoTableViewCellIdentifier = @"VideoTableViewCell";
ns *kQueuedExercisesTableViewCellIdentifier = @"QueuedExercisesTableViewCell";
ns *KStatsMoodTableViewCell = @"StatsMoodTableViewCell";

#pragma mark - S3Buckets
ns *kAWSPath = @"https://s3-eu-west-1.amazonaws.com";
ns *kLiveProfileImageBucket = @"mentalsnapp/production/profile_images";
ns *kLiveVideoThumbnailImageBucket = @"mentalsnapp/production/video_thumbnails";
ns *kLiveVideoBucket = @"mentalsnapp/production/videos";
ns *kStagingProfileImageBucket = @"mentalsnapp/staging/profile_images";
ns *kStagingVideoThumbnailImageBucket = @"mentalsnapp/staging/video_thumbnails";
ns *kStagingVideoBucket = @"mentalsnapp/staging/videos";

