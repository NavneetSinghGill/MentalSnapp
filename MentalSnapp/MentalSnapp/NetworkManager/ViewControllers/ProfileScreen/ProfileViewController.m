 //
//  ProfileViewController.m
//  MentalSnapp
//
//  Copyright © 2016 Systango. All rights reserved.
//

#import "ProfileViewController.h"
#import "RequestManager.h"
#import "ChangePasswordViewController.h"
#import "UserManager.h"
#import "PickerViewController.h"
#import "DownloadAllVideoViewController.h"

@interface ProfileViewController () <UITextFieldDelegate, PickerViewControllerDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, DownloadVideoDelegate>
{
    NSInteger selectedGender;
    NSString *profilePicURL;
    NSDate *selectedDate;
}
    
@property (strong, nonatomic) IBOutlet UITextField *emailTextFeild;
@property (strong, nonatomic) IBOutlet UIButton *profilePictureImageView;
@property (strong, nonatomic) IBOutlet UILabel *userNameLabel;
@property (strong, nonatomic) IBOutlet UIButton *dateOfBirthButton;
@property (strong, nonatomic) IBOutlet UITextField *phoneTextField;
@property (strong, nonatomic) IBOutlet UIButton *maleGenderButton;
@property (strong, nonatomic) IBOutlet UIButton *femaleGenderButton;
@property (strong, nonatomic) IBOutlet UIButton *changePasswordButton;
@property (strong, nonatomic) IBOutlet UIButton *saveButton;
@property (strong, nonatomic) IBOutlet UIScrollView *scrollView;
@property (strong, nonatomic) IBOutlet UIView *containerView;
@property (strong, nonatomic) IBOutlet UIView *emailFieldview;
@property (strong, nonatomic) IBOutlet UIView *phoneFieldView;
@property (strong, nonatomic) PickerViewController *pickerViewController;
@property (strong, nonatomic) UIImage *userImage;
@property (strong, nonatomic) IBOutlet UIView *changepasswordView;
@property (strong, nonatomic) IBOutlet UIButton *otherGenderButton;

- (IBAction)genderButtonAction:(id)sender;
- (IBAction)changePasswordButtonAction:(id)sender;
- (IBAction)saveButtonAction:(id)sender;
- (IBAction)addPictureProfileAction:(id)sender;
- (IBAction)deleteProfileAction:(id)sender;
- (IBAction)ChangePasswordDragOutsideAction:(id)sender;
- (IBAction)changePasswordButtontouchDown:(id)sender;

@end

@implementation ProfileViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
//    [self.maleGenderButton setSelected:YES];
    [[UserManager sharedManager] setValueInLoggedInUserObjectFromUserDefault];
    self.user = [UserManager sharedManager].userModel;
    [self setNavigationBarButtonTitle:@"Profile"];
    [self setLeftMenuButtons:[NSArray arrayWithObject:[self backButton]]];
    [self addLeftMenubutton];
    [self setRightMenuButtons:[NSArray arrayWithObject:[self logoutButtonAction]]];
    //show pre fileld users data
    [self showDataOfUsers];
    [self getUserDetail];
    self.pickerViewController = [[UIStoryboard storyboardWithName:KProfileStoryboard bundle:nil] instantiateViewControllerWithIdentifier:kPickerViewController];
    self.pickerViewController.modalPresentationStyle = UIModalPresentationOverFullScreen;
    [self.pickerViewController setPickerType:dateOnly];
     [self.pickerViewController setDateSelection:past18Year];
    [self.pickerViewController setDelegate:self];
    
    self.navigationController.navigationBar.barTintColor = [UIColor colorWithRed:15/255.f green:175/255.f blue:198/255.f alpha:1.f];
    [[UINavigationBar appearance] setShadowImage:[UIImage new]];
    [[UINavigationBar appearance] setBackgroundImage:[UIImage new] forBarMetrics:UIBarMetricsDefault];
    [[UINavigationBar appearance]  setTranslucent:NO];
    
    UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(buttonDidLongPress:)];
    [self.changePasswordButton addGestureRecognizer:longPress];
    
}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.changepasswordView setBackgroundColor:[UIColor colorWithRed:235.0/255.0 green:235.0/255.0 blue:235.0/255.0 alpha:1.0]];    
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self.changepasswordView setBackgroundColor:[UIColor colorWithRed:235.0/255.0 green:235.0/255.0 blue:235.0/255.0 alpha:1.0]];
    self.navigationController.navigationBar.barTintColor = [UIColor colorWithRed:15/255.f green:175/255.f blue:198/255.f alpha:1.f];
    [[UINavigationBar appearance] setShadowImage:[UIImage new]];
    [[UINavigationBar appearance] setBackgroundImage:[UIImage new] forBarMetrics:UIBarMetricsDefault];
    [[UINavigationBar appearance]  setTranslucent:NO];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)addLeftMenubutton{
    if([ApplicationDelegate.window.rootViewController isKindOfClass:[UINavigationController class]]){
        UINavigationController *navController = (UINavigationController *)ApplicationDelegate.window.rootViewController;
        NSArray *array = navController.viewControllers;
        if(array.count>0 && [[array firstObject] isKindOfClass:[ProfileViewController class]]) {
            [self setLeftMenuButtons:nil];
            [self setLeftMenuButtons:[NSArray arrayWithObject:[self skipButtonAction]]];
        }
    }
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

#pragma mark  - TextField Delegates

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField {
    //[self toolBarCancelButtonAction:nil];
    return YES;
}

- (void)textFieldDidBeginEditing:(UITextField *)textField{
    CGPoint point = (([textField isEqual:self.emailTextFeild])?self.emailFieldview.frame.origin:self.phoneFieldView.frame.origin);
    point.y = point.y+20;
    [self.scrollView setContentOffset:point];
}

- (BOOL)textFieldShouldEndEditing:(UITextField *)textField{
    return YES;
}

- (void)textFieldDidEndEditing:(UITextField *)textField{

}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    if([textField isEqual:self.phoneTextField]){
        return [Util formatePhoneNumberOftextField:textField withRange:range ReplacemenString:string];
    }
    
    return YES;
}  // return NO to not change text

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return YES;
}



#pragma mark - Private methods

- (UIBarButtonItem *)logoutButtonAction {
    UIButton *leftButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 4, 25, 30)];
    [leftButton setImage:[UIImage imageNamed:@"logout"] forState:UIControlStateNormal];
    [leftButton addTarget:self action:@selector(logoutButtonTapped) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *leftBarButton = [[UIBarButtonItem alloc] initWithCustomView:leftButton];
    return leftBarButton;
}

- (UIBarButtonItem *)skipButtonAction {
    UIButton *leftButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 4, 50, 30)];
    [leftButton setBackgroundColor:[UIColor clearColor]];
    [leftButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [leftButton setTitle:@"Skip" forState:UIControlStateNormal];
    [leftButton.titleLabel setFont:[UIFont fontWithName:@"Roboto" size:15]];
    leftButton.cornerRadius = 5;
    leftButton.borderColor = [UIColor whiteColor];
    leftButton.borderWidth = 1.0f;
    [leftButton addTarget:self action:@selector(backButtonTapped) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *leftBarButton = [[UIBarButtonItem alloc] initWithCustomView:leftButton];
    return leftBarButton;
}

- (void)getUserDetail {
    if(self.user) {
        [self showInProgress:YES];
        [[RequestManager alloc] getUserDetailWithUserModel:self.user withCompletionBlock:^(BOOL success, id response) {
            if(success){
                self.user = response;
                [self showDataOfUsers];
            }
            [self showInProgress:NO];
        }];
    }
}

-(void)showDataOfUsers {
    if(self.user){
        profilePicURL = self.user.profilePicURL;
        selectedGender = ([self.user.gender caseInsensitiveCompare:@"female"]==NSOrderedSame)?1:(([self.user.gender caseInsensitiveCompare:@"other"]==NSOrderedSame)?2:(([self.user.gender isEqualToString:@""])?3:0));
        [self.userNameLabel setText:[NSString stringWithFormat:@"%@ %@",self.user.firstName, self.user.lastName]];
        [self.emailTextFeild setText:self.user.email];
        NSMutableString *phoneNumber = [NSMutableString stringWithString:self.user.phoneNumber] ;
        if(phoneNumber.length>0){
            [phoneNumber insertString:@" " atIndex:0];
            [phoneNumber insertString:@" " atIndex:5];
        }
        [self.phoneTextField setText:((phoneNumber.length>0)?phoneNumber:@"")];
        [self.maleGenderButton setSelected:(selectedGender == MaleGender)?YES:NO];
        [self.femaleGenderButton setSelected:(selectedGender == MaleGender)?NO:((selectedGender == FemaleGender)?YES:NO)];
        [self.otherGenderButton setSelected:(selectedGender == OtherGender)?YES:NO];

        [self displayProfileImageFromURL];
        selectedDate = [NSDate dateFromString:self.user.dateOfBirth format:@"yyyy-MM-dd"];
        [self.dateOfBirthButton setTitle:(self.user.dateOfBirth.length<=0)?@"Enter your date of birth":[NSDate stringFromDate:selectedDate format:@"dd MMM yyyy"] forState:UIControlStateNormal];
        if(self.user.dateOfBirth.length<=0) {
            [self.dateOfBirthButton setTitleColor:[UIColor colorWithRed:210.0/255.0 green:210.0/255.0 blue:210.0/255.0 alpha:1.0] forState:UIControlStateNormal];
        }
    }
}

-(BOOL)isValidateFeilds {
    if([self.emailTextFeild.text isEqualToString:@""]) {
        [Banner showFailureBannerOnTopWithTitle:@"Error" subtitle:LocalizedString(@"ProfileScreenEmailMessage")];
        return NO;
    }
    if(![Util isValidEmail:self.emailTextFeild.text]){
        [Banner showFailureBannerOnTopWithTitle:@"Error" subtitle:LocalizedString(@"ProfileScreenValidEmailMessage")];
        return NO;
    }
//    if([self.phoneTextField.text isEqualToString:@""]) {
//        [Banner showFailureBannerOnTopWithTitle:@"Error" subtitle:LocalizedString(@"ProfileScreenPhoneMessage")];
//        return NO;
//    }
    
    if((self.phoneTextField.text.length>0) && (self.phoneTextField.text.length<11)) {
        [Banner showFailureBannerOnTopWithTitle:@"Error" subtitle:LocalizedString(@"SignupScreenPhoneMessage")];
        return NO;
    }
    
    if((self.phoneTextField.text.length>0) && ![Util validatePhone:self.phoneTextField.text]){
        [Banner showFailureBannerOnTopWithTitle:@"Error" subtitle:LocalizedString(@"ProfileScreenValidPhoneMessage")];
        return NO;
    }
//    if([[self.dateOfBirthButton titleForState:UIControlStateNormal] isEqualToString:@""]){
//        [Banner showFailureBannerOnTopWithTitle:@"Error" subtitle:LocalizedString(@"ProfileScreenDOBmessage")];
//        return NO;
//    }
    return YES;
}

- (void)willPerformUpdateUserDetailsAPICall
{
    [self showInProgress:YES];
    if(self.userImage)
    {
        [[[Util alloc] init] didFinishPickingImageFile:self.userImage fileType:ImageProfile completionBlock:^(BOOL success, id response)
         {
             NSLog([NSString stringWithFormat:@"response : : %@", response]);
             if(success)
             {
                 AppSettings *appSettings = [AppSettingsManager sharedInstance].appSettings;
                 NSString *bucketName = ([appSettings.NetworkMode isEqualToString:kLiveEnviroment]) ? kLiveProfileImageBucket : kStagingProfileImageBucket;
                 profilePicURL = [NSString stringWithFormat:@"%@/%@/%@", kAWSPath, bucketName, response];
                 [self didPerformUpdateUserDetailsAPICall];
             }
             else
             {
                 [Banner showFailureBannerWithSubtitle:LocalizedString(@"ImageUploadFailureMessage")];
                 [self removeProfileImage];
                 [self showInProgress:NO];
             }
         }];
    }
    else
    {
        [self didPerformUpdateUserDetailsAPICall];
    }
}

- (void)didPerformUpdateUserDetailsAPICall
{
    NSString *phoneNumber = self.phoneTextField.text;
    phoneNumber = [phoneNumber stringByReplacingOccurrencesOfString:@"+44" withString:@""];
    phoneNumber = [phoneNumber stringByReplacingOccurrencesOfString:@" " withString:@""];
    NSString *dateOfBirth= (([[self.dateOfBirthButton titleForState:UIControlStateNormal] isEqualToString:@"Enter your date of birth"])?@"":[self.dateOfBirthButton titleForState:UIControlStateNormal]);
    UserModel *user = [[UserModel alloc] initWithUserId:self.user.userId andEmail:self.emailTextFeild.text andfirstName:self.user.firstName andlastName:self.user.lastName andPhone:phoneNumber andGender:[NSString stringWithFormat:@"%@",(selectedGender == MaleGender)?@"male":((selectedGender == FemaleGender)?@"female":((selectedGender == OtherGender)?@"other":@""))] andDateOfBirth:dateOfBirth andProfilePic:profilePicURL];
    
    [[RequestManager alloc] editUserWithUserModel:user withCompletionBlock:^(BOOL success, id response) {
        if(success)
        {
            [[UserManager sharedManager] updateProfileURL:profilePicURL];
            self.userImage = nil;
            if (_didOpenFromMoreScreen) {
                [self backButtonTapped];
            }
            [Banner showSuccessBannerWithSubtitle:LocalizedString(@"UserUpdationMessage")];
            
            [[UserManager sharedManager] sendAnalyticsForGenderAndDOBforUser:user];
        }
        [self showInProgress:NO];
    }];
}


-(void)displayProfileImageFromURL
{
    if(profilePicURL.length > 0)
    {
        [self.profilePictureImageView sd_setImageWithURL:[NSURL URLWithString:profilePicURL] forState:UIControlStateNormal placeholderImage:[UIImage imageNamed:@"profile-image"] completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
            [self.profilePictureImageView setClipsToBounds:YES];
        }];
    }
    else
    {
        [self.profilePictureImageView setImage:[UIImage imageNamed:@"profile-image"] forState:UIControlStateNormal];
    }
}

- (void)performImageChangeAction
{
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    UIAlertAction *alertActionGallery = [UIAlertAction actionWithTitle:LocalizedString(@"ChoosePhoto") style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [self selectPhoto:Gallery];
    } ];
    UIAlertAction *alertActionCamera = [UIAlertAction actionWithTitle:LocalizedString(@"TakePhoto") style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [self selectPhoto:Camera];
    }];
    UIAlertAction *alertActionCancel = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:nil];
    
    if(self.userImage || profilePicURL.trim.length > 0)
    {
        UIAlertAction *alertActionDeleteImage = [UIAlertAction actionWithTitle:LocalizedString(@"DeletePhoto") style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
            [self selectPhoto:DeleteImage];
        }];
        
        [alertController addAction:alertActionDeleteImage];
    }
    
    [alertController addAction:alertActionGallery];
    [alertController addAction:alertActionCamera];
    [alertController addAction:alertActionCancel];
    [self presentViewController:alertController animated:YES completion:nil];
}

- (void)removeProfileImage
{
    profilePicURL = kEmptyString;
    self.userImage = nil;
    [self.profilePictureImageView setImage:[UIImage imageNamed:@"profile-image"] forState:UIControlStateNormal];
}

#pragma mark - ImagePicker Delegate Method

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    self.userImage = info[UIImagePickerControllerEditedImage];
    CGSize profileImageSize = CGSizeMake(self.profilePictureImageView.frame.size.width * 3, self.profilePictureImageView.frame.size.height * 3);
    self.userImage = [self.userImage imageByScalingProportionallyToSize:profileImageSize withPriority:PriorityWidth];
    if (self.userImage)
    {
        [self.profilePictureImageView setImage:self.userImage forState:UIControlStateNormal];
    }
    else
    {
        [self.profilePictureImageView setImage:[UIImage imageNamed:@"profile-image"] forState:UIControlStateNormal];
    }
    
    [self.profilePictureImageView setClipsToBounds:YES];
    [picker dismissViewControllerAnimated:YES completion:NULL];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [picker dismissViewControllerAnimated:YES completion:NULL];
}

- (void)selectPhoto:(ImagePickerType)type
{
    if(type == Camera && (![UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]))
    {
        return;
    }
    else if (type == DeleteImage)
    {
        [self removeProfileImage];
    }
    else
    {
        UIImagePickerController *picker = [[UIImagePickerController alloc] init];
        picker.allowsEditing = YES;
        picker.delegate = self;
        if (type == Gallery)
        {
            picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
        }
        else if (type == Camera) {
            picker.sourceType = UIImagePickerControllerSourceTypeCamera;
        }
        
        [picker setMediaTypes:[NSArray arrayWithObjects:(NSString *)kUTTypeImage, nil]];
        [self presentViewController:picker animated:YES completion:NULL];
    }
}

#pragma mark - Date Picker view Delegate
- (void)didSelectDoneButton:(NSDate *)date {
    selectedDate = date;
    [self.dateOfBirthButton setTitleColor:[UIColor colorWithRed:83.0/255.0 green:83.0/255.0 blue:83.0/255.0 alpha:1.0] forState:UIControlStateNormal];
    [self.dateOfBirthButton setTitle:[NSDate stringFromDate:date format:@"dd MMM yyyy"] forState:UIControlStateNormal];
}
- (void)didSelectCancelButton {
//    selectedDate = [NSDate dateFromString:self.user.dateOfBirth format:@"yyyy-dd-MM"];
//    [self.dateOfBirthButton setTitle:[NSDate stringFromDate:selectedDate format:@"dd MMM yyyy"] forState:UIControlStateNormal];
}

#pragma mark - Tap gesture
- (void)buttonDidLongPress:(UILongPressGestureRecognizer*)gesture
{
    switch (gesture.state) {
        case UIGestureRecognizerStateBegan:
        {
            [self.changepasswordView setBackgroundColor:[UIColor colorWithRed:200.0/255.0 green:200.0/255.0 blue:200.0/255.0 alpha:1.0]];
        }
            break;
        case UIGestureRecognizerStateEnded:
        {
            [self.changepasswordView setBackgroundColor:[UIColor colorWithRed:235.0/255.0 green:235.0/255.0 blue:235.0/255.0 alpha:1.0]];
        }
            break;
        default:
            break;
    }
}

#pragma mark - Download Delegate
-(void)didDownloadCompleted:(BOOL)success {
    if(success){
        [Banner showFailureBannerWithSubtitle:LocalizedString(@"DownloadCompletionMessage")];
        [self deleteProfileAPI];
    } else {
    }
}

#pragma mark - IBActions
- (void)logoutButtonTapped {
    [self showInProgress:YES];
    [[RequestManager alloc] userLogoutWithUserModel:self.user withCompletionBlock:^(BOOL success, id response) {
        if(success){
            [[UserManager sharedManager] logoutUser];
        }
        [self showInProgress:NO];
    }];
}


- (IBAction)genderButtonAction:(id)sender {
    selectedGender = [sender tag];
    if([sender tag] == MaleGender){
        self.maleGenderButton.selected = YES;
        self.femaleGenderButton.selected = NO;
        self.otherGenderButton.selected = NO;

    } else if([sender tag] == FemaleGender) {
        self.maleGenderButton.selected = NO;
        self.femaleGenderButton.selected = YES;
        self.otherGenderButton.selected = NO;
    } else {
        self.maleGenderButton.selected = NO;
        self.femaleGenderButton.selected = NO;
        self.otherGenderButton.selected = YES;
    }
 }

- (IBAction)changePasswordButtonAction:(id)sender {

    [self.changepasswordView setBackgroundColor:[UIColor colorWithRed:200.0/255.0 green:200.0/255.0 blue:200.0/255.0 alpha:1.0]];
    
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:KProfileStoryboard bundle:nil];
    ChangePasswordViewController *changePasswordScreen = [storyboard instantiateViewControllerWithIdentifier:KChangePasswordViewController];
    [self.navigationController pushViewController:changePasswordScreen animated:YES ];
}

- (IBAction)saveButtonAction:(id)sender
{
    if([self isValidateFeilds])
    {
        [self willPerformUpdateUserDetailsAPICall];
    }
}

- (IBAction)dateOfBirthButtonAction:(id)sender {
    [self.view endEditing:YES];
    [self.navigationController.navigationBar endEditing:YES];
    if(selectedDate){
        [self.pickerViewController updatePickerDate:selectedDate];
    }
    [[[ApplicationDelegate window] rootViewController] presentViewController:self.pickerViewController animated:YES completion:nil];
}

- (IBAction)addPictureProfileAction:(id)sender {
    if(ApplicationDelegate.hasNetworkAvailable){
        [self performImageChangeAction];
    }
}

-(void)deleteProfileAPI {
    [self showInProgress:YES];
    [[RequestManager alloc] userDeactivateWithUserModel:self.user withCompletionBlock:^(BOOL success, id response) {
        if(success){
            [[UserManager sharedManager] logoutUser];
            [Banner showSuccessBannerOnTopWithTitle:@"Good Bye" subtitle:LocalizedString(@"DeleteProfileApiMessage")];
        }
        [self showInProgress:NO];
    }];
}

-(void)showDownloadScreen {
    DownloadAllVideoViewController *downloadVideoController = [[UIStoryboard storyboardWithName:KProfileStoryboard bundle:nil] instantiateViewControllerWithIdentifier:kDownloadAllVideoViewController];
    downloadVideoController.delegate = self;
    downloadVideoController.modalPresentationStyle = UIModalPresentationOverFullScreen;
    [self presentViewController:downloadVideoController animated:YES completion:nil];
}

-(void)downloadVideoPopUP {
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Mental Snapp" message:LocalizedString(@"DownloadVideoPopupMessage") preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"Yes" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self showDownloadScreen];
          //  [self deleteProfileAPI];
        });
    }];
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"No" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self deleteProfileAPI];
        });
    }];
    
    [alertController addAction:okAction];
    [alertController addAction:cancelAction];
    dispatch_async(dispatch_get_main_queue(), ^{
        [self presentViewController:alertController animated:YES completion:nil];
    });
}

- (IBAction)deleteProfileAction:(id)sender {

    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Mental Snapp" message:LocalizedString(@"DeleteProfilePopupMessage") preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"Ok" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self downloadVideoPopUP];
        });
    }];
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
    }];

    [alertController addAction:okAction];
     [alertController addAction:cancelAction];
    dispatch_async(dispatch_get_main_queue(), ^{
        [self presentViewController:alertController animated:YES completion:nil];
    });
}

- (IBAction)ChangePasswordDragOutsideAction:(id)sender {
        [self.changepasswordView setBackgroundColor:[UIColor colorWithRed:235.0/255.0 green:235.0/255.0 blue:235.0/255.0 alpha:1.0]];
}

- (IBAction)changePasswordButtontouchDown:(id)sender {
    //[self.changepasswordView setBackgroundColor:[UIColor colorWithRed:235.0/255.0 green:235.0/255.0 blue:235.0/255.0 alpha:1.0]];
}

@end
