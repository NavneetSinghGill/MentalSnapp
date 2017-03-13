//
//  RecordViewController.m
//  MentalSnapp
//

#import "RecordViewController.h"
#import "RecordAlertViewController.h"
#import "MoodViewController.h"

@interface RecordViewController () <UIImagePickerControllerDelegate>
@property (strong, nonatomic) IBOutlet UILabel *welcomeLabel;
@property (strong, nonatomic) IBOutlet UIButton *recordButton;
@property (strong, nonatomic) IBOutlet UIView *welcomeView;


- (IBAction)recordButtonAction:(id)sender;


@end

@implementation RecordViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(cleanRVC) name:kCleanRecordViewControllerNotification object:nil];
    [[UserManager sharedManager] setValueInLoggedInUserObjectFromUserDefault];
    NSString *firstname = [UserDefaults valueForKey:@"firstName"];
    NSString *lastname = [UserDefaults valueForKey:@"lastName"];
    
    NSString *userName = [NSString stringWithFormat:@"%@ %@",firstname.length?firstname:@"",lastname.length?lastname:@""];
    _welcomeLabel.text = [NSString stringWithFormat:@"Welcome back \n%@, \nwhat do you want to record today?",userName];
    
    UIFont *boldFont = [UIFont fontWithName:@"Roboto-Bold" size:22.0f];
    NSMutableAttributedString *attText = [[NSMutableAttributedString alloc] initWithString:_welcomeLabel.text];
    [attText addAttribute:NSFontAttributeName value:boldFont range:[_welcomeLabel.text rangeOfString:userName]];
    [attText addAttribute:NSForegroundColorAttributeName value:[UIColor colorWithRed:233.0/255.0 green:101.0/255.0 blue:58.0/255.0 alpha:1.0] range:[_welcomeLabel.text rangeOfString:userName]];
    _welcomeLabel.attributedText = attText;
    
    _welcomeLabel.transform = CGAffineTransformScale(_welcomeLabel.transform, 0.35, 0.35);
    [UIView animateWithDuration:1.0 animations:^{
        _welcomeLabel.transform = CGAffineTransformScale(_welcomeLabel.transform, 3, 3);
    }];
    
}

- (void)viewWillAppear:(BOOL)animated {
    if(_isExerciseView) {
        [self.welcomeView setHidden:NO];
    } else {
        [self setNavigationBarButtonTitle:@"Mental Snapp"];
        [self.welcomeView setHidden:YES];
    }
}

#pragma mark - Image picker delegate
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info {
        [picker dismissViewControllerAnimated:YES completion:^{
        MoodViewController *moodViewController = [[UIStoryboard storyboardWithName:KProfileStoryboard bundle:nil] instantiateViewControllerWithIdentifier:kMoodViewController];
        NSURL *urlvideo = [info objectForKey:UIImagePickerControllerMediaURL];
        moodViewController.videoURL = urlvideo;
        if(self.exercise)
        {
            moodViewController.excercise = self.exercise;
        }
        
    //[ApplicationDelegate.tabBarController setSelectTabIndex:1];
        UINavigationController *navController = ApplicationDelegate.tabBarController.selectedViewController;
        //[navController popToRootViewControllerAnimated:NO];
        [navController pushViewController:moodViewController animated:YES];
    }];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    self.exercise = nil;
    [ApplicationDelegate.tabBarController setSelectTabIndex:0];
    [ApplicationDelegate.tabBarController setSelectedIndex:0];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [picker dismissViewControllerAnimated:YES completion:nil];
    });
}

#pragma mark - Private methods

- (void)cleanRVC
{
    self.exercise = nil;
}

#pragma mark - IBAction methods

- (IBAction)recordButtonAction:(id)sender {
    
    [Util openCameraView:self WithAnimation:NO];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.4 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        
        if(![UserDefaults boolForKey:kIsCameraDurationAlertShown])
        {
            [UserDefaults setBool:YES forKey:kIsCameraDurationAlertShown];
            RecordAlertViewController *recordAlertView = [[UIStoryboard storyboardWithName:KProfileStoryboard bundle:nil] instantiateViewControllerWithIdentifier:kRecordAlertViewController];
            recordAlertView.modalPresentationStyle = UIModalPresentationOverFullScreen;
            [self.presentedViewController presentViewController:recordAlertView animated:NO completion:nil];
        }
    });
}
@end
