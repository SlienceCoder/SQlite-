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
#import "TableTool.h"

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
//        NSLog(@"必须设置+ (NSString *)primaryKey;这个方法设置主键");
        return NO;
    }
    
    NSString *primaryKey = [cls primaryKey];
    
    // 1.2获取模型里面的所有字段 ,以及类型
    NSString *dropTableSql = @"drop table if exists Student";
    
    NSString *createSql = [NSString stringWithFormat:@"create table if not exists %@ (%@,primary key(%@))",tableName,[ModelTool columnNameAndTypesStr:cls],primaryKey];
    // 执行
    return [SqliteTool deal:createSql uid:uid];
    
    
}
// 表格是否需要和更新
+ (BOOL)isTableRequiredUpdate:(Class)cls uid:(NSString *)uid
{
    NSArray *modelNames = [ModelTool allTableSortedIvarNames:cls];
   NSArray *tableNames = [TableTool tableSortedColumnNames:cls uid:uid];
    
    return ![modelNames isEqualToArray:tableNames];
}


+ (BOOL)updateTable:(Class)cls uid:(NSString *)uid
{
    // 1.创建一个正确结构的临时表
    // 1.1获取表格名称
    NSString *temptableName = [ModelTool tempTableName:cls];
    NSString *tableName = [ModelTool tableName:cls];
    
    if (![cls respondsToSelector:@selector(primaryKey)]) {
        //        NSLog(@"必须设置+ (NSString *)primaryKey;这个方法设置主键");
        return NO;
    }
    // 所有执行的sql语句
    NSMutableArray *execSqls = [NSMutableArray array];
    
    NSString *primaryKey = [cls primaryKey];

    NSString *createSql = [NSString stringWithFormat:@"create table if not exists %@ (%@,primary key(%@))",temptableName,[ModelTool columnNameAndTypesStr:cls],primaryKey];
    [execSqls addObject:createSql];
    // 2.根据主键插入数据
    // insert into stu_temp(stuNum) select stuNum from xmgstu
    NSString *insertPrimaryKeyData = [NSString stringWithFormat:@"insert into %@(%@) select %@ from %@;",temptableName,primaryKey,primaryKey,tableName];
    [execSqls addObject:insertPrimaryKeyData];
    // 3. 根据主键，把所有的数据更新到新的表里面
    NSArray *oldNames = [TableTool tableSortedColumnNames:cls uid:uid];
    
    NSArray *newNames = [ModelTool allTableSortedIvarNames:cls];
    
    for (NSString *columnName in newNames) {
        if (![oldNames containsObject:columnName]) {
            continue;
        }
        // update %@ set age = (select age from xmgstu where xmgstu_temp.stuNum = xmgstu.stuName);
        NSString *updateSql = [NSString stringWithFormat:@"update %@ set %@ = (select %@ from %@ where %@.%@ = %@.%@);",temptableName,columnName,columnName,tableName,temptableName,primaryKey,tableName,primaryKey];
        
        [execSqls addObject:updateSql];
        
    }
    
    NSString *deleteOldTable = [NSString stringWithFormat:@"drop table if exists %@",tableName];
    [execSqls addObject:deleteOldTable];
    
    
    
    
    NSString *renameTableName = [NSString stringWithFormat:@"alter table %@ rename to %@",temptableName,tableName];
    [execSqls addObject:renameTableName];
    
  return  [SqliteTool dealSqlS:execSqls uid:uid];
    
    
}

/*
 create table if not exists Student_tep (age integer,stuNum integer,score real,name text,score3 real,primary key(stuNum)),
 insert into Student_tep(stuNum) select stuNum from Student;,
 update Student_tep set age = (select age from Student where Student_tep.stuNum = Student.stuNum);,
 update Student_tep set name = (select name from Student where Student_tep.stuNum = Student.stuNum);,
 update Student_tep set score = (select score from Student where Student_tep.stuNum = Student.stuNum);,
 update Student_tep set score3 = (select score3 from Student where Student_tep.stuNum = Student.stuNum);,
 drop table if exists Student,
 alter table Student_tep rename to Student
 */

@end
