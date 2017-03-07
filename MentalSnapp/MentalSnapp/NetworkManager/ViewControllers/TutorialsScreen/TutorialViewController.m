//
//  TutorialViewController.m
//  MentalSnapp
//
//  Created by Systango on 24/02/17.
//  Copyright © 2017 Systango. All rights reserved.
//

#import "TutorialViewController.h"

@interface TutorialViewController ()

@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UITextView *descriptionTextView;
@property (weak, nonatomic) IBOutlet UIImageView *mainImageView;

@property (weak, nonatomic) IBOutlet UIButton *tapToRecordButton;
@property (weak, nonatomic) IBOutlet UIButton *tapToSignupButton;
@property (weak, nonatomic) IBOutlet UIButton *signatureImageButton;

@end

@implementation TutorialViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self initialSetup];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Private methods

- (void)initialSetup
{
    self.mainImageView.image = self.selectedTutorial.mainImage;
    
    if (self.index < 11) {
        self.titleLabel.text = self.selectedTutorial.tutorialTitle;
        self.descriptionTextView.text = self.selectedTutorial.tutorialDescription;
        
        _tapToRecordButton.hidden = _tapToSignupButton.hidden = _signatureImageButton.hidden = YES;
        _titleLabel.hidden = _descriptionTextView.hidden = NO;
    } else {
        _tapToRecordButton.hidden = _tapToSignupButton.hidden = _signatureImageButton.hidden = NO;
        _titleLabel.hidden = _descriptionTextView.hidden = YES;
    }
}

- (IBAction)tapToRecordButton:(id)sender {
    if ([_recordDelegate conformsToProtocol:@protocol(RecordProtocol)] && [_recordDelegate respondsToSelector:@selector(recordButtonTapped)]) {
        [_recordDelegate recordButtonTapped];
    }
}

- (IBAction)tapToSignupButton:(id)sender {
    [[UserManager sharedManager] showSignupViewController];
}

@end
