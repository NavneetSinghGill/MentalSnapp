//
//  S3Manager.m
//  MentalSnapp
//
//  Created by Systango on 22/12/16.
//  Copyright © 2016 Systango. All rights reserved.
//

#import "S3Manager.h"
#import <AWSS3/AWSS3.h>
#import <AVFoundation/AVFoundation.h>
#import <AssetsLibrary/AssetsLibrary.h>
#import <Photos/Photos.h>

@interface S3Manager()
{
    completionBlock downloadCompletionBlock;
}
@property (nonatomic, strong) UIProgressView *mediaUploadProgressBarView;
@property (nonatomic, strong) UILabel *progressBarLabel;
@property (nonatomic, strong) NSURL *fileURL;
@property (nonatomic, strong) NSString * s3Key;
@property (nonatomic, assign) UploadFileType fileType;
@property (nonnull, strong) NSNumber *contentLength;
@property (nonatomic, assign) AWSS3TransferManager *transferDownloadManager;

@end

@implementation S3Manager

- (id)initWithFileURL:(NSURL *)fileURL s3Key:(NSString *)s3Key mediaUploadProgressBarView:(UIProgressView *)mediaUploadProgressBarView progressBarLabel:(UILabel *)progressBarLabel fileType:(UploadFileType)fileType contentLength:(NSNumber *)contentLength
{
    self = [super init];
    if(self)
    {
        _fileURL = fileURL;
        _s3Key = s3Key;
        _mediaUploadProgressBarView = mediaUploadProgressBarView;
        _fileType = fileType;
        _progressBarLabel = progressBarLabel;
        _contentLength = contentLength;
    }
    
    return self;
}

- (void)uploadFileToS3CompletionBlock:(completionBlock)block
{
    AppSettings *appSettings = [AppSettingsManager sharedInstance].appSettings;
    
    AWSS3TransferManagerUploadRequest *uploadRequest = [AWSS3TransferManagerUploadRequest new];
    
    NSString *bucketName = kEmptyString;
    
    if (self.fileType == VideoFileType)
    {
        bucketName = ([appSettings.NetworkMode isEqualToString:kLiveEnviroment]) ? kLiveVideoBucket : kStagingVideoBucket;
    }
    else if (self.fileType == VideoThumbnailImageType)
    {
        bucketName = ([appSettings.NetworkMode isEqualToString:kLiveEnviroment]) ? kLiveVideoThumbnailImageBucket : kStagingVideoThumbnailImageBucket;
    }
    else if (self.fileType == ImageProfile)
    {
        bucketName = ([appSettings.NetworkMode isEqualToString:kLiveEnviroment]) ? kLiveProfileImageBucket : kStagingProfileImageBucket;
    }
    
    uploadRequest.key = self.s3Key;
    uploadRequest.body = self.fileURL;
    uploadRequest.bucket = bucketName;
    uploadRequest.contentLength = self.contentLength;
    uploadRequest.ACL = AWSS3ObjectCannedACLPublicRead;
    
    [[SMobiLogger sharedInterface] info:@"Started uploading file to S3." withDescription:[NSString stringWithFormat:@"At: %s, \n(URL: %@). \n  \n", __FUNCTION__, [NSString stringWithFormat:@"%@/%@", uploadRequest.bucket, uploadRequest.key]]];
    
    __unsafe_unretained typeof(self) weakSelf = self;
    
    uploadRequest.uploadProgress =  ^(int64_t bytesSent, int64_t totalBytesSent, int64_t totalBytesExpectedToSend){
        dispatch_async(dispatch_get_main_queue(), ^{
            //Update progress.
            [weakSelf uploadProgress:totalBytesSent totalBytesExpectedToSend:totalBytesExpectedToSend];
        });
    };
    
    [self.mediaUploadProgressBarView setProgress:0];
    
    AWSS3TransferManager *transferManager = [AWSS3TransferManager defaultS3TransferManager];
    
    
    [[transferManager upload:uploadRequest] continueWithExecutor:[AWSExecutor mainThreadExecutor]
                                                       withBlock:^id(AWSTask *task) {
                                                           if (task.error)
                                                           {
                                                               if ([task.error.domain isEqualToString:AWSS3TransferManagerErrorDomain]) {
                                                                   switch (task.error.code) {
                                                                       case AWSS3TransferManagerErrorCancelled:
                                                                       case AWSS3TransferManagerErrorPaused:
                                                                           break;
                                                                           
                                                                       default:
                                                                           [[SMobiLogger sharedInterface] error:@"Failed uploading file to S3." withDescription:[NSString stringWithFormat:@"At: %s, \n(URL: %@) \n[Error: %@]. \n  \n", __FUNCTION__, [NSString stringWithFormat:@"%@/%@", uploadRequest.bucket, uploadRequest.key], task.error]];
                                                                           NSLog([NSString stringWithFormat:@"Error: %@", task.error ]);
                                                                           break;
                                                                   }
                                                               } else {
                                                                   // Unknown error.
                                                                   NSLog([NSString stringWithFormat:@"Error: %@", task.error ]);
                                                                   
                                                                   [[SMobiLogger sharedInterface] error:@"Failed uploading file to S3." withDescription:[NSString stringWithFormat:@"At: %s, \n(URL: %@) \n[Error: %@]. \n  \n", __FUNCTION__, [NSString stringWithFormat:@"%@/%@", uploadRequest.bucket, uploadRequest.key], task.error]];
                                                               }
                                                               
                                                               block (NO, nil);
                                                               return nil;
                                                           }
                                                           else if (task.result)
                                                           {
                                                               NSLog(@"Upload completed");
                                                               self.progressBarLabel.hidden = YES;
                                                               //self.mediaUploadProgressBarView.hidden = YES;
                                                           }
                                                           
                                                           [[SMobiLogger sharedInterface] info:@"Successfully uploaded file to S3." withDescription:[NSString stringWithFormat:@"At: %s, \n(URL: %@). \n  \n", __FUNCTION__, [NSString stringWithFormat:@"%@/%@", uploadRequest.bucket, uploadRequest.key]]];
                                                           
                                                           block (YES, uploadRequest.key);
                                                           
                                                           return nil;
                                                       }];
    
}


- (void)downloadFileToS3CompletionBlock:(completionBlock)block
{
    downloadCompletionBlock  = block;
    AppSettings *appSettings = [AppSettingsManager sharedInstance].appSettings;
    
    AWSS3TransferManagerDownloadRequest *downloadRequest = [AWSS3TransferManagerDownloadRequest new];
    
    NSString *bucketName = kEmptyString;
    
    if (self.fileType == VideoFileType)
    {
        bucketName = ([appSettings.NetworkMode isEqualToString:kLiveEnviroment]) ? kLiveVideoBucket : kStagingVideoBucket;
    }
    else if (self.fileType == VideoThumbnailImageType)
    {
        bucketName = ([appSettings.NetworkMode isEqualToString:kLiveEnviroment]) ? kLiveVideoThumbnailImageBucket : kStagingVideoThumbnailImageBucket;
    }
    else if (self.fileType == ImageProfile)
    {
        bucketName = ([appSettings.NetworkMode isEqualToString:kLiveEnviroment]) ? kLiveProfileImageBucket : kStagingProfileImageBucket;
    }
    
    downloadRequest.key = self.s3Key;
    downloadRequest.bucket = bucketName;
    
    [[SMobiLogger sharedInterface] info:@"Started Dowloading file to S3." withDescription:[NSString stringWithFormat:@"At: %s, \n(URL: %@). \n  \n", __FUNCTION__, [NSString stringWithFormat:@"%@/%@", downloadRequest.bucket, downloadRequest.key]]];
    
    __unsafe_unretained typeof(self) weakSelf = self;
    
    downloadRequest.downloadProgress =  ^(int64_t bytesSent, int64_t totalBytesSent, int64_t totalBytesExpectedToSend){
        dispatch_async(dispatch_get_main_queue(), ^{
            //Update progress.
            [weakSelf uploadProgress:totalBytesSent totalBytesExpectedToSend:totalBytesExpectedToSend];
        });
    };
    
    [self.mediaUploadProgressBarView setProgress:0];
    
    _transferDownloadManager = [AWSS3TransferManager defaultS3TransferManager];
    
    [[_transferDownloadManager download:downloadRequest] continueWithExecutor:[AWSExecutor mainThreadExecutor]
                                                           withBlock:^id(AWSTask *task) {
                                                               if (task.error)
                                                               {
                                                                   if ([task.error.domain isEqualToString:AWSS3TransferManagerErrorDomain]) {
                                                                       switch (task.error.code) {
                                                                           case AWSS3TransferManagerErrorCancelled:
                                                                           case AWSS3TransferManagerErrorPaused:
                                                                               break;
                                                                               
                                                                           default:
                                                                               [[SMobiLogger sharedInterface] error:@"Failed Dowloading file to S3." withDescription:[NSString stringWithFormat:@"At: %s, \n(URL: %@) \n[Error: %@]. \n  \n", __FUNCTION__, [NSString stringWithFormat:@"%@/%@", downloadRequest.bucket, downloadRequest.key], task.error]];
                                                                               NSLog([NSString stringWithFormat:@"Error: %@", task.error ]);
                                                                               break;
                                                                       }
                                                                   } else {
                                                                       // Unknown error.
                                                                       NSLog([NSString stringWithFormat:@"Error: %@", task.error ]);
                                                                       
                                                                       [[SMobiLogger sharedInterface] error:@"Failed Dowloading file to S3." withDescription:[NSString stringWithFormat:@"At: %s, \n(URL: %@) \n[Error: %@]. \n  \n", __FUNCTION__, [NSString stringWithFormat:@"%@/%@", downloadRequest.bucket, downloadRequest.key], task.error]];
                                                                   }
                                                                   
                                                                   block (NO, nil);
                                                                   return nil;
                                                               }
                                                               else if (task.result)
                                                               {
                                                                   NSLog(@"Dowloading completed");
                                                                   self.progressBarLabel.hidden = YES;
                                                                   //self.mediaUploadProgressBarView.hidden = YES;
                                                               }
                                                               
                                                               [[SMobiLogger sharedInterface] info:@"Successfully Dowloading file to S3." withDescription:[NSString stringWithFormat:@"At: %s, \n(URL: %@). \n  \n", __FUNCTION__, [NSString stringWithFormat:@"%@/%@", downloadRequest.bucket, downloadRequest.key]]];
                                                               
                                                               if(task.result){
                                                                   [self saveVideoInLibraray: task.result withCompletionBlock:block];
                                                               }
                                                               return nil;
                                                           }];
}

-(void)cancelAllDownloads{
    [_transferDownloadManager cancelAll];
}
-(void)pauseAllDownloads{
    [_transferDownloadManager pauseAll];
}
-(void)resumeAllDownloads{
    [_transferDownloadManager resumeAll:^(AWSRequest *request) {
        if(request){
            downloadCompletionBlock(NO,nil);
        }
    }];
}

-(uint64_t)getFreeDiskspace {
    uint64_t totalSpace = 0;
    uint64_t totalFreeSpace = 0;
    NSError *error = nil;
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSDictionary *dictionary = [[NSFileManager defaultManager] attributesOfFileSystemForPath:[paths lastObject] error: &error];
    
    if (dictionary) {
        NSNumber *fileSystemSizeInBytes = [dictionary objectForKey: NSFileSystemSize];
        NSNumber *freeFileSystemSizeInBytes = [dictionary objectForKey:NSFileSystemFreeSize];
        totalSpace = [fileSystemSizeInBytes unsignedLongLongValue];
        totalFreeSpace = [freeFileSystemSizeInBytes unsignedLongLongValue];
        NSLog(@"Memory Capacity of %llu MiB with %llu MiB Free memory available.", ((totalSpace/1024ll)/1024ll), ((totalFreeSpace/1024ll)/1024ll));
    } else {
        NSLog(@"Error Obtaining System Memory Info: Domain = %@, Code = %ld", [error domain], (long)[error code]);
    }
    
    return totalFreeSpace;
}

-(void)saveVideoInLibraray:(AWSS3TransferManagerDownloadOutput *)output withCompletionBlock:(completionBlock)block {
    __block NSURL *videoPath = output.body;
    if([self getFreeDiskspace]<[output.contentLength floatValue]){
         block (NO, @"##Memory#");
        [Banner showFailureBannerWithSubtitle:@"Failed to save due to low memory. Please remove some data and try again."];
        [[SMobiLogger sharedInterface] error:@"Could not save movie to camera roll." withDescription:[NSString stringWithFormat:@"At: %s, \n(File name: %@ With Error: Memory full). \n  \n", __FUNCTION__, videoPath]];
        return;
    }
    
    [[PHPhotoLibrary sharedPhotoLibrary] performChanges:^ {
        [PHAssetChangeRequest creationRequestForAssetFromVideoAtFileURL:videoPath];
        
    } completionHandler:^(BOOL success, NSError *error) {
        block (success, nil);
        if (success) {
            
            [[SMobiLogger sharedInterface] info:@"Successfully saved to camera roll." withDescription:[NSString stringWithFormat:@"At: %s, \n(File name: %@). \n  \n", __FUNCTION__, videoPath]];
            NSLog(@"Movie saved to camera roll.");
        }
        else {
            [[SMobiLogger sharedInterface] error:@"Could not save movie to camera roll." withDescription:[NSString stringWithFormat:@"At: %s, \n(File name: %@ With Error:%@). \n  \n", __FUNCTION__, videoPath, error]];
            NSLog(@"Could not save movie to camera roll. Error: %@", error);
            
            [Banner showFailureBannerWithSubtitle:@"Failed to save in library"];
        }
    }];
}

- (void)uploadProgress:(int64_t)totalBytesSent totalBytesExpectedToSend:(int64_t)totalBytesExpectedToSend {
    self.progressBarLabel.text = [NSString stringWithFormat:@"%.0f%%", ((float)totalBytesSent/(float)totalBytesExpectedToSend)*100];
    [self.mediaUploadProgressBarView setProgress:((float)totalBytesSent/(float)totalBytesExpectedToSend) animated:YES];
    
    NSLog([NSString stringWithFormat:@"Progress: %f", ((float)totalBytesSent/(float)totalBytesExpectedToSend)])
}

-(void) deleteObjectFromS3 {
    AWSS3 *s3 = [AWSS3 defaultS3];
    AWSS3DeleteObjectRequest *deleteRequest = [AWSS3DeleteObjectRequest new];
    
    AppSettings *appSettings = [AppSettingsManager sharedInstance].appSettings;
    NSString *bucketName = kEmptyString;
    
    if (self.fileType == VideoFileType)
    {
        bucketName = ([appSettings.NetworkMode isEqualToString:kLiveEnviroment]) ? kLiveVideoBucket : kStagingVideoBucket;
    }
    else if (self.fileType == VideoThumbnailImageType)
    {
        bucketName = ([appSettings.NetworkMode isEqualToString:kLiveEnviroment]) ? kLiveVideoThumbnailImageBucket : kStagingVideoThumbnailImageBucket;
    }
    else if (self.fileType == ImageProfile)
    {
        bucketName = ([appSettings.NetworkMode isEqualToString:kLiveEnviroment]) ? kLiveProfileImageBucket : kStagingProfileImageBucket;
    }
    
    deleteRequest.bucket = bucketName;
    deleteRequest.key = self.s3Key;
    [[s3 deleteObject:deleteRequest] continueWithBlock:^id(AWSTask *task) {
        if(task.error != nil){
            if(task.error.code != AWSS3TransferManagerErrorCancelled && task.error.code != AWSS3TransferManagerErrorPaused){
                NSLog(@"%s Error: [%@]",__PRETTY_FUNCTION__, task.error);
            }
        }else{
            // Completed logic here
        }
        return nil;
    }];
}

@end
