//
//  SqliteModelTool.m
//  Splite封装
//
//  Created by xpchina2003 on 2017/5/12.
//  Copyright © 2017年 xpchina2003. All rights reserved.
//

#import "SqliteModelTool.h"
#import "ModelTool.h"
#import "SqliteTool.h"

@implementation SqliteModelTool

// 关于这个工具类的封装
// 实现方案 2
// 1.基于配置
// 2.runtime动态获取
+ (BOOL)createTable:(Class)cls uid:(NSString *)uid
{
    // 创建表格的sql语句拼接出来
    // create table if not exists 表名 (字段1 字段1类型(约束)，字段2 字段2类型(约束)，...,primary key（字段）)
    // 1.1获取表格名称
    NSString *tableName = [ModelTool tableName:cls];
    
    
    if (![cls respondsToSelector:@selector(primaryKey)]) {
        NSLog(@"必须设置+ (NSString *)primaryKey;这个方法设置主键");
        return NO;
    }
    
    NSString *primaryKey = [cls primaryKey];
    // 1.2获取模型里面的所有字段
    NSString *createSql = [NSString stringWithFormat:@"create table if not exists %@ (%@,primary key(%@))",tableName,[ModelTool columnNameAndTypesStr:cls],primaryKey];
    // 执行
    return [SqliteTool deal:createSql uid:uid];
    
    
}

@end
