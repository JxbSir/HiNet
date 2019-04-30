//
//  HiNetURLConnectionExchanger.m
//  HiNet
//
//  Created by Peter on 2019/4/30.
//  Copyright © 2019 Peter. All rights reserved.
//

#import "HiNetURLConnectionExchanger.h"

@implementation HiNetURLConnectionExchanger

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
    
}

@end
