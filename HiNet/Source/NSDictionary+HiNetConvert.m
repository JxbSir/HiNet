//
//  NSDictionary+HiNetConvert.m
//  HiNet
//
//  Created by Peter on 2019/5/1.
//  Copyright © 2019 Peter. All rights reserved.
//

#import "NSDictionary+HiNetConvert.h"

@implementation NSDictionary (HiNetConvert)

- (NSString*)toString
{
    NSError* error;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:self options:0 error:&error];
    
    if (error) {
        return nil;
    }
    
    NSString *jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    jsonString = [jsonString stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]]; 
    
    return jsonString;
}

@end
