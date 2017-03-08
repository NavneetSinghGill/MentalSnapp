//
//  MoodViewController.m
//  MentalSnapp
//
//  Created by Systango on 08/12/16.
//  Copyright © 2016 Systango. All rights reserved.
//

#import "MoodViewController.h"
#import "EFCircularSlider.h"
#import <AVFoundation/AVFoundation.h>
#import "Feeling.h"
#import "FeelingListViewController.h"
#import "RequestManager.h"
#import "RecordPost.h"

#define PlaceHolderTextView LocalizedString(@"MoodsTextViewPlaceHolder")
#define PlaceHolderColor [UIColor colorWithRed:90.0/255.0 green:90.0/255.0 blue:90.0/255.0 alpha:1.0]
#define DefaultTextViewColor [UIColor colorWithRed:61.0/255.0 green:61.0/255.0 blue:61.0/255.0 alpha:1.0]

@interface MoodViewController () <UITextFieldDelegate, UITextViewDelegate, FeelingListDalegate>
{
    BOOL isUserEditedName;
    MoodType selectedMood;
    Feeling *selectedFeeling;
    CGFloat videoDuration;
}

@property (strong, nonatomic) IBOutlet UIScrollView *scrollView;
@property (strong, nonatomic) IBOutlet UIView *containerView;
@property (strong, nonatomic) IBOutlet UIView *videoNameView;
@property (strong, nonatomic) IBOutlet UITextField *videoNameTextField;
@property (strong, nonatomic) IBOutlet UIView *moodWheelView;
@property (strong, nonatomic) IBOutlet UIView *addFeelingView;
@property (strong, nonatomic) IBOutlet UIButton *addFeelingButton;
@property (strong, nonatomic) IBOutlet UIView *descriptionView;
@property (strong, nonatomic) IBOutlet UITextView *descriptionTextView;
@property (strong, nonatomic) IBOutlet UILabel *moodLabel;
@property (strong, nonatomic) IBOutlet UIView *descptionView;
@property (strong, nonatomic) FeelingListViewController *feelingListViewController;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *feelingViewHeightConstraint;
@property (strong, nonatomic) IBOutlet UILabel *selectedFeelingLabel;
@property (strong, nonatomic) IBOutlet UIButton *feelingColorButton;

@property(nonatomic, strong) NSString *videoURLPath;
@property(nonatomic, strong) NSString *videoThumbnailURLPath;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *lastBorderLabelBottomConstraint;

- (IBAction)addFeelingButtonAction:(id)sender;

@end

@implementation MoodViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self setNavigationBarButtonTitle:@"Mental Snapp"];
    [self setRightMenuButtons:[NSArray arrayWithObjects:[self uploadButton], nil]];
//    [self setLeftMenuButtons:[NSArray arrayWithObjects:[self backButton], nil]];

    self.navigationItem.hidesBackButton = YES;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self addMoodWheel];
        [self populateNameOfVideo];
    });
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillShow:)
                                                 name:UIKeyboardWillShowNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillHide:)
                                                 name:UIKeyboardWillHideNotification
                                               object:nil];
    [self addToolBarForDone];
//[self.scrollView setScrollEnabled:NO];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [ApplicationDelegate.tabBarController setSelectTabIndex:2];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

#pragma mark - Private methods
- (void)populateNameOfVideo {
    if(!isUserEditedName) {
        NSString *formatedVideoName = (selectedMood!=KNone)?((selectedFeeling)?[NSString stringWithFormat:@"%@_%@_%@_%@",[UserManager sharedManager].userModel.userName,selectedFeeling.feelingName,[Util getMoodString:selectedMood],([[NSDate date] stringInUKFormat])]:[NSString stringWithFormat:@"%@_%@_%@",[UserManager sharedManager].userModel.userName,[Util getMoodString:selectedMood],([[NSDate date] stringInUKFormat])]):((selectedFeeling)?[NSString stringWithFormat:@"%@_%@_%@",[UserManager sharedManager].userModel.userName,selectedFeeling.feelingName,([[NSDate date] stringInUKFormat])]:[NSString stringWithFormat:@"%@_%@",[UserManager sharedManager].userModel.userName,([[NSDate date] stringInUKFormat])]);
        [self.videoNameTextField setText:formatedVideoName];
    }
}

- (void)willUploadVideoOnAWS
{
    [self showInProgress:YES];
    if(self.videoURL && self.videoURLPath.length == 0)
    {
        NSString *videoName = self.videoNameTextField.text;
        videoName = [videoName stringByReplacingOccurrencesOfString:@" " withString:@"_"];
        [[[Util alloc] init] didFinishPickingVideoFile:self.videoURL withName:videoName fileType:VideoFileType completionBlock:^(BOOL success, id response)
         {
             NSLog([NSString stringWithFormat:@"response : : %@", response]);
             if(success)
             {
                 AppSettings *appSettings = [AppSettingsManager sharedInstance].appSettings;
                 NSString *bucketName = ([appSettings.NetworkMode isEqualToString:kLiveEnviroment]) ? kLiveVideoBucket : kStagingVideoBucket;
                 self.videoURLPath = [NSString stringWithFormat:@"%@/%@/%@", kAWSPath, bucketName, response];
                 [self didUploadVideoOnAWS];
             }
             else
             {
                 [Banner showFailureBannerWithSubtitle:LocalizedString(@"MoodsVideoUploadFailure")];
                 // handle failure case
                 [self showInProgress:NO];
             }
         }];
    }
    else
    {
        [self didUploadVideoOnAWS];
    }
}

- (void)didUploadVideoOnAWS
{
    AVAsset *asset = [AVAsset assetWithURL:self.videoURL];
    videoDuration = CMTimeGetSeconds(asset.duration);
    AVAssetImageGenerator *imageGenerator = [[AVAssetImageGenerator alloc]initWithAsset:asset];
    CMTime time = CMTimeMake(0, 1);
    CGImageRef imageRef = [imageGenerator copyCGImageAtTime:time actualTime:NULL error:NULL];
    UIImage *thumbnail = [UIImage imageWithCGImage:imageRef];
    
    if(thumbnail && self.videoThumbnailURLPath.length == 0)
    {
        [[[Util alloc] init] didFinishPickingImageFile:thumbnail fileType:VideoThumbnailImageType completionBlock:^(BOOL success, id response)
         {
             NSLog([NSString stringWithFormat:@"response : : %@", response]);
             if(success)
             {
                 AppSettings *appSettings = [AppSettingsManager sharedInstance].appSettings;
                 NSString *bucketName = ([appSettings.NetworkMode isEqualToString:kLiveEnviroment]) ? kLiveVideoThumbnailImageBucket : kStagingVideoThumbnailImageBucket;
                 self.videoThumbnailURLPath = [NSString stringWithFormat:@"%@/%@/%@", kAWSPath, bucketName, response];
                 [self didPerformAPICall];
             }
             else
             {
                 [Banner showFailureBannerWithSubtitle:@"Video's thumbnail could not be uploaded. Please try again"];
                 // handle failure case
                 [self showInProgress:NO];
             }
         }];
    }
    else
    {
        [self didPerformAPICall];
    }
}

-(BOOL)isValidateField
{
    if([self.videoURLPath isEqualToString:@""])
    {
        [Banner showFailureBannerOnTopWithTitle:@"Error" subtitle:@"Video url is missing."];
        return NO;
    }
    else if([self.videoThumbnailURLPath isEqualToString:@""])
    {
        [Banner showFailureBannerOnTopWithTitle:@"Error" subtitle:@"Video cover image is missing."];
        return NO;
    }
    else if([self.videoNameTextField.text isEqualToString:@""])
    {
        [Banner showFailureBannerOnTopWithTitle:@"Error" subtitle:@"Please enter video title."];
        return NO;
    }
    else if(selectedMood == KNone)
    {
        [Banner showFailureBannerOnTopWithTitle:@"Error" subtitle:@"Please select your mood."];
        return NO;
    }
    else if(!selectedFeeling)
    {
        [Banner showFailureBannerOnTopWithTitle:@"Error" subtitle:@"Please select feeling."];
        return NO;
    }
//    else if([self.descriptionTextView.text isEqualToString:PlaceHolderTextView] || [self.descriptionTextView.text isEqualToString:@""])
//    {
//        [Banner showFailureBannerOnTopWithTitle:@"Error" subtitle:@"Please enter description."];
//        return NO;
//    }
    
    return YES;
}

- (void)didPerformAPICall {
    
    NSString *videoName = self.videoNameTextField.text;
    videoName = [videoName stringByReplacingOccurrencesOfString:@" " withString:@"_"];
    
    NSString *description = _descriptionTextView.text;
    if ([_descriptionTextView.text isEqualToString:PlaceHolderTextView]) {
        description = @"";
    }
    
    RecordPost *post = [[RecordPost alloc] initWithVideoName:videoName andExcerciseType:((_excercise)?(([_excercise.excerciseStringType isEqualToString:@""])?@"GuidedExcercise":_excercise.excerciseStringType):@"") andCoverURL:self.videoThumbnailURLPath andPostDesciption:description andVideoURL:self.videoURLPath andUserId:[UserManager sharedManager].userModel.userId andMoodId:[NSString stringWithFormat:@"%ld",(long)selectedMood] andFeelingId:selectedFeeling.feelingId andWithExcercise:_excercise];
    
    [[RequestManager alloc] postRecordPost:post withCompletionBlock:^(BOOL success, id response) {
        [self showInProgress:NO];
        if(success)
        {
            [self didClearStateOnPop];
            [self didSuccessAPI];
            [self logEvents:post];
        }
    }];
}

- (void)didClearStateOnPop
{
    self.videoURLPath = kEmptyString;
    self.videoThumbnailURLPath = kEmptyString;
}

- (void)didSuccessAPI
{
    [Util postNotification:kCleanRecordViewControllerNotification withDict:nil];
    [Util postNotification:kRefreshVideosViewControllerNotification withDict:nil];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [ApplicationDelegate.tabBarController setSelectTabIndex:1];
        [ApplicationDelegate.tabBarController setSelectedIndex:1];
        [self.navigationController popViewControllerAnimated:NO];
        
        [Banner showSuccessBannerWithSubtitle:@"Video uploaded successfully"];
    });
    
}

- (void)logEvents:(RecordPost *)post {
    id<GAITracker> tracker = [[GAI sharedInstance] trackerWithTrackingId:@"UA-92763376-1"];;
    
    UserModel *user = [UserManager sharedManager].userModel;
    
    NSString *category = [NSString stringWithFormat:@"%@ %@",user.userId, user.userName];
    NSString *eventAction = [NSString stringWithFormat:@"%@",post.postName];
    NSString *label = @"";
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"EEEE"];
    label = [NSString stringWithFormat:@"Day of week of Recording: %@", [dateFormatter stringFromDate:[NSDate date]]];
    
    [tracker send:
     [[GAIDictionaryBuilder createEventWithCategory:category
                                             action:eventAction
                                              label:label
                                              value:@1] build]];
    
    if (selectedFeeling.feelingName.length != 0) {
        label = [NSString stringWithFormat:@"Feeling Tags: %@",selectedFeeling.feelingName];
        
        [tracker send:
         [[GAIDictionaryBuilder createEventWithCategory:category
                                                 action:eventAction
                                                  label:label
                                                  value:@1] build]];
    }
    
    if (post.postDesciption.length != 0) {
        label = [NSString stringWithFormat:@"Free text associated: %@",post.postDesciption];
        
        [tracker send:
         [[GAIDictionaryBuilder createEventWithCategory:category
                                                 action:eventAction
                                                  label:label
                                                  value:@1] build]];
    }
    
    label = [NSString stringWithFormat:@"Length of recording: %f",videoDuration];
    
    [tracker send:
     [[GAIDictionaryBuilder createEventWithCategory:category
                                             action:eventAction
                                              label:label
                                              value:@1] build]];
    
    label = [NSString stringWithFormat:@"Mood rating: %@",post.moodId];
    
    [tracker send:
     [[GAIDictionaryBuilder createEventWithCategory:category
                                             action:eventAction
                                              label:label
                                              value:@1] build]];
    
    label = [NSString stringWithFormat:@"Time of recording: %@",([[NSDate date] stringInUKFormat])];
    
    [tracker send:
     [[GAIDictionaryBuilder createEventWithCategory:category
                                             action:eventAction
                                              label:label
                                              value:@1] build]];
}

- (UIBarButtonItem *)uploadButton {
    UIButton *leftButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 4, 50, 25)];
    [leftButton setTitle:@"Upload" forState:UIControlStateNormal];
    [leftButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [leftButton.titleLabel setFont:[UIFont fontWithName:@"Roboto" size:13]];
    leftButton.cornerRadius = 5;
    leftButton.borderColor = [UIColor whiteColor];
    leftButton.borderWidth = 1.0f;
   // [leftButton setImage:[UIImage imageNamed:@"uploadButton"] forState:UIControlStateNormal];
    [leftButton addTarget:self action:@selector(uploadButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *leftBarButton = [[UIBarButtonItem alloc] initWithCustomView:leftButton];
    return leftBarButton;
}

-(void)addToolBarForDone {
    UIToolbar* numberToolbar = [[UIToolbar alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 50)];
    numberToolbar.barStyle = UIBarStyleDefault;
    UIBarButtonItem *button = [[UIBarButtonItem alloc]initWithTitle:@"Done" style:UIBarButtonItemStyleDone target:self action:@selector(uploadButtonAction:)];
    [button setTitleTextAttributes:
     [NSDictionary dictionaryWithObjectsAndKeys:
      [UIColor colorWithRed:15.0/255.0 green:175.0/255.0 blue:198.0/255.0 alpha:1.0], NSForegroundColorAttributeName,nil]
                          forState:UIControlStateNormal];
    numberToolbar.items = [NSArray arrayWithObjects:
                           [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil],
                           button,
                           nil];
    [numberToolbar sizeToFit];
    self.descriptionTextView.inputAccessoryView = numberToolbar;
}

-(void)addMoodWheel {
    CGFloat xValue = (self.moodWheelView.frame.size.width-250)/2;
    CGFloat yValue = (self.moodWheelView.frame.size.height-250)/2;
    CGRect sliderFrame = CGRectMake(xValue, yValue, 250, 250);
    EFCircularSlider* circularSlider = [[EFCircularSlider alloc] initWithFrame:sliderFrame];
    [circularSlider addTarget:self action:@selector(sliderValueChanged:) forControlEvents:UIControlEventValueChanged];
    UITapGestureRecognizer *seekbarGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(seekBarTapped:)];
    [circularSlider addGestureRecognizer:seekbarGesture];
    circularSlider.lineWidth = 25;
    circularSlider.handleType = EFDoubleCircleWithOpenCenter;
    NSArray* labels = @[@"B", @"C", @"D", @"E",@"F",@"G", @"A"];
    [circularSlider setInnerMarkingLabels:labels];
    
    [self.moodWheelView addSubview:circularSlider];
}

#pragma mark - mood wheel actions
- (void)seekBarTapped:(UIGestureRecognizer *)gestureRecognizer {
    EFCircularSlider* circularSlider = (EFCircularSlider*)gestureRecognizer.view;
    CGPoint point = [gestureRecognizer locationInView:circularSlider];
    [circularSlider moveHandle:point];
    [self sliderValueChanged:circularSlider];
}

-(void)sliderValueChanged:(EFCircularSlider*)slider {
    [self.view endEditing:YES];
    CGFloat value = 100.0/7.0;
    if(slider.currentValue<=(value)){
        selectedMood = TheBestMood;
        [slider setFilledColor:[Util getMoodColor:TheBestMood]];
    }else if(slider.currentValue<=(value*2)){
        selectedMood = VeryGoodMood;
        [slider setFilledColor:[Util getMoodColor:VeryGoodMood]];
    }else if(slider.currentValue<=(value*3)){
        selectedMood = GoodMood;
        [slider setFilledColor:[Util getMoodColor:GoodMood]];
    }else if(slider.currentValue<=(value*4)){
        selectedMood = OkMood;
        [slider setFilledColor:[Util getMoodColor:OkMood]];
    }else if(slider.currentValue<=(value*5)){
        selectedMood = BadMood;
        [slider setFilledColor:[Util getMoodColor:BadMood]];
    }else if(slider.currentValue<=(value*6)){
        selectedMood = VeryBadMood;
        [slider setFilledColor:[Util getMoodColor:VeryBadMood]];
    }else if(slider.currentValue<=(100)){
        selectedMood = TheWorstMood;
        [slider setFilledColor:[Util getMoodColor:TheWorstMood]];
    }
    [self.moodLabel setText:[Util getMoodString:selectedMood].uppercaseString];
    [self populateNameOfVideo];
}

#pragma mark  - TextField Delegates

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField {
    //[self toolBarCancelButtonAction:nil];
    return YES;
}

- (void)textFieldDidBeginEditing:(UITextField *)textField{
}

- (BOOL)textFieldShouldEndEditing:(UITextField *)textField{
    return YES;
}

- (void)textFieldDidEndEditing:(UITextField *)textField{
    
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    isUserEditedName = YES;
    return YES;
}  // return NO to not change text

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return YES;
}

#pragma mark - Text View Delegate
- (BOOL)textViewShouldBeginEditing:(UITextView *)textView {
    NSString *string = textView.text;
    if([string.trim isEqualToString:PlaceHolderTextView]){
        textView.text = @"";
        [textView setTextColor:DefaultTextViewColor];
    }
    return YES;
}
- (BOOL)textViewShouldEndEditing:(UITextView *)textView {
    return YES;
}
- (void)textViewDidBeginEditing:(UITextView *)textView {
    CGPoint point = self.descptionView.frame.origin;
    point.y = point.y-100;
    [self.scrollView setContentOffset:point];
}
- (void)textViewDidEndEditing:(UITextView *)textView {
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
    
    const char * _char = [text cStringUsingEncoding:NSUTF8StringEncoding];
    int backSpace = strcmp(_char, "\b");
    if (backSpace == -8 && textView.text.length<=1) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            textView.text = PlaceHolderTextView;
            [textView setTextColor:PlaceHolderColor];
            textView.selectedRange = NSMakeRange(0, 0);
        });
        return YES;
    }
    
    NSString *string = textView.text;
    if([string.trim isEqualToString:PlaceHolderTextView]){
        textView.text = @"";
        [textView setTextColor:DefaultTextViewColor];
        return YES;
    }

    NSString * newString = [textView.text stringByReplacingCharactersInRange:range withString:text];
    if(newString.length > 160){
        return NO;
    }
    return YES;
}
- (void)textViewDidChange:(UITextView *)textView {
}

#pragma mark - KeyBoard Show/Hide Delegate

- (void)keyboardWillShow:(NSNotification *)note {
}

- (void)keyboardWillHide:(NSNotification *)note {
    [self.scrollView setContentOffset:CGPointMake(0, 0)];
}

#pragma mark - feeling Delegate
-(void)didSelectFeeling:(Feeling *)feeling {
    if(feeling)
    {
        NSString *title = [NSString stringWithFormat:@"  Feeling: %@", feeling.feelingName];
        [self.addFeelingButton setTitle:title forState:UIControlStateNormal];
        if(feeling.feelingRedColor == nil)
        {        [self.feelingColorButton setBackgroundColor:[UIColor colorWithRed:[feeling.feelingRedColor floatValue]/255.0 green:[feeling.feelingGreenColor floatValue]/255.0 blue:[feeling.feelingBlueColor floatValue]/255.0 alpha:0.0]];
        } else {
            [self.feelingColorButton setBackgroundColor:[UIColor colorWithRed:[feeling.feelingRedColor floatValue]/255.0 green:[feeling.feelingGreenColor floatValue]/255.0 blue:[feeling.feelingBlueColor floatValue]/255.0 alpha:1.0]];
        }
        selectedFeeling = feeling;
        [self populateNameOfVideo];
    }
}

#pragma mark - IBActions
- (IBAction)uploadButtonAction:(id)sender {
    [self.descriptionTextView resignFirstResponder];
    if(([self isValidateField]))
    {
        [self willUploadVideoOnAWS];
    }
}

- (IBAction)addFeelingButtonAction:(id)sender {
     [self.view endEditing:YES];
    self.feelingListViewController = [[UIStoryboard storyboardWithName:KProfileStoryboard bundle:nil] instantiateViewControllerWithIdentifier:kFeelingListViewController];
    if(selectedFeeling){
        self.feelingListViewController.selectedFeeling = selectedFeeling;
    }
    self.feelingListViewController.delegate = self;
    [self.navigationController pushViewController:self.feelingListViewController animated:YES];
}
@end
