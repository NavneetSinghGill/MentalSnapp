//
//  LineStatViewController.m
//  MentalSnapp
//
//  Created by Systango on 28/12/16.
//  Copyright © 2016 Systango. All rights reserved.
//

#import "LineStatViewController.h"
#import "LineChart.h"

@interface LineStatViewController ()
{
    LCLineChartView *chartView;
    NSMutableArray *arrayOfRecord;
    NSInteger selectedMonth;
    NSInteger selectedYear;
}
@end

@implementation LineStatViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [chartView hideIndicator];
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

-(void)refreshDataForMonth:(NSInteger)month andYear:(NSInteger)year WithRecords:(NSMutableArray *)array{
    arrayOfRecord = array;
    selectedMonth = month;
    selectedYear = year;
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"dd-MM-yyyy"];
    LCLineChartData *d = [LCLineChartData new];
    NSString *startDateOfFirstWeek = [Util startDateofWeek:1 inMonth:month inYear:year withFormate:@"dd-MM-yyyy"];
    NSString *endDateOfLastWeek = [Util endDateofWeek:[Util weeksOfMonth:month inYear:year] inMonth:month inYear:year withFormate:@"dd-MM-yyyy"];

    NSDate *date1 = [formatter dateFromString:startDateOfFirstWeek];
    NSDate *date2 = [formatter dateFromString:endDateOfLastWeek];

    if([date1 month]<month){
        date1 = [NSDate dateFromString:[NSString stringWithFormat:@"01-%ld-%ld",(long)month,(long)year] format:@"dd-MM-yyyy"];
    }
    if([date2 month]>month){
        NSCalendar * calendar = [NSCalendar currentCalendar];
        NSDate * plusOneMonthDate = [date2 dateByAddingMonths: 0];
        NSDateComponents * plusOneMonthDateComponents = [calendar components:NSCalendarUnitMonth fromDate: plusOneMonthDate];
        NSDate * endOfMonth = [[calendar dateFromComponents: plusOneMonthDateComponents] dateByAddingTimeInterval: -1]; // One second before the start of next month
        if(endOfMonth.year != year){
            date2 = [NSDate dateWithYear:year month:month day:endOfMonth.day];
        } else {
            date2 = [NSDate dateFromString:[endOfMonth stringInISO8601Format] format:@"dd-MM-yyyy"];
        }
    }
    
    d.xMin = [date1 timeIntervalSince1970];
    d.xMax = [date2 timeIntervalSince1970];
    //d.title = @"The title for the legend";
    d.color = [UIColor orangeColor];
    
    NSMutableArray *arr = [NSMutableArray array];
    for(NSUInteger i = 0; i < [array count]; ++i) {
        RecordPost *post = [array objectAtIndex:i];
        NSDate *date = [NSDate dateWithTimeIntervalSince1970:[post.createdAt integerValue]];
        date = [formatter dateFromString:[formatter stringFromDate:date]];
        //[arr addObject:@(d.xMin + ([date timeIntervalSinceReferenceDate] * (d.xMax - d.xMin)))];
        [arr addObject:@([date timeIntervalSince1970])];
    }
    //[arr addObject:@(d.xMin)];
    //[arr addObject:@(d.xMax)];
//    [arr sortUsingComparator:^NSComparisonResult(id obj1, id obj2) {
//        return [obj1 compare:obj2];
//    }];
    NSMutableArray *arr2 = [NSMutableArray array];
    for(NSUInteger i = 0; i < [array count]; ++i) {
        RecordPost *post = [array objectAtIndex:i];
        [arr2 addObject:@([post.moodId integerValue])];
    }
//    [arr2 sortUsingComparator:^NSComparisonResult(id obj1, id obj2) {
//        return [obj1 compare:obj2];
//    }];
    d.itemCount = arr2.count;
    [formatter setDateFormat:[NSDateFormatter dateFormatFromTemplate:@"dd-MM-yyyy" options:0 locale:[NSLocale currentLocale]]];
    d.getData = ^(NSUInteger item) {
        float x = [arr[item] floatValue];
        float y = [arr2[item] floatValue];
        RecordPost *post = [array objectAtIndex:item];
        //NSString *label1 = [formatter stringFromDate:[date1 dateByAddingTimeInterval:x]];
        NSString *a = post.postDesciption;
        if (post.feelings.count != 0) {
            NSDictionary *feeling = [post.feelings firstObject];
            if ([feeling hasValueForKey:@"name"]) {
                NSString *feelingName = [feeling valueForKey:@"name"];
                
                if (a.length != 0) {
                    a = [NSString stringWithFormat:@"Feeling %@, %@",feelingName, a];
                } else {
                    a = [NSString stringWithFormat:@"Feeling %@",feelingName];
                }
            }
        }
        NSString *label2 = [NSString stringWithFormat:@"%@",a];
        return [LCLineChartDataItem dataItemWithX:x y:y xLabel:@"" dataLabel:label2 withData:post];
    };
    
    if(chartView){
        [chartView removeFromSuperview];
    }
    [chartView setClipsToBounds:NO];
    chartView = [[LCLineChartView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width-20, 170)];
    chartView.yMin = 7;
    chartView.yMax = 1;
    chartView.month = month;
    chartView.year = year;
    chartView.selectedWeek = _selectedWeek;
    chartView.ySteps = @[@"T Worst",
                         [NSString stringWithFormat:@"V Bad"],
                         [NSString stringWithFormat:@"Bad"], [NSString stringWithFormat:@"OK"],[NSString stringWithFormat:@"Good"], [NSString stringWithFormat:@"V Good"], [NSString stringWithFormat:@"T Best"]];
    
    NSMutableArray *weekArray = [[NSMutableArray alloc] init];
    for (int i=1; i<=[Util weeksOfMonth:12 inYear:2016]; i++) {
        NSString *startDate = [Util startDateofWeek:i inMonth:month inYear:year withFormate:@"MM/dd"];
        NSString *endDate = [Util endDateofWeek:i inMonth:month inYear:year withFormate:@"MM/dd"];
        
        if(i==1){
            startDate = [NSDate stringFromDate:date1 format:@"MM/dd"];
        }
        
        if(i==[Util weeksOfMonth:12 inYear:2016]){
            endDate = [NSDate stringFromDate:date2 format:@"MM/dd"];
        }

        NSString* string = [NSString stringWithFormat:@"%@ - %@",startDate,endDate];
        [weekArray addObject:string];
    }
    
    chartView.xSteps = [NSArray arrayWithArray:weekArray];
    chartView.data = @[d];
    chartView.lineDelegate = _parentView;
    CGFloat fontValue = floorf((self.view.frame.size.width*1.9)/100);

    [chartView setXScaleFont:[UIFont systemFontOfSize:fontValue]];
    [chartView setScaleFont:[UIFont systemFontOfSize:fontValue]];
    for (UIView *view in [self.chatContainerView subviews]) {
        [view removeFromSuperview];
    }
    [self.chatContainerView addSubview:chartView];
    [self.headingLabel setText:[NSString stringWithFormat:@" %d/%ld's Analysis",month,(long)year]];
}

@end
