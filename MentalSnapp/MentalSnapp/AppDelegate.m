//
//  AppDelegate.m
//  Skeleton
//
//  Created by Systango on 25/05/16.
//  Copyright © 2016 Systango. All rights reserved.
//

#import "AppDelegate.h"
#import "TutorialPageViewController.h"
#import <AWSCore/AWSCore.h>
#import <Crittercism/Crittercism.h>
#import <Google/Analytics.h>

@interface AppDelegate ()
@property (nonatomic) BOOL isNetworkAvailable;

@end

@implementation AppDelegate

void uncaughtExceptionHandler(NSException *exception) {
    [[SMobiLogger sharedInterface] unCaughtExceptionWithDescription:[NSString stringWithFormat:@"At: %s, \n(Exception: %@ \n \n Stack Symbols: %@). \n  \n", __FUNCTION__, [exception description], [exception callStackSymbols]]];
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    NSSetUncaughtExceptionHandler(&uncaughtExceptionHandler);
    AppSettings *appSettings = [[AppSettingsManager sharedInstance] fetchSettings];
    [[UIApplication sharedApplication] clearBadgeNumbers];

    if(appSettings.EnableCoreData)
    {
        // Setup CoreData with MagicalRecord
        [MagicalRecord setupCoreDataStackWithStoreNamed:@"Skeleton"];
    }
    
  //Add crittercism and apteligent
    [Crittercism enableWithAppID:[self appteligentAppId]];
    
    //Google analytics
    id<GAITracker> tracker = [[GAI sharedInstance] trackerWithTrackingId:@"UA-54478999-2"];

//    if(appSettings.EnableFlurry)
//    {
//        //init Flurry
//        [Flurry startSession:@"YVV32ZQDD6V64NP45PVY"];
//    }
//
    [self setupNetworkMonitoring];
    
    [self setUpAmazonS3];
    
    // iOS8 or plus
    if ([application respondsToSelector:@selector(registerUserNotificationSettings:)])
    {
        UIUserNotificationSettings *settings = [UIUserNotificationSettings settingsForTypes:(UIUserNotificationTypeBadge|UIUserNotificationTypeAlert|UIUserNotificationTypeSound) categories:nil];
        [application registerUserNotificationSettings:settings];
    }
    
    // Handle launching from a notification
    UILocalNotification *locationNotification = [launchOptions objectForKey:UIApplicationLaunchOptionsLocalNotificationKey];
    if (locationNotification) {
        [self processLocalNotification:locationNotification application:application];
    }

    if ([UserDefaults boolForKey:kIsUserLoggedIn]) {
        [[UserManager sharedManager] setValueInLoggedInUserObjectFromUserDefault];
        self.tabBarController = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"MainTabController"];
        ApplicationDelegate.window.rootViewController = self.tabBarController;
        [[ScheduleManager sharedInstance] fetchAllSchedules];
    }
    else if (![UserDefaults boolForKey:kIsTutorialShownBefore])
    {
        [[UserManager sharedManager] showTutorialScreen:YES];
    }
    
    [Crittercism setUsername:([UserDefaults boolForKey:kIsUserLoggedIn])?[UserManager sharedManager].userModel.userName:@""];
    
    return YES;
}

- (NSString *)appteligentAppId
{
    AppSettings *appSettings = [[AppSettingsManager sharedInstance] appSettings];
    
    if ([appSettings.NetworkMode isEqualToString:kLiveEnviroment]) // for live machine
    {
        return [NSString stringWithFormat:@"%@", appSettings.ProductionApteligentKey];
    }
    else if([appSettings.NetworkMode isEqualToString:kStagingEnviroment]) // for staging env
    {
        return [NSString stringWithFormat:@"%@", appSettings.StagingApteligentKey];
    }
    else // for local env
    {
        return [NSString stringWithFormat:@"%@", appSettings.StagingApteligentKey];
    }
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    [[UIApplication sharedApplication] clearBadgeNumbers];

}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    if([UserDefaults boolForKey:kIsUserLoggedIn]){
        [[UserManager sharedManager] setValueInLoggedInUserObjectFromUserDefault];
    }
    
    [[SMobiLogger sharedInterface] startMobiLogger];
    
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    // Saves changes in the application's managed object context before the application terminates.
    AppSettings *appSettings = [[AppSettingsManager sharedInstance] appSettings];
    if(appSettings.EnableCoreData)
    {
        [[NSManagedObjectContext MR_defaultContext] MR_saveToPersistentStoreWithCompletion:nil];
    }
}

- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url
  sourceApplication:(NSString *)sourceApplication annotation:(id)annotation
{    
    return YES;   
}

-(void)application:(UIApplication *)application didReceiveLocalNotification:(UILocalNotification *)notification
{
    [self processLocalNotification:notification application:application];
}

#pragma mark - Private Methods

- (void)processLocalNotification:(UILocalNotification *)notification application:(UIApplication *)application
{
    if([notification.userInfo hasValueForKey:@"schedule"])
    {
        NSDictionary *scheduleInfo = [notification.userInfo valueForKey:@"schedule"];
        [[SMobiLogger sharedInterface] info:@"Received Local Notification" withDescription:[NSString stringWithFormat:@"%@", scheduleInfo]];
        
        ScheduleModel *schedule = [[ScheduleModel alloc] initWithDictionary:scheduleInfo error:nil];
        
        [[ScheduleManager sharedInstance] didReceiveScheduleNotification:schedule withState:application.applicationState];
    }
    
    // Set icon badge number to zero
    application.applicationIconBadgeNumber = 0;
}

- (void)setUpAmazonS3
{
    // Initialize the Amazon Cognito credentials provider
    
    AWSCognitoCredentialsProvider *credentialsProvider = [[AWSCognitoCredentialsProvider alloc]
                                                          initWithRegionType:AWSRegionEUWest1
                                                          identityPoolId:@"eu-west-1:3361fea2-28fb-4b73-b82e-3f50f8c25bed"];
    
    AWSServiceConfiguration *configuration = [[AWSServiceConfiguration alloc] initWithRegion:AWSRegionEUWest1 credentialsProvider:credentialsProvider];
    
    [AWSServiceManager defaultServiceManager].defaultServiceConfiguration = configuration;
}

#pragma mark - 

#pragma mark - AFNetworking methods
    
-(void)setupNetworkMonitoring {
    self.isNetworkAvailable = YES;
    [[AFNetworkReachabilityManager sharedManager] setReachabilityStatusChangeBlock:^(AFNetworkReachabilityStatus status) {
        switch (status) {
            case AFNetworkReachabilityStatusReachableViaWWAN:
            case AFNetworkReachabilityStatusReachableViaWiFi:
            self.isNetworkAvailable = YES;
            // Save response in MobiLogger
            [[SMobiLogger sharedInterface] info:@"Network:" withDescription:@"ON"];
            break;
            
            case AFNetworkReachabilityStatusNotReachable:
            default:
            self.isNetworkAvailable = NO;
            // Save response in MobiLogger
            [[SMobiLogger sharedInterface] info:@"Network:" withDescription:@"OFF"];
            break;
        }
    }];
    
    [[AFNetworkReachabilityManager sharedManager] startMonitoring];
}
    
- (BOOL)hasNetworkAvailable {

    [[SMobiLogger sharedInterface] info:[NSString stringWithFormat:@"%s", __FUNCTION__] withDescription:[NSString stringWithFormat:@"Info: isNetworkAvailable: %@", self.isNetworkAvailable?@"ON":@"OFF"]];
        if (!self.isNetworkAvailable) {
            dispatch_async(dispatch_get_main_queue(), ^{
                 [Banner showNetworkFailureBanner];
           });
        }
        return self.isNetworkAvailable;
}
    
@end
