//
//  TutorialViewController.h
//  MentalSnapp
//
//  Created by Systango on 24/02/17.
//  Copyright © 2017 Systango. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TutorialPageModel.h"
#import "MSViewController.h"

@protocol RecordProtocol <NSObject>

- (void)recordButtonTapped;

@end

@interface TutorialViewController : MSViewController

@property (strong, nonatomic) TutorialPageModel *selectedTutorial;

@property (assign, nonatomic) NSInteger index;

@property (assign, nonatomic) id<RecordProtocol> recordDelegate;

@property (assign, nonatomic) BOOL didOpenFromMoreScreen;

@end
