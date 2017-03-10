//
//  MoreViewController.m
//  MentalSnapp
//

#import "MoreViewController.h"
#import "MoreTableViewCell.h"
#import "ProfileViewController.h"
#import "SupportScreenViewController.h"
#import "TermsViewController.h"
#import "TutorialPageViewController.h"

@interface MoreViewController () <UITableViewDelegate, UITableViewDataSource> {
    NSArray *tableViewCellTitles;
    NSArray *tableViewCellTitleImageNames;
    ProfileViewController *profileViewController;
    SupportScreenViewController *supportScreenViewController;
}

@property(weak, nonatomic) IBOutlet UITableView *tableView;

@end

@implementation MoreViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self initialSetup];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    self.tabBarController.tabBar.hidden = NO;
    [[self navigationController] setNavigationBarHidden:NO];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
//    self.navigationController.navigationBar.hidden = NO;
//    self.tabBarController.tabBar.hidden = NO;
    
}

#pragma mark - Private methods

- (void)initialSetup {
    [self setNavigationBarButtonTitle:@"Mental Snapp"];
    
    tableViewCellTitles = @[@"Queued exercises", @"Profile", @"Technical support", @"Terms and conditions", @"Privacy policy", @"How To Use"];//, @"How to record"];
    tableViewCellTitleImageNames = @[@"MoreQueuedExercise", @"MoreProfile", @"MoreIssue", @"MoreReport", @"MorePolicy", @"MoreHowToUse"];//, @"MoreHowToRecord"];
    [self.tableView reloadData];
}

#pragma mark - IBAction methods

- (IBAction)termsButtonTapped:(id)sender {
    [self performSegueWithIdentifier:@"ToTermsScreen" sender:self];
}

#pragma mark - TableView methods
#pragma mark Datasource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return tableViewCellTitles.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    MoreTableViewCell *moreTableViewCell = [tableView dequeueReusableCellWithIdentifier:kMoreScreenTableViewCellIdentifier];
    if (!moreTableViewCell) {
        moreTableViewCell = [[MoreTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:kMoreScreenTableViewCellIdentifier];
    }
    
    moreTableViewCell.headingLabel.text = tableViewCellTitles[indexPath.row];
    [moreTableViewCell.headingIconButton setImage:[UIImage imageNamed:[tableViewCellTitleImageNames objectAtIndex:indexPath.row]] forState:UIControlStateNormal];
    moreTableViewCell.selectionStyle = UITableViewCellSelectionStyleGray;
    
    return moreTableViewCell;
}

#pragma mark Delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    switch (indexPath.row) {
        case 0:
            [self performSegueWithIdentifier:kGoToQueuedExercisesScreen sender:self];
            break;
            
        case 1: {
            UIStoryboard *profileStoryboard = [UIStoryboard storyboardWithName:KProfileStoryboard bundle:nil];
            profileViewController = [profileStoryboard instantiateViewControllerWithIdentifier:KProfileViewControllerIdentifier];
            profileViewController.didOpenFromMoreScreen = YES;
            [self.navigationController pushViewController:profileViewController animated:YES];
            break;
        }
        case 2: {
            UIStoryboard *profileStoryboard = [UIStoryboard storyboardWithName:KProfileStoryboard bundle:nil];
            supportScreenViewController = [profileStoryboard instantiateViewControllerWithIdentifier:KSupportScreenViewController];
            [self.navigationController pushViewController:supportScreenViewController animated:YES];
            break;
        }
        case 3: {
            [self performSegueWithIdentifier:@"ToTermsScreen" sender:self];
            break;
        }
        case 4: {
            [self performSegueWithIdentifier:@"ToPrivacyPolicyScreen" sender:self];
            break;
        }
        case 5: {
            TutorialPageViewController *tutorialPageViewController = [[UIStoryboard storyboardWithName:@"TutorialStoryboard" bundle:nil] instantiateViewControllerWithIdentifier:@"TutorialPageViewController"];
            tutorialPageViewController.isFirstTutorial = YES;
            tutorialPageViewController.didOpenFromMoreScreen = YES;
            [self.navigationController pushViewController:tutorialPageViewController animated:YES];
            [[self navigationController] setNavigationBarHidden:YES animated:YES];
            self.tabBarController.tabBar.hidden = YES;
            break;
        }
        case 6: {
            TutorialPageViewController *tutorialPageViewController = [[UIStoryboard storyboardWithName:@"TutorialStoryboard" bundle:nil] instantiateViewControllerWithIdentifier:@"TutorialPageViewController"];
            tutorialPageViewController.didOpenFromMoreScreen = YES;
            [self.navigationController pushViewController:tutorialPageViewController animated:YES];
            [[self navigationController] setNavigationBarHidden:YES animated:YES];
            self.tabBarController.tabBar.hidden = YES;
            break;
        }
            
        default:
            break;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 44;
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"ToTermsScreen"]) {
        TermsViewController *termsViewController = segue.destinationViewController;
        termsViewController.contentType = TermsAndCondition;
    } else if ([segue.identifier isEqualToString:@"ToPrivacyPolicyScreen"]) {
        TermsViewController *termsViewController = segue.destinationViewController;
        termsViewController.contentType = PrivacyPolicy;
    }
}

@end
