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
// 操作模型必须实现的方法，通过这个方法获取主键信息

+ (NSString *)primaryKey;
@optional
// 忽略的字段数组
+ (NSArray *)ignoreColumnNames;

// 新字段-》旧的字段映射
+ (NSDictionary *)newNameToOldNameDic;
@end
