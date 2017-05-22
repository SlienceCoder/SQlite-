//
//  ModelProtocol.h
//  Splite封装
//
//  Created by xpchina2003 on 2017/5/12.
//  Copyright © 2017年 xpchina2003. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol ModelProtocol <NSObject>

@required
+ (NSString *)primaryKey;
@optional

+ (NSArray *)ignoreColumnNames;

@end
