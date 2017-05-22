//
//  SqliteTool.m
//  Splite封装
//
//  Created by xpchina2003 on 2017/5/11.
//  Copyright © 2017年 xpchina2003. All rights reserved.
//



#import "SqliteTool.h"
#import "sqlite3.h"

//#define kCachePath NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES).firstObject
#define kCachePath @"/Users/xpchina/Desktop/sqlite封装/"


@interface SqliteTool ()

@end

@implementation SqliteTool

// 创建一个数据库
sqlite3 *ppDb = nil;

+ (BOOL)deal:(NSString *)sql uid:(NSString *)uid
{
    // 打开数据库

    if (![self openDB:uid]) {
        NSLog(@"打开");
        return NO;
    }
    
    // 执行语句
    BOOL result = sqlite3_exec(ppDb, sql.UTF8String, nil, nil, nil) == SQLITE_OK;
    
    // 关闭数据库
    [self closeDB];
    
    return result;
}
+ (NSMutableArray <NSMutableDictionary *>*)querySql:(NSString *)sql uid:(NSString *)uid
{
    [self openDB:uid];
    // 准备语句(预处理语句）
    
    // 创建准备语句
    // 1.已经打开的数据库  2.sql语句  3.参数2多少字节长度 -1自动计算 \0结束  4.准备语句 5.通过参数3取出2的长度后，剩下的字符串
    sqlite3_stmt *ppStmt = nil;
    if (sqlite3_prepare_v2(ppDb, sql.UTF8String, -1, &ppStmt, nil) != SQLITE_OK) {
        
        NSLog(@"准备语句编译失败");
        return nil;
    }
    // 绑定数据
    
    // 执行
    NSMutableArray *rowDicArr = [NSMutableArray array];
    while (sqlite3_step(ppStmt) == SQLITE_ROW) {
        // 一行记录 -> 字典
        // 获取所有列的个数
        int columCount = sqlite3_column_count(ppStmt);
        
        
        NSMutableDictionary *rowDict = [NSMutableDictionary dictionary];
        [rowDicArr addObject:rowDict];
        // 遍历所有的列
        for (int i = 0; i < columCount; i++) {
            // 2.1列明
            const char *columnNameC = sqlite3_column_name(ppStmt, i);
            NSString *columnName = [NSString stringWithUTF8String:columnNameC];
            // 2.2列值->不同列的类型，使用不同的函数，进行获取
            // 2.2.1获取列的类型
            int type = sqlite3_column_type(ppStmt, i);

             // 2,2.2根据列的类型，使用不同的函数进行获取
            id value = nil;
            switch (type) {
                case SQLITE_INTEGER:
                    value = @(sqlite3_column_int(ppStmt, i));
                    break;
                case SQLITE_FLOAT:
                    value = @(sqlite3_column_double(ppStmt, i));
                    break;
                case SQLITE_BLOB:
                    value = CFBridgingRelease(sqlite3_column_blob(ppStmt, i));
                    break;
                case SQLITE_NULL:
                    value = @"";
                    break;
                case SQLITE3_TEXT:
                   value = [NSString stringWithUTF8String:(const char*)sqlite3_column_text(ppStmt, i)];
                    break;
                default:
                    break;
            }
            [rowDict setValue:value forKey:columnName];

        }
        
        
    }
    
    
    // 重置
    
    // 释放资源
    sqlite3_finalize(ppStmt);
    
    [self closeDB];
    return rowDicArr;
    
}

+ (BOOL)dealSqlS:(NSArray <NSString *>*)sqls uid:(NSString *)uid
{
    
    [self begainTransaction:uid];
    
    for (NSString *sql in sqls) {
       BOOL result = [self deal:sql uid:uid];
        if (result == NO) {
            [self rollBackTransaction:uid];
            return NO;
        }
    }
    
    
    [self commitTransaction:uid];
    return YES;
}

+ (void)begainTransaction:(NSString *)uid
{
    [self deal:@"begin transaction" uid:uid];
}
+ (void)commitTransaction:(NSString *)uid
{
    [self deal:@"commit transaction" uid:uid];
}
+ (void)rollBackTransaction:(NSString *)uid
{
    [self deal:@"rollback transaction" uid:uid];
}

#pragma mark --私有方法
+ (BOOL)openDB:(NSString *)uid
{
    
    NSString *dbName = @"common.sqlite";
    if (uid.length != 0) {
        dbName = [NSString stringWithFormat:@"%@.sqlite",uid];
    }
    NSString *dbpath = [kCachePath stringByAppendingString:dbName];
    
    
    return  sqlite3_open(dbpath.UTF8String, &ppDb) != SQLITE_OK ?NO:YES;
        
    
}
+ (void)closeDB
{
    // 关闭数据库
    sqlite3_close(ppDb);
}

@end
