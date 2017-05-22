//
//  TableTool.m
//  Splite封装
//
//  Created by xpchina2003 on 2017/5/22.
//  Copyright © 2017年 xpchina2003. All rights reserved.
//

#import "TableTool.h"
#import "ModelTool.h"
#import "SqliteTool.h"

@implementation TableTool

+ (NSArray *)tableSortedColumnNames:(Class)cls uid:(NSString *)uid
{

    NSString *tableName = [ModelTool tableName:cls];
    
    // CREATE TABLE Student (age integer,stuNum integer,score real,name text,primary key(stuNum))
    
    // SELECT sql From sqlite_master
    
    NSString *queryCreateSqlStr = [NSString stringWithFormat:@"select sql from sqlite_master where type = 'table' and name = '%@'",tableName];
    
    
  NSMutableDictionary *dic =  [[SqliteTool querySql:queryCreateSqlStr uid:uid] firstObject];
    
    NSString *createTableSql = [dic[@"sql"] lowercaseString];
    if (createTableSql.length == 0) {
        return nil;
    }
    
    createTableSql = [createTableSql stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"\"\n\t"]];
    createTableSql = [createTableSql stringByReplacingOccurrencesOfString:@"\"" withString:@""];
    createTableSql = [createTableSql stringByReplacingOccurrencesOfString:@"\t" withString:@""];
    createTableSql = [createTableSql stringByReplacingOccurrencesOfString:@"\n" withString:@""];
    
    // CREATE TABLE Student ((stuNum))

    // 1.age integer,stuNum integer,score real,name text,primary key
    NSString *nameTypesStr = [createTableSql componentsSeparatedByString:@"("][1];
    
    
    // age integer
    // stuNum integer
    // score real
    // name text
   //  primary key
    NSArray *nameTypeArr = [nameTypesStr componentsSeparatedByString:@","];
    
    NSMutableArray *names = [NSMutableArray array];
    for (NSString *nameType in nameTypeArr) {
        
        
        if ([nameType containsString:@"primary"]) {
            continue;
        }
        
        NSString *nameType2 = [nameType stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@" "]];
        // age integer
       NSString *name = [nameType2 componentsSeparatedByString:@" "].firstObject;
        [names addObject:name];
    }
    
    
    [names sortUsingComparator:^NSComparisonResult(NSString *obj1, NSString *obj2) {
        return [obj1 compare:obj2];
    }];
    
    
    return names;
    
    
}

@end
