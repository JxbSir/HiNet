//
//  HiNetListModel.h
//  HiNet
//
//  Created by Peter on 2019/4/30.
//  Copyright © 2019 Peter. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "HiNetJsonable.h"

NS_ASSUME_NONNULL_BEGIN

@interface HiNetworkModel : NSObject<HiNetJsonable>
@property (nonatomic, strong) NSString* name;
@property (nonatomic, strong) NSString* method;
@property (nonatomic, strong) NSString* status;
@property (nonatomic, strong) NSString* type;
@property (nonatomic, strong) NSString* size;
@property (nonatomic, strong) NSString* time;
@property (nonatomic, strong) NSString* start;
@property (nonatomic, strong) NSString* end;
@end

@interface HiNetListModel : NSObject<HiNetJsonable>
@property (nonatomic, assign) NSInteger code;
@property (nonatomic, assign) NSInteger count;
@property (nonatomic, strong) NSArray<HiNetworkModel *> *data;
@end

NS_ASSUME_NONNULL_END
