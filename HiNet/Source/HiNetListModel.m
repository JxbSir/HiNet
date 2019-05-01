//
//  HiNetListModel.m
//  HiNet
//
//  Created by Peter on 2019/4/30.
//  Copyright © 2019 Peter. All rights reserved.
//

#import "HiNetListModel.h"

@implementation HiNetworkModel

- (instancetype)initWithJSON:(id)json {
    self = [super init];
    if (self) {
        if ([json objectForKey:@"name"]) {
            self.name = [json objectForKey:@"name"];
        }
        if ([json objectForKey:@"method"]) {
            self.method = [json objectForKey:@"method"];
        }
        if ([json objectForKey:@"status"]) {
            self.status = [json objectForKey:@"status"];
        }
        if ([json objectForKey:@"type"]) {
            self.type = [json objectForKey:@"type"];
        }
        if ([json objectForKey:@"size"]) {
            self.size = [json objectForKey:@"size"];
        }
        if ([json objectForKey:@"time"]) {
            self.time = [json objectForKey:@"time"];
        }
        if ([json objectForKey:@"start"]) {
            self.start = [json objectForKey:@"start"];
        }
        if ([json objectForKey:@"end"]) {
            self.end = [json objectForKey:@"end"];
        }
        if ([json objectForKey:@"requestHeaders"]) {
            self.requestHeaders = [json objectForKey:@"requestHeaders"];
        }
        if ([json objectForKey:@"requestBody"]) {
            self.requestBody = [json objectForKey:@"requestBody"];
        }
        if ([json objectForKey:@"responseHeaders"]) {
            self.responseHeaders = [json objectForKey:@"responseHeaders"];
        }
        if ([json objectForKey:@"responseBody"]) {
            self.responseBody = [json objectForKey:@"responseBody"];
        }
    }
    return self;
}

- (NSMutableDictionary *)toJSON {
    NSMutableDictionary* json = [NSMutableDictionary new];
    if (self.name) {
        [json setObject:self.name forKey:@"name"];
    }
    if (self.method) {
        [json setObject:self.method forKey:@"method"];
    }
    if (self.status) {
        [json setObject:self.status forKey:@"status"];
    }
    if (self.type) {
        [json setObject:self.type forKey:@"type"];
    }
    if (self.size) {
        [json setObject:self.size forKey:@"size"];
    }
    if (self.time) {
        [json setObject:self.time forKey:@"time"];
    }
    if (self.start) {
        [json setObject:self.start forKey:@"start"];
    }
    if (self.end) {
        [json setObject:self.end forKey:@"end"];
    }
    if (self.requestHeaders) {
        [json setObject:self.requestHeaders forKey:@"requestHeaders"];
    }
    if (self.requestBody) {
        [json setObject:self.requestBody forKey:@"requestBody"];
    }
    if (self.responseHeaders) {
        [json setObject:self.responseHeaders forKey:@"responseHeaders"];
    }
    if (self.responseBody) {
        [json setObject:self.responseBody forKey:@"responseBody"];
    }
    return json;
}
@end

@implementation HiNetListModel

- (instancetype)initWithJSON:(id)json {
    self = [super init];
    if (self) {
        if ([json objectForKey:@"count"]) {
            self.count = (NSInteger)[json objectForKey:@"count"];
        }
        if ([json objectForKey:@"code"]) {
            self.code = (NSInteger)[json objectForKey:@"code"];
        }
        if ([json objectForKey:@"data"]) {
            NSArray* list = [json objectForKey:@"data"];
            __block NSMutableArray* models = [NSMutableArray array];
            [list enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                HiNetworkModel* model = [[HiNetworkModel alloc] initWithJSON:obj];
                [models addObject:model];
            }];
            self.data = models;
        }
    }
    return self;
}

- (NSMutableDictionary *)toJSON {
    NSMutableDictionary* json = [NSMutableDictionary new];
    [json setObject:@(self.code) forKey:@"code"];
    [json setObject:@(self.count) forKey:@"count"];
    if (self.data) {
        __block NSMutableArray* list = [NSMutableArray array];
        [self.data enumerateObjectsUsingBlock:^(HiNetworkModel * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            NSDictionary* dic = [obj toJSON];
            [list addObject:dic];
        }];
        [json setObject:list forKey:@"data"];
    }
    return json;
}
@end
