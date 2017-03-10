//
//  UserModel.m
//  MentalSnapp
//

#import "UserModel.h"

@implementation UserModel

+ (JSONKeyMapper *)keyMapper {
    return [[JSONKeyMapper alloc] initWithModelToJSONDictionary:@{
                                                                  @"authorizationToken": @"auth_token",
                                                                  @"email": @"email",
                                                                  @"password": @"password",
                                                                  @"confirmPassword": @"password_confirmation",
                                                                  @"phoneNumber": @"phone_number",
                                                                  @"gender": @"gender",
                                                                  @"userId": @"id",
//                                                                  @"userName": @"name",
                                                                  @"firstName": @"first_name",
                                                                  @"lastName" : @"last_name",
                                                                  @"dateOfBirth" : @"date_of_birth",
                                                                  @"profilePicURL" : @"profile_url",
                                                                  @"phoneCountryCode" : @"phone_country_code",
                                                                  }];
}
    
- (UserModel *)initWithUserEmail:(NSString *)email andPassword:(NSString *)password {
    self = [super init];
    
    self.email = email;
    self.password = password;
    
    return self;
}
    
- (UserModel *)initWithUserId:(NSString *)userId andEmail:(NSString *)email andfirstName:(NSString *)firstName andlastName:(NSString *)lastName andPhone:(NSString *)phone andGender:(NSString *)gender andDateOfBirth:(NSString *)dateOfBirth andProfilePic:(NSString *)profilePicURL {
    self = [super init];
    self.userId = userId;
    self.email = email;
    self.firstName = firstName;
    self.lastName = lastName;
    self.phoneNumber = phone;
    self.gender = gender;
    self.dateOfBirth = dateOfBirth;
    self.profilePicURL = profilePicURL;
    self.phoneCountryCode = @"+44";
    return self;
}

@end
