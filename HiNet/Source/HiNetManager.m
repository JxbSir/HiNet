//
//  HiNetManager.m
//  HiNet
//
//  Created by Peter on 2019/4/30.
//  Copyright © 2019 Peter. All rights reserved.
//

#import "HiNetManager.h"
#import "HiNetURLSessionExchanger.h"
#import "HiNetURLConnectionExchanger.h"
#import "HiNetRequest.h"

#import <GCDWebServer/GCDWebServer.h>
#import <GCDWebServer/GCDWebServerDataResponse.h>

NSString *const kNetworkTaskList = @"kNetworkTaskList";

@interface HiNetManager ()<HiNetURLSessionExchangerDelegate, HiNetURLConnectionExchangerDelegate>
@property (nonatomic, strong) HiNetURLSessionExchanger* sessionExchanger;
@property (nonatomic, strong) HiNetURLConnectionExchanger* connectionExchanger;

@property (nonatomic, strong) NSMutableDictionary* executingTasks;
@end

@implementation HiNetManager

+(instancetype)shared {
    static dispatch_once_t onceToken;
    static HiNetManager *manager;
    dispatch_once(&onceToken, ^{
        manager = [HiNetManager new];
    });
    return manager;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.executingTasks = [NSMutableDictionary dictionary];
        self.sessionExchanger = [[HiNetURLSessionExchanger alloc] init];
        self.sessionExchanger.delegate = self;
        
        self.connectionExchanger = [[HiNetURLConnectionExchanger alloc] init];
        self.connectionExchanger.delegate = self;
    }
    return self;
}

- (void)start {
    GCDWebServer* server = [[GCDWebServer alloc] init];
    [server addDefaultHandlerForMethod:@"GET" requestClass:[GCDWebServerRequest class] processBlock:^GCDWebServerResponse * _Nullable(__kindof GCDWebServerRequest * _Nonnull request) {
        return [GCDWebServerDataResponse responseWithHTML:@"<html><body><p>Hello World</p></body></html>"];
    }];
    [server addHandlerForMethod:@"GET" path:@"/network" requestClass:[GCDWebServerRequest class] processBlock:^GCDWebServerResponse * _Nullable(__kindof GCDWebServerRequest * _Nonnull request) {
        
        
        NSArray* tasks = [[NSUserDefaults standardUserDefaults] arrayForKey:kNetworkTaskList];
        if (tasks && tasks.count > 0) {
            return [GCDWebServerDataResponse responseWithHTML:tasks.firstObject];
        } else {
            return [GCDWebServerDataResponse responseWithHTML:@"<html><body><p>Hello World</p></body></html>"];
        }

    }];
    [server start];
}


- (void)saveTask:(HiNetRequest *)req {
    NSError *error;
    NSData* reqData = [NSJSONSerialization dataWithJSONObject:[req toJSON] options:0 error:&error];
    if (!reqData || error) {
        return;
    }
    
    NSString* taskString = [[NSString alloc] initWithData:reqData encoding:NSUTF8StringEncoding];
    
    NSArray* tasks = [[NSUserDefaults standardUserDefaults] arrayForKey:kNetworkTaskList];
    NSMutableArray* _tasks;
    if (!tasks) {
        _tasks = [NSMutableArray array];
    } else {
        _tasks = [NSMutableArray arrayWithArray:tasks];
    }
    
    [_tasks addObject:taskString];
    [[NSUserDefaults standardUserDefaults] setObject:_tasks forKey:kNetworkTaskList];
}

#pragma mark - HiNetURLSessionExchangerDelegate
- (void)urlSession:(HiNetURLSessionExchanger*)exchanger didStart:(NSURLSessionDataTask*)dataTask {
    NSString* task = [NSString stringWithFormat:@"%p", dataTask];
    
    HiNetRequest* req = [[HiNetRequest alloc] init];
    req.url = dataTask.currentRequest.URL;
    req.requestHeaders = dataTask.currentRequest.allHTTPHeaderFields;
    req.requestBody = dataTask.currentRequest.HTTPBody;
    req.requestMethod = dataTask.currentRequest.HTTPMethod;
    req.startDate = [NSDate date];
    
    [self.executingTasks setObject:req forKey:task];
}

- (void)urlSession:(HiNetURLSessionExchanger*)exchanger didReceiveResponse:(NSURLSessionDataTask*)dataTask response:(NSURLResponse*)response {
    NSString* task = [NSString stringWithFormat:@"%p", dataTask];
    
    id value = [self.executingTasks objectForKey:task];
    if (value && [value isKindOfClass:HiNetRequest.class]) {
        NSHTTPURLResponse* httpURLResponse = (NSHTTPURLResponse*)response;
        HiNetRequest* req = (HiNetRequest *)value;
        req.responseHeaders = httpURLResponse.allHeaderFields;
        req.statusCode = [NSString stringWithFormat:@"%ld",(long)httpURLResponse.statusCode];
    }
    
}

- (void)urlSession:(HiNetURLSessionExchanger*)exchanger didReceiveData:(NSURLSessionDataTask*)dataTask data:(NSData*)data {
    NSString* task = [NSString stringWithFormat:@"%p", dataTask];
    
    id value = [self.executingTasks objectForKey:task];
    if (value && [value isKindOfClass:HiNetRequest.class]) {
        HiNetRequest* req = (HiNetRequest *)value;
        [req append:data];
    }
}

- (void)urlSession:(HiNetURLSessionExchanger*)exchanger didFinishWithError:(NSURLSessionDataTask*)dataTask error:(NSError*)error {
    NSString* task = [NSString stringWithFormat:@"%p", dataTask];
    
    id value = [self.executingTasks objectForKey:task];
    if (value && [value isKindOfClass:HiNetRequest.class]) {
        HiNetRequest* req = (HiNetRequest *)value;
        req.error = error;
        req.endDate = [NSDate date];
        [self saveTask:req];
        [self.executingTasks removeObjectForKey:task];
    }
}


#pragma mark - HiNetURLConnectionExchangerDelegate
@end
