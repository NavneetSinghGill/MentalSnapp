//
//  UserModel.h
//  MentalSnapp
//

#import <JSONModel/JSONModel.h>

@interface UserModel : JSONModel

@property(strong, nonatomic) NSString <Optional> *firstName;
@property(strong, nonatomic) NSString <Optional> *lastName;
//@property(strong, nonatomic) NSString <Optional> *userName;
@property(strong, nonatomic) NSString <Optional> *email;
@property(strong, nonatomic) NSString <Optional> *password;
@property(strong, nonatomic) NSString <Optional> *confirmPassword;
@property(strong, nonatomic) NSString <Optional> *dateOfBirth;
@property(strong, nonatomic) NSString <Optional> *phoneNumber;
@property(strong, nonatomic) NSString <Optional> *gender;
@property(strong, nonatomic) NSString <Optional> *userId;
@property(strong, nonatomic) NSString <Optional> *profilePicURL;
@property(strong, nonatomic) NSString <Optional> *phoneCountryCode;


- (UserModel *)initWithUserEmail:(NSString *)email andPassword:(NSString *)password;
- (UserModel *)initWithUserId:(NSString *)userId andEmail:(NSString *)email andfirstName:(NSString *)firstName andlastName:(NSString *)lastName andPhone:(NSString *)phone andGender:(NSString *)gender andDateOfBirth:(NSString *)dateOfBirth andProfilePic:(NSString *)profilePicURL;

@end
