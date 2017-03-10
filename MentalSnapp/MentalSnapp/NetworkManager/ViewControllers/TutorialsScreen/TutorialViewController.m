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
@property (weak, nonatomic) IBOutlet UIImageView *signatureImageView;

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
        
        if (_index == 10) {
//            for (NSString *fontt in [UIFont familyNames]) {
//                [UIFont fontNamesForFamilyName:fontt];
//            }
            
            NSMutableAttributedString *attString = [_descriptionTextView.attributedText mutableCopy];
            UIFont *font1 = [UIFont fontWithName:@"Roboto-LightItalic" size:15.f];
            [attString addAttribute:NSFontAttributeName value:font1 range:NSMakeRange(0, self.descriptionTextView.text.length)];
            UIFont *font = [UIFont fontWithName:@"Roboto-Light" size:14.f];
            [attString addAttribute:NSFontAttributeName value:font range:[_descriptionTextView.text rangeOfString:@"Sometimes recording a diary is boring, sometimes it’s a chore. It’s an everyday thing, part of the routine. In the poem Born Yesterday, Phillip Larkin reflects on what it is to be ordinary. The poem ends;\n\n"]];
            _descriptionTextView.attributedText = attString;
        } else {
            UIFont *font = [UIFont fontWithName:@"Roboto-Light" size:14.f];
            NSMutableAttributedString *attString = [[NSMutableAttributedString alloc]initWithString:_descriptionTextView.text];
            [attString addAttribute:NSFontAttributeName value:font range:NSMakeRange(0, _descriptionTextView.text.length)];
            _descriptionTextView.attributedText = attString;
        }
        
        _tapToRecordButton.hidden = _tapToSignupButton.hidden = _signatureImageView.hidden = YES;
        _titleLabel.hidden = _descriptionTextView.hidden = NO;
    } else {
        _tapToRecordButton.hidden = _tapToSignupButton.hidden = _signatureImageView.hidden = NO;
        _titleLabel.hidden = _descriptionTextView.hidden = YES;
        
        if (_didOpenFromMoreScreen) {
            [_tapToRecordButton setTitle:@"Go on, give it a try!" forState:UIControlStateNormal];
            [_tapToRecordButton.titleLabel setFont:[UIFont fontWithName:@"Roboto-Medium" size:15.f]];
            _tapToSignupButton.hidden = YES;
        } else {
            [_tapToRecordButton setTitle:@"Tap here for our guide to recording your first video" forState:UIControlStateNormal];
            _tapToSignupButton.hidden = NO;
        }
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
