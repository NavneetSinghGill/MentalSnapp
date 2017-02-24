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
    self.titleLabel.text = self.selectedTutorial.tutorialTitle;
    self.descriptionTextView.text = self.selectedTutorial.tutorialDescription;
    self.mainImageView.image = self.selectedTutorial.mainImage;
}

@end
