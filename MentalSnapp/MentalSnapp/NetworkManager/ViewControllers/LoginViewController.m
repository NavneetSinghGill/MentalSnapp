//
//  LoginViewController.m
//  MentalSnapp
//

#import "LoginViewController.h"
#import "RequestManager.h"
#import "WelcomeBackViewController.h"
#import <Crittercism/Crittercism.h>
#import "TutorialPageViewController.h"

@interface LoginViewController() <UITextFieldDelegate> {
    NSInteger kLogoTopConstraintDefaultValue;
    CGRect keyboardBounds;
}

@property(weak, nonatomic) IBOutlet UILabel *titleLabel;
@property(weak, nonatomic) IBOutlet UIView *userNameView;
@property(weak, nonatomic) IBOutlet UIView *passwordView;
@property(weak, nonatomic) IBOutlet UIButton *loginButton;
@property(weak, nonatomic) IBOutlet UIButton *rememberMeButton;
@property (strong, nonatomic) IBOutlet UIScrollView *scrollView;

@property(weak, nonatomic) IBOutlet UITextField *userEmailTextField;
@property(weak, nonatomic) IBOutlet UITextField *passwordTextField;

@end

@implementation LoginViewController

#pragma mark - View Life cycle methods

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(keyboardDidHide) name:UIKeyboardWillHideNotification object:nil];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    if ([[NSUserDefaults standardUserDefaults]boolForKey:kRememberMe]) {
        self.userEmailTextField.text = [[NSUserDefaults standardUserDefaults]valueForKey:kUserEmail];
        self.passwordTextField.text = [[NSUserDefaults standardUserDefaults]valueForKey:kUserPassword];
        self.rememberMeButton.selected = YES;
    } else if ([UserManager sharedManager].userModel.email.trim.length != 0) {
        _userEmailTextField.text = [UserManager sharedManager].userModel.email;
    }
    [UserDefaults setBool:NO forKey:kIsUserLoggedIn];
    
    self.navigationController.navigationBar.hidden = YES;
}

- (BOOL)prefersStatusBarHidden {
    return YES;
}

#pragma mark - Keyboard methods
- (void)keyboardDidHide {
        [UIView animateWithDuration:0.3f animations:^{
            [self.scrollView setContentOffset:CGPointMake(0, 0)];
        }];
}

#pragma mark - IBAction methods

- (IBAction)loginButtonTapped:(id)sender {
    if (self.userEmailTextField.text.length < 1) {
        [Banner showSuccessBannerWithSubtitle:LocalizedString(@"LoginScreenEmailMessage")];
    } else if (![UserManager isValidEmail:self.userEmailTextField.text.trim]) {
        [Banner showSuccessBannerWithSubtitle:LocalizedString(@"LoginScreenValidEmailMessage")];
    } else if (self.passwordTextField.text.length < 1) {
        [Banner showSuccessBannerWithSubtitle:LocalizedString(@"LoginScreenPasswordMessage")];
    } else {
        [ALAlertBanner hideAllAlertBanners];
    
        [self showInProgress:YES];
        UserModel *userModel = [[UserModel alloc]initWithUserEmail:self.userEmailTextField.text andPassword:self.passwordTextField.text];
        [[RequestManager alloc] loginWithUserModel:userModel withCompletionBlock:^(BOOL success, id response) {
            [self showInProgress:NO];
            if (success){
                [UserDefaults setBool:self.rememberMeButton.selected forKey:kRememberMe];
                [UserDefaults setValue:self.userEmailTextField.text forKey:kUserEmail];
                [UserDefaults setValue:self.passwordTextField.text forKey:kUserPassword];
                [UserDefaults setBool:YES forKey:kIsUserLoggedIn];
                [UserDefaults synchronize];
                [Crittercism setUsername:self.userEmailTextField.text];
                if ([UserManager sharedManager].isFirstTime) {
//                    [UIView transitionWithView:ApplicationDelegate.window
//                                      duration:0.5f
//                                       options:UIViewAnimationOptionTransitionFlipFromLeft
//                                    animations:^{
//                                        UINavigationController *controller = [[UINavigationController alloc] initWithRootViewController:[[UIStoryboard storyboardWithName:KProfileStoryboard bundle:nil] instantiateViewControllerWithIdentifier:KProfileViewControllerIdentifier]];
//                                        [[UINavigationBar appearance] setShadowImage:[UIImage new]];
//                                        [[UINavigationBar appearance] setBackgroundImage:[UIImage new] forBarMetrics:UIBarMetricsDefault];
//                                        [[UINavigationBar appearance]  setTranslucent:NO];
//                                        controller.navigationBar.translucent = NO;
//                                        controller.navigationBar.shadowImage = [UIImage new];
//                                        controller.navigationBar.backIndicatorImage = [UIImage new];
//                                        ApplicationDelegate.window.rootViewController = controller;
//                                    } completion:nil];
                    
                    UIStoryboard *tutorialStoryBoard = [UIStoryboard storyboardWithName:kTutorialStoryboard bundle:nil];
                    TutorialPageViewController *pageVC = [tutorialStoryBoard instantiateViewControllerWithIdentifier:@"TutorialPageViewController"];
                    pageVC.isFirstTutorial = YES;
                    [self.navigationController pushViewController:pageVC animated:YES];
                    [self.navigationController setNavigationBarHidden:YES animated:YES];
                } else {
                    UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
                    ApplicationDelegate.tabBarController = [mainStoryboard instantiateViewControllerWithIdentifier:@"MainTabController"];
                    ApplicationDelegate.window.rootViewController = ApplicationDelegate.tabBarController;
                    [[ScheduleManager sharedInstance] fetchAllSchedules];;
                }
            }
        }];
    }
}

- (IBAction)signUpButtonTapped:(id)sender {
    [self performSegueWithIdentifier:kGoToSignUp sender:self];
}

- (IBAction)forgotPasswordButtonTapped:(id)sender {
    [self performSegueWithIdentifier:kGoToForgotPasswordFirstScreen sender:self];
}

- (IBAction)rememberMeButtonTapped:(id)sender {
    self.rememberMeButton.selected = !self.rememberMeButton.selected;
}

#pragma mark - Private methods

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:kGoToSignUp]) {
        segue.destinationViewController.navigationController.navigationBar.hidden = NO;
    }
}

#pragma mark - TextField Delegate methods

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField {
    return YES;
}

- (void)textFieldDidBeginEditing:(UITextField *)textField{
    CGPoint point = (([textField isEqual:self.userEmailTextField])?self.userEmailTextField.frame.origin:self.passwordView.frame.origin);
    point.y = point.y-50;
    point.x = 0;
    [self.scrollView setContentOffset:point];
}

//- (void)textFieldDidBeginEditing:(UITextField *)textField{
//
//        CGRect superRect = [textField convertRect:textField.frame toView:_scrollView];
//        [UIView animateWithDuration:0.3f animations:^{
//            //This calculation ensures that the selected textField will be in the upper 3rd part of view
//            [self.scrollView setContentOffset:CGPointMake(0, (superRect.origin.y - _scrollView.frame.size.height / 3)-50)];
//        }];
//}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    if(textField == self.userEmailTextField) {
        [self.passwordTextField becomeFirstResponder];
    } else {
        [textField resignFirstResponder];
        [self loginButtonTapped:self.loginButton];
    }
    return YES;
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    [self.view endEditing:YES];
}

@end
