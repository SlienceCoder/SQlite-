//
//  SqliteTool.h
//  Splite封装
//
//  Created by xpchina2003 on 2017/5/11.
//  Copyright © 2017年 xpchina2003. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SqliteTool : NSObject
// 用户机制
// uid ： nil  --> common.db
// uid : zhangsan  --> zhangsan.db

+ (BOOL)deal:(NSString *)sql uid:(NSString *)uid;


+ (BOOL)dealSqlS:(NSArray <NSString *>*)sqls uid:(NSString *)uid;


+ (NSMutableArray <NSMutableDictionary *>*)querySql:(NSString *)sql uid:(NSString *)uid;



@end
