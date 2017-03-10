//
//  UserManager.m
//  MentalSnapp
//

#import "UserManager.h"
#import "LoginViewController.h"
#import "TutorialPageViewController.h"
#import "SignUpViewController.h"

@implementation UserManager

static UserManager *userManager = nil;
static dispatch_once_t userOnceToken;

+ (UserManager *)sharedManager
{
    dispatch_once(&userOnceToken, ^{
        userManager = [[UserManager alloc] init];
    });
    return userManager;
}

- (id)init {
    self = [super init];
    if(self)
    {
        _userModel = [UserModel new];
    }
    
    return self;
}

- (void)saveLoggedinUserInfoInUserDefault
{
    [UserDefaults setBool:YES forKey:kIsUserLoggedIn];
    
    [UserDefaults setValue:_authorizationToken forKey:@"authorizationToken"];
    [UserDefaults setValue:_userModel.email forKey:@"email"];
    [UserDefaults setValue:_userModel.password forKey:@"password"];
    [UserDefaults setValue:_userModel.firstName forKey:@"firstName"];
    [UserDefaults setValue:_userModel.lastName forKey:@"lastName"];
    [UserDefaults setValue:_userModel.userId forKey:@"id"];
    [UserDefaults setValue:_userModel.profilePicURL forKey:@"profile_url"];
    [UserDefaults setValue:_userModel.dateOfBirth forKey:@"date_of_birth"];
    [UserDefaults setValue:_userModel.gender forKey:@"gender"];
    [UserDefaults setValue:_userModel.phoneNumber forKey:@"phone_number"];
    [UserDefaults synchronize];
}

- (void)setValueInLoggedInUserObjectFromUserDefault
{
    _authorizationToken = [UserDefaults valueForKey:@"authorizationToken"];
    _userModel.email = [UserDefaults valueForKey:@"email"];
    _userModel.firstName = [UserDefaults valueForKey:@"firstName"];
    _userModel.lastName = [UserDefaults valueForKey:@"lastName"];
    _userModel.password = [UserDefaults valueForKey:@"password"];
    _userModel.dateOfBirth = [UserDefaults valueForKey:@"date_of_birth"];
    _userModel.phoneNumber = [UserDefaults valueForKey:@"phone_number"];
    _userModel.gender = [UserDefaults valueForKey:@"gender"];
    _userModel.userId = [UserDefaults valueForKey:@"id"];
    _userModel.profilePicURL = [UserDefaults valueForKey:@"profile_url"];
    NSError *error;
    NSDictionary *dictionary = [UserDefaults dictionaryRepresentation];
    _userModel = [[UserModel alloc] initWithDictionary:dictionary error:&error];
}

- (void)updateProfileURL:(NSString *)profileURL
{
    _userModel.profilePicURL = profileURL;
    [UserDefaults setValue:_userModel.profilePicURL forKey:@"profile_url"];
    [UserDefaults synchronize];
}

-(void)logoutUser {
    [self removeUserFromUserDefault];
    [[ScheduleManager sharedInstance] didcleanSchedules];
    [self showLoginViewController];
}

- (void)sendAnalyticsForGenderAndDOBforUser:(UserModel *)user {
    id<GAITracker> tracker = [[GAI sharedInstance] trackerWithTrackingId:@"UA-92763376-1"];
    
    NSString *category = [NSString stringWithFormat:@"%@_%@_%@",user.userId, user.firstName,user.lastName];
    NSString *eventAction;
    NSString *label;
    
    if (user.gender.length !=0) {
        eventAction = @"Gender";
        
        label = user.gender;
        
        [tracker send:
         [[GAIDictionaryBuilder createEventWithCategory:category
                                                 action:eventAction
                                                  label:label
                                                  value:@1] build]];
    }
    
    if (user.dateOfBirth.length != 0) {
        eventAction = @"Date of birth";
        
        label = user.dateOfBirth;
        
        [tracker send:
         [[GAIDictionaryBuilder createEventWithCategory:category
                                                 action:eventAction
                                                  label:label
                                                  value:@1] build]];
    }
}

- (void)showLoginViewController
{
    LoginViewController *loginViewController = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"LoginViewController"];
    
    [UIView transitionWithView:[ApplicationDelegate window]
                      duration:0.5
                       options:UIViewAnimationOptionTransitionFlipFromRight
                    animations:^{
                        [[ApplicationDelegate window] setRootViewController:[[UINavigationController alloc] initWithRootViewController:loginViewController]];
                    }
                    completion:nil];
}

- (void)showSignupViewController
{
    LoginViewController *loginViewController = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"LoginViewController"];
    
    SignUpViewController *signUpViewController = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"SignUpViewController"];
    
    UINavigationController *navController = [[UINavigationController alloc]initWithRootViewController:loginViewController];
    [navController setViewControllers:[NSArray arrayWithObjects:loginViewController, signUpViewController, nil]];
    
    [UIView transitionWithView:[ApplicationDelegate window]
                      duration:0.5
                       options:UIViewAnimationOptionTransitionFlipFromRight
                    animations:^{
                        [[ApplicationDelegate window] setRootViewController:navController];
                    }
                    completion:nil];
}

- (void)showTutorialScreen:(BOOL)isFirstTutorial
{
    TutorialPageViewController *tutorialPageViewController = [[UIStoryboard storyboardWithName:kTutorialStoryboard bundle:nil] instantiateViewControllerWithIdentifier:kTutorialPageViewControllerIdentifier];
    tutorialPageViewController.isFirstTutorial = isFirstTutorial;
    
    [UIView transitionWithView:[ApplicationDelegate window]
                      duration:0.5
                       options:UIViewAnimationOptionTransitionFlipFromRight
                    animations:^{
                        [[ApplicationDelegate window] setRootViewController:[[UINavigationController alloc] initWithRootViewController:tutorialPageViewController]];
                    }
                    completion:nil];
}

- (void)openTabBar {
    ApplicationDelegate.tabBarController = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"MainTabController"];
    ApplicationDelegate.window.rootViewController = ApplicationDelegate.tabBarController;
}

//*>    Save Logged in user's info in user default
- (void)removeUserFromUserDefault
{
    [UserDefaults setBool:NO forKey:kIsUserLoggedIn];
    [UserDefaults removeObjectForKey:@"authorizationToken"];
    [UserDefaults removeObjectForKey:@"email"];
    [UserDefaults removeObjectForKey:@"name"];
    [UserDefaults removeObjectForKey:@"password"];
    [UserDefaults removeObjectForKey:@"date_of_birth"];
    [UserDefaults removeObjectForKey:@"phone_number"];
    [UserDefaults removeObjectForKey:@"gender"];
    [UserDefaults removeObjectForKey:@"id"];
    [UserDefaults removeObjectForKey:@"profile_url"];
    [UserDefaults removeObjectForKey:kIsCameraDurationAlertShown];
    [UserDefaults synchronize];
}

+ (BOOL)isValidEmail:(NSString *)checkString
{
    BOOL stricterFilter = YES;
    NSString *stricterFilterString = @"[A-Z0-9a-z\\._%+-]+@([A-Za-z0-9-]+\\.)+[A-Za-z]{2,4}";
    NSString *laxString = @".+@([A-Za-z0-9]+\\.)+[A-Za-z]{2}[A-Za-z]*";
    NSString *emailRegex = stricterFilter ? stricterFilterString : laxString;
    NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegex];
    return [emailTest evaluateWithObject:checkString];
}

@end
