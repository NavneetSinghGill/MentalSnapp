//
//  ScheduleRequest.m
//  MentalSnapp
//
//  Created by Systango on 19/12/16.
//  Copyright © 2016 Systango. All rights reserved.
//

#import "ScheduleRequest.h"
#import "Paginate.h"

@interface ScheduleRequest ()

@property (nonatomic, strong) NSMutableDictionary *parameters;

@end

@implementation ScheduleRequest

- (id)initWithGetSchedules:(Paginate *)paginate
{
    self = [super init];
    if (self)
    {
        _parameters = [NSMutableDictionary dictionary];
        
        if (paginate.hasMoreRecords) {
            [_parameters setObject:paginate.pageNumber forKey:kJPage];
        }
        [_parameters setObject:[NSNumber numberWithInteger:paginate.perPageLimit] forKey:kJPerPage];
        
        self.urlPath = kSchedulesAPI;
    }
    return self;
}

- (id)initWithEditSchedule:(ScheduleModel *)schedule
{
    self = [super init];
    if (self)
    {
        NSMutableDictionary *dictionary = [[schedule toDictionary] mutableCopy];
        _parameters = [NSMutableDictionary dictionaryWithObject:dictionary forKey:@"schedules"];
        self.urlPath = [NSString stringWithFormat:kEditSchedulesAPI, schedule.scheduleId];
    }
    return self;
}

- (id)initWithDeleteSchedule:(ScheduleModel *)schedule
{
    self = [super init];
    if (self)
    {
        _parameters = [NSMutableDictionary dictionaryWithObject:schedule.scheduleId forKey:@"id"];
        self.urlPath = [NSString stringWithFormat:kEditSchedulesAPI, schedule.scheduleId];
    }
    return self;
}

- (NSMutableDictionary *)getParams {
    if (_parameters) {
        return _parameters;
    } else {
        return [NSMutableDictionary dictionary];
    }
}

@end
