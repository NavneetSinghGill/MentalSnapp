//
//  LoginInterface.m
//  Skeleton
//
//  Created by Systango on 18/12/13.
//  Copyright © 2016 Systango. All rights reserved.
//

#import "LoginInterface.h"

@implementation LoginInterface

- (void)loginWithUserRequest:(LoginRequest *)loginRequest andCompletionBlock:(completionBlock)block {
    _block = block;
    id apiInteractorProvider = [[APIInteractorProvider sharedInterface] getAPIInetractor];
    [apiInteractorProvider loginWithRequest:loginRequest andCompletionBlock:^(BOOL success, id response) {
        [self parseLoginResponse:response];
    }];
}

- (void)signUpWithUserRequest:(LoginRequest *)loginRequest andCompletionBlock:(completionBlock)block {
    _block = block;
    id apiInteractorProvider = [[APIInteractorProvider sharedInterface] getAPIInetractor];
    [apiInteractorProvider signUpWithRequest:loginRequest andCompletionBlock:^(BOOL success, id response) {
        [self parseSignUpResponse:response];
    }];
}

- (void)forgotPasswordWithUserRequest:(LoginRequest *)loginRequest andCompletionBlock:(completionBlock)block {
    _block = block;
    id apiInteractorProvider = [[APIInteractorProvider sharedInterface] getAPIInetractor];
    [apiInteractorProvider forgotPasswordWithRequest:loginRequest andCompletionBlock:^(BOOL success, id response) {
        [self parseForgotPasswordResponse:response];
    }];
}

#pragma mark - Parsing methods

- (void)parseLoginResponse:(id)response {
    if ([response isKindOfClass:[NSDictionary class]])
    {
        NSString *success = nil;
        if([(NSDictionary *)response hasValueForKey:@"success"]) {
            success = [response valueForKey:@"success"];
        }
        if ([success integerValue] == kStatusSuccess) {
            if ([response hasValueForKey:@"auth_token"]) {
                [UserManager sharedManager].authorizationToken = [response valueForKey:@"auth_token"];
                [UserManager sharedManager].isFirstTime = NO;
                if ([response hasValueForKey:@"is_first_user"]) {
                    [UserManager sharedManager].isFirstTime = [[response valueForKey:@"is_first_user"] boolValue];
                }
                
                if([response hasValueForKey:@"user"]) {
                    NSError *error;
                    
                    UserModel *user = [[UserModel alloc] initWithDictionary:[response objectForKey:@"user"] error:&error];
                    [UserManager sharedManager].userModel = user;
                    
                    //Analytics
                    [[UserManager sharedManager] sendAnalyticsForGenderAndDOBforUser:user];

                }
                [[UserManager sharedManager] saveLoggedinUserInfoInUserDefault];
                [[ScheduleManager sharedInstance] fetchAllSchedules];
            }
            
            self.block([success integerValue], @"Login successfull");
        } else
        {
            NSString *errorMessage = nil;
            if([response hasValueForKey:@"message"])
            {
                errorMessage = [response valueForKey:@"message"];
            }
            _block([success integerValue], errorMessage);
            [Banner showFailureBannerWithSubtitle:errorMessage];
        }
        
    } else if([response isKindOfClass:[NSError class]]) {
        
        NSString *errorMessage = ((NSError *)response).localizedDescription;
        _block(NO, errorMessage);
    } else {
        _block(NO, @"Something went wrong while processing your request");
    }
}

- (void)parseSignUpResponse:(id)response {
    if ([response isKindOfClass:[NSDictionary class]])
    {
        NSString *success = nil;
        if([(NSDictionary *)response hasValueForKey:@"success"]) {
            success = [response valueForKey:@"success"];
        }
        if ([success integerValue] == kStatusSuccess) {
            if ([response hasValueForKey:@"auth_token"]) {
                [UserManager sharedManager].authorizationToken = [response valueForKey:@"auth_token"];
            }
            if ([response hasValueForKey:@"users"]) {
                UserModel *user = [[UserModel alloc] initWithDictionary:[response valueForKey:@"users"] error:nil];
                [UserManager sharedManager].userModel = user;
                [[UserManager sharedManager] saveLoggedinUserInfoInUserDefault];
                [[ScheduleManager sharedInstance] fetchAllSchedules];
            }
            self.block([success integerValue], @"Signup successfull.");
        } else
        {
            NSString *errorMessage = nil;
            if([response hasValueForKey:@"message"])
            {
                errorMessage = [response valueForKey:@"message"];
            }
            _block([success integerValue], errorMessage);
            [Banner showFailureBannerWithSubtitle:errorMessage];
        }
        
    } else if([response isKindOfClass:[NSError class]]) {
        
        NSString *errorMessage = ((NSError *)response).localizedDescription;
        _block(NO, errorMessage);
    } else {
        _block(NO, @"Something went wrong while processing your request");
    }
}

- (void)parseForgotPasswordResponse:(id)response {
    if ([response isKindOfClass:[NSDictionary class]])
    {
        NSString *success = nil;
        if([(NSDictionary *)response hasValueForKey:@"success"]) {
            success = [response valueForKey:@"success"];
        }
        if ([success integerValue] == kStatusSuccess) {
            
            self.block([success integerValue], @"");
        } else
        {
            NSString *errorMessage = nil;
            if([response hasValueForKey:@"message"])
            {
                errorMessage = [response valueForKey:@"message"];
            }
            
            if([response hasValueForKey:@"error"])
            {
                errorMessage = [response valueForKey:@"error"];
            }
            
            _block([success integerValue], errorMessage);
            [Banner showFailureBannerWithSubtitle:[NSString stringWithFormat:@"Email %@",errorMessage]];
        }
        
    } else if([response isKindOfClass:[NSError class]]) {
        
        NSString *errorMessage = ((NSError *)response).localizedDescription;
        _block(NO, errorMessage);
    } else {
        _block(NO, @"Something went wrong while processing your request");
    }
}

#pragma mark public method

// Session methods
- (NSMutableArray *)getSavedSessionCookies
{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSMutableArray *httpCookies = nil;
    
    httpCookies = [userDefaults objectForKey:kSessionCookies];
    return httpCookies;
}

- (BOOL)setSavedSessionCookies
{
    NSMutableArray *httpCookies = [self getSavedSessionCookies];
    if(httpCookies.count)
    {
        for (NSDictionary* cookieProperties in httpCookies)
        {
            NSHTTPCookie *cookie = [[NSHTTPCookie alloc] initWithProperties:cookieProperties];
            [[NSHTTPCookieStorage sharedHTTPCookieStorage] setCookie:cookie];
        }
        return YES;
    }
    return NO;
}

- (void)saveSessionCookies:(NSString *)urlPath
{
    if([urlPath isEqualToString:@"/api/login"] || [urlPath isEqualToString:@"/api/signup"])
    {
        NSHTTPCookieStorage* cookies = [NSHTTPCookieStorage sharedHTTPCookieStorage];
        
        NSArray *httpCookies = [cookies cookiesForURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@",[NetworkHttpClient sharedInstance].baseURL, urlPath]]];
        NSMutableArray *sessionCookies = [[NSMutableArray alloc]init];
        for (NSHTTPCookie* cookie in httpCookies)
        {
            [sessionCookies addObject:cookie.properties];
        }
        
        if(sessionCookies.count)
        {
            NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
            [userDefaults setObject:sessionCookies forKey:kSessionCookies];
            [userDefaults synchronize];
        }
    }
}

- (void)clearSavedSessionCookies
{
    for (NSHTTPCookie *cookie in [NSHTTPCookieStorage sharedHTTPCookieStorage].cookies) {
        [[NSHTTPCookieStorage sharedHTTPCookieStorage] deleteCookie:cookie];
    }
    
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults removeObjectForKey:kSessionCookies];
    [userDefaults synchronize];
}


@end
