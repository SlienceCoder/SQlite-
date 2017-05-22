//
//  ModelTool.h
//  Splite封装
//
//  Created by xpchina2003 on 2017/5/12.
//  Copyright © 2017年 xpchina2003. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ModelTool : NSObject

+ (NSString *)tableName:(Class)cls;
+ (NSString *)tempTableName:(Class)cls;

// 所有的字段和类型（成员变量和类型）
+ (NSDictionary *)classIvarNameTypeDic:(Class)cls;

// 映射到数据库里面的类型
+ (NSDictionary *)classIvarNameSqliteTypeDic:(Class)cls;

+ (NSString *)columnNameAndTypesStr:(Class)cls;

// 获取排序后的数据组
+ (NSArray *)allTableSortedIvarNames:(Class)cls;

@end
