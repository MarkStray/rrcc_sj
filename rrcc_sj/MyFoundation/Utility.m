//
//  Utility.m
//  CloudTravel
//
//  Created by hetao on 10-12-5.
//  Copyright 2010 oulin. All rights reserved.
//

#import "Utility.h"
#import <Reachability.h>
#import <JSONKit.h>
#import "NSDictionary+expanded.h"
//#import "DMHessian.h"
#import <arpa/inet.h>
#import "AppDelegate.h"
#include <sys/socket.h>
#include <sys/sysctl.h>
#include <net/if.h>
#include <net/if_dl.h>
#import "LoginViewController.h"



#define picMidWidth 200
#define picSmallWidth 100
@interface Utility (){
    UITextField *accountField,*passField;
    NSString *phoneNum;
    UIAlertView *alertview;
    NSString *strIFlyType;
}
@property (nonatomic,strong) NSURL *phoneNumberURL;
@property (nonatomic,strong) Reachability *reachability;
@end

@implementation Utility

static Utility *_utilityinstance=nil;
static dispatch_once_t utility;

+(id)Share
{
    dispatch_once(&utility, ^ {
        _utilityinstance = [[Utility alloc] init];
    });
	return _utilityinstance;
}
#pragma mark validateMobile
-(BOOL)validateMobileNumber:(NSString *)mobileNum
{
    //    电信号段:133/153/180/181/189/177
    //    联通号段:130/131/132/155/156/185/186/145/176
    //    移动号段:134/135/136/137/138/139/150/151/152/157/158/159/182/183/184/187/188/147/178
    //    虚拟运营商:170
    NSString *MOBILE = @"^1(3[0-9]|4[57]|5[0-35-9]|8[0-9]|7[06-8])\\d{8}$";
    NSPredicate *regextestmobile = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", MOBILE];
    return [regextestmobile evaluateWithObject:mobileNum];
    
}

#pragma mark validateEmail
- (BOOL) validateEmail: (NSString *) candidate {
    NSString *emailRegex = @"[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}"; 
    NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegex];
    return [emailTest evaluateWithObject:candidate];
}

#pragma ImagePeSize
-(CGFloat)percentage:(NSString*)per width:(NSInteger)width
{
    if (per) { 
        NSArray *stringArray = [per componentsSeparatedByString:@"*"];
        
        if ([stringArray count]==2) {
            CGFloat w=[[stringArray objectAtIndex:0] floatValue];
            CGFloat h=[[stringArray objectAtIndex:1] floatValue];
            if (w>=width) {
                return h*width/w;
            }else{
                return  h;
            }
        }
    }
    return width;
}

//判断ios版本AVAILABLE
- (BOOL)isAvailableIOS:(CGFloat)availableVersion
{
    if ([[[UIDevice currentDevice] systemVersion] floatValue]>=availableVersion) {
        return YES;
    }else{
        return NO;
    }
}

#pragma mark TimeTravel
- (NSString*)timeToNow:(NSString*)theDate
{
    if (!theDate) {
        return nil;
    }
    NSDateFormatter *dateFormatter=[[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm"];
    NSDate *d=[dateFormatter dateFromString:theDate];
    if (!d) {
        return theDate;
    }
    
    NSTimeInterval late=[d timeIntervalSince1970]*1;
    
    
    NSDate* dat = [NSDate dateWithTimeIntervalSinceNow:0];
    NSTimeInterval now=[dat timeIntervalSince1970]*1;
    NSString *timeString=@"";
    
    NSTimeInterval cha=(now-late)>0 ? (now-late) : 0;
    
    if (cha/3600<1) {
        timeString = [NSString stringWithFormat:@"%f", cha/60];
        timeString = [timeString substringToIndex:timeString.length-7];
        timeString=[NSString stringWithFormat:@"%@ 分前", timeString];
        
    }else if (cha/3600>1 && cha/3600<24) {
        timeString = [NSString stringWithFormat:@"%f", cha/3600];
        timeString = [timeString substringToIndex:timeString.length-7];
        timeString=[NSString stringWithFormat:@"%@ 小时前", timeString];
    }
    else
    {

        timeString = [NSString stringWithFormat:@"%.0f 天前",cha/3600/24];
    }
    
    return timeString;
}
+ (void)alertError:(NSString*)content
{
    dispatch_async(dispatch_get_main_queue(), ^{
    });
}
+ (void)alertSuccess:(NSString*)content
{
    dispatch_async(dispatch_get_main_queue(), ^{
    });
}
- (void)alert:(NSString*)content
{
    [self alert:content delegate:nil];
}
- (void)alert:(NSString*)content delegate:(id)delegate
{
    dispatch_async(dispatch_get_main_queue(), ^{
        if (alertview) {
            [alertview dismissWithClickedButtonIndex:-1 animated:NO];
        }
        alertview =  [[UIAlertView alloc] initWithTitle:UI_language(@"提示", @"tips") message:content delegate:delegate cancelButtonTitle:nil otherButtonTitles:UI_language(@"确定", @"OK"), nil] ;[alertview show];//UI_language(@"取消", @"cancel")
    });
}
/**
 *	保存obj的array到本地，如果已经存在会替换本地。
 *
 *	@param	obj	待保存的obj
 *	@param	key	保存的key
 */
+ (void)saveToArrayDefaults:(id)obj forKey:(NSString*)key
{
    [self saveToArrayDefaults:obj replace:obj forKey:key];
}
+ (void)saveToArrayDefaults:(id)obj replace:(id)oldobj forKey:(NSString*)key
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSArray *array = [defaults valueForKey:key];
    
    NSMutableArray *marray = [NSMutableArray array];
    if (!oldobj) {
        oldobj = obj;
    }
    if (array) {
        [marray addObjectsFromArray:array];
        if ([marray containsObject:oldobj]) {
            [marray replaceObjectAtIndex:[marray indexOfObject:oldobj] withObject:obj];
        }else{
            [marray addObject:obj];
        }
    }else{
      [marray addObject:obj];  
    }
    [defaults setValue:marray forKey:key];
    [defaults synchronize];
}

+ (BOOL)removeForArrayObj:(id)obj forKey:(NSString*)key
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSArray *array = [defaults valueForKey:key];
    
    NSMutableArray *marray = [NSMutableArray array];
    if (array) {
        [marray addObjectsFromArray:array];
        if ([marray containsObject:obj]) {
            [marray removeObject:obj];
        }
    }
    if (marray.count) {
        [defaults setValue:marray forKey:key];
    }else{
        [defaults removeObjectForKey:key];
    }
    [defaults synchronize];
    return marray.count;
}
/**
 *	保存obj到本地
 *
 *	@param	obj	数据
 *	@param	key	键
 */
+ (void)saveToDefaults:(id)obj forKey:(NSString*)key
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setValue:obj forKey:key];
    [defaults synchronize];
}

+ (id)defaultsForKey:(NSString*)key
{
    return [[NSUserDefaults standardUserDefaults] valueForKey:key];
}
+ (void)removeForKey:(NSString*)key
{
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:key];
}

+(id)uid
{
    return [[Utility Share] userId];
}
-(void)ShowMessage:(NSString *)title msg:(NSString *)msg
{
	UIAlertView *alert=[[UIAlertView alloc] initWithTitle:title message:msg delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil];
	[alert show];
}

#pragma mark makeCall
- (NSString*) cleanPhoneNumber:(NSString*)phoneNumber
{
    return [[[[phoneNumber stringByReplacingOccurrencesOfString:@" " withString:@""]
              stringByReplacingOccurrencesOfString:@"-" withString:@""]
             stringByReplacingOccurrencesOfString:@"(" withString:@""]
            stringByReplacingOccurrencesOfString:@")" withString:@""];
}

- (void) makeCall:(NSString *)phoneNumber{
    
    phoneNum = phoneNumber;
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"拨打号码?"
                                                    message:phoneNum
                                                         delegate:self
                                                cancelButtonTitle:@"取消"
                                                otherButtonTitles:@"拨打",nil];
                                                [alert show];
    
}

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
{
	if ([alertView.title isEqualToString:@"拨打号码?"]) {//phoneCall AlertView
        if (buttonIndex==1){
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[NSString stringWithFormat:@"tel:%@", phoneNum]]];
        }
      //  phoneNum=nil;
	}
    else if (alertView.tag == 1001) {//版本验证
        UIView *notTouchView = [[UIView alloc] initWithFrame:[UIScreen mainScreen].bounds];
        notTouchView.backgroundColor = [UIColor blackColor];
        notTouchView.alpha = 0.2;
        [[[UIApplication sharedApplication] keyWindow] addSubview:notTouchView];
    }
}
- (NSString*)timeToNow:(NSString*)theDate needYear:(BOOL)needYear
{
    if (!theDate) {
        return nil;
    }
    NSDateFormatter *dateFormatter=[[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    NSDate *d=[dateFormatter dateFromString:theDate];
    if (!d) {
        return theDate;
    }
    
    NSTimeInterval late=[d timeIntervalSince1970]*1;
    
    
    NSDate* dat = [NSDate dateWithTimeIntervalSinceNow:0];
    NSTimeInterval now=[dat timeIntervalSince1970]*1;
    NSString *timeString=@"";
    
    NSTimeInterval cha=(now-late)>0 ? (now-late) : 0;
    
    [dateFormatter setDateFormat:@"yyyy-MM-dd"];
    NSString *todayString = [dateFormatter stringFromDate:[NSDate date]];
    NSString *dateOfCurrentString = [dateFormatter stringFromDate:d];
    NSString *dateOfYesterdayString = [dateFormatter stringFromDate:[NSDate dateWithTimeInterval:-24*60*60 sinceDate:[NSDate date]]];
    
    if (cha/3600<1) {
        timeString = [NSString stringWithFormat:@"%f", cha/60];
        timeString = [timeString substringToIndex:timeString.length-7];
        if ([timeString intValue]==0) {
            timeString=@"刚刚";
        }else{
            timeString=[NSString stringWithFormat:@"%@分钟前", timeString];
        }
        
    }else if (cha/3600>1 && [todayString isEqualToString:dateOfCurrentString]) {
        [dateFormatter setDateFormat:@"HH:mm"];
        timeString = [dateFormatter stringFromDate:d];
        timeString=[NSString stringWithFormat:@"今天%@", timeString];
    }else if ([dateOfCurrentString isEqualToString:dateOfYesterdayString]){
        [dateFormatter setDateFormat:@"HH:mm"];
        timeString = [dateFormatter stringFromDate:d];
        timeString=[NSString stringWithFormat:@"昨天%@", timeString];
    }
    else
    {
        if (needYear) {
            [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm"];
        }
        else
        {
            [dateFormatter setDateFormat:@"MM-dd HH:mm"];
        }
        timeString=[dateFormatter stringFromDate:d];
    }
    
    return timeString;
}

-(NSString*)GetUnixTime
{
    NSTimeInterval timeInterval = [[NSDate date] timeIntervalSince1970];
    long long dTime = [[NSNumber numberWithDouble:timeInterval] longLongValue]; // 将double转为long long型
    NSString *tempTime = [NSString stringWithFormat:@"%llu",dTime]; // 输出long long型
    return tempTime;
}

//时间戳
-(NSString *)timeToTimestamp:(NSString *)timestamp
{
    if (!timestamp)
    {
        return @"";
    }    
    NSDateFormatter *dateFormatter=[[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyyMMddHHmm"];
     NSDate *aTime = [NSDate dateWithTimeIntervalSince1970:[timestamp integerValue]];
    
    NSString *str=[dateFormatter stringFromDate:aTime];
    return str;
}


//登陆注册

-(void)loginWithAccount:(NSString *)account pwd:(NSString *)password
{
    

}


-(void)registerWithAccount:(NSString *)account pwd:(NSString *)password authorCode:(NSString *)code
{
    
}


#pragma mark 数据更新
-(void)saveUserInfoToDefault
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setValue:self.userName        forKey:default_userName];
    [defaults setValue:self.userPwd         forKey:default_pwd];
    [defaults setValue:self.userLogo        forKey:default_userLogo];
    [defaults setValue:self.userId          forKey:default_userId];
    [defaults setValue:self.userToken       forKey:default_userToken];
    [defaults setValue:self.captchCode      forKey:default_captchCode];
    [defaults setValue:self.storeId         forKey:default_storeId];
    [defaults setValue:self.userAccount     forKey:default_userAccount];
    [defaults setValue:self.openStatus      forKey:default_openStatus];
    [defaults setValue:self.storeDic        forKey:default_storeDic];
    [defaults setValue:self.priviteKey      forKey:default_priviteKey];
    [defaults setValue:self.aiLiPayCountStr forKey:default_aliPayCount];
    [defaults setValue:self.UpdataTime      forKey:default_updateTime];
    [defaults synchronize];
}
-(void)readUserInfoFromDefault
{
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [self setUserPwd:        [defaults valueForKey:default_pwd]];
    [self setUserName:       [defaults valueForKey:default_userName]];
    [self setUserLogo:       [defaults valueForKey:default_userLogo]];
    [self setUserToken:      [defaults valueForKey:default_userToken]];
    [self setUserId:         [defaults valueForKey:default_userId]];
    [self setCaptchCode:     [defaults valueForKey:default_captchCode]];
    [self setStoreId:        [defaults valueForKey:default_storeId]];
    [self setUserAccount:    [defaults valueForKey:default_userAccount]];
    [self setOpenStatus:     [defaults valueForKey:default_openStatus]];
    [self setStoreDic:       [defaults valueForKey:default_storeDic]];
    [self setPriviteKey:     [defaults valueForKey:default_priviteKey]];
    [self setAiLiPayCountStr:[defaults valueForKey:default_aliPayCount]];
    [self setUpdataTime:     [defaults valueForKey:default_updateTime]];
    self.isAlertViewFlag=NO;
}
-(void)clearUserInfoInDefault
{
    //
    self.userId     =nil;
    self.userName   =nil;
    self.userPwd    =nil;
    self.userLogo   =nil;
    self.userToken  =nil;
    self.captchCode =nil;
    self.storeId    =nil;
    self.userAccount=nil;
    self.openStatus =nil;
    self.storeDic   =nil;
    self.priviteKey =nil;
    self.aiLiPayCountStr =nil;
    self.UpdataTime =nil;

    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    //消除用户手势
    [defaults removeObjectForKey:default_pwd];
    [defaults removeObjectForKey:default_userLogo];
    [defaults removeObjectForKey:default_userName];
    [defaults removeObjectForKey:default_userId];
    [defaults removeObjectForKey:default_userToken];
    [defaults removeObjectForKey:default_captchCode];
    [defaults removeObjectForKey:default_storeId];
    [defaults removeObjectForKey:default_userAccount];
    [defaults removeObjectForKey:default_openStatus];
    [defaults removeObjectForKey:default_storeDic];
    [defaults removeObjectForKey:default_priviteKey];
    [defaults removeObjectForKey:default_aliPayCount];
    [defaults removeObjectForKey:default_updateTime];
    [defaults synchronize];
}




+(NSString *)getMacAddress
{
    int                 mgmtInfoBase[6];
    char                *msgBuffer = NULL;
    size_t              length;
    unsigned char       macAddress[6];
    struct if_msghdr    *interfaceMsgStruct;
    struct sockaddr_dl  *socketStruct;
    NSString            *errorFlag = NULL;
    
    // Setup the management Information Base (mib)
    mgmtInfoBase[0] = CTL_NET;        // Request network subsystem
    mgmtInfoBase[1] = AF_ROUTE;       // Routing table info
    mgmtInfoBase[2] = 0;
    mgmtInfoBase[3] = AF_LINK;        // Request link layer information
    mgmtInfoBase[4] = NET_RT_IFLIST;  // Request all configured interfaces
    
    // With all configured interfaces requested, get handle index
    if ((mgmtInfoBase[5] = if_nametoindex("en0")) == 0)
        errorFlag = @"if_nametoindex failure";
    else
    {
        // Get the size of the data available (store in len)
        if (sysctl(mgmtInfoBase, 6, NULL, &length, NULL, 0) < 0)
            errorFlag = @"sysctl mgmtInfoBase failure";
        else
        {
            // Alloc memory based on above call
            if ((msgBuffer = malloc(length)) == NULL)
                errorFlag = @"buffer allocation failure";
            else
            {
                // Get system information, store in buffer
                if (sysctl(mgmtInfoBase, 6, msgBuffer, &length, NULL, 0) < 0)
                    errorFlag = @"sysctl msgBuffer failure";
            }
        }
    }
    
    // Befor going any further...
    if (errorFlag != NULL)
    {
        free(msgBuffer);
        //NSLog(@"Error: %@", errorFlag);
        return errorFlag;
    }
    
    // Map msgbuffer to interface message structure
    interfaceMsgStruct = (struct if_msghdr *) msgBuffer;
    
    // Map to link-level socket structure
    socketStruct = (struct sockaddr_dl *) (interfaceMsgStruct + 1);
    
    // Copy link layer address data in socket structure to an array
    memcpy(&macAddress, socketStruct->sdl_data + socketStruct->sdl_nlen, 6);
    
    // Read from char array into a string object, into traditional Mac address format
    NSString *macAddressString = [NSString stringWithFormat:@"%02X:%02X:%02X:%02X:%02X:%02X",
                                  macAddress[0], macAddress[1], macAddress[2],
                                  macAddress[3], macAddress[4], macAddress[5]];
    NSLog(@"Mac Address: %@", macAddressString);
    
    // Release the buffer memory
    free(msgBuffer);
    
    return macAddressString;
}


//获取当前时间

-(NSString*)GetNowTime
{
    NSDateFormatter *formatter =[[NSDateFormatter alloc] init];
    //[formatter setDateFormat:@"yyyy-mm-dd hh:mm:ss"];
      [formatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    NSString *currentTime = [formatter stringFromDate:[NSDate date]];
    return currentTime;
}

- (NSString*)ACtime_ChangeTheFormat:(NSString*)theDate
{
    DLog(@"________%@",theDate);
    if (!theDate) {
        return @"";
    }
    NSDateFormatter *dateFormatter=[[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss.0"];
    NSDate *d=[dateFormatter dateFromString:theDate];
    DLog(@"_______________%@",d);
    if (!d) {
        return @"";
    }
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    return [dateFormatter stringFromDate:d];
}

-(NSInteger)ACtimeToNow:(NSString*)theDate
{
    /*
        -1过期
     */
  
    
    if (!theDate) {
        return -1;
    }
    NSDateFormatter *dateFormatter=[[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss.0"];
    NSDate *d=[dateFormatter dateFromString:theDate];
    if (!d) {
        return -1;
    }
    
    NSTimeInterval late=[d timeIntervalSince1970]*1;
    NSDate* dat = [NSDate dateWithTimeIntervalSinceNow:0];
    NSTimeInterval now=[dat timeIntervalSince1970]*1;
    NSTimeInterval cha=(now-late);//>0 ? (now-late) : 0
    return -cha/3600/24;
}


#pragma mark view
//类似qq聊天窗口的抖动效果
-(void)viewAnimations:(UIView *)aV{
    CGFloat t =5.0;
    CGAffineTransform translateRight  =CGAffineTransformTranslate(CGAffineTransformIdentity, t,0.0);
    CGAffineTransform translateLeft =CGAffineTransformTranslate(CGAffineTransformIdentity,-t,0.0);
    CGAffineTransform translateTop =CGAffineTransformTranslate(CGAffineTransformIdentity,0.0,1);
    CGAffineTransform translateBottom =CGAffineTransformTranslate(CGAffineTransformIdentity,0.0,-1);
    
    aV.transform = translateLeft;
    
    [UIView animateWithDuration:0.07 delay:0.0 options:UIViewAnimationOptionAutoreverse animations:^{//UIViewAnimationOptionRepeat
        //[UIView setAnimationRepeatCount:2.0];
        aV.transform = translateRight;
    } completion:^(BOOL finished){
        [UIView animateWithDuration:0.07 animations:^{
            aV.transform = translateBottom;
        } completion:^(BOOL finished) {
            [UIView animateWithDuration:0.07 animations:^{
                aV.transform = translateTop;
            } completion:^(BOOL finished) {
                [UIView animateWithDuration:0.05 delay:0.0 options:UIViewAnimationOptionBeginFromCurrentState animations:^{
                    aV.transform =CGAffineTransformIdentity;//回到没有设置transform之前的坐标
                } completion:NULL];
            }];
        }];
//        if(finished){
//            [UIView animateWithDuration:0.05 delay:0.0 options:UIViewAnimationOptionBeginFromCurrentState animations:^{
//                aV.transform =CGAffineTransformIdentity;//回到没有设置transform之前的坐标
//            } completion:NULL];
//        }else{
//            aV.transform = translateTop;
//            
//        }
    }];
}

//view 左右抖动
-(void)leftRightAnimations:(UIView *)view{
    
    CGFloat t =5.0;
    CGAffineTransform translateRight  =CGAffineTransformTranslate(CGAffineTransformIdentity, t,0.0);
    CGAffineTransform translateLeft =CGAffineTransformTranslate(CGAffineTransformIdentity,-t,0.0);
    
    view.transform = translateLeft;
    
    [UIView animateWithDuration:0.07 delay:0.0 options:UIViewAnimationOptionAutoreverse|UIViewAnimationOptionRepeat animations:^{
        [UIView setAnimationRepeatCount:2.0];
        view.transform = translateRight;
    } completion:^(BOOL finished){
        if(finished){
            [UIView animateWithDuration:0.05 delay:0.0 options:UIViewAnimationOptionBeginFromCurrentState animations:^{
                view.transform =CGAffineTransformIdentity;
            } completion:NULL];
        }
    }];
    
}
- (UIView*)tipsView:(NSString*)str;
{
    UIView *v = [[UIView alloc] init];
   // UIImageView *imageview = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"no_data_hint_ic.png"]];
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(35, 150, 250,80)];
    label.font = [UIFont systemFontOfSize:15];
    label.textColor = [UIColor lightGrayColor];
    label.backgroundColor = [UIColor clearColor];
    label.textAlignment = NSTextAlignmentCenter;
    label.numberOfLines = 0;
    label.text = str?str:@"暂无数据，敬请期待！";
   // [imageview setCenter:CGPointMake(160, 120)];
   // [v addSubview:imageview];
    [v addSubview:label];
    return v;
}
//圆角或椭圆
-(void)viewLayerRound:(UIView *)view borderWidth:(float)width borderColor:(UIColor *)color{
    // 必須加上這一行，這樣圓角才會加在圖片的「外側」
    view.layer.masksToBounds = YES;
    // 其實就是設定圓角，只是圓角的弧度剛好就是圖片尺寸的一半
    view.layer.cornerRadius =H(view)/ 35.0;
    //边框
    view.layer.borderWidth=width;
    view.layer.borderColor =[color CGColor];
}

-(NSString *)VersionSelect{
     NSString *v = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleVersion"];
    return v;
}




#pragma mark -数据格式化
//////////////数据格式化
//格式化电话号码
-(NSString *)ACFormatPhone:(NSString *)str{
    if (str.length<10) {
        return str;
    }else{
        NSString *s1=[str substringToIndex:3];
        NSString *s2=[str substringWithRange:NSMakeRange(3, 4)];
        NSString *s3=[str substringFromIndex:7];
        DLog(@"%@,%@,%@",s1,s2,s3);
        NSString *turntoCarIDString=[NSString stringWithFormat:@"%@ %@ %@",s1,s2,s3];
        return turntoCarIDString;
    }
}
///格式化手机号
-(NSString *)ACFormatMobile:(NSString *)str{
    if (str.length<10) {//含固定电话
        return str;
    }else{
        NSString *s1=[str substringToIndex:3];
        NSString *s2=[str substringWithRange:NSMakeRange(3, 4)];
        NSString *s3=[str substringFromIndex:7];
        DLog(@"%@,%@,%@",s1,s2,s3);
        NSString *turntoCarIDString=[NSString stringWithFormat:@"%@ %@ %@",s1,s2,s3];
        return turntoCarIDString;
    }
}
///格式化身份证号
-(NSString *)ACFormatIDC:(NSString *)str{
    if (str.length==18) {
        NSString *s1=[str substringToIndex:3];
        NSString *s2=[str substringWithRange:NSMakeRange(3, 3)];
        NSString *s3=[str substringWithRange:NSMakeRange(6, 4)];
        NSString *s4=[str substringWithRange:NSMakeRange(10, 4)];
        NSString *s5=[str substringFromIndex:14];
        DLog(@"%@,%@,%@,%@,%@",s1,s2,s3,s4,s5);
        NSString *turntoCarIDString=[NSString stringWithFormat:@"%@ %@ %@ %@ %@",s1,s2,s3,s4,s5];
        return turntoCarIDString;
    }else if(str.length>=15){
        NSString *s1=[str substringToIndex:(str.length-8)];
        NSString *s4=[str substringWithRange:NSMakeRange((str.length-8), 4)];
        NSString *s5=[str substringFromIndex:(str.length-4)];
        DLog(@"%@,%@,%@",s1,s4,s5);
        NSString *turntoCarIDString=[NSString stringWithFormat:@"%@ %@ %@",s1,s4,s5];
        return turntoCarIDString;
    }else{
        return str;
    }
}


//获取KeyStr
-(NSString*)GetPriviteKey:(NSString *)PriviteKey GetResourceId:(NSString *)ResourceId GetPayLoad:(NSString *)PayLoad GetTimeStamp:(NSString*)TimeStamp;
{
    NSString *EndStr  = [NSString stringWithFormat:@"%@%@%@%@",PriviteKey,ResourceId,TimeStamp,PayLoad].md5;
    return EndStr;
}

//图片转Base64
-(NSString*)image2DataURL:(UIImage *)image
{
    NSData *data = UIImageJPEGRepresentation(image,0.5);
    data = [data base64EncodedDataWithOptions:0];
    NSString *endStr = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    return endStr;
}

//Base64转图片
-(NSData*)Data2Image:(NSString*)string
{
    NSData *imageData = [[NSData alloc] initWithBase64EncodedString:string options:NSDataBase64DecodingIgnoreUnknownCharacters];
    return imageData;
}


-(NSString*)toBase64String:(NSString *)string
{
    NSData *data = [string dataUsingEncoding:NSUnicodeStringEncoding];
    data = [data base64EncodedDataWithOptions:0];
    NSString *endStr = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    return endStr;
}

//字符串转Bas464
- (NSString *)base64Encode:(NSString *)plainText
{
    NSData *plainTextData = [plainText dataUsingEncoding:NSUTF8StringEncoding];
    NSString *base64String = [plainTextData base64EncodedStringWithOptions:0];
    return base64String;
}
//验证身份证
- (BOOL) validateIdentityCard: (NSString *)identityCard;
{
    BOOL flag;
    if (identityCard.length <= 0)
    {
        flag = NO;
        return flag;
    }
    NSString *regex2 = @"^(\\d{14}|\\d{17})(\\d|[xX])$";
    NSPredicate *identityCardPredicate = [NSPredicate predicateWithFormat:@"SELF MATCHES %@",regex2];
    return [identityCardPredicate evaluateWithObject:identityCard];
}


-(NSString*)DayBeforeYesterday
{
    //设置时间
    NSDateFormatter *formatter =[[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyy-MM-dd"];
    //获取前天,使用日历类
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDateComponents *Comps;
    Comps = [calendar components:(NSHourCalendarUnit | NSMinuteCalendarUnit | NSSecondCalendarUnit) fromDate:[[NSDate alloc] init]];
    [Comps setHour:-48]; //+24表示获取下一天的date，-24表示获取前一天的date；
    [Comps setMinute:0];
    [Comps setSecond:0];
    NSDate *nowDate = [calendar dateByAddingComponents:Comps toDate:[NSDate date] options:0];
    NSString *BeforeYesterday  = [[NSString stringWithFormat:@"%@",nowDate] substringWithRange:NSMakeRange(0, 10)];
    return BeforeYesterday;
}


//获取一周前的日期
-(NSString*)lastWeekDay{
    //设置时间
    NSDateFormatter *formatter =[[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyy-MM-dd"];
    //获取前天,使用日历类
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDateComponents *Comps;
    Comps = [calendar components:(kCFCalendarUnitHour| kCFCalendarUnitMinute | kCFCalendarUnitSecond) fromDate:[[NSDate alloc] init]];
    [Comps setHour:-24*7]; //+24表示获取下一天的date，-24表示获取前一天的date；
    [Comps setMinute:0];
    [Comps setSecond:0];
    NSDate *nowDate = [calendar dateByAddingComponents:Comps toDate:[NSDate date] options:0];
    NSString *lastDay  = [[NSString stringWithFormat:@"%@",nowDate] substringWithRange:NSMakeRange(0, 10)];
    return lastDay;
}




//判断网络请求的
-(BOOL)HaveNetWork
{
    
    BOOL NetworkBool = NO;
    Reachability *reach = [Reachability reachabilityForInternetConnection];
    if ([reach currentReachabilityStatus] == NotReachable)
    {
        NetworkBool = NO;
    }
    else
    {
        NetworkBool = YES;
    }
    return NetworkBool;
}

@end
