//
//  HiNetRequest.h
//  HiNet
//
//  Created by Peter on 2019/4/30.
//  Copyright © 2019 Peter. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "HiNetJsonable.h"

NS_ASSUME_NONNULL_BEGIN

@interface HiNetRequest : NSObject<HiNetJsonable>
@property (nonatomic, strong) NSURL* url;

@property (nonatomic, strong) NSDictionary* requestHeaders;
@property (nonatomic, strong) NSData* requestBody;
@property (nonatomic, strong) NSString* requestMethod;

@property (nonatomic, strong) NSDictionary* responseHeaders;
@property (nonatomic, strong) NSData* responseData;

@property (nonatomic, strong) NSString* statusCode;
@property (nonatomic, strong) NSError* error;

@property (nonatomic, strong) NSDate* startDate;
@property (nonatomic, strong) NSDate* endDate;

- (NSString *)start;
- (NSString *)end;
- (double)takeTime;

- (void)append:(NSData *)data;

@end

NS_ASSUME_NONNULL_END
