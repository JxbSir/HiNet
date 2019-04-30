//
//  HiNetManager.h
//  HiNet
//
//  Created by Peter on 2019/4/30.
//  Copyright © 2019 Peter. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

UIKIT_EXTERN NSString *const kNetworkTaskList;

@interface HiNetManager : NSObject

+(instancetype)shared;

- (void)start;
@end

NS_ASSUME_NONNULL_END
