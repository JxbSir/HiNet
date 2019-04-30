//
//  HiNetURLSessionExchanger.m
//  HiNet
//
//  Created by Peter on 2019/4/30.
//  Copyright © 2019 Peter. All rights reserved.
//

#import "HiNetURLSessionExchanger.h"
#include <objc/runtime.h>

@implementation HiNetURLSessionExchanger

- (instancetype)init
{
    self = [super init];
    if (self) {
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            [self exchange];
        });
    }
    return self;
}

- (void)exchange {
    Class sessionClass = NSClassFromString(@"__NSCFURLLocalSessionConnection");
    Class taskClass = NSClassFromString(@"__NSCFURLSessionTask");
    
    if (sessionClass == nil) {
        sessionClass = NSClassFromString(@"__NSCFURLSessionConnection");
    }
    
    if (sessionClass) {
        [self swizzleSessionDidReceiveData:sessionClass];
        [self swizzleSessionDidReceiveResponse:sessionClass];
        [self swizzleSessiondDidFinishWithError:sessionClass];
    }
    
    if (taskClass) {
        [self swizzleSessionTaskResume:taskClass];
    }
}

#pragma mark - internal exchange method
- (void)swizzleSessionTaskResume:(Class)class
{
    SEL selector = NSSelectorFromString(@"resume");
    Method m = class_getInstanceMethod(class, selector);
    
    if (m && [class instancesRespondToSelector:selector]) {
        
        typedef void (*OriginalIMPBlockType)(id self, SEL _cmd);
        OriginalIMPBlockType originalIMPBlock = (OriginalIMPBlockType)method_getImplementation(m);
        
        __weak typeof(self) weakSelf = self;
        
        void (^swizzledSessionTaskResume)(id) = ^void(id self) {
            [weakSelf.delegate urlSession:weakSelf didStart:self];
            originalIMPBlock(self, _cmd);
        };
        
        method_setImplementation(m, imp_implementationWithBlock(swizzledSessionTaskResume));
    }
}

- (void)swizzleSessionDidReceiveResponse:(Class)class
{
    SEL selector = NSSelectorFromString(@"_didReceiveResponse:sniff:");
    Method m = class_getInstanceMethod(class, selector);
    
    if (m && [class instancesRespondToSelector:selector]) {
        
        typedef void (*OriginalIMPBlockType)(id self, SEL _cmd, id arg1, BOOL sniff);
        OriginalIMPBlockType originalIMPBlock = (OriginalIMPBlockType)method_getImplementation(m);
        
        __weak typeof(self) weakSelf = self;
        
        void (^swizzledSessionDidReceiveResponse)(id, id, BOOL) = ^void(id self, id arg1, BOOL sniff) {
            [weakSelf.delegate urlSession:weakSelf didReceiveResponse:[self valueForKey:@"task"] response:arg1];
            originalIMPBlock(self, _cmd, arg1, sniff);
        };
        
        method_setImplementation(m, imp_implementationWithBlock(swizzledSessionDidReceiveResponse));
    }
}

- (void)swizzleSessionDidReceiveData:(Class)class
{
    SEL selector = NSSelectorFromString(@"_didReceiveData:");
    Method m = class_getInstanceMethod(class, selector);
    
    if (m && [class instancesRespondToSelector:selector]) {
        
        typedef void (*OriginalIMPBlockType)(id self, SEL _cmd, id arg1);
        OriginalIMPBlockType originalIMPBlock = (OriginalIMPBlockType)method_getImplementation(m);
        
        __weak typeof(self) weakSelf = self;
        
        void (^swizzledSessionDidReceiveData)(id, id) = ^void(id self, id arg1) {
            [weakSelf.delegate urlSession:weakSelf didReceiveData:[self valueForKey:@"task"] data:[arg1 copy]];
            originalIMPBlock(self, _cmd, arg1);
        };
        
        method_setImplementation(m, imp_implementationWithBlock(swizzledSessionDidReceiveData));
    }
}

- (void)swizzleSessiondDidFinishWithError:(Class)class
{
    SEL selector = NSSelectorFromString(@"_didFinishWithError:");
    Method m = class_getInstanceMethod(class, selector);
    
    if (m && [class instancesRespondToSelector:selector]) {
        
        typedef void (*OriginalIMPBlockType)(id self, SEL _cmd, id arg1);
        OriginalIMPBlockType originalIMPBlock = (OriginalIMPBlockType)method_getImplementation(m);
        
        __weak typeof(self) weakSelf = self;
        
        void (^swizzledSessiondDidFinishWithError)(id, id) = ^void(id self, id arg1) {
            [weakSelf.delegate urlSession:weakSelf didFinishWithError:[self valueForKey:@"task"] error:arg1];
            originalIMPBlock(self, _cmd, arg1);
        };
        
        method_setImplementation(m, imp_implementationWithBlock(swizzledSessiondDidFinishWithError));
    }
}

@end
