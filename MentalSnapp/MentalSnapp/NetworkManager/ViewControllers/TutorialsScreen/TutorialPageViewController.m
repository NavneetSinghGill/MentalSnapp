//
//  TutorialPageViewController.m
//  MentalSnapp
//
//  Created by Systango on 24/02/17.
//  Copyright © 2017 Systango. All rights reserved.
//

#import "TutorialPageViewController.h"
#import "TutorialViewController.h"
#import "TutorialPageModel.h"

@interface TutorialPageViewController () <UIPageViewControllerDataSource, UIPageViewControllerDelegate, RecordProtocol>

@property (weak, nonatomic) IBOutlet UIView *pageContainerView;
@property (weak, nonatomic) IBOutlet UIImageView *pageIndicatorImageView;
@property (weak, nonatomic) IBOutlet UIButton *nextButton;
@property (strong, nonatomic) UIPageViewController *pageController;
@property (strong, nonatomic) NSMutableArray *tutorialPages;
@property (assign, nonatomic) NSInteger currentIndex;

@property (strong, nonatomic) NSArray *pageIndicatorImages;
@property (strong, nonatomic) NSArray *mainImages;
@property (strong, nonatomic) NSArray *titles;
@property (strong, nonatomic) NSArray *descriptions;
@property (assign, nonatomic) NSInteger maxTutorialsCount;

@end

@implementation TutorialPageViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self initialSetup];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (BOOL) prefersStatusBarHidden {
    return YES;
}

#pragma mark - RecordProtocol Delegate method

- (void)recordButtonTapped {
    [self nextButtonTap];
}

#pragma mark - IBActions

- (IBAction)nextButtonTapped:(id)sender
{
    [self nextButtonTap];
}

- (void)nextButtonTap {
    if(self.isFirstTutorial)
    {
        [[UserManager sharedManager] showTutorialScreen:NO];
    }
    else
    {
        [[UserManager sharedManager] showSignupViewController];
        
        [UserDefaults setBool:NO forKey:kIsTutorialShownBefore];
        [UserDefaults synchronize];
    }
}

#pragma mark - Private methods

- (void)initialSetup
{
    [self initialiseTutoarialPages];
    [self.navigationController setNavigationBarHidden:YES];
    
    self.pageController = [[UIPageViewController alloc] initWithTransitionStyle:UIPageViewControllerTransitionStyleScroll navigationOrientation:UIPageViewControllerNavigationOrientationHorizontal options:nil];
    
    self.pageController.dataSource = self;
    self.pageController.delegate = self;
    CGRect frame = [self.pageContainerView bounds];
    frame.size.height = frame.size.height;
    [[self.pageController view] setFrame:frame];
    
    TutorialViewController *initialViewController = [self viewControllerAtIndex:self.currentIndex];
    
    NSArray *viewControllers = [NSArray arrayWithObject:initialViewController];
    
    [self.pageController setViewControllers:viewControllers direction:UIPageViewControllerNavigationDirectionForward animated:NO completion:nil];
    
    [self addChildViewController:self.pageController];
    [self.pageContainerView addSubview:[self.pageController view]];
    [self.pageController didMoveToParentViewController:self];
    
    self.pageIndicatorImageView.image = [self.pageIndicatorImages firstObject];
}

- (void)initialiseTutoarialPages
{
    self.tutorialPages = [NSMutableArray array];
    [self initialiseTutoarialsData];
    
    self.maxTutorialsCount = self.isFirstTutorial ? 12 : 6;
    
    for (int counter = 0; counter < self.maxTutorialsCount; counter ++)
    {
        TutorialPageModel *tutorialPage = [[TutorialPageModel alloc] init];
        tutorialPage.tutorialTitle = [self.titles objectAtIndex:counter];
        tutorialPage.tutorialDescription = [self.descriptions objectAtIndex:counter];
        tutorialPage.pageIndicatorImage = [self.pageIndicatorImages objectAtIndex:counter];
        tutorialPage.mainImage = self.isFirstTutorial ? [self.mainImages objectAtIndex:counter] : [self.mainImages firstObject];
        
        [self.tutorialPages addObject:tutorialPage];
    }
}

- (void)initialiseTutoarialsData
{
    if(self.isFirstTutorial)
    {
        self.titles = @[@"Welcome!",
                        @"How it works",
                        @"Exercises",
                        @"Exercise questions",
                        @"Mood rating",
                        @"Insights",
                        @"My videos",
                        @"Your data",
                        @"Deleting and downloading",
                        @"Your profile",
                        @"One last thing",
                        @"Enjoy telling your story"];
        
        self.descriptions = @[@"Thank you for downloading Mental Snapp; a new video diary service for people actively managing their mental health.\n\nThe purpose of recording video diaries with Mental Snapp is to make your voice and awareness of your mental health useful to you. We believe that you already have the skills to manage your mental health successfully, and creating video diaries on a regular basis can draw out the expertise you have already.",
                              @"We encourage you to record freeform or in your own words as much as possible so it becomes part and parcel of your routine. You can set regular times to record, whenever the time is right for you. We recognise this may take a bit of getting used to! We’ve created some optional prompts to help you through the first few videos.",
                              @"You might have days when you can’t think of what you want to say, don’t worry, we’ve come up with some guided exercises to help you through.\n\nThe guided exercises are split into the following sections:\nEveryday coping\nWellbeing\nPurpose\nRelationships\nSOS",
                              @"After you have selected an exercise category and subcategory, the individual exercises come up as single questions. You can swipe right to select the question you want to answer. You then press record now - or if you would rather - schedule the exercise for later using the calendar icon. You can see your queued exercises on the ‘More’ tab.",
                              @"After recording, then you rate your mood, from ‘the best’ to ‘the worst’ or grades in between using the wheel. You then give the video a feeling - these are taken from Plutchik, a recognised system of emotional categories. You also have the option to add your own free text as tags. These ratings and tags will form an overview of how you are doing so you can track your feelings and emotions.",
                              @"Over time you will be able to track your mood and gain insight on your mental health. In doing so, you will be able to take control again. You can review the videos any time. Single click on a point on the graph to show the tags and name of the video - double click on a point to play the video.",
                              @"You can search the videos by date, exercise category, feeling or any of the freeform text you have entered against them. You can play the videos and share them with others - but only if you show them yourself on your phone. That way you can get an immediate response and you know they’ve been seen.",
                              @"Your data is important to us so we have put policies in place to protect it. We are compliant with the Information Commissioners Office. We make our Terms and Conditions and Privacy Policy available on our website as well as in the app here.",
                              @"Your data remains yours, and you can download the videos at any time. You also have the right to delete your data when you delete the app. We wouldn’t want our time together to be cut short, but if you did want to leave we aim to make it easy for you.",
                              @"You can customise your profile to make it useful to you. You might want to put an emergency contact and their number there so that you have it handy if you need it. You might want to set a reminder to record Mental Snapp, daily, every few days, or weekly. It’s up to you.",
                              @"Sometimes recording a diary is boring, sometimes it’s a chore. It’s an everyday thing, part of the routine. In the poem Born Yesterday, Phillip Larkin reflects on what it is to be ordinary. The poem ends;\n… may you be dull -\nIf that is what a skilled,\nVigilant, flexible,\nUnemphasised, enthralled\nCatching of happiness is called.",
                              @"Use our guide to recording your first videos\nGo straight to recording and using the app"];
        
        self.pageIndicatorImages = @[[UIImage imageNamed:@"page1_1"],
                                     [UIImage imageNamed:@"page1_2"],
                                     [UIImage imageNamed:@"page1_3"],
                                     [UIImage imageNamed:@"page1_4"],
                                     [UIImage imageNamed:@"page1_5"],
                                     [UIImage imageNamed:@"page1_6"],
                                     [UIImage imageNamed:@"page1_7"],
                                     [UIImage imageNamed:@"page1_8"],
                                     [UIImage imageNamed:@"page1_9"],
                                     [UIImage imageNamed:@"page1_10"],
                                     [UIImage imageNamed:@"page1_11"],
                                     [UIImage imageNamed:@"page1_12"]];
        
        self.mainImages = @[[UIImage imageNamed:@"tutorial_1"],
                            [UIImage imageNamed:@"tutorial_2"],
                            [UIImage imageNamed:@"tutorial_3"],
                            [UIImage imageNamed:@"tutorial_4"],
                            [UIImage imageNamed:@"tutorial_5"],
                            [UIImage imageNamed:@"tutorial_6"],
                            [UIImage imageNamed:@"tutorial_7"],
                            [UIImage imageNamed:@"tutorial_8"],
                            [UIImage imageNamed:@"tutorial_9"],
                            [UIImage imageNamed:@"tutorial_10"],
                            [UIImage imageNamed:@"tutorial_11"],
                            [UIImage imageNamed:@"tutorial_last"]];
    }
    else
    {
        self.titles = @[@"Say hello",
                        @"How did that feel?",
                        @"What’s your response?",
                        @"Your stats",
                        @"Who are you speaking to?",
                        @"Congratulations!"];
        
        self.descriptions = @[@"This is your first video diary. Say hello to yourself, to Mental Snapp, introduce yourself, see how it feels. Then rate your mood, tag it with feelings, upload. Well done.",
                              @"When you’re ready, it’s time to record again. How did making that first recording feel? Was it what you were expecting? Is there anything that surprised you? Rate your mood again, tag the feelings, and you’re done.",
                              @"Have you watched yourself back yet? Take some time to watch one or both of the recordings that you’ve made, in preparation to make another one. How does it feel watching yourself back? Have you learnt anything? Any surprises? Tag and upload. Well done.",
                              @"You’re building up a picture of your current state. Look at your stats page, and record a response. Do they seem to reflect where you are at the moment? What would you add or take away? Tell the story of how you were then, and how you are today.",
                              @"You’re building a relationship with yourself as if you were a friend, seeing yourself from the outside. Does this feel like a new way to relate to yourself? What are you learning? Who are you speaking to when you record your own story? Rate your mood, tag your feelings.",
                              @"You’ve reached the end of this guide, but are at the very beginning of your journey to record your own story. In a total of 10 short minutes, you have rated your mood and logged your story 5 times. That process encourages ‘metacognition’ - thinking about thinking - which is a skill that will stand you in good stead in the future. Well done. Keep going."];
        
        self.pageIndicatorImages = @[[UIImage imageNamed:@"page2_1"],
                                     [UIImage imageNamed:@"page2_2"],
                                     [UIImage imageNamed:@"page2_3"],
                                     [UIImage imageNamed:@"page2_4"],
                                     [UIImage imageNamed:@"page2_5"],
                                     [UIImage imageNamed:@"page2_6"]];
        
        self.mainImages = @[[UIImage imageNamed:@"tutorial_11"]];
    }
    
}

- (UIImage *)pageIndicatorImageWithIndex:(NSUInteger)index
{
    TutorialPageModel *tutorial = [self.tutorialPages objectAtIndex:index];
    return tutorial.pageIndicatorImage;
}

- (UIViewController *)currentController
{
    if ([self.pageController.viewControllers count])
    {
        return self.pageController.viewControllers[0];
    }
    
    return nil;
}

- (NSUInteger)currentControllerIndex
{
    TutorialViewController *tutorialVC = (TutorialViewController *) [self currentController];
    
    if (tutorialVC)
    {
        return tutorialVC.index;
    }
    
    return -1;
}

- (TutorialViewController *)viewControllerAtIndex:(NSUInteger)index {
    
    TutorialViewController *childViewController = [[UIStoryboard storyboardWithName:kTutorialStoryboard bundle:nil] instantiateViewControllerWithIdentifier:kTutorialViewControllerIdentifier];
    childViewController.recordDelegate = self;
    childViewController.selectedTutorial = [self.tutorialPages objectAtIndex:index];
    
    childViewController.index = index;
    
    return childViewController;
    
}

#pragma mark - UIPageViewController delegate

- (void)pageViewController:(UIPageViewController *)pageViewController didFinishAnimating:(BOOL)finished previousViewControllers:(NSArray<UIViewController *> *)previousViewControllers transitionCompleted:(BOOL)completed
{
    if(completed)
    {
        self.currentIndex = [self currentControllerIndex];
        self.pageIndicatorImageView.image = [self pageIndicatorImageWithIndex:self.currentIndex];
        
        CATransition *transition = [CATransition animation];
        transition.duration = 1.0f;
        transition.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
        transition.type = kCATransitionFade;
        
        [self.pageIndicatorImageView.layer addAnimation:transition forKey:nil];
        
        if(self.currentIndex == (self.maxTutorialsCount - 1))
        {
            [self.nextButton setTitle:@"Next" forState:UIControlStateNormal];
            self.nextButton.hidden = NO;
            if (_isFirstTutorial) {
                self.nextButton.hidden = YES;
            }
        }
        else
        {
            [self.nextButton setTitle:@"Skip" forState:UIControlStateNormal];
            self.nextButton.hidden = NO;
        }
    }
}

#pragma mark - UIPageViewController data source

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerBeforeViewController:(UIViewController *)viewController {
    
    NSUInteger index = [(TutorialViewController *)viewController index];
    
    if (index == 0) {
        return nil;
    }
    
    // Decrease the index by 1 to return
    index--;
    
    return [self viewControllerAtIndex:index];
    
}

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerAfterViewController:(UIViewController *)viewController {
    
    NSUInteger index = [(TutorialViewController *)viewController index];
    
    index++;
    
    if (index == self.tutorialPages.count) {
        return nil;
    }
    
    return [self viewControllerAtIndex:index];
    
}

@end
