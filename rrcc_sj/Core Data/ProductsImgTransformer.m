//
//  ProductsImgTransformer.m
//  rrcc_sj
//
//  Created by lawwilte on 7/5/15.
//  Copyright (c) 2015 ting liu. All rights reserved.
//

#import "ProductsImgTransformer.h"

@implementation ProductsImgTransformer

+(Class)transformedValueClass{
    return [UIImage class];
}

-(id)transformedValue:(id)value{
    if (!value){
        return nil;
    }
    if ([value isKindOfClass:[NSData class]]){
        return value;
    }
    return UIImagePNGRepresentation(value);
}

-(id)reverseTransformedValue:(id)value{
    return [UIImage imageWithData:value];
}

@end
