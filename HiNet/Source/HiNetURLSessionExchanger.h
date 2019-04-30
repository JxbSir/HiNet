//
//  HiNetURLSessionExchanger.h
//  HiNet
//
//  Created by Peter on 2019/4/30.
//  Copyright © 2019 Peter. All rights reserved.
//

#import <Foundation/Foundation.h>

@class HiNetURLSessionExchanger;

NS_ASSUME_NONNULL_BEGIN

@protocol HiNetURLSessionExchangerDelegate <NSObject>
- (void)urlSession:(HiNetURLSessionExchanger*)exchanger didStart:(NSURLSessionDataTask*)dataTask;
- (void)urlSession:(HiNetURLSessionExchanger*)exchanger didReceiveResponse:(NSURLSessionDataTask*)dataTask response:(NSURLResponse*)response;
- (void)urlSession:(HiNetURLSessionExchanger*)exchanger didReceiveData:(NSURLSessionDataTask*)dataTask data:(NSData*)data;
- (void)urlSession:(HiNetURLSessionExchanger*)exchanger didFinishWithError:(NSURLSessionDataTask*)dataTask error:(NSError*)error;
@end

@interface HiNetURLSessionExchanger : NSObject

@property (nonatomic, weak) id<HiNetURLSessionExchangerDelegate> delegate;

@end

NS_ASSUME_NONNULL_END
