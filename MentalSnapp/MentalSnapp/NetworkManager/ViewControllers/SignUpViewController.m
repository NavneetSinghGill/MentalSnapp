//
//  SignUpViewController.m
//  MentalSnapp
//

#import "SignUpViewController.h"
#import "RequestManager.h"
#import <MessageUI/MessageUI.h>

@interface SignUpViewController () <MFMailComposeViewControllerDelegate> {
    NSInteger selectedGender;
    NSDate *selectedDate;
}

@property (nonatomic, strong) UserModel *user;

@property (strong, nonatomic) IBOutlet UITextField *nameTextFeild;
@property (strong, nonatomic) IBOutlet UITextField *emailTextFeild;
@property (strong, nonatomic) IBOutlet UITextField *phoneTextField;
@property (strong, nonatomic) IBOutlet UITextField *passwordTextField;
@property (strong, nonatomic) IBOutlet UITextField *confirmPasswordTextField;

@property (strong, nonatomic) IBOutlet UIButton *dateOfBirthButton;
@property (strong, nonatomic) IBOutlet UIButton *maleGenderButton;
@property (strong, nonatomic) IBOutlet UIButton *femaleGenderButton;
@property (strong, nonatomic) IBOutlet UIButton *signUpButton;

@property (strong, nonatomic) IBOutlet UIScrollView *scrollView;

@property (strong, nonatomic) IBOutlet UIView *containerView;
@property (strong, nonatomic) IBOutlet UIView *emailFieldview;
@property (strong, nonatomic) IBOutlet UIView *phoneFieldView;
@property (strong, nonatomic) IBOutlet UIView *dateOfBirthView;
@property (strong, nonatomic) IBOutlet UIButton *otherGenderButton;

@property (strong, nonatomic) IBOutlet UIDatePicker *datePicker;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *datePickerViewBottomConstraint;

@property(weak, nonatomic) IBOutlet UIButton *termsAndConditionCheckMarkButton;

@end

@implementation SignUpViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    selectedGender = NoneGender;
    [self setMaxDate18Year];
    [self.datePicker addTarget:self action:@selector(dateIsChanged:) forControlEvents:UIControlEventValueChanged];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(keyboardDidHide) name:UIKeyboardWillHideNotification object:nil];
}

- (BOOL)prefersStatusBarHidden {
    return YES;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    self.navigationController.navigationBar.hidden = YES;
}

- (void)keyboardDidHide {
    if (_scrollView.frame.size.height + _scrollView.contentOffset.y > _containerView.frame.size.height) {
        [UIView animateWithDuration:0.3f animations:^{
            [self.scrollView setContentOffset:CGPointMake(0, _containerView.frame.size.height - _scrollView.frame.size.height)];
        }];
    }
}

#pragma mark  - TextField Delegates

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField {
    [self toolBarCancelButtonAction:nil];
    return YES;
}

- (void)textFieldDidBeginEditing:(UITextField *)textField{
    
    if(![textField isEqual:self.nameTextFeild]){
        CGRect superRect = [textField convertRect:textField.frame toView:_containerView];
        [UIView animateWithDuration:0.3f animations:^{
            //This calculation ensures that the selected textField will be in the upper 3rd part of view
            [self.scrollView setContentOffset:CGPointMake(0, superRect.origin.y - _scrollView.frame.size.height / 3)];
        }];
    }
}

- (BOOL)textFieldShouldEndEditing:(UITextField *)textField{
    return YES;
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    if([textField isEqual:self.phoneTextField]){
        return [Util formatePhoneNumberOftextField:textField withRange:range ReplacemenString:string];
    }
    return YES;
}  // return NO to not change text


- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    if ([textField isEqual:_nameTextFeild]) {
        [_emailTextFeild becomeFirstResponder];
    } else if ([textField isEqual:_emailTextFeild]) {
        [_phoneTextField becomeFirstResponder];
    } else if ([textField isEqual:_phoneTextField]) {
        [_passwordTextField becomeFirstResponder];
    } else if ([textField isEqual:_passwordTextField]) {
        [_confirmPasswordTextField becomeFirstResponder];
    } else if ([textField isEqual:_confirmPasswordTextField]) {
        [_confirmPasswordTextField resignFirstResponder];
        [self signUpButtonTapped:self.signUpButton];
    }
    return YES;
}

#pragma mark - Date picker Selector method
- (void)dateIsChanged:(id)sender{
   //Profile [self.dateOfBirthButton setTitle:[NSDate stringFromDate:self.datePicker.date format:@"dd MMM yyyy"] forState:UIControlStateNormal];
}

#pragma mark - Private methods

-(void)setMaxDate18Year {
    NSCalendar * gregorian = [[NSCalendar alloc] initWithCalendarIdentifier: NSCalendarIdentifierGregorian];
    NSDate * currentDate = [NSDate date];
    NSDateComponents * comps = [[NSDateComponents alloc] init];
    [comps setYear: -18];
    NSDate * maxDate = [gregorian dateByAddingComponents: comps toDate: currentDate options: 0];
    [comps setYear: -120];
    NSDate * minDate = [gregorian dateByAddingComponents: comps toDate: currentDate options: 0];
    self.datePicker.minimumDate = minDate;
    self.datePicker.maximumDate = maxDate;
    self.datePicker.date = maxDate;
}

-(BOOL)isValidateFields {
    if ([self.nameTextFeild.text.trim isEqualToString:@""]) {
        [Banner showFailureBannerOnTopWithTitle:@"Error" subtitle:LocalizedString(@"SignupScreenNameMessage")];
        return NO;
    }
    if([self.emailTextFeild.text.trim isEqualToString:@""]) {
        [Banner showFailureBannerOnTopWithTitle:@"Error" subtitle:LocalizedString(@"SignupScreenEmailMessage")];
        return NO;
    }
    if(![Util isValidEmail:self.emailTextFeild.text]){
        [Banner showFailureBannerOnTopWithTitle:@"Error" subtitle:LocalizedString(@"SignupScreenValidEmailMessage")];
        return NO;
    }
//    if([self.phoneTextField.text.trim isEqualToString:@""]) {
//        [Banner showFailureBannerOnTopWithTitle:@"Error" subtitle:LocalizedString(@"SignupScreenPhoneMessage")];
//        return NO;
//    }
    
    if((self.phoneTextField.text.length>0) && (self.phoneTextField.text.length<11)) {
          [Banner showFailureBannerOnTopWithTitle:@"Error" subtitle:LocalizedString(@"SignupScreenValidPhoneMessage")];
          return NO;
       }
    
    if((self.phoneTextField.text.length>0) && ![Util validatePhone:self.phoneTextField.text]){
        [Banner showFailureBannerOnTopWithTitle:@"Error" subtitle:LocalizedString(@"SignupScreenValidPhoneMessage")];
        return NO;
    }
//    if([[self.dateOfBirthButton titleForState:UIControlStateNormal] isEqualToString:@""]){
//        [Banner showFailureBannerOnTopWithTitle:@"Error" subtitle:LocalizedString(@"SignupScreenDOBMessage")];
//        return NO;
//    }
    if ([self.passwordTextField.text.trim isEqualToString:@""]) {
        [Banner showFailureBannerOnTopWithTitle:@"Error" subtitle:LocalizedString(@"SignupScreenPasswordMessage")];
        return NO;
    }
    if ([self.confirmPasswordTextField.text.trim isEqualToString:@""]) {
        [Banner showFailureBannerOnTopWithTitle:@"Error" subtitle:LocalizedString(@"SignupScreenConfirmPasswordMessage")];
        return NO;
    }
    if (![self.passwordTextField.text isEqualToString:self.confirmPasswordTextField.text]) {
        [Banner showFailureBannerOnTopWithTitle:@"Error" subtitle:LocalizedString(@"SignupScreenPasswordMismatchMessage")];
        return NO;
    }
    if (_termsAndConditionCheckMarkButton.selected == NO) {
        [Banner showFailureBannerOnTopWithTitle:@"Error" subtitle:LocalizedString(@"SignupScreenTermsAndConditionNotSelectedMessage")];
        return NO;
    }
    return YES;
}

#pragma mark - IBActions

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

- (IBAction)signUpButtonTapped:(id)sender {
    if([self isValidateFields]){
        NSString *phoneNumber = self.phoneTextField.text;
        phoneNumber = [phoneNumber stringByReplacingOccurrencesOfString:@"+44" withString:@""];
        phoneNumber = [phoneNumber stringByReplacingOccurrencesOfString:@" " withString:@""];
        UserModel *user = [UserModel new];
        user.userName = self.nameTextFeild.text.trim;
        user.email = self.emailTextFeild.text.trim;
        user.phoneNumber = phoneNumber;
        user.dateOfBirth = ([self.dateOfBirthButton.titleLabel.text isEqualToString:@"Enter your date of birth"])?@"":self.dateOfBirthButton.titleLabel.text;
        user.gender = [NSString stringWithFormat:@"%@",(selectedGender == MaleGender)?@"male":((selectedGender == FemaleGender)?@"female":((selectedGender == OtherGender)?@"other":@""))];
        user.password = self.passwordTextField.text;
        user.confirmPassword = self.confirmPasswordTextField.text;
        user.phoneCountryCode = @"+44";
        [self showInProgress:YES];
        [[RequestManager alloc] signUpWithUserModel:user withCompletionBlock:^(BOOL success, id response) {
            [self showInProgress:NO];
            if (success) {
                [[UserManager sharedManager] saveLoggedinUserInfoInUserDefault];
                [Banner showRigidBannerWithSubtitle:@"A confirmation link has been send to your email."];
                [self.navigationController popToRootViewControllerAnimated:YES];
            }
        }];
    }
}

- (IBAction)toolBarCancelButtonAction:(id)sender {
    if(selectedDate){
        [self.datePicker setDate:selectedDate];
    }
    self.datePickerViewBottomConstraint.constant = -self.dateOfBirthView.frame.size.width;
    [UIView animateWithDuration:0.5 animations:^{
        [self.view layoutIfNeeded];
    } completion:^(BOOL finished) {
        
    }];
}

- (IBAction)toolBarDoneButtonAction:(id)sender {
    [self.dateOfBirthButton setTitleColor:[UIColor colorWithRed:83.0/255.0 green:83.0/255.0 blue:83.0/255.0 alpha:1] forState:UIControlStateNormal];
    selectedDate =self.datePicker.date;
    [self.dateOfBirthButton setTitle:[NSDate stringFromDate:self.datePicker.date format:@"dd MMM yyyy"] forState:UIControlStateNormal];
    self.datePickerViewBottomConstraint.constant = -self.dateOfBirthView.frame.size.width;
    [UIView animateWithDuration:0.5 animations:^{
        [self.view layoutIfNeeded];
    } completion:^(BOOL finished) {
        
    }];
}

- (IBAction)dateOfBirthButtonAction:(id)sender {
    [self.view endEditing:YES];
    [self.navigationController.navigationBar endEditing:YES];
    self.datePickerViewBottomConstraint.constant = 0;
    [UIView animateWithDuration:0.5 animations:^{
        [self.view layoutIfNeeded];
    } completion:^(BOOL finished) {
        
    }];
}

- (IBAction)backButtonTapped:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)termsAndConditionCheckMarkButtonTapped:(id)sender {
    self.termsAndConditionCheckMarkButton.selected = !self.termsAndConditionCheckMarkButton.selected;
}

- (IBAction)termsAndConditionButtonTapped:(id)sender {
    [self performSegueWithIdentifier:@"ToTermsScreen" sender:self];
}

- (IBAction)feedbackButtonPressed:(id)sender
{
    NSDate *date = [NSDate date];
    NSDateFormatter *dateFormater = [[NSDateFormatter alloc] init];
    
    [dateFormater setDateFormat:@"MM-DD-yyyy HH:mm:ss"];
    NSString *dateString = [dateFormater stringFromDate:date];
    
    if ([MFMailComposeViewController canSendMail]) {
        MFMailComposeViewController *composeViewController = [[MFMailComposeViewController alloc] initWithNibName:nil bundle:nil];
        [composeViewController setMailComposeDelegate:self];
        [composeViewController setToRecipients:@[@"feedback@mentalsnapp.com"]];
        [composeViewController setSubject:[NSString stringWithFormat:@"%@: Feedback for mentalsnapp android app", dateString]];
        [self.navigationController presentViewController:composeViewController animated:YES completion:nil];
    }
}

- (void)mailComposeController:(MFMailComposeViewController*)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError*)error
{
    //Add an alert in case of failure
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
