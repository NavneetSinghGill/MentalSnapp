//
//  Feed.m
//  MentalSnapp
//
//  Copyright (c) 2015 Systango. All rights reserved.
//

#import "Paginate.h"

@implementation Paginate

+ (Paginate *)getPaginateFrom:(NSDictionary *)jsonDict {
    Paginate *pagination = [[Paginate alloc] init];
    
    if ([jsonDict hasValueForKey:kJPage] ) {
        pagination.pageNumber = [NSNumber numberWithInteger:[[jsonDict valueForKey:kJPage] integerValue]];
    }
    if([jsonDict hasValueForKey:@"perPage"]){
        pagination.perPage = [NSNumber numberWithInteger:[[jsonDict valueForKey:@"perPage"] integerValue]];
    }
    if([jsonDict hasValueForKey:@"per_page"]){
        pagination.perPage = [NSNumber numberWithInteger:[[jsonDict valueForKey:@"per_page"] integerValue]];
    }
    if([jsonDict hasValueForKey:@"current_page"]){
        pagination.perPage = [NSNumber numberWithInteger:[[jsonDict valueForKey:@"current_page"] integerValue]];
    }

    pagination.pageResults = [NSArray new];
    return pagination;
}

- (Paginate *)initWithPageNumber:(NSNumber *)number withMoreRecords:(BOOL)boolean andPerPageLimit:(NSInteger)limit{
    self = [super init];
    
    if(self) {
        self.pageNumber = number;
        self.hasMoreRecords = boolean;
        self.perPageLimit = limit;
        self.pageResults = [[NSArray alloc] init];
    }
    return self;
}

- (Paginate *)initWithSocialPageNumber:(NSNumber *)number withMoreRecords:(BOOL)boolean andPerPageLimit:(NSInteger)limit andType:(NSString *)type
{
    self = [super init];
    
    if(self) {
        self.pageNumber = number;
        self.hasMoreRecords = boolean;
        self.perPageLimit = limit;
        self.socialUserType = type;
        self.pageResults = [[NSArray alloc] init];
    }
    return self;
}

- (Paginate *)initPaginationWith:(NSArray *)results pageNumber:(NSNumber *)pageNumber andPerPage:(NSNumber *)perPage {
    self = [super init];
    
    if(self) {
        self.pageResults = results;
        self.pageNumber = pageNumber;
        self.perPage = perPage;
    }
    return self;
}

- (Paginate *)initWithHashTagPageNumber:(NSNumber *)number withMoreRecords:(BOOL)boolean andPerPageLimit:(NSInteger)limit andHashTag:(NSString *)hashTag
{
    self = [super init];
    
    if(self) {
        self.pageNumber = number;
        self.hasMoreRecords = boolean;
        self.perPageLimit = limit;
        self.hashTagText = hashTag;
        self.pageResults = [[NSArray alloc] init];
    }
    return self;
}

- (Paginate *)initWithLastUpdatedAt:(NSDate *)lastUpdatedAt andPerPageLimit:(NSInteger)limit
{
    self = [super init];
    
    if(self) {
        self.lastUpdatedAt = lastUpdatedAt;
        self.perPageLimit = limit;
    }
    return self;
}

#pragma mark - Public Methods

- (void)updatePaginationWith:(Paginate *)page {
    [self addToFeedResultsFrom:page.pageResults];
    self.pageNumber = page.perPage;
    self.perPage = page.perPage;
    NSInteger perPageValue = page.pageResults.count;
    if (perPageValue < self.perPageLimit) {
        self.hasMoreRecords = NO;
    } else {
        self.pageNumber = [NSNumber numberWithInteger:[self.pageNumber integerValue] + 1];
    }
}

#pragma mark - Private Methods

- (void)addToFeedResultsFrom:(NSArray *)array {
    NSMutableArray *mutableResults = [NSMutableArray arrayWithArray:self.pageResults];
    [mutableResults addObjectsFromArray:array];
    self.pageResults = [NSArray arrayWithArray:mutableResults];
}

@end
