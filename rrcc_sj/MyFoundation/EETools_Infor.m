

#import "EETools_Infor.h"

@implementation EETools_Infor

+(void)tools_alert:(NSString *)str{
    UIAlertView *alerview = [[UIAlertView alloc] initWithTitle:@"" message:str delegate:nil cancelButtonTitle:@"知道了" otherButtonTitles:nil, nil];
    [alerview show];
}

+(void)tools_alert:(NSString *)str title:(NSString *)title{
    UIAlertView *alerview = [[UIAlertView alloc] initWithTitle:title message:str delegate:nil cancelButtonTitle:@"知道了" otherButtonTitles:nil, nil];
    [alerview show];
}

#define aMinute 60
#define anHour 3600
#define aDay 86400

+(NSString *)refreshLastUpdatedDate:(NSDate*)date {
    if(date) {
        NSTimeInterval timeSinceLastUpdate = [date timeIntervalSinceNow];
        NSInteger timeToDisplay = 0;
        timeSinceLastUpdate *= -1;
        
        if(timeSinceLastUpdate < anHour) {
            timeToDisplay = (NSInteger) (timeSinceLastUpdate / aMinute);
            
            if(timeToDisplay == /* Singular*/ 0) {
                return [NSString stringWithFormat:NSLocalizedStringFromTable(@"刚刚",@"PullTableViewLan",@"Last uppdate in minutes singular"),(long)timeToDisplay];
            } else {
                /* Plural */
                return [NSString stringWithFormat:NSLocalizedStringFromTable(@"%ld 分钟前",@"PullTableViewLan",@"Last uppdate in minutes plural"), (long)timeToDisplay];
                
            }
            
        } else if (timeSinceLastUpdate < aDay) {
            timeToDisplay = (NSInteger) (timeSinceLastUpdate / anHour);
            if(timeToDisplay == /* Singular*/ 1) {
                return [NSString stringWithFormat:NSLocalizedStringFromTable(@"%ld 小时前",@"PullTableViewLan",@"Last uppdate in hours singular"), (long)timeToDisplay];
            } else {
                /* Plural */
                return [NSString stringWithFormat:NSLocalizedStringFromTable(@"%ld 小时前",@"PullTableViewLan",@"Last uppdate in hours plural"), (long)timeToDisplay];
                
            }
            
        } else {
            NSDateFormatter * dateFormatter = [[NSDateFormatter alloc] init];
            [dateFormatter setDateFormat:@"MM-dd HH:mm"];
            NSString * dateStr = [dateFormatter stringFromDate:date];
            return dateStr;
            timeToDisplay = (NSInteger) (timeSinceLastUpdate / aDay);
            if(timeToDisplay == /* Singular*/ 1) {
                return @"昨天";
                return [NSString stringWithFormat:NSLocalizedStringFromTable(@"%ld 天前",@"PullTableViewLan",@"Last uppdate in days singular"), (long)timeToDisplay];
            } else if(timeToDisplay == 2){
                return @"前天";
                /* Plural */
                return [NSString stringWithFormat:NSLocalizedStringFromTable(@"%ld 天前",@"PullTableViewLan",@"Last uppdate in days plural"), (long)timeToDisplay];
            }else{
                NSDateFormatter * dateFormatter = [[NSDateFormatter alloc] init];
                [dateFormatter setDateFormat:@"MM-dd HH:mm"];
                NSString * dateStr = [dateFormatter stringFromDate:date];
                return dateStr;
            }
            
        }
        
    } else {
        return @" ";
    }
    
}

@end
