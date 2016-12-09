//
//  Util.m
//  Skeleton
//
//  Created by Systango on 31/05/16.
//  Copyright © 2016 Systango. All rights reserved.
//

#import "Util.h"
#import "NSUserDefaults+RMSaveCustomObject.h"

@implementation Util

+ (void)postNotification:(NSString *)name withDict:(NSDictionary *)dict
{
    NSNotification *notif = [NSNotification notificationWithName:name
                                                          object:nil userInfo:dict];
    [[NSNotificationCenter defaultCenter] postNotification:notif];
}

+ (void)saveCustomObject:(id)object toUserDefaultsForKey:(NSString *)key
{
    NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
    [defaults rm_setCustomObject:object forKey:key];
}

+ (id)fetchCustomObjectForKey:(NSString *)key
{
    NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
    return [defaults rm_customObjectForKey:key];
}

+ (BOOL)validatePhone:(NSString *)phoneNumber
{
    NSString *phoneRegex =@"^ [0-9]{4} [0-9]{3,6}$";
    NSPredicate *phoneTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", phoneRegex];
    return [phoneTest evaluateWithObject:phoneNumber];
}

+(BOOL)formatePhoneNumberOftextField:(UITextField *)textField withRange:(NSRange)range ReplacemenString:(NSString *)string
{
    BOOL result = YES;
    BOOL valid;
    NSCharacterSet *alphaNums = [NSCharacterSet decimalDigitCharacterSet];
    NSCharacterSet *inStringSet = [NSCharacterSet characterSetWithCharactersInString:string];
    valid = [alphaNums isSupersetOfSet:inStringSet];
    
    if (string.length != 0) {
        NSMutableString *text = [NSMutableString stringWithString:[[textField.text componentsSeparatedByCharactersInSet:[[NSCharacterSet decimalDigitCharacterSet] invertedSet]] componentsJoinedByString:@""]];
        [text insertString:@" " atIndex:0];
        
        if (text.length > 4)
            [text insertString:@" " atIndex:5];
        
        if (text.length > 11) {
            text = [NSMutableString stringWithString:[text substringToIndex:textField.text.length]];
            result = NO;
        } else {
            textField.text = text;
        }
    }
    
    return result;
}

+(BOOL)isValidEmail:(NSString *)email
{
    BOOL stricterFilter = NO;
    NSString *stricterFilterString = @"^[A-Z0-9a-z\\._%+-]+@([A-Za-z0-9-]+\\.)+[A-Za-z]{2,4}$";
    NSString *laxString = @"^.+@([A-Za-z0-9-]+\\.)+[A-Za-z]{2}[A-Za-z]*$";
    NSString *emailRegex = stricterFilter ? stricterFilterString : laxString;
    NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegex];
    return [emailTest evaluateWithObject:email];
}

+ (void)openCameraView:(id)target {
    if ([UIImagePickerController isSourceTypeAvailable: UIImagePickerControllerSourceTypeCamera]) {
        UIImagePickerController *imgPicker = [[UIImagePickerController alloc] init];
        imgPicker.delegate = target;
        imgPicker.sourceType = UIImagePickerControllerSourceTypeCamera;
        imgPicker.mediaTypes = [NSArray arrayWithObjects:(NSString *)kUTTypeMovie, nil];
        imgPicker.allowsEditing = NO;
        [imgPicker setVideoMaximumDuration:2*60];
        [[ApplicationDelegate window].rootViewController presentViewController:imgPicker animated:YES completion:nil];
    } else {
        [Banner showFailureBannerWithSubtitle:@"Camera not available."];
    }
}

- (UIImage *)didFinishPickingImageFile:(UIImage *)image fileType:(UploadFileType)fileType completionBlock:(completionBlock)block
{
    NSString *deviceToken = [UserDefaults valueForKey:keyDeviceToken];
    if(!deviceToken || deviceToken.length == 0)
        deviceToken = @"Simulator";
    
    NSString *fileName = [NSString stringWithFormat:@"%@_%@.png", [[NSDate date] getMilliSeconds], deviceToken];
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *filePath = [documentsDirectory stringByAppendingPathComponent:fileName];
    
    NSData *imageData = UIImagePNGRepresentation(image);
    [imageData writeToFile:filePath atomically:YES];
    
    NSURL *imageURL = [NSURL fileURLWithPath:filePath];
    
    //*> Getting size
    NSError *attributesError;
    NSDictionary *fileAttributes = [[NSFileManager defaultManager] attributesOfItemAtPath:filePath error:&attributesError];
    NSNumber *fileSizeNumber = [fileAttributes objectForKey:NSFileSize];
    long long fileSize = [fileSizeNumber longLongValue];
    
    S3Manager * s3Manager = [[S3Manager alloc] initWithFileURL:imageURL s3Key:fileName mediaUploadProgressBarView:nil progressBarLabel:nil fileType:fileType contentLength:[NSNumber numberWithUnsignedLongLong:fileSize]];
    [s3Manager uploadFileToS3CompletionBlock:^(BOOL success, id response) {
        block(success, response);
    }];
    
    return image;
}

- (NSData *)didFinishPickingVideoFile:(NSData *)videoData fileType:(UploadFileType)fileType completionBlock:(completionBlock)block
{
    NSString *deviceToken = [UserDefaults valueForKey:keyDeviceToken];
    if(!deviceToken || deviceToken.length == 0)
        deviceToken = @"Simulator";
    
    NSString *fileName = [NSString stringWithFormat:@"%@_%@.mov", [[NSDate date] getMilliSeconds], deviceToken];
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *filePath = [documentsDirectory stringByAppendingPathComponent:fileName];
    
//    NSData *imageData = UIImagePNGRepresentation(image);
    [videoData writeToFile:filePath atomically:YES];
    
    NSURL *videoURL = [NSURL fileURLWithPath:filePath];
    
    //*> Getting size
    NSError *attributesError;
    NSDictionary *fileAttributes = [[NSFileManager defaultManager] attributesOfItemAtPath:filePath error:&attributesError];
    NSNumber *fileSizeNumber = [fileAttributes objectForKey:NSFileSize];
    long long fileSize = [fileSizeNumber longLongValue];
    
    S3Manager * s3Manager = [[S3Manager alloc] initWithFileURL:videoURL s3Key:fileName mediaUploadProgressBarView:nil progressBarLabel:nil fileType:fileType contentLength:[NSNumber numberWithUnsignedLongLong:fileSize]];
    [s3Manager uploadFileToS3CompletionBlock:^(BOOL success, id response) {
        block(success, response);
    }];
    
    return videoData;
}

@end
