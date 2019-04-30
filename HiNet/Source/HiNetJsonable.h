//
//  HiNetJsonable.h
//  HiNet
//
//  Created by Peter on 2019/4/30.
//  Copyright © 2019 Peter. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol HiNetJsonable <NSObject>
- (NSMutableDictionary*)toJSON;
- (instancetype)initWithJSON:(id)json;
@end
