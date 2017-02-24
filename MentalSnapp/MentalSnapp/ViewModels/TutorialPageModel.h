//
//  TutorialPageModel.h
//  MentalSnapp
//
//  Created by Systango on 24/02/17.
//  Copyright © 2017 Systango. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TutorialPageModel : NSObject

@property (nonatomic, strong) UIImage *mainImage;
@property (nonatomic, strong) UIImage *pageIndicatorImage;
@property (nonatomic, copy) NSString *tutorialTitle;
@property (nonatomic, copy) NSString *tutorialDescription;

@end
