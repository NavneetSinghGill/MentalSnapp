//
//  StatsViewController.m
//  MentalSnapp
//

#import "StatsViewController.h"
#import "HACBarChart.h"
#import "RequestManager.h"
#import "FPPopoverController.h"
#import "FPPopoverKeyboardResponsiveController.h"
#import "MonthYearPickerViewController.h"
#import "LineStatViewController.h"
#import "StatsMoodTableViewCell.h"

@import AVFoundation;
@import AVKit;

static const CGFloat barChartHeight = 160.0;
static const CGFloat barChartCellHeight = 210.0;
static const CGFloat lineChartCellHeight = 240.0;

@interface StatsViewController ()<FPPopoverControllerDelegate, MonthYearPickerViewControllerDelegate>
{
    FPPopoverKeyboardResponsiveController *popover;
    NSArray *data;
    LineStatViewController *lineChartController;
    NSInteger selectedWeek;
    BOOL isNextButtonHidden;
    BOOL isPreviouseButtonHidden;
}
@property (strong, nonatomic) StatsModel *stats;
@property (strong, nonatomic) HACBarChart *barChartView;
@property (strong, nonatomic) UILabel *barChartLabel;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UIView *noContentView;
@property (strong, nonatomic) MonthYearPickerViewController *pickerViewController;

@end

@implementation StatsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.tableView registerNib:[UINib nibWithNibName:KStatsMoodTableViewCell bundle:nil] forCellReuseIdentifier:KStatsMoodTableViewCell];
    [self initialiseBarView];
    [self.noContentView setHidden:YES];
    [self getStatsAPIForMonth:[[NSDate date] month] andYear:[[NSDate date] year]];
    [self setRightMenuButtons:[NSArray arrayWithObject:[self calendarButtonAction]]];
    
    self.pickerViewController = [[UIStoryboard storyboardWithName:KProfileStoryboard bundle:nil] instantiateViewControllerWithIdentifier:kMonthYearPickerViewController];
    self.pickerViewController.modalPresentationStyle = UIModalPresentationOverFullScreen;
    [self.pickerViewController setDateSelection:pastDateOnly];
    [self.pickerViewController setDelegate:self];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshViewForNewRecord) name:kRefreshVideosViewControllerNotification object:nil];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self setNavigationBarButtonTitle:@"Mental Snapp"];
}

-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    [self updateBarChartInfo];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if(self.stats.posts.count > 0)
    {
       // [self.noContentView setHidden:YES];
        [self.tableView setHidden:NO];
    }
    else
    {
       // [self.noContentView setHidden:NO];
        [self.tableView setHidden:YES];
    }
    NSArray *arrayMoods = ([self.stats weekDataInfo].count>selectedWeek)?[[self.stats weekDataInfo] objectAtIndex:selectedWeek]:[NSArray new];
    return (section == 0) ? 0 : arrayMoods.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    StatsMoodTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:KStatsMoodTableViewCell];
    
    if(cell == nil)
    {
        cell = [[StatsMoodTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:KStatsMoodTableViewCell];
    }
    [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
    NSArray *arrayMoods = [[self.stats weekDataInfo] objectAtIndex:selectedWeek];
    NSArray *array = [arrayMoods objectAtIndex:indexPath.row];
    [cell.moodNameLabel setText:[Util getMoodString:[array[0] integerValue]]];
    [cell.moodValueLabel setText:[NSString stringWithFormat:@"%ld Time",(long)[array[1] integerValue]]];
    [cell.moodNameLabel setTextColor:[Util getMoodColor:[array[0] integerValue]]];
    [cell.moodValueLabel setTextColor:[Util getMoodColor:[array[0] integerValue]]];
    return cell;
}


#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (nullable UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    if(section == 0)
        return [self getBarChartView];
    else if(section == 1)
        return [self getLineChartView];
    else
        return nil;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return (section == 0) ? barChartCellHeight : lineChartCellHeight;
}

#pragma mark - Private methods

-(void)refreshViewForNewRecord {
     [self getStatsAPIForMonth:[[NSDate date] month] andYear:[[NSDate date] year]];
}

- (UIBarButtonItem *)calendarButtonAction {
    UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake(0, 4, 30, 30)];
    [button setImage:[UIImage imageNamed:@"calendar"] forState:UIControlStateNormal];
    [button addTarget:self action:@selector(calendarButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *barButtonItem = [[UIBarButtonItem alloc] initWithCustomView:button];
    return barButtonItem;
}

- (UIView *)getBarChartView
{
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.tableView.frame.size.width, barChartHeight)];
    
    [view addSubview:self.barChartView];
    [view addSubview:self.barChartLabel];
    [self updateBarChartInfo];
    return view;
}

- (UIView *)getLineChartView
{
    lineChartController = [[UIStoryboard storyboardWithName:KProfileStoryboard bundle:nil] instantiateViewControllerWithIdentifier:kLineStatViewController];
    lineChartController.parentView = self;
    lineChartController.selectedWeek = selectedWeek+1;
    if(self.stats.posts.count){
        [lineChartController refreshDataForMonth:[self.stats.selectedDate month] andYear:[self.stats.selectedDate year] WithRecords:[NSMutableArray arrayWithArray:self.stats.posts]];
    }
    UIView *view = lineChartController.view;
    
    NSArray *arrayMoods = [self.stats.weekDataInfo objectAtIndex:selectedWeek];
    __block NSInteger maxValuedMood = 0;
    __block NSInteger maxValuedMoodId = 0;
    [arrayMoods enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        NSArray* newValue = obj;
        NSInteger value = [newValue[1] integerValue];
        if (value>maxValuedMood) {
            maxValuedMood = value;
            maxValuedMoodId = [newValue[0] integerValue];
        }
    }];
    
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"MM/dd"];

    NSString *startDateOfFirstWeek = [Util startDateofWeek:selectedWeek+1 inMonth:[self.stats.selectedDate month] inYear:[self.stats.selectedDate year] withFormate:@"MM/dd"];
    NSString *endDateOfLastWeek = [Util endDateofWeek:selectedWeek+1 inMonth:[self.stats.selectedDate month] inYear:[self.stats.selectedDate year] withFormate:@"MM/dd"];
    
    NSDate *date1 = [formatter dateFromString:startDateOfFirstWeek];
    NSDate *date2 = [formatter dateFromString:endDateOfLastWeek];
    
    if([date1 month]<[self.stats.selectedDate month]){
        date1 = [NSDate dateFromString:[NSString stringWithFormat:@"01-%ld-%ld",(long)[self.stats.selectedDate month],(long)[self.stats.selectedDate year]] format:@"dd-MM-yyyy"];
    }
    if([date2 month]>[self.stats.selectedDate month]){
        NSCalendar * calendar = [NSCalendar currentCalendar];
        NSDate * plusOneMonthDate = [date2 dateByAddingMonths: 0];
        NSDateComponents * plusOneMonthDateComponents = [calendar components:NSCalendarUnitMonth fromDate: plusOneMonthDate];
        NSDate * endOfMonth = [[calendar dateFromComponents: plusOneMonthDateComponents] dateByAddingTimeInterval: -1]; // One second before the start of next month
        if(endOfMonth.year != [self.stats.selectedDate year]){
            date2 = [NSDate dateWithYear:[self.stats.selectedDate year] month:[self.stats.selectedDate month] day:endOfMonth.day];
        } else {
            date2 = [NSDate dateFromString:[endOfMonth stringInISO8601Format] format:@"dd-MM-yyyy"];
        }
    }
    
    [formatter setDateFormat:@"MM/dd"];

    NSString* string = [NSString stringWithFormat:@"I was %@ in week (%@ - %@)",[Util getMoodString:maxValuedMoodId],[formatter stringFromDate:date1],[formatter stringFromDate:date2]];
    [lineChartController.weekTitleLabel setText:string];
    [lineChartController.previouseButton addTarget:self action:@selector(previouseButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    [lineChartController.nextButton addTarget:self action:@selector(nextButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    [lineChartController.previouseButton setHidden:isPreviouseButtonHidden];
    [lineChartController.nextButton setHidden:isNextButtonHidden];
    return view;
}

- (void)initialiseBarView
{
    [self initBarChartView];
    [self initBarChartLabelView];
}

- (void)initBarChartView
{
    self.barChartView = [[HACBarChart alloc] initWithFrame:CGRectMake(0, 30, self.view.frame.size.width, barChartHeight)];
    
    // Assign data in bar chart
    
    self.barChartView.vertical = YES;
    self.barChartView.showProgressLabel = YES;
    self.barChartView.showDataValue = YES;
    self.barChartView.showCustomText = YES;
    self.barChartView.numberDividersAxisY = 5;
    self.barChartView.dashedLineColor = [UIColor clearColor];
    self.barChartView.typeBar = HACBarType2;
}


- (void)initBarChartLabelView
{
    // Set bar chart Y axis label
    self.barChartLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, barChartHeight + 15, self.view.frame.size.width, 18)];
    [self.barChartLabel setFont:[UIFont fontWithName:@"Roboto" size:13]];
    self.barChartLabel.textAlignment = NSTextAlignmentCenter;
    [self.barChartLabel setTextColor:[UIColor appUpdatesBlueColor]];
}

- (void)updateBarChartInfo
{
    NSMutableArray *statsData = [NSMutableArray array];
    if(self.stats.barChartMoodData.theBestMood)
        [statsData addObject:@{kHACPercentage:(self.stats.barChartMoodData.theBestMood), kHACColor  : [Util getMoodColor:1], kHACCustomText : [NSString stringWithFormat:@"The Best\n%@%%", (self.stats.barChartMoodData.theBestMood)]}];
    if(self.stats.barChartMoodData.veryGoodMood)
        [statsData addObject:@{kHACPercentage:(self.stats.barChartMoodData.veryGoodMood),  kHACColor  : [Util getMoodColor:2], kHACCustomText : [NSString stringWithFormat:@"Very Good\n%@%%", (self.stats.barChartMoodData.veryGoodMood)]}];
    if(self.stats.barChartMoodData.goodMood)
        [statsData addObject:@{kHACPercentage:(self.stats.barChartMoodData.goodMood),  kHACColor  : [Util getMoodColor:3], kHACCustomText : [NSString stringWithFormat:@"Good\n%@%%", (self.stats.barChartMoodData.goodMood)]}];
    if(self.stats.barChartMoodData.okMood)
        [statsData addObject:@{kHACPercentage:(self.stats.barChartMoodData.okMood),  kHACColor  : [Util getMoodColor:4], kHACCustomText : [NSString stringWithFormat:@"OK\n%@%%", (self.stats.barChartMoodData.okMood)]}];
    if(self.stats.barChartMoodData.badMood)
        [statsData addObject:@{kHACPercentage:(self.stats.barChartMoodData.badMood),  kHACColor  : [Util getMoodColor:5], kHACCustomText : [NSString stringWithFormat:@"Bad\n%@%%", (self.stats.barChartMoodData.badMood)]}];
    if(self.stats.barChartMoodData.veryBadMood)
        [statsData addObject:@{kHACPercentage:(self.stats.barChartMoodData.veryBadMood),  kHACColor  : [Util getMoodColor:6], kHACCustomText : [NSString stringWithFormat:@"Very Bad\n%@%%", (self.stats.barChartMoodData.veryBadMood)]}];
    if(self.stats.barChartMoodData.theWorstMood)
        [statsData addObject:@{kHACPercentage:(self.stats.barChartMoodData.theWorstMood),  kHACColor  : [Util getMoodColor:7], kHACCustomText : [NSString stringWithFormat:@"The Worst\n%@%%", (self.stats.barChartMoodData.theWorstMood)]}];
    
    self.barChartView.data = [NSArray arrayWithArray:statsData];
    [self.barChartView clearChart];
    [self.barChartView draw];
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"MMMM yyyy"];
    self.barChartLabel.text = [formatter stringFromDate:self.stats.selectedDate ? self.stats.selectedDate : [NSDate date]];
    
}

#pragma mark - IBAction method

- (void)calendarButtonTapped:(UIButton *)sender
{
    SAFE_ARC_RELEASE(popover); popover=nil;
    
    //the controller we want to present as a popover
    popover = [[FPPopoverKeyboardResponsiveController alloc] initWithViewController:self.pickerViewController];
    popover.tint = FPPopoverWhiteTint;
    popover.border = NO;
    
    popover.contentSize = CGSizeMake(self.view.getWidth, 320);
    popover.arrowDirection = FPPopoverArrowDirectionAny;
    
    CGRect frame = sender.frame;
    frame.origin.y = frame.origin.y - 10;
    
    UIButton *view = sender;
    view.frame = frame;
    [popover presentPopoverFromView:view];
    
    frame.origin.y = frame.origin.y + 10;
    sender.frame = frame;
    
}

- (void)showPlayerWithRecordPost:(RecordPost *)recordPost
{
    NSURL *videoURL = [NSURL URLWithString:recordPost.videoURL];
    // create an AVPlayer
    AVPlayer *player = [AVPlayer playerWithURL:videoURL];
    AVPlayerLayer *playerLayer = [AVPlayerLayer playerLayerWithPlayer:player];
    [playerLayer setVideoGravity:AVLayerVideoGravityResizeAspectFill];
    
    // create a player view controller
    AVPlayerViewController *avPlayerController = [[AVPlayerViewController alloc]init];
    avPlayerController.player = player;
    [player play];
    
    // show the view controller
    avPlayerController.modalPresentationStyle = UIModalPresentationOverFullScreen;
    [self presentViewController:avPlayerController animated:YES completion:nil];
}

-(void)lineChartDataForMonth:(NSInteger)month andForYear:(NSInteger)year{
    RecordPost *post = [self.stats.posts firstObject];
    NSDate *date = [NSDate dateWithTimeIntervalSince1970:[post.createdAt integerValue]];
    NSDateComponents *components = [[NSCalendar currentCalendar] components:NSCalendarUnitDay | NSCalendarUnitMonth | NSCalendarUnitYear | NSCalendarUnitWeekOfMonth fromDate:date];
    selectedWeek = [components weekOfMonth]-1;
    for (int i=0; i<selectedWeek; i++) {
        [[self.stats weekDataInfo] insertObject:[NSArray new] atIndex:i];
    }
    NSInteger weekCount = [self.stats weekDataInfo].count;
    for (int i=weekCount; i<=[Util weeksOfMonth:month inYear:year]; i++) {
        [[self.stats weekDataInfo] insertObject:[NSArray new] atIndex:i];
    }
}

#pragma mark - API

- (void)getStatsAPIForMonth:(NSInteger)month andYear:(NSInteger)year
{
    [self showInProgress:YES];
    [[RequestManager alloc] getStatsForMonth:month andYear:year withCompletionBlock:^(BOOL success, id response) {
        
        dispatch_async(dispatch_get_main_queue(), ^{
            if(success)
            {
                if(response && [response isKindOfClass:[StatsModel class]])
                {
                    self.stats = response;
                    [self.tableView setHidden:(self.stats.posts.count > 0)];
                    [self.noContentView setHidden:(self.stats.posts.count > 0)];
                    self.stats.selectedDate = [NSDate dateWithYear:year month:month day:1];
                    [self lineChartDataForMonth:month andForYear:year];
                    [self.tableView reloadData];
                    isPreviouseButtonHidden = YES;
                    NSArray *arrayNextMoods = [[self.stats weekDataInfo] objectAtIndex:selectedWeek+1];
                    isNextButtonHidden = ([arrayNextMoods count]>0)?NO:YES;
                }
                else
                {
                    [self.tableView setHidden:YES];
                    [self.noContentView setHidden:NO];
                }
            }
        });
        [self showInProgress:NO];
    }];
}

#pragma mark - Date Picker view Delegate
- (void)didSelectDoneButton:(NSDate *)date withDay:(NSInteger)day
{
    [self getStatsAPIForMonth:[date month] andYear:[date year]];
    [popover dismissPopoverAnimated:YES];
}

- (void)didSelectCancelButton
{
    [popover dismissPopoverAnimated:YES];
}

#pragma mark - Line Chart Delegate
-(void)didSelectWeekSection:(NSInteger)section {
    if(section<=0){
        return;
    }
    NSArray *arrayMoods = [[self.stats weekDataInfo] objectAtIndex:section-1];
    if(arrayMoods.count>0){
        selectedWeek = section-1;
    }
    
    __block NSInteger maxValuedMood = 0;
    __block NSInteger maxValuedMoodId = 0;
    [arrayMoods enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        NSArray* newValue = obj;
        NSInteger value = [newValue[1] integerValue];
        if (value>maxValuedMood) {
            maxValuedMood = value;
            maxValuedMoodId = [newValue[0] integerValue];
        }
    }];
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"MM/dd"];

    NSString *startDateOfFirstWeek = [Util startDateofWeek:selectedWeek+1 inMonth:[self.stats.selectedDate month] inYear:[self.stats.selectedDate year] withFormate:@"MM/dd"];
    NSString *endDateOfLastWeek = [Util endDateofWeek:selectedWeek+1 inMonth:[self.stats.selectedDate month] inYear:[self.stats.selectedDate year] withFormate:@"MM/dd"];
    
    NSDate *date1 = [formatter dateFromString:startDateOfFirstWeek];
    NSDate *date2 = [formatter dateFromString:endDateOfLastWeek];
    
    if([date1 month]<[self.stats.selectedDate month]){
        date1 = [NSDate dateFromString:[NSString stringWithFormat:@"01-%ld-%ld",(long)[self.stats.selectedDate month],(long)[self.stats.selectedDate year]] format:@"dd-MM-yyyy"];
    }
    if([date2 month]>[self.stats.selectedDate month]){
        NSCalendar * calendar = [NSCalendar currentCalendar];
        NSDate * plusOneMonthDate = [date2 dateByAddingMonths: 0];
        NSDateComponents * plusOneMonthDateComponents = [calendar components:NSCalendarUnitMonth fromDate: plusOneMonthDate];
        NSDate * endOfMonth = [[calendar dateFromComponents: plusOneMonthDateComponents] dateByAddingTimeInterval: -1]; // One second before the start of next month
        if(endOfMonth.year != [self.stats.selectedDate year]){
            date2 = [NSDate dateWithYear:[self.stats.selectedDate year] month:[self.stats.selectedDate month] day:endOfMonth.day];
        } else {
            date2 = [NSDate dateFromString:[endOfMonth stringInISO8601Format] format:@"dd-MM-yyyy"];
        }
    }
    
    [formatter setDateFormat:@"MM/dd"];
    
    NSString* string = [NSString stringWithFormat:@"I was %@ in week (%@ - %@)",[Util getMoodString:maxValuedMoodId],[formatter stringFromDate:date1],[formatter stringFromDate:date2]];
    
    [lineChartController.weekTitleLabel setText:string];
    if(selectedWeek != 0){
        NSArray *arrayNextMoods = [[self.stats weekDataInfo] objectAtIndex:selectedWeek+1];
        isNextButtonHidden = ([arrayNextMoods count]>0)?NO:YES;
        NSArray *arrayPreMoods = [[self.stats weekDataInfo] objectAtIndex:selectedWeek-1];
        isPreviouseButtonHidden = ([arrayPreMoods count]>0)?NO:YES;
    } else {
        isPreviouseButtonHidden = YES;
        if([self.stats weekDataInfo].count>0 && [self.stats weekDataInfo].count>selectedWeek+1){
            NSArray *arrayNextMoods = [[self.stats weekDataInfo] objectAtIndex:selectedWeek+1];
            isNextButtonHidden = ([arrayNextMoods count]>0)?NO:YES;
        }
    }
    [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:1] withRowAnimation:UITableViewRowAnimationNone];

}

-(void)didDoubleTapSection:(id)object {
    [self showPlayerWithRecordPost:object];
}

#pragma mark - IBActions
-(IBAction)nextButtonAction:(id)sender {
    [self didSelectWeekSection:(selectedWeek+2)];
}

-(IBAction)previouseButtonAction:(id)sender {
    [self didSelectWeekSection:(selectedWeek)];
}

@end
