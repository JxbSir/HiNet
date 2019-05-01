//
//  HiNetManager.m
//  HiNet
//
//  Created by Peter on 2019/4/30.
//  Copyright © 2019 Peter. All rights reserved.
//

#import "HiNetManager.h"
#import "HiNetURLSessionExchanger.h"
#import "HiNetRequest.h"
#import "HiNetListModel.h"
#import "NSDictionary+HiNetConvert.h"

#import <GCDWebServer/GCDWebServer.h>
#import <GCDWebServer/GCDWebServerDataResponse.h>

NSString *const kNetworkTaskList = @"kNetworkTaskList";

@interface HiNetManager ()<HiNetURLSessionExchangerDelegate>
@property (nonatomic, strong) HiNetURLSessionExchanger* sessionExchanger;
@property (nonatomic, strong) GCDWebServer* server;
    
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
    }
    return self;
}

- (void)start {
    _server = [[GCDWebServer alloc] init];
    
    [self addIndexHandler];
    [self addNetworkClearHandler];
    [self addNetworkDataHandler];
    [self addResouceHandler];
    
    [_server start];
}

- (void)addNetworkClearHandler {
     [_server addHandlerForMethod:@"GET" path:@"/network/clear" requestClass:[GCDWebServerRequest class] processBlock:^GCDWebServerResponse * _Nullable(__kindof GCDWebServerRequest * _Nonnull request) {
         [[NSUserDefaults standardUserDefaults] removeObjectForKey:kNetworkTaskList];
         [[NSUserDefaults standardUserDefaults] synchronize];
         return [GCDWebServerDataResponse responseWithText:@""];
     }];
}

- (void)addNetworkDataHandler {
    [_server addHandlerForMethod:@"GET" path:@"/network/list" requestClass:[GCDWebServerRequest class] processBlock:^GCDWebServerResponse * _Nullable(__kindof GCDWebServerRequest * _Nonnull request) {
        
        NSString* page = [request.query objectForKey:@"page"];
        NSString* limit = [request.query objectForKey:@"limit"];
        
        HiNetListModel* model = [[HiNetListModel alloc] init];
        model.code = 0;
        
        if (!page || !limit) {
            model.count = 0;
            model.data = @[];
        } else {
            NSArray* list = [[NSUserDefaults standardUserDefaults] arrayForKey:kNetworkTaskList];
            if (!list || list.count == 0) {
                model.count = 0;
                model.data = @[];
            } else {
                model.count = list.count;
                NSInteger start = (page.integerValue - 1) * limit.integerValue;
                NSInteger end = start + limit.integerValue;
                end = MIN(end, list.count - 1);
                NSArray* pageList = [list subarrayWithRange:NSMakeRange(start, end - start + 1)];
                __block NSMutableArray* array = [NSMutableArray array];
                [pageList enumerateObjectsUsingBlock:^(NSString*  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                    NSError* error;
                    NSDictionary* dic = [NSJSONSerialization JSONObjectWithData:[obj dataUsingEncoding:NSUTF8StringEncoding] options:kNilOptions error:&error];
                    
                    if (!error) {
                        HiNetRequest* req = [[HiNetRequest alloc] initWithJSON:dic];
                        
                        HiNetworkModel* network = [[HiNetworkModel alloc] init];
                        network.name = req.url.absoluteString;
                        network.method = req.requestMethod;
                        network.type = req.responseHeaders[@"Content-Type"];
                        
                        NSString* count = (NSString*)req.responseHeaders[@"Content-Length"];
                        network.size = [NSByteCountFormatter stringFromByteCount:count.longLongValue countStyle:NSByteCountFormatterCountStyleFile];
                        network.status = req.statusCode;
                        network.time = [NSString stringWithFormat:@"%.3fms", [req takeTime]];
                        network.start = [req start];
                        network.end = [req end];
                        
                        network.requestHeaders = [req.requestHeaders toString];
                        if (!network.requestHeaders || network.requestHeaders.length == 0) {
                            network.requestHeaders = @"无";
                        }
                        network.requestBody = [[NSString alloc] initWithData:req.requestBody encoding:NSUTF8StringEncoding];
                        if (!network.requestBody || network.requestBody.length == 0) {
                            network.requestBody = @"无";
                        }
                        network.responseHeaders = [req.responseHeaders toString];
                        if (!network.responseHeaders || network.responseHeaders.length == 0) {
                            network.responseHeaders = @"无";
                        }
                        if ([network.type containsString:@"application/"] || [network.type containsString:@"text"]) {
                            network.responseBody = [[NSString alloc] initWithData:req.responseData encoding:NSUTF8StringEncoding];
                            if (!network.responseBody || network.responseBody.length == 0) {
                                network.responseBody = @"无";
                            }
                        }
                        
                        [array addObject:network];
                    }
                    
                }];

                model.data = array;
            }
        }
 
        return [GCDWebServerDataResponse responseWithJSONObject:[model toJSON]];
    }];
}

- (void)addIndexHandler {
    [_server addDefaultHandlerForMethod:@"GET" requestClass:[GCDWebServerRequest class] processBlock:^GCDWebServerResponse * _Nullable(__kindof GCDWebServerRequest * _Nonnull request) {
        NSString* path = [[NSBundle mainBundle] pathForResource:@"network" ofType:@"html"];
        NSError* error;
        NSString* html = [[NSString alloc] initWithContentsOfFile:path encoding:NSUTF8StringEncoding error:&error];
        return [GCDWebServerDataResponse responseWithHTML:html];
    }];
}
    

- (void)addResouceHandler {
    [self addHandler:@"/layui/css/layui.css"];
    [self addHandler:@"/layui/css/layui.mobile.css"];
    [self addHandler:@"/layui/css/modules/code.css"];
    [self addHandler:@"/layui/css/modules/layer/default/layer.css"];
    [self addHandler:@"/layui/css/modules/layerdate/default/laydate.css"];
    [self addHandler:@"/layui/layui.js"];
    [self addHandler:@"/layui/lay/modules/table.js"];
    [self addHandler:@"/layui/lay/modules/laytpl.js"];
    [self addHandler:@"/layui/lay/modules/laypage.js"];
    [self addHandler:@"/layui/lay/modules/layer.js"];
    [self addHandler:@"/layui/lay/modules/jquery.js"];
    [self addHandler:@"/layui/lay/modules/form.js"];
    [self addHandler:@"/layui/lay/modules/carousel.js"];
    [self addHandler:@"/layui/lay/modules/code.js"];
    [self addHandler:@"/layui/lay/modules/colorpicker.js"];
    [self addHandler:@"/layui/lay/modules/element.js"];
    [self addHandler:@"/layui/lay/modules/laydate.js"];
    [self addHandler:@"/layui/lay/modules/layedit.js"];
    [self addHandler:@"/layui/lay/modules/mobile.js"];
    [self addHandler:@"/layui/lay/modules/rate.js"];
    [self addHandler:@"/layui/lay/modules/slider.js"];
    [self addHandler:@"/layui/lay/modules/tree.js"];
    [self addHandler:@"/layui/lay/modules/upload.js"];
    [self addHandler:@"/layui/lay/modules/util.js"];
}
    
- (void)addHandler:(NSString *)path {
    NSArray* arr = [path pathComponents];
    NSString* ext = [path pathExtension];
    NSString* name = [arr.lastObject stringByReplacingOccurrencesOfString:[NSString stringWithFormat:@".%@",ext] withString:@""];
    [_server addHandlerForMethod:@"GET" path:path requestClass:[GCDWebServerRequest class] processBlock:^GCDWebServerResponse * _Nullable(__kindof GCDWebServerRequest * _Nonnull request) {
        NSString* path = [[NSBundle mainBundle] pathForResource:name ofType:ext];
        NSError* error;
        NSString* css = [[NSString alloc] initWithContentsOfFile:path encoding:NSUTF8StringEncoding error:&error];
        return [GCDWebServerDataResponse responseWithHTML:css];
    }];
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
    
    [_tasks insertObject:taskString atIndex:0];
    [[NSUserDefaults standardUserDefaults] setObject:_tasks forKey:kNetworkTaskList];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

#pragma mark - HiNetURLSessionExchangerDelegate
- (void)urlSession:(HiNetURLSessionExchanger*)exchanger didStart:(NSURLSessionDataTask*)dataTask {
    NSString* task = [NSString stringWithFormat:@"%p", dataTask];
    
    HiNetRequest* req = [[HiNetRequest alloc] init];
    req.url = dataTask.currentRequest.URL;
    req.requestHeaders = dataTask.currentRequest.allHTTPHeaderFields;
    req.requestBody = dataTask.currentRequest.HTTPBody;
    req.requestMethod = dataTask.currentRequest.HTTPMethod;
    req.startDate = @([[NSDate date] timeIntervalSince1970] * 1000);
    
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
        req.endDate = @([[NSDate date] timeIntervalSince1970] * 1000);
        [self saveTask:req];
        [self.executingTasks removeObjectForKey:task];
    }
}

@end
