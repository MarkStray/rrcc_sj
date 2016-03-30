

#import <Foundation/Foundation.h>

@interface EETools_Infor : NSObject{
    
}

+(void)tools_alert:(NSString *)str;

+(void)tools_alert:(NSString *)str title:(NSString *)title;

+(NSString *)refreshLastUpdatedDate:(NSDate*)date;

@end
