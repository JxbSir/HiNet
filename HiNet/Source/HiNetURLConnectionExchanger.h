//
//  HiNetURLConnectionExchanger.h
//  HiNet
//
//  Created by Peter on 2019/4/30.
//  Copyright © 2019 Peter. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@protocol HiNetURLConnectionExchangerDelegate <NSObject>

@end


@interface HiNetURLConnectionExchanger : NSObject

@property (nonatomic, weak) id<HiNetURLConnectionExchangerDelegate> delegate;

@end

NS_ASSUME_NONNULL_END
