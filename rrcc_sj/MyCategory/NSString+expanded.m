//
//  StringRef.m
//  beta1


#import "NSString+expanded.h"
#import <CommonCrypto/CommonDigest.h>
@implementation NSString(expanded)

- (NSString *)stringByReplaceHTML{
    
    NSScanner *theScanner;
    NSString *text = nil;
    NSString *html = self;
    theScanner = [NSScanner scannerWithString:html];
    
    while ([theScanner isAtEnd] == NO) {
        
        // find start of tag
        [theScanner scanUpToString:@"<" intoString:NULL] ;
        
        // find end of tag
        [theScanner scanUpToString:@">" intoString:&text] ;
        
        // replace the found tag with a space
        //(you can filter multi-spaces out later if you wish)
        html = [html stringByReplacingOccurrencesOfString:
                [ NSString stringWithFormat:@"%@>", text]
                                               withString:@" "];
        
    } // while //
    
    return html;
    
}

-(NSString*)replaceControlString
{
    NSString *tempStr = self;
	tempStr=[tempStr stringByReplacingOccurrencesOfString:@"\\" withString:@"\\\\"];
	tempStr=[tempStr stringByReplacingOccurrencesOfString:@"\b" withString:@"\\b"];
	tempStr=[tempStr stringByReplacingOccurrencesOfString:@"\f" withString:@"\\f"];
	tempStr=[tempStr stringByReplacingOccurrencesOfString:@"\r" withString:@"\\t"];
	tempStr=[tempStr stringByReplacingOccurrencesOfString:@"\t" withString:@"\\r"];
	tempStr=[tempStr stringByReplacingOccurrencesOfString:@"\n" withString:@"\\n"];
	tempStr=[tempStr stringByReplacingOccurrencesOfString:@"\"" withString:@"\\\""];
	
	return tempStr;
}
-(NSString*)replaceStoreKey
{
    NSString *tempStr = self;
    NSRange range=[tempStr rangeOfString:@"user.lat="];
    if (range.length==0) {
        range=[tempStr rangeOfString:@"loc.latOffset="];
        if (range.length==0) {
            range=[tempStr rangeOfString:@"lat="];
            if (range.length!=0) {
                NSInteger l=[[tempStr substringFromIndex:[tempStr rangeOfString:@"lng="].location] rangeOfString:@"&"].location;
                range.length=[tempStr rangeOfString:@"lng="].location-range.location+l;
                tempStr=[tempStr stringByReplacingCharactersInRange:range withString:@""];
            }
        }else{
            NSInteger l=[[tempStr substringFromIndex:[tempStr rangeOfString:@"loc.lngOffset="].location] rangeOfString:@"&"].location;
            range.length=[tempStr rangeOfString:@"loc.lngOffset="].location-range.location+l;
            tempStr=[tempStr stringByReplacingCharactersInRange:range withString:@""];
        }
    }else{
        NSInteger l=[[tempStr substringFromIndex:[tempStr rangeOfString:@"user.lng="].location] rangeOfString:@"&"].location;
        range.length=[tempStr rangeOfString:@"user.lng="].location-range.location+l;
        tempStr=[tempStr stringByReplacingCharactersInRange:range withString:@""];
    }
    return tempStr;
}

//"upload/".length=7
-(NSString*)imagePathType:(imageType)__type
{
    if ((__type != imageSmallType && __type != imageBigType)) {
        return self;
    }else{
        return [self stringByReplacingOccurrencesOfString:@"/" withString:__type==imageSmallType?@"/s":@"/b" options:0 range:NSMakeRange(7, [self length]-7)];
    }
}

- (NSString *)indentLength:(CGFloat)_len font:(UIFont *)_font
{
    NSString *str=@"";
    CGFloat temp=0.0;
    while (temp<=_len) {
        str=[str stringByAppendingString:@" "];
        temp=[str sizeWithFont:_font].width;
    }
    return [NSString stringWithFormat:@"%@%@",str,self];
}
- (BOOL)notEmptyOrNull
{
    if ([self isEqualToString:@""]||[self isEqualToString:@"null"] || [self isEqualToString:@"\"\""] || [self isEqualToString:@"''"]) {
        return NO;
    }
    return YES;
}

+ (NSString *)replaceEmptyOrNull:(NSString *)checkString
{
    if (!checkString || [checkString isEqualToString:@""]||[checkString isEqualToString:@"null"]) {
        return @"";
    }
    return checkString;
}
-(NSString*)replaceTime
{
    NSString *tempStr = self;
    tempStr=[tempStr stringByReplacingOccurrencesOfString:@"-" withString:@"年" options:0 range:NSMakeRange(0, 5)];
    tempStr=[tempStr stringByReplacingOccurrencesOfString:@"-" withString:@"月"];
    tempStr=[tempStr stringByAppendingString:@"日"];
    return tempStr;
}

- (NSString*)soapMessage:(NSString *)key,...
{
    NSString *akey;
    va_list ap;
    va_start(ap, key);
    NSString *obj = nil;
    if (key) {
        if ([key rangeOfString:@"<"].length == 0)
            obj=[NSString stringWithFormat:@"<%@>%@</%@>",key,@"%@",key];
        else
            obj = key;
        
        while (obj&&(akey=va_arg(ap,id))) {
            if ([akey rangeOfString:@"<"].length == 0)
                obj=[obj stringByAppendingFormat:@"<%@>%@</%@>",akey,@"%@",akey];
            else
                obj = [obj stringByAppendingString:akey];
        }
        va_end(ap);
    }
    
    return [NSString stringWithFormat:@"<?xml version=\"1.0\" encoding=\"UTF-8\"?><soapenv:Envelope xmlns:soapenv=\"http://schemas.xmlsoap.org/soap/envelope/\" xmlns:soap=\"http://soap.csc.iofd.cn/\"> <soapenv:Header/> <soapenv:Body><soap:%@>%@</soap:%@></soapenv:Body></soapenv:Envelope>",self,obj?obj:@"",self];
}
- (NSString *)md5
{
	const char *concat_str = [self UTF8String];
	unsigned char result[CC_MD5_DIGEST_LENGTH];
    CC_MD5(concat_str, strlen(concat_str), result);
	NSMutableString *hash = [NSMutableString string];
	for (int i = 0; i < 16; i++){
		[hash appendFormat:@"%02X", result[i]];
	}
	return [hash lowercaseString];
	
}


    
    



@end
