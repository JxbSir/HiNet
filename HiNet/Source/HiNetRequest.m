//
//  HiNetRequest.m
//  HiNet
//
//  Created by Peter on 2019/4/30.
//  Copyright © 2019 Peter. All rights reserved.
//

#import "HiNetRequest.h"

@implementation HiNetRequest

- (double)takeTime {
    return self.endDate.doubleValue - self.startDate.doubleValue;
}

- (NSString *)start {
    NSDateFormatter* formatter = [[NSDateFormatter alloc] init];
    formatter.dateFormat = @"yyyy-MM-dd HH:mm:ss";
    return [formatter stringFromDate:[NSDate dateWithTimeIntervalSince1970:self.startDate.doubleValue / 1000]];
}

- (NSString *)end {
    NSDateFormatter* formatter = [[NSDateFormatter alloc] init];
    formatter.dateFormat = @"yyyy-MM-dd HH:mm:ss";
    return [formatter stringFromDate:[NSDate dateWithTimeIntervalSince1970:self.endDate.doubleValue / 1000]];
}

- (instancetype)initWithJSON:(id)json {
    self = [super init];
    
    if (self) {
        if ([json objectForKey:@"url"]) {
            self.url = [NSURL URLWithString:[json objectForKey:@"url"]];
        }
        
        if ([json objectForKey:@"requestHeaders"]) {
            self.requestHeaders = [json objectForKey:@"requestHeaders"];
        }
        
        if ([json objectForKey:@"requestMethod"]) {
            self.requestMethod = [json objectForKey:@"requestMethod"];
        }
        
        if ([json objectForKey:@"requestBody"]) {
            NSData* base64Data = [[NSData alloc] initWithBase64EncodedString:[json objectForKey:@"requestBody"] options:NSDataBase64DecodingIgnoreUnknownCharacters];
            
            self.requestBody = base64Data;
        }
        
        if ([json objectForKey:@"responseHeaders"]) {
            self.responseHeaders = [json objectForKey:@"responseHeaders"];
        }
        
        if ([json objectForKey:@"responseData"]) {
            NSData* base64Data = [[NSData alloc] initWithBase64EncodedString:[json objectForKey:@"responseData"] options:NSDataBase64DecodingIgnoreUnknownCharacters];
            
            self.responseData = base64Data;
        }
        
        if ([json objectForKey:@"statusCode"]) {
            self.statusCode = [json objectForKey:@"statusCode"];
        }
        
        if ([json objectForKey:@"startDate"]) {
            self.startDate = [json objectForKey:@"startDate"];
        }
        
        if ([json objectForKey:@"endDate"]) {
            self.endDate = [json objectForKey:@"endDate"];
        }
    }
    
    return self;
}

- (NSMutableDictionary *)toJSON {
    NSMutableDictionary* json = [NSMutableDictionary new];
    
    if (self.url) {
        [json setObject:self.url.absoluteString forKey:@"url"];
    }
    
    if (self.requestHeaders) {
        [json setObject:self.requestHeaders forKey:@"requestHeaders"];
    }
    
    if (self.requestMethod) {
        [json setObject:self.requestMethod forKey:@"requestMethod"];
    }
    
    if (self.requestBody) {
        NSString* base64String = [self.requestBody base64EncodedStringWithOptions:NSDataBase64Encoding64CharacterLineLength];
        
        if (base64String) {
            [json setObject:base64String forKey:@"requestBody"];
        }
    }
    
    if (self.responseHeaders) {
        [json setObject:self.responseHeaders forKey:@"responseHeaders"];
    }
    
    if (self.responseData) {
        NSString* base64String = [self.responseData base64EncodedStringWithOptions:NSDataBase64Encoding64CharacterLineLength];
        if (base64String) {
            [json setObject:base64String forKey:@"responseData"];
        }
    }
    
    if (self.statusCode) {
        [json setObject:self.statusCode forKey:@"statusCode"];
    }
    
    if (self.startDate) {
        [json setObject:self.startDate forKey:@"startDate"];
    }
    
    if (self.endDate) {
        [json setObject:self.endDate forKey:@"endDate"];
    }
    
    return json;
}

- (void)append:(NSData *)data {
    if (self.responseData == nil) {
        self.responseData = data;
    } else {
        NSMutableData* d = [NSMutableData dataWithData:self.responseData];
        [d appendData:data];
        self.responseData = d;
    }
}

@end
