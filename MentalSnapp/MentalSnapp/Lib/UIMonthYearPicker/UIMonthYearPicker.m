//
//  Created by Evgeny Yagrushkin on 2012-08-15.
//  Copyright (c) 2012 Evgeny Yagrushkin. All rights reserved.
// base on
// http://stackoverflow.com/questions/3348247/uidatepicker-select-month-and-year

// TODO disable months for max and min years
// TODO return last date of the month date and last date, next last date
// TODO add to guthub
// TODO optional selection for the current month and date
// showCurrentDate

#import "UIMonthYearPicker.h"

// Identifiers of components
#define MONTH ( 0 )
#define YEAR ( 1 )

// Identifies for component views
#define LABEL_TAG 43

@interface UIMonthYearPicker()

@property (nonatomic, strong) NSIndexPath *todayIndexPath;
@property (nonatomic, strong) NSArray *months;
@property (nonatomic, strong) NSArray *years;
@property (nonatomic, strong) NSArray *days;
@property (nonatomic, assign) NSInteger todaysDay;

-(NSArray *)nameOfYears;
-(NSArray *)nameOfMonths;
-(NSArray *)nameOfdays;
-(CGFloat)componentWidth;

-(UILabel *)labelForComponent:(NSInteger)component selected:(BOOL)selected;
-(NSString *)titleForRow:(NSInteger)row forComponent:(NSInteger)component;
-(NSIndexPath *)todayPath;
-(NSInteger)bigRowMonthCount;
-(NSInteger)bigRowYearCount;
-(NSString *)currentMonthName;
-(NSString *)currentYearName;
-(NSString *)currentDayName;

@end

@implementation UIMonthYearPicker

const NSInteger bigRowCount = 1;
NSInteger minYear;
NSInteger maxYear;
const CGFloat rowHeight = 44.f;
const NSInteger numberOfComponents = 2;

@synthesize todayIndexPath;
@synthesize months;
@synthesize years = _years;
@synthesize days = _days;
@synthesize _delegate = _privateDelegate;
@synthesize maximumDate;
@synthesize minimumDate;

-(void)awakeFromNib
{
    [super awakeFromNib];
    
    minYear = [[NSCalendar currentCalendar] components:NSCalendarUnitYear fromDate:[NSDate date]].year;
    maxYear = minYear + 15;
    
    self.months = [self nameOfMonths];
    self.years = [self nameOfYears];
    self.days = [self nameOfdays];
    [self reloadAllComponents];

    self.todayIndexPath = [self todayPath];
    self.todaysDay = [[NSDate date] day];
    self.delegate = self;
    self.dataSource = self;
}

- (void) setMaximumDate:(NSDate *)aMaximumDate{
    
    NSDateComponents *components = [[NSCalendar currentCalendar] components:NSCalendarUnitYear fromDate:aMaximumDate];
    maxYear = [components year];
    if (maxYear < minYear) {
        minYear = maxYear;
        minimumDate = aMaximumDate;
    }
    maximumDate = aMaximumDate;
    self.years = [self nameOfYears];
    
    [self reloadComponent:YEAR];
}

- (void) setMinimumDate:(NSDate *)aMinimumDate{
    NSDateComponents *components = [[NSCalendar currentCalendar] components:NSCalendarUnitYear fromDate:aMinimumDate];
    minYear = [components year];
    if (maxYear < minYear) {
        maxYear = minYear;
        maximumDate = aMinimumDate;
    }
    minimumDate = aMinimumDate;
    self.years = [self nameOfYears];
    [self reloadComponent:YEAR];
}

- (void) setDate:(NSDate *)aDate{
    [self setDate:aDate animated:NO];
}

- (void) setDate:(NSDate *)aDate animated:(BOOL)animated{
    
    NSInteger dateYear;
    NSInteger dateMonth;
    NSInteger dateday;

    NSDateComponents *components = [[NSCalendar currentCalendar] components:NSCalendarUnitMonth fromDate:aDate];
    dateMonth = [components month];
    components = [[NSCalendar currentCalendar] components:NSCalendarUnitYear fromDate:aDate];
    dateYear = [components year];
    
    [self selectRow: dateMonth - 1
        inComponent: MONTH
           animated: NO];
    
    NSInteger rowIndex = dateYear - minYear;
    if (rowIndex < 0) {
        rowIndex = 0;
    }
    
    [self selectRow: rowIndex
        inComponent: YEAR
           animated: animated];
    components = [[NSCalendar currentCalendar] components:NSCalendarUnitDay fromDate:aDate];
    dateday = [components day];
    [self selectRow: dateday-1
        inComponent: 2
           animated: animated];
}

-(NSDate *)date
{
    NSInteger monthCount = [self.months count];
    NSString *month = [self.months objectAtIndex:([self selectedRowInComponent:MONTH] % monthCount)];
    
    NSInteger yearCount = [self.years count];
    NSString *year = [self.years objectAtIndex:([self selectedRowInComponent:YEAR] % yearCount)];
    NSDate *date;
    if(_isOptionalDate){
        NSInteger daysCount = [self.days count];
        NSNumber *day = [self.days objectAtIndex:([self selectedRowInComponent:2] % daysCount)];
        if([day integerValue]!=0){
            self.selectedDay = [day integerValue];
            NSDateFormatter *formatter = [[NSDateFormatter alloc] init]; [formatter setDateFormat:@"dd:MMMM:yyyy"];
            date = [formatter dateFromString:[NSString stringWithFormat:@"%ld:%@:%@",(long)[day integerValue], month, year]];
        } else {
            self.selectedDay = 0;
            NSDateFormatter *formatter = [[NSDateFormatter alloc] init]; [formatter setDateFormat:@"MMMM:yyyy"];
            date = [formatter dateFromString:[NSString stringWithFormat:@"%@:%@", month, year]];
        }
    } else {
        self.selectedDay = 0;
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init]; [formatter setDateFormat:@"MMMM:yyyy"];
        date = [formatter dateFromString:[NSString stringWithFormat:@"%@:%@", month, year]];
    }
    return date;
}

#pragma mark - UIPickerViewDelegate
-(CGFloat)pickerView:(UIPickerView *)pickerView widthForComponent:(NSInteger)component
{
    return [self componentWidth];
}

-(UIView *)pickerView: (UIPickerView *)pickerView
           viewForRow: (NSInteger)row
         forComponent: (NSInteger)component
          reusingView: (UIView *)view
{
    BOOL selected = NO;
    if(component == MONTH)
    {
        NSInteger monthCount = [self.months count];
        NSString *monthName = [self.months objectAtIndex:(row % monthCount)];
        NSString *currentMonthName = [self currentMonthName];
        if([monthName isEqualToString:currentMonthName])
        {
            selected = YES;
        }
    }
    else if(component == YEAR)
    {
        NSInteger yearCount = [self.years count];
        NSString *yearName = [self.years objectAtIndex:(row % yearCount)];
        NSString *currenrYearName  = [self currentYearName];
        if([yearName isEqualToString:currenrYearName])
        {
            selected = YES;
        }
    } else {
        NSInteger dayCount = [self.days count];
        NSNumber *dayName = [self.days objectAtIndex:(row % dayCount)];
        NSString *currenrDayName  = [self currentDayName];
        if([[NSString stringWithFormat:@"%ld",(long)[dayName integerValue]] isEqualToString:currenrDayName])
        {
            selected = YES;
        }
    }
    
    UILabel *returnView = nil;
    if(view.tag == LABEL_TAG)
    {
        returnView = (UILabel *)view;
    }
    else
    {
        returnView = [self labelForComponent: component selected: selected];
    }
    
    returnView.text = [self titleForRow:row forComponent:component];
    return returnView;
}

-(CGFloat)pickerView:(UIPickerView *)pickerView rowHeightForComponent:(NSInteger)component
{
    return rowHeight;
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component{
    if (self._delegate) {
        if ([self._delegate respondsToSelector:@selector(pickerView:didChangeDate:)]) {
            [self._delegate pickerView:self didChangeDate:self.date];
        }
    }
}

#pragma mark - UIPickerViewDataSource
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return (_isOptionalDate)?3:numberOfComponents;
}

-(NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
        if(component == MONTH)
    {
        return [self bigRowMonthCount];
    } else if(component == YEAR){
        return [self bigRowYearCount];
    } else {
        return [self bigRowDayCount];
    }
}

#pragma mark - Util
-(NSInteger)bigRowDayCount
{
    return [self.days count]  * bigRowCount;
}

-(NSInteger)bigRowMonthCount
{
    return [self.months count]  * bigRowCount;
}

-(NSInteger)bigRowYearCount
{
    return [self.years count]  * bigRowCount;
}

-(CGFloat)componentWidth
{
    return CGRectGetWidth(self.bounds) / ((_isOptionalDate)?3:numberOfComponents);
}

-(NSString *)titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    if(component == MONTH)
    {
        NSInteger monthCount = [self.months count];
        return [self.months objectAtIndex:(row % monthCount)];
    } else if(component == YEAR) {
        NSInteger yearCount = [self.years count];
        return [self.years objectAtIndex:(row % yearCount)];
    }else {
        NSInteger daysCount = [self.days count];
        NSNumber *day = [self.days objectAtIndex:(row % daysCount)];
        if([day integerValue] == 0){
            return @"None";
        }
        return [NSString stringWithFormat:@"%ld",(long)[day integerValue]];
    }
}

-(UILabel *)labelForComponent:(NSInteger)component selected:(BOOL)selected
{
    CGRect frame = CGRectMake(0.f, 0.f, [self componentWidth],rowHeight);
    
    UILabel *label = [[UILabel alloc] initWithFrame:frame];
    label.textAlignment = NSTextAlignmentCenter;
    label.backgroundColor = [UIColor clearColor];
    label.font = [UIFont boldSystemFontOfSize:18.f];
    label.userInteractionEnabled = NO;
    label.tag = LABEL_TAG;
    
    return label;
}

-(NSArray *)nameOfdays {
     NSCalendar *c = [NSCalendar currentCalendar];
    NSRange days = [c rangeOfUnit:NSCalendarUnitDay
                           inUnit:NSCalendarUnitMonth
                          forDate:[NSDate dateWithYear:[self.currentYearName integerValue] month:[self.currentMonthName integerValue] day:1]];
    NSMutableArray *array  = [[NSMutableArray alloc] init];
    for (int i= 1; i<=days.length; i++) {
        [array addObject:[NSNumber numberWithInt:i]];
    }
    return array;
}


-(NSArray *)nameOfMonths
{
    NSDateFormatter *dateFormatter = [NSDateFormatter new];
    return [dateFormatter standaloneMonthSymbols];
}

-(NSArray *)nameOfYears
{
    NSMutableArray *years = [NSMutableArray array];
    
    for(NSInteger year = minYear; year <= maxYear; year++)
    {
        NSString *yearStr = [NSString stringWithFormat:@"%li", (long)year];
        [years addObject:yearStr];
    }
    return years;
}

-(void)selectToday
{
    [self selectRow: self.todayIndexPath.row
        inComponent: MONTH
           animated: NO];
    
    [self selectRow: self.todayIndexPath.section
        inComponent: YEAR
           animated: NO];
    
    [self selectRow: self.todaysDay
        inComponent: 2
           animated: NO];
}

-(NSIndexPath *)todayPath // row - month ; section - year
{
    CGFloat row = 0.f;
    CGFloat section = 0.f;
    
    NSString *month = [self currentMonthName];
    NSString *year  = [self currentYearName];
    
    //set table on the middle
    for(NSString *cellMonth in self.months)
    {
        if([cellMonth isEqualToString:month])
        {
            row = [self.months indexOfObject:cellMonth];
            break;
        }
    }
    
    for(NSString *cellYear in self.years)
    {
        if([cellYear isEqualToString:year])
        {
            section = [self.years indexOfObject:cellYear];
            break;
        }
    }
    
    return [NSIndexPath indexPathForRow:row inSection:section];
}

-(NSString *)currentMonthName
{
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"MMMM"];
    return [formatter stringFromDate:[NSDate date]];
}

-(NSString *)currentDayName
{
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"dd"];
    return [formatter stringFromDate:[NSDate date]];
}

-(NSString *)currentYearName
{
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyy"];
    return [formatter stringFromDate:[NSDate date]];
}


@end
