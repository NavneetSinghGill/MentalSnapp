//
//  RealAPI.m
//  Skeleton
//
//  Created by Systango on 14/08/15.
//  Copyright © 2016 Systango. All rights reserved.
//

#import "RealAPI.h"
#import "APIInteractor.h"
#import "Request.h"
#import "NetworkHttpClient.h"

@interface RealAPI () <APIInteractor>  {
    BOOL isForbiddenRetry;
    Request *VMRequest;
    completionBlock realAPIBlock;
}

@end

@implementation RealAPI

#pragma mark - User
    
- (void)editUserWithRequest:(Request *)request andCompletionBlock:(completionBlock)block {
    [self patchObject:request withCompletionBlock:block];
}

- (void)changePasswordWithRequest:(Request *)request andCompletionBlock:(completionBlock)block {
    [self putObject:request withCompletionBlock:block];
}

- (void)getUserDetailWithRequest:(Request *)request andCompletionBlock:(completionBlock)block {
    [self interactAPIWithGetObject:request withCompletionBlock:block];
}

- (void)userDeactivateWithRequest:(Request *)request andCompletionBlock:(completionBlock)block {
    [self putObject:request withCompletionBlock:block];
}
- (void)userLogoutWithRequest:(Request *)request andCompletionBlock:(completionBlock)block {
    [self getObject:request withCompletionBlock:block];
}

#pragma mark - Support
- (void)sendSupportRequest:(Request *)request andCompletionBlock:(completionBlock)block {
    [self interactAPIWithTwoMultipartFormRequestWithObject:request withCompletionBlock:block];
}

#pragma mark - Guided Excercise
- (void)getGuidedExcerciseWithRequest:(Request *)request andCompletionBlock:(completionBlock)block {
      [self getObject:request withCompletionBlock:block];
}
- (void)getSubCategoryExcerciseWithRequest:(Request *)request andCompletionBlock:(completionBlock)block {
     [self getObject:request withCompletionBlock:block];
}
- (void)getSubCategoryQuestionsExcerciseWithRequest:(Request *)request andCompletionBlock:(completionBlock)block {
    [self getObject:request withCompletionBlock:block];
}

#pragma mark - Record post data
- (void)getRecordPostsWithRequest:(Request *)request andCompletionBlock:(completionBlock)block{
    [self getObject:request withCompletionBlock:block];
}

- (void)postRecordPostWithRequest:(Request *)request andCompletionBlock:(completionBlock)block {
    [self postObject:request withCompletionBlock:block];
}

- (void)deleteRecordPostWithRequest:(Request *)request andCompletionBlock:(completionBlock)block {
    [self deleteObject:request withCompletionBlock:block];
}

#pragma mark - Feeling data
- (void)getFeelingWithRequest:(Request *)request andCompletionBlock:(completionBlock)block {
    [self getObject:request withCompletionBlock:block];
}

#pragma mark - Filter data
- (void)getFiltersWithRequest:(Request *)request andCompletionBlock:(completionBlock)block
{
    [self getObject:request withCompletionBlock:block];
}

#pragma mark - Schedule data
- (void)getSchedulesWithRequest:(Request *)request andCompletionBlock:(completionBlock)block
{
    [self getObject:request withCompletionBlock:block];
}

- (void)deleteScheduleWithRequest:(Request *)request andCompletionBlock:(completionBlock)block
{
    [self deleteObject:request withCompletionBlock:block];
}

- (void)patchScheduleWithRequest:(Request *)request andCompletionBlock:(completionBlock)block
{
    [self patchObject:request withCompletionBlock:block];
}

- (void)postScheduleWithRequest:(Request *)request andCompletionBlock:(completionBlock)block
{
    [self postObject:request withCompletionBlock:block];
}

#pragma mark - Stats data
- (void)getStatsWithRequest:(Request *)request andCompletionBlock:(completionBlock)block
{
    [self getObject:request withCompletionBlock:block];
}

#pragma mark - Login

- (void)loginWithRequest:(Request *)request andCompletionBlock:(completionBlock)block {
    [self postObject:request withCompletionBlock:block];
}

- (void)signUpWithRequest:(Request *)request andCompletionBlock:(completionBlock)block {
    [self postObject:request withCompletionBlock:block];
}

- (void)forgotPasswordWithRequest:(Request *)request andCompletionBlock:(completionBlock)block {
    [self getObject:request withCompletionBlock:block];
}

#pragma mark -

- (void)putObject:(Request *)request withCompletionBlock:(completionBlock)block {
    [self interactAPIWithPutObject:request withCompletionBlock:block];
}

- (void)patchObject:(Request *)request withCompletionBlock:(completionBlock)block {
    [self interactAPIWithPatchObject:request withCompletionBlock:block];
}

- (void)getObject:(Request *)request withCompletionBlock:(completionBlock)block {
    [self interactAPIWithGetObject:request withCompletionBlock:block];
}

- (void)postObject:(Request *)request withCompletionBlock:(completionBlock)block {
    [self interactAPIWithPostObject:request withCompletionBlock:block];
}

- (void)deleteObject:(Request *)request withCompletionBlock:(completionBlock)block {
    [self interactAPIWithDeleteObject:request withCompletionBlock:block];
}

- (void)multiPartObjectPost:(Request *)request withCompletionBlock:(completionBlock)block {
    [self interactAPIWithMultipartFormRequestWithObject:request withCompletionBlock:block];
}

- (void)multiPartObjectPut:(Request *)request withCompletionBlock:(completionBlock)block {
    [self interactAPIWithMultipartFormRequestWithPutObject:request withCompletionBlock:block];
}

#pragma mark - Request methods

- (void)interactAPIWithGetObject:(Request *)getObject  withCompletionBlock:(completionBlock)block {
    [self initialSetupWithRequest:getObject requestType:RequestGET];
    [[NetworkHttpClient sharedInstance] getAPICallWithUrl:getObject.urlPath parameters:getObject.getParams successBlock:^(NSURLSessionDataTask *task, id responseObject) {
        [self handleSuccessResponse:task response:responseObject withBlock:block];
    } failureBlock:^(NSURLSessionDataTask *task, NSError *error) {
        [self handleError:error operation:task withBlock:block];
    }];
}

- (void)interactAPIWithPatchObject:(Request *)postObject withCompletionBlock:(completionBlock)block {
    [self initialSetupWithRequest:postObject requestType:RequestPATCH];
    [[NetworkHttpClient sharedInstance] patchAPICallWithUrl:postObject.urlPath parameters:postObject.getParams successBlock:^(NSURLSessionDataTask *task, id responseObject) {
        [self handleSuccessResponse:task response:responseObject withBlock:block];
    } failureBlock:^(NSURLSessionDataTask *task, NSError *error) {
        [self handleError:error operation:task withBlock:block];
    }];
}

- (void)interactAPIWithPostObject:(Request *)postObject withCompletionBlock:(completionBlock)block {
    [self initialSetupWithRequest:postObject requestType:RequestPOST];
    [[NetworkHttpClient sharedInstance] postAPICallWithUrl:postObject.urlPath parameters:postObject.getParams successBlock:^(NSURLSessionDataTask *task, id responseObject) {
        [self handleSuccessResponse:task response:responseObject withBlock:block];
    } failureBlock:^(NSURLSessionDataTask *task, NSError *error) {
        [self handleError:error operation:task withBlock:block];
    }];
}

- (void)interactAPIWithPutObject:(Request *)putObject withCompletionBlock:(completionBlock)block {
    [self initialSetupWithRequest:putObject requestType:RequestPUT];
    [[NetworkHttpClient sharedInstance] putAPICallWithUrl:putObject.urlPath parameters:putObject.getParams successBlock:^(NSURLSessionDataTask *task, id responseObject) {
        [self handleSuccessResponse:task response:responseObject withBlock:block];
    } failureBlock:^(NSURLSessionDataTask *task, NSError *error) {
        [self handleError:error operation:task withBlock:block];
    }];
}

- (void)interactAPIWithDeleteObject:(Request *)deleteObject withCompletionBlock:(completionBlock)block {
    [self initialSetupWithRequest:deleteObject requestType:RequestDELETE];
    [[NetworkHttpClient sharedInstance] deleteAPICallWithUrl:deleteObject.urlPath parameters:deleteObject.getParams successBlock:^(NSURLSessionDataTask *task, id responseObject) {
        [self handleSuccessResponse:task response:responseObject withBlock:block];
    } failureBlock:^(NSURLSessionDataTask *task, NSError *error) {
        [self handleError:error operation:task withBlock:block];
    }];
}

- (void)interactAPIWithMultipartFormRequestWithObject:(Request *)object withCompletionBlock:(completionBlock)block {
    [self initialSetupWithRequest:object requestType:RequestMutiPartPost];
    [[NetworkHttpClient sharedInstance] multipartApiCallWithUrl:object.urlPath parameters:object.getParams data:object.fileData name:object.dataFilename fileName:object.fileName mimeType:object.mimeType successBlock:^(NSURLSessionDataTask *task, id responseObject) {
        [self handleSuccessResponse:task response:responseObject withBlock:block];
    } failureBlock:^(NSURLSessionDataTask *task, NSError *error) {
        [self handleError:error operation:task withBlock:block];
    }];
}

- (void)interactAPIWithTwoMultipartFormRequestWithObject:(Request *)object withCompletionBlock:(completionBlock)block {
    [self initialSetupWithRequest:object requestType:RequestMutiPartPost];
    [[NetworkHttpClient sharedInstance] multipartObjectApiCallWithUrl:object.urlPath parameters:object.getParams withObject:object successBlock:^(NSURLSessionDataTask *task, id responseObject) {
        [self handleSuccessResponse:task response:responseObject withBlock:block];
    } failureBlock:^(NSURLSessionDataTask *task, NSError *error) {
        [self handleError:error operation:task withBlock:block];
    }];
}

- (void)interactAPIWithMultipartFormRequestWithPutObject:(Request *)object withCompletionBlock:(completionBlock)block {
    [self initialSetupWithRequest:object requestType:RequestMutiPartPost];
}

#pragma mark - Private methods

//Handling success response
- (void)handleSuccessResponse:(NSURLSessionDataTask *)task response:(id)responseObject withBlock:(completionBlock)block {
    
    NSHTTPURLResponse *responseStatus = (NSHTTPURLResponse *)task.response;
    
    NSString *message = [NSString stringWithFormat:@"Success:- URL:%@\n response::%@", task.currentRequest.URL, responseObject];
    NSLog(message);
    [[SMobiLogger sharedInterface] info:[NSString stringWithFormat:@"%s", __FUNCTION__] withDescription:message];
    
    if(responseStatus.statusCode == kResponseStatusSuccess || responseStatus.statusCode == kResponseStatusCreated) {
        if (responseObject)
        {
            isForbiddenRetry = NO;
            block(YES, responseObject);
            return;
        }
    }
    
    block(NO, nil);
}

//Handling Error response
- (void)handleError:(NSError *)error operation:(NSURLSessionDataTask *)task withBlock:(completionBlock)block
{
    NSHTTPURLResponse *responseStatus = (NSHTTPURLResponse *)task.response;
    
    if([self isForbiddenResponse:responseStatus.statusCode])
    {
        realAPIBlock = block;
        if([UserDefaults boolForKey:kIsUserLoggedIn]){
            [[UserManager sharedManager] logoutUser];
        }
        block(NO, [NSMutableDictionary dictionaryWithObject:@"Your session expire. Please login again." forKey:@"message"]);
        //[self renewLogin];
        return;
    }
    
    NSDictionary *errorResponse = [NSDictionary dictionary];
    if (error.localizedRecoverySuggestion!=nil)
    {
        NSError *errorData;
        errorResponse = [NSJSONSerialization JSONObjectWithData: [error.localizedRecoverySuggestion dataUsingEncoding:NSUTF8StringEncoding]
                                                        options: NSJSONReadingMutableContainers
                                                          error: &errorData];
        
        NSString *message = [NSString stringWithFormat:@"\n Error :Failure with error: %@", [error localizedRecoverySuggestion]];
        NSLog(message);
        [[SMobiLogger sharedInterface] error:[NSString stringWithFormat:@"%s", __FUNCTION__] withDescription:message];
        
        errorResponse ? block(NO, errorResponse) : block(NO, error);
    }
    else if (error.localizedDescription != nil)
    {

        NSString *message = [NSString stringWithFormat:@"\n Error :Failure with error: %@", [error localizedDescription]];
        NSLog(message);
        [[SMobiLogger sharedInterface] error:[NSString stringWithFormat:@"%s", __FUNCTION__] withDescription:message];
        
        NSLog([NSString stringWithFormat:@"%@",error]);
        NSData *errorData = error.userInfo[AFNetworkingOperationFailingURLResponseDataErrorKey];
        
        NSMutableDictionary *serializedData = nil;
        if (errorData != nil) {
            serializedData = [NSJSONSerialization JSONObjectWithData: errorData options:kNilOptions error:nil];
            if ([serializedData isKindOfClass:[NSMutableDictionary class]] && [serializedData hasValueForKey:@"error"]) {
//                [Banner showFailureBannerWithSubtitle:[serializedData valueForKey:@"error"]];
            }
        } else {
            serializedData = [NSMutableDictionary dictionaryWithObject:([error.localizedDescription containsString:@"request timed"])?@"Low network. Please try again later.":error.localizedDescription forKey:@"message"];
//            [Banner showFailureBannerWithSubtitle:error.localizedDescription];
        }
        serializedData = [serializedData mutableCopy];
        
        message = [NSString stringWithFormat:@"Failure error serialised - %@",serializedData];
        NSLog(message);
        [[SMobiLogger sharedInterface] error:[NSString stringWithFormat:@"%s", __FUNCTION__] withDescription:message];
        
        if (!serializedData) {
            serializedData = [NSMutableDictionary dictionaryWithObject:@"An error occured while processing your request." forKey:@"message"];
//            [Banner showFailureBannerWithSubtitle:@"An error occured while processing your request."];
        }
        NSHTTPURLResponse *responseStatus = (NSHTTPURLResponse *)task.response;
        
        if(responseStatus.statusCode == kResponseStatusForbidden) {
            //*> Show Alert
//            [ApplicationDelegate showAlertWithMessage:@"Your session expire" isLogout:YES];
        }
        
        block(NO, serializedData);
    }
    else
    {
        if([error.localizedDescription containsString:@"request timed"])
        {
            block(NO, @"Low network. Please try again later.");

        } else {
            block(NO, error.description);
        }
    }
    
}

- (void)initialSetupWithRequest:(Request *)request requestType:(NSInteger)requestType {
    VMRequest = request;
    VMRequest.requestType = requestType;
    NSMutableDictionary *dictionary = [[request getParams] mutableCopy];
    if([request.urlPath isEqualToString:kLoginAPI] || [request.urlPath isEqualToString:kSignUpAPI]){
        [dictionary setValue:@"**********" forKey:@"password"];
        [dictionary setValue:@"**********" forKey:@"password_confirmation"];
    }
    NSString *message = [NSString stringWithFormat:@"Info: Performing API call [Request:%@] with [URL:%@] [params: %@]", [request class], request.urlPath, dictionary];
    NSLog(message);
    [[SMobiLogger sharedInterface] info:[NSString stringWithFormat:@"%s", __FUNCTION__] withDescription:message];
}

- (BOOL)isForbiddenResponse:(NSInteger)statusCode
{
    if(statusCode == kResponseStatusForbidden && isForbiddenRetry == NO)
    {
        isForbiddenRetry = YES;
        [[SMobiLogger sharedInterface] error:[NSString stringWithFormat:@"%s", __FUNCTION__] withDescription:@"Error: Renewing session expired"];
        return YES;
    }
    
    return NO;
}

- (void)renewLogin
{
//    [[User sharedUser] resetSharedInstance];
    
    // login with the saved valued
    [self loginWithSavedValues];
}

- (void)loginWithSavedValues
{
//    UserAuth *userAuth = [UserAuth getSavedAuth];
//    if(userAuth)
//    {
//        if((userAuth.facebookId && userAuth.facebookId.length) || (userAuth.password && userAuth.password.length && userAuth.email && userAuth.email.length))
//        {
//            [[RequestManager alloc] loginWithUserAuth:userAuth withCompletionBlock:^(BOOL success, id response) {
//                if (success)
//                {
//                    [[User sharedUser] saveLoggedinUserInfoInUserDefault];
//                    
//                    [[SMobiLogger sharedInterface] info:[NSString stringWithFormat:@"%s", __FUNCTION__] withDescription:@"Info: Successfully able to loggedin with stored user's auth, performing last saved API call"];
//                    
//                    // Triger last saved API call
//                    [self renewLoginRequestCompleted];
//                }
//                else
//                {
//                    [[SMobiLogger sharedInterface] error:[NSString stringWithFormat:@"%s", __FUNCTION__] withDescription:@"Error: Not able to loggedin with stored user's auth, application is going to logout"];
//                    
//                    realAPIBlock(NO, nil);
//                }
//            }];
//            
//            return;
//        }
//    }
//    
//    [[SMobiLogger sharedInterface] error:[NSString stringWithFormat:@"%s", __FUNCTION__] withDescription:@"Error: No stored user's auth found, application is going to logout"];
//    
//    realAPIBlock(NO, nil);
//    
//    //*> Show Alert
//    [ApplicationDelegate showAlertWithMessage:@"Your session expire" isLogout:YES];
}

- (void)renewLoginRequestCompleted
{
    //calling failed API again
    switch (VMRequest.requestType)
    {
        case RequestGET:{
            [self interactAPIWithGetObject:VMRequest withCompletionBlock:realAPIBlock];
            break;
        }
        case RequestPOST:{
            [self interactAPIWithPostObject:VMRequest withCompletionBlock:realAPIBlock];
            break;
        }
        case RequestPATCH:{
            [self interactAPIWithPatchObject:VMRequest withCompletionBlock:realAPIBlock];
            break;
        }
        case RequestPUT:{
            [self interactAPIWithPutObject:VMRequest withCompletionBlock:realAPIBlock];
            break;
        }
        case RequestMutiPartPost:{
            [self interactAPIWithMultipartFormRequestWithObject:VMRequest withCompletionBlock:realAPIBlock];
            break;
        }
        case RequestDELETE:{
            [self interactAPIWithDeleteObject:VMRequest withCompletionBlock:realAPIBlock];
            break;
        }
    }
}


@end
