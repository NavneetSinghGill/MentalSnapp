//
//  GuidedExcerciseViewController.m
//  MentalSnapp
//
//  Created by Systango on 29/11/16.
//  Copyright © 2016 Systango. All rights reserved.
//

#import "GuidedExcerciseViewController.h"
#import "Paginate.h"
#import "guidedExcerciseCellCollectionViewCell.h"
#import "ExcerciseSubCategoryViewController.h"
#import "RequestManager.h"
#import "GuidedExcercise.h"
#import "RecordViewController.h"

#define _minsScreeniPhoneSwipe ([[UIScreen mainScreen] bounds].size.width * 1/4)

@interface GuidedExcerciseViewController () <UIPageViewControllerDelegate, UIPageViewControllerDataSource, UIGestureRecognizerDelegate, UIScrollViewDelegate>
{
    BOOL isSelectedTab;
    UIScrollView *pageScrollView;
    BOOL isNext;
}

@property (strong, nonatomic) IBOutlet UIView *topTabScrollableView;
@property (strong, nonatomic) Paginate *guidedExcercisePaginate;
@property (assign, nonatomic) NSInteger selectedIndexPath;
@property (strong, nonatomic) IBOutlet UICollectionView *guidedExcerciseCollectionView;
@property (nonatomic, assign) CGFloat lastContentOffset;
@property (nonatomic,strong) UIPageViewController *pageViewController;
@property (strong, nonatomic) IBOutlet UIView *paginationContainerView;
@property (strong, nonatomic) IBOutlet UIView *swipableView;
@property (strong, nonatomic) NSMutableArray *guideExcerciseViewControllers;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *swipableViewLeadingConstraint;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *swipableViewTrailingConstraint;
@property (assign, nonatomic) NSInteger index;
@property (assign, nonatomic) NSInteger selectedViewTag;
@property (strong, nonatomic) IBOutlet UIView *noContentView;
@property (assign, nonatomic) BOOL noDataAvailable;
@property (strong, nonatomic) IBOutlet UILabel *selectedExcerciseName;
@property (strong, nonatomic) IBOutlet UILabel *selectedExcerciseDescription;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *guidedExcerciseLabelHeightConstraint;

@end

@implementation GuidedExcerciseViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Do any additional setup after loading the view.
    _selectedIndexPath = 1;
    self.selectedViewTag = 1;
       
    [self setNavigationBarButtonTitle:@"Mental Snapp"];
      [self showInProgress:YES];
    [self getGuidedExcercise];
    UIPanGestureRecognizer *panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panGestureRecognizer:)];
    [self.guidedExcerciseCollectionView setUserInteractionEnabled:YES];
    [panGesture setCancelsTouchesInView:YES];
    [panGesture setDelaysTouchesEnded:YES];
    [panGesture setDelegate:self];
    [panGesture setMinimumNumberOfTouches:1];
    [self.noContentView setHidden:YES];
    [self.guidedExcerciseCollectionView addGestureRecognizer:panGesture];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    if(_noDataAvailable){
        if(self.guidedExcercisePaginate.pageResults.count<=0){
            [self showInProgress:YES];
            [self getGuidedExcercise];
        }
    }
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _noDataAvailable = YES;
    });
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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

-(void)showDetailOfSelectedExcercise:(GuidedExcercise *)exercise {
//    if(exercise == nil){
//        [self.selectedExcerciseName setText:@"Free form"];
//        [self.selectedExcerciseDescription setText:@"Record any video"];
//    } else {
//        [self.selectedExcerciseName setText:exercise.excerciseName];
//        [self.selectedExcerciseDescription setText:exercise.excerciseDescription];
//    }
}

- (UIViewController *)viewControllerAtIndex:(NSUInteger)index {
    return self.guideExcerciseViewControllers[index];
}

-(void)showScrollSelectedExcerciseForIndexpath:(NSIndexPath *)indexPath withAnimation:(BOOL)animate andGrowValue:(CGFloat)growValue andShrinkValue:(CGFloat)value{
    if(indexPath.item != _selectedIndexPath){
        guidedExcerciseCellCollectionViewCell *selectedCell = (guidedExcerciseCellCollectionViewCell *)[self.guidedExcerciseCollectionView cellForItemAtIndexPath:indexPath];
        [selectedCell setSelectedViewDetail:([self.guidedExcercisePaginate.pageResults count]+2) withAnimation:animate andValue:(animate?0:growValue)];
//        [self showDetailOfSelectedExcercise:((selectedCell.excercise == nil)?nil:selectedCell.excercise)];
        guidedExcerciseCellCollectionViewCell *unSelectedcell = (guidedExcerciseCellCollectionViewCell *)[self.guidedExcerciseCollectionView cellForItemAtIndexPath:[NSIndexPath indexPathForItem:_selectedIndexPath inSection:0]];
        [unSelectedcell setUnSelectedViewDetail:([self.guidedExcercisePaginate.pageResults count]+2) withAnimation:animate andValue:(animate?0:value)];
    }
}

-(void)showSelectedExcerciseForIndexpath:(NSIndexPath *)indexPath withAnimation:(BOOL)animate andGrowValue:(CGFloat)growValue andShrinkValue:(CGFloat)value{
    if(indexPath.item != _selectedIndexPath){
        [self.guidedExcerciseCollectionView scrollToItemAtIndexPath:indexPath atScrollPosition:UICollectionViewScrollPositionCenteredHorizontally animated:YES];
        guidedExcerciseCellCollectionViewCell *selectedCell = (guidedExcerciseCellCollectionViewCell *)[self.guidedExcerciseCollectionView cellForItemAtIndexPath:indexPath];
        [selectedCell setSelectedViewDetail:([self.guidedExcercisePaginate.pageResults count]+2) withAnimation:animate andValue:(animate?0:growValue)];
       // [self showDetailOfSelectedExcercise:((selectedCell.excercise == nil)?nil:selectedCell.excercise)];

        guidedExcerciseCellCollectionViewCell *unSelectedcell = (guidedExcerciseCellCollectionViewCell *)[self.guidedExcerciseCollectionView cellForItemAtIndexPath:[NSIndexPath indexPathForItem:_selectedIndexPath inSection:0]];
        [unSelectedcell setUnSelectedViewDetail:([self.guidedExcercisePaginate.pageResults count]+2) withAnimation:animate andValue:(animate?0:value)];
        _selectedIndexPath = indexPath.item;
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.4 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            isSelectedTab = NO;
        });
    }
}

-(void)showPreSelectedExcerciseForIndexpath:(NSIndexPath *)indexPath AndUnselectedIndexPath:(NSIndexPath *)unselectedIndexPath withAnimation:(BOOL)animate andGrowValue:(CGFloat)growValue andShrinkValue:(CGFloat)value{
        [self.guidedExcerciseCollectionView scrollToItemAtIndexPath:indexPath atScrollPosition:UICollectionViewScrollPositionCenteredHorizontally animated:YES];
        guidedExcerciseCellCollectionViewCell *selectedCell = (guidedExcerciseCellCollectionViewCell *)[self.guidedExcerciseCollectionView cellForItemAtIndexPath:indexPath];
        [selectedCell setSelectedViewDetail:([self.guidedExcercisePaginate.pageResults count]+2) withAnimation:animate andValue:(animate?0:growValue)];
        guidedExcerciseCellCollectionViewCell *unSelectedcell = (guidedExcerciseCellCollectionViewCell *)[self.guidedExcerciseCollectionView cellForItemAtIndexPath:unselectedIndexPath];
      // [self showDetailOfSelectedExcercise:((selectedCell.excercise == nil)?nil:selectedCell.excercise)];

        [unSelectedcell setUnSelectedViewDetail:([self.guidedExcercisePaginate.pageResults count]+2) withAnimation:animate andValue:(animate?0:value)];
        _selectedIndexPath = indexPath.item;
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.4 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            isSelectedTab = NO;
        });
}

- (void)defaultSettings {
    // pageViewController
    self.pageViewController = [[UIPageViewController alloc] initWithTransitionStyle:UIPageViewControllerTransitionStyleScroll
                                                              navigationOrientation:UIPageViewControllerNavigationOrientationHorizontal
                                                                            options:nil];
    
    for (UIView *view in self.pageViewController.view.subviews) {
        if ([view isKindOfClass:[UIScrollView class]]) {
            pageScrollView = (UIScrollView *)view;
            [(UIScrollView *)view setDelegate:self];
            [view setTag:999];
        }
    } 

    [self addViewControllerInPagination];
    [self.paginationContainerView addSubview:self.pageViewController.view];
    [self.pageViewController.view setBackgroundColor:[UIColor clearColor]];
    NSDictionary *viewsDictionary = [[NSDictionary alloc] init];
    CGRect frame = self.view.frame;
    frame.size.height = [self.paginationContainerView frame].size.height-50;
    frame.origin.y = 0;
    [self.pageViewController.view setBounds:frame];
    [self.pageViewController.view setFrame:frame];
    viewsDictionary = @{@"view":self.pageViewController.view};
    if([viewsDictionary count] > 0)
    {
        NSArray *verticalConstraints = [NSLayoutConstraint constraintsWithVisualFormat:@"V:|-0-[view]|" options:0 metrics:nil views:viewsDictionary];
        NSArray *horizontalConstraints = [NSLayoutConstraint constraintsWithVisualFormat:@"H:|[view]|" options:0 metrics:nil views:viewsDictionary];
        [self.paginationContainerView addConstraints:verticalConstraints];
        [self.paginationContainerView addConstraints:horizontalConstraints];
    } 
    // Setup some forwarding events to hijack the scrollView
    // Set self as new delegate
    self.pageViewController.dataSource = self;
    self.pageViewController.delegate = self;
}

-(void)addViewControllerInPagination {
    [self didMoveToParentViewController:self];
    UIStoryboard *profileStoryboard = [UIStoryboard storyboardWithName:KProfileStoryboard bundle:nil];
    self.guideExcerciseViewControllers = [[NSMutableArray alloc] init];
    int tag=2;
    
    RecordViewController *recordViewController = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:kRecordViewController];
    CGRect frame = self.pageViewController.view.frame;
    frame.origin.y=0;
    [recordViewController setViewTag:1];
    [recordViewController.view setFrame:frame];
    recordViewController.isExerciseView = YES;
    [self.guideExcerciseViewControllers addObject:recordViewController];
    
    if(self.guidedExcercisePaginate && self.guidedExcercisePaginate.pageResults.count>0){
        for (GuidedExcercise *excercise in [self.guidedExcercisePaginate pageResults]) {
            ExcerciseSubCategoryViewController *guidedExcercisePage = [profileStoryboard instantiateViewControllerWithIdentifier:kExcerciseSubCategoryViewController];
            CGRect frame = self.pageViewController.view.frame;
            frame.origin.y=0;
            [guidedExcercisePage setViewTag:tag];
            tag++;
            [guidedExcercisePage.view setFrame:frame];
            [guidedExcercisePage setExcercise:excercise];
            [guidedExcercisePage setExcerciseParentViewController:self];
            [self.guideExcerciseViewControllers addObject:guidedExcercisePage];
        }
    }
        self.lastContentOffset = pageScrollView.contentOffset.x;
        self.index = 0;
        if(self.guideExcerciseViewControllers.count>0){
            RecordViewController *recordView = (RecordViewController *) [self viewControllerAtIndex:0];
            CGRect frame = self.pageViewController.view.frame;
            frame.origin.y=0;
            [recordView.view setFrame:frame];
            self.selectedViewTag = recordView.viewTag;
            [self.pageViewController setViewControllers:[NSArray arrayWithObject:recordView] direction:UIPageViewControllerNavigationDirectionForward animated:NO completion:nil];
            //[self showDetailOfSelectedExcercise:nil];
        }
}

- (void)initGuidedPaginate {
    self.guidedExcercisePaginate = [[Paginate alloc] initWithPageNumber:[NSNumber numberWithInt:1] withMoreRecords:YES andPerPageLimit:50];
}

#pragma mark - API Call
-(void)getGuidedExcercise {
    [self initGuidedPaginate];
    [self fetchGuidedExcercise];
}

-(void)fetchGuidedExcercise {
    [[RequestManager alloc] getGuidedExcerciseWithPaginate:self.guidedExcercisePaginate withCompletionBlock:^(BOOL success, id response) {
        if(success){
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.guidedExcercisePaginate updatePaginationWith:response];
                [self.guidedExcerciseCollectionView reloadData];
                if(_guidedExcercisePaginate.pageResults.count>0){
                    [self.noContentView setHidden:YES];
                    [self defaultSettings];
                } else {
                    [self.noContentView setHidden:NO];
                }
            });
        }else {
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.noContentView setHidden:NO];
            });
        }
        [self showInProgress:NO];
   }];
}

#pragma mark - Gesture methods

- (IBAction)panGestureRecognizer:(UIPanGestureRecognizer *)panGesture
{
    isSelectedTab = YES;
    if(self.guidedExcercisePaginate.pageResults.count>0){
    
    CGPoint translatedPoint = [panGesture translationInView:self.swipableView];
    //    NSLog(@"%@ \n %f",panGesture, translatedPoint.x);
         switch (panGesture.state) {
            
        case UIGestureRecognizerStateBegan:
                 break;
        case UIGestureRecognizerStateChanged: {
            
            if(translatedPoint.x > 0.0) // left slide
            {
                if(_selectedIndexPath>1){
                    // change left slide alpha value
                    translatedPoint.y = 0;
                    translatedPoint.x = -translatedPoint.x;
                    if(self.guidedExcerciseCollectionView.contentOffset.x>0 && translatedPoint.x <0){
                        translatedPoint.x=0;
                    }
                    [self.guidedExcerciseCollectionView setContentOffset:translatedPoint animated:YES];
                }
            }
            else if(translatedPoint.x < 0.0) // right slide
            {
                if(_selectedIndexPath < ([self.guideExcerciseViewControllers count])){
                    // change right slide alpha value
                    translatedPoint.y = 0;
                    translatedPoint.x = -translatedPoint.x;
                    if(translatedPoint.x < self.guidedExcerciseCollectionView.frame.size.width){
                        [self.guidedExcerciseCollectionView setContentOffset:translatedPoint animated:YES];
                    }
                }
            }
            break;
        }
            
        case UIGestureRecognizerStateCancelled:
        case UIGestureRecognizerStateEnded:
        {
            dispatch_async(dispatch_get_main_queue(), ^{
                if(translatedPoint.x > 0.0)
                {
                    if(_selectedIndexPath>1){
                        [self showSelectedExcerciseForIndexpath:[NSIndexPath indexPathForRow:(_selectedIndexPath-1) inSection:0] withAnimation:YES andGrowValue:0 andShrinkValue:0];
                        ExcerciseSubCategoryViewController *controller = [self.guideExcerciseViewControllers objectAtIndex:((_selectedIndexPath)-1)];
                        CGRect frame = self.pageViewController.view.frame;
                        frame.origin.y = 0;
                        [controller.view setFrame:frame];
                        self.selectedViewTag = controller.viewTag;
                        [self.pageViewController setViewControllers:@[controller] direction:UIPageViewControllerNavigationDirectionReverse animated:YES completion:nil];
                     //   [self showDetailOfSelectedExcercise:((controller.excercise == nil)?nil:controller.excercise)];
                    }
                }
                else if (translatedPoint.x < 0.0)
                {
                    if(_selectedIndexPath < ([self.guideExcerciseViewControllers count])){
                        [self showSelectedExcerciseForIndexpath:[NSIndexPath indexPathForRow:(_selectedIndexPath+1) inSection:0] withAnimation:YES andGrowValue:0 andShrinkValue:0];
                        ExcerciseSubCategoryViewController *controller = [self.guideExcerciseViewControllers objectAtIndex:((_selectedIndexPath)-1)];
                        CGRect frame = self.pageViewController.view.frame;
                        frame.origin.y = 0;
                        [controller.view setFrame:frame];
                        self.selectedViewTag = controller.viewTag;
                        [self.pageViewController setViewControllers:@[controller] direction:UIPageViewControllerNavigationDirectionForward animated:YES completion:nil];
                      //  [self showDetailOfSelectedExcercise:((controller.excercise == nil)?nil:controller.excercise)];
                    }
                }
                else
                {
                }
            });
            break;
        }
        default:
            break;
         }
    }
}


#pragma mark - Collection view Data Souarce

-(NSInteger) collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return (self.guideExcerciseViewControllers.count>0)?(self.guideExcerciseViewControllers.count+2):3;
}
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    guidedExcerciseCellCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:kguidedExcerciseCellCollectionViewCell forIndexPath:indexPath];
    cell.index = indexPath.item;
    [cell setDefaultViewDetail];
    if(indexPath.item <= [self.guideExcerciseViewControllers count]) {
        if(indexPath.item != 0 && indexPath.item !=([self.guidedExcercisePaginate.pageResults count]+2)) {
            if(1 != indexPath.item){
                [cell setExcercise:[self.guidedExcercisePaginate.pageResults objectAtIndex:indexPath.item-2]];
            }
            if(self.selectedIndexPath == indexPath.item){
                [cell setSelectedViewDetail:([self.guidedExcercisePaginate.pageResults count]+2) withAnimation:YES andValue:0];
            } else {
                [cell setUnSelectedViewDetail:([self.guidedExcercisePaginate.pageResults count]+2) withAnimation:YES andValue:0];
            }
        }
    } else {
        
        if(indexPath.item != 0 && indexPath.item !=2) {
            if(1 == indexPath.item){
                self.selectedIndexPath = 1;
                [cell setSelectedViewDetail:3 withAnimation:YES andValue:0];
            }
        }
    }
    return cell;
}

#pragma mark - Collection View Delegate
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    if(indexPath.row == 0 || indexPath.row>=([self.guidedExcercisePaginate.pageResults count]+2)){
        return;
    }
    if(indexPath.item <= [self.guidedExcercisePaginate.pageResults count]+1){
        isSelectedTab = YES;
        BOOL scrollDirectionLeft = (indexPath.row < _selectedIndexPath)?YES:NO;
        [self showSelectedExcerciseForIndexpath:indexPath withAnimation:YES andGrowValue:0 andShrinkValue:0];
        ExcerciseSubCategoryViewController *controller = [self.guideExcerciseViewControllers objectAtIndex:indexPath.row-1];
        CGRect frame = self.pageViewController.view.frame;
        frame.origin.y = 0;
        [controller.view setFrame:frame];
        self.selectedViewTag = controller.viewTag;
        [self.pageViewController setViewControllers:@[controller] direction:(scrollDirectionLeft)?UIPageViewControllerNavigationDirectionReverse:UIPageViewControllerNavigationDirectionForward animated:YES completion:nil];
//        [self showDetailOfSelectedExcercise:((controller.excercise == nil)?nil:controller.excercise)];
    }
}

-(CGSize) collectionView:(UICollectionView *)collectionView
                  layout:(UICollectionViewLayout *)collectionViewLayout
  sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    return CGSizeMake([collectionView getWidth]/3, [collectionView getHeight]);
}

#pragma mark - ScrollViewDelegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if(scrollView.tag == 999 && !isSelectedTab) {
        CGPoint offset= scrollView.contentOffset;
        CGFloat ratio = offset.x/([self.guidedExcerciseCollectionView getWidth]/3);
       
        offset.y=0;
        if (self.lastContentOffset > scrollView.contentOffset.x) {
            offset.x=(self.guidedExcerciseCollectionView.contentOffset.x-ratio);
        } else {
            offset.x=(self.guidedExcerciseCollectionView.contentOffset.x+ratio);
        }
        
        CGFloat growRadius= ratio+fabs(offset.x);
        CGFloat shrinkRadius= ratio+fabs(offset.x);
        growRadius += KShrinkValue;
        shrinkRadius -= KGrowValue;
        shrinkRadius = (fabs(shrinkRadius)<KGrowValue)?KShrinkValue:shrinkRadius;
        growRadius = (growRadius >=KGrowValue)?KGrowValue:growRadius;
        shrinkRadius = (shrinkRadius < KShrinkValue)?shrinkRadius:KShrinkValue;
        
        if (self.lastContentOffset > scrollView.contentOffset.x) {
            
            if(self.selectedViewTag<=1){
                return;
            }
            if(offset.x>(([self.guidedExcerciseCollectionView getWidth]/3)*(_selectedIndexPath-1))-(([self.guidedExcerciseCollectionView getWidth]/3))) {
                [self.guidedExcerciseCollectionView setContentOffset:offset];
                self.selectedViewTag = (_selectedIndexPath-1);
                [self showScrollSelectedExcerciseForIndexpath:[NSIndexPath indexPathForRow:(_selectedIndexPath-1) inSection:0] withAnimation:NO andGrowValue:growRadius andShrinkValue:shrinkRadius];
            }else {
                self.selectedViewTag = _selectedIndexPath;
                [self.guidedExcerciseCollectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForRow:_selectedIndexPath inSection:0] atScrollPosition:UICollectionViewScrollPositionCenteredHorizontally animated:YES];
            }
        } else if (self.lastContentOffset < scrollView.contentOffset.x) {
            
            if(self.selectedViewTag>=(self.guidedExcercisePaginate.pageResults.count+1)){
                return;
            }
            
            if(offset.x<(([self.guidedExcerciseCollectionView getWidth]/3)*_selectedIndexPath)) {
                [self.guidedExcerciseCollectionView setContentOffset:offset];
                if(self.selectedViewTag<(self.guidedExcercisePaginate.pageResults.count+1)){
                    self.selectedViewTag = (_selectedIndexPath+1);
                    [self showScrollSelectedExcerciseForIndexpath:[NSIndexPath indexPathForRow:(_selectedIndexPath+1) inSection:0] withAnimation:NO andGrowValue:growRadius andShrinkValue:shrinkRadius];
                } else {
                    self.selectedViewTag = _selectedIndexPath;
                    [self.guidedExcerciseCollectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForRow:_selectedIndexPath inSection:0] atScrollPosition:UICollectionViewScrollPositionCenteredHorizontally animated:YES];
                }
            }
        }
    }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
        if(scrollView.contentOffset.x > self.lastContentOffset ) {
            if(self.selectedViewTag == self.selectedIndexPath){
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self showPreSelectedExcerciseForIndexpath:[NSIndexPath indexPathForRow:_selectedIndexPath-1 inSection:0] AndUnselectedIndexPath:[NSIndexPath indexPathForRow:self.selectedViewTag inSection:0] withAnimation:YES andGrowValue:0 andShrinkValue:0];
                    self.selectedViewTag = _selectedViewTag;
                });
            }
        }
        else if (scrollView.contentOffset.x < self.lastContentOffset && (_selectedIndexPath<self.guideExcerciseViewControllers.count)) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [self showPreSelectedExcerciseForIndexpath:[NSIndexPath indexPathForRow:_selectedIndexPath+1 inSection:0] AndUnselectedIndexPath:[NSIndexPath indexPathForRow:self.selectedViewTag inSection:0] withAnimation:YES andGrowValue:0 andShrinkValue:0];
                self.selectedViewTag = _selectedViewTag;
            });
        }
        else
        {
            dispatch_async(dispatch_get_main_queue(), ^{
                
                if(self.selectedViewTag == 0){
                    self.selectedViewTag = _selectedIndexPath+1;
                }
                if(self.selectedViewTag == self.guidedExcercisePaginate.pageResults.count+1){
                    self.selectedViewTag = _selectedIndexPath-1;
                }
                
                if(self.selectedViewTag != _selectedIndexPath){
                    [self showPreSelectedExcerciseForIndexpath:[NSIndexPath indexPathForRow:_selectedIndexPath inSection:0] AndUnselectedIndexPath:[NSIndexPath indexPathForRow:self.selectedViewTag inSection:0] withAnimation:YES andGrowValue:0 andShrinkValue:0];
                    self.selectedViewTag = _selectedIndexPath;
                }
            });
        }
        self.lastContentOffset = scrollView.contentOffset.x;
}


#pragma mark -
#pragma mark -Page Delegate and Data Source
- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerBeforeViewController:(UIViewController *)viewController {
    
    NSUInteger index = [self.guideExcerciseViewControllers indexOfObject:viewController];
//    dispatch_async(dispatch_get_main_queue(), ^{
//        if(index != _selectedIndexPath){
//            [self showSelectedExcerciseForIndexpath:[NSIndexPath indexPathForRow:index+1 inSection:0] withAnimation:YES andGrowValue:0 andShrinkValue:0];
//        }
//    });
    if (index == 0) {
        return nil;
    }
    // Decrease the index by 1 to return
    index--;
    self.index = index;
    isNext = NO;
    
    CGRect frame = self.pageViewController.view.frame;
    ExcerciseSubCategoryViewController *guidedExcercisePage = (ExcerciseSubCategoryViewController *) [self viewControllerAtIndex:index];
    frame.origin.y = 0;
    [guidedExcercisePage.view setBounds:frame];
    return guidedExcercisePage;
}

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerAfterViewController:(UIViewController *)viewController {
    NSUInteger index =[self.guideExcerciseViewControllers indexOfObject:viewController];
//    dispatch_async(dispatch_get_main_queue(), ^{
//        if(index != _selectedIndexPath){
//            [self showSelectedExcerciseForIndexpath:[NSIndexPath indexPathForRow:index+1 inSection:0] withAnimation:YES andGrowValue:0 andShrinkValue:0];
//        }
//    });
    index++;
    if (index >= [self.guideExcerciseViewControllers count]) { return nil; }
    
    self.index = index;
     isNext = YES;
    CGRect frame = self.pageViewController.view.frame;
    ExcerciseSubCategoryViewController *guidedExcercisePage = (ExcerciseSubCategoryViewController *) [self viewControllerAtIndex:index];
    frame.origin.y = 0;
    [guidedExcercisePage.view setBounds:frame];
    return guidedExcercisePage;
}

- (void)pageViewController:(UIPageViewController *)pageViewController didFinishAnimating:(BOOL)finished previousViewControllers:(NSArray *)previousViewControllers transitionCompleted:(BOOL)completed {
    if(completed) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self showSelectedExcerciseForIndexpath:[NSIndexPath indexPathForRow:self.selectedViewTag inSection:0] withAnimation:YES andGrowValue:0 andShrinkValue:0];
        });
    } else {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self showPreSelectedExcerciseForIndexpath:[NSIndexPath indexPathForRow:_selectedIndexPath inSection:0] AndUnselectedIndexPath:[NSIndexPath indexPathForRow:self.selectedViewTag inSection:0] withAnimation:YES andGrowValue:0 andShrinkValue:0];
        });
    }
}

@end
