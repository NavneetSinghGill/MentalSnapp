//
//  ProfileViewController.h
//  MentalSnapp
//
//  Copyright © 2016 Systango. All rights reserved.
//

#import "ViewController.h"

@interface ProfileViewController : MSViewController

@property (nonatomic, strong) UserModel *user;

@property (nonatomic, assign) BOOL didOpenFromMoreScreen;

@end
