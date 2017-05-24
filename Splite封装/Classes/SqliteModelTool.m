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
//    NSString *dropTableSql = @"drop table if exists Student";
    
    NSString *createSql = [NSString stringWithFormat:@"create table if not exists %@ (%@,primary key(%@))",tableName,[ModelTool columnNameAndTypesStr:cls],primaryKey];
    // 执行
    return [SqliteTool deal:createSql uid:uid];
    
    
}
// 表格是否需要和更新
+ (BOOL)isTableRequiredUpdate:(Class)cls uid:(NSString *)uid
{
    // // 1. 获取类对应的所有有效成员变量名称, 并排序
    NSArray *modelNames = [ModelTool allTableSortedIvarNames:cls];
    // 2. 获取当前表格, 所有字段名称, 并排序
   NSArray *tableNames = [TableTool tableSortedColumnNames:cls uid:uid];
    // 3. 通过对比数据判定是否需要更新
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
    
    NSString *dropTmpTableSql = [NSString stringWithFormat:@"drop table if exists %@;", temptableName];
    [execSqls addObject:dropTmpTableSql];

    NSString *createSql = [NSString stringWithFormat:@"create table if not exists %@ (%@,primary key(%@))",temptableName,[ModelTool columnNameAndTypesStr:cls],primaryKey];
    [execSqls addObject:createSql];
    // 2.根据主键插入数据
    // insert into stu_temp(stuNum) select stuNum from xmgstu
    NSString *insertPrimaryKeyData = [NSString stringWithFormat:@"insert into %@(%@) select %@ from %@;",temptableName,primaryKey,primaryKey,tableName];
    [execSqls addObject:insertPrimaryKeyData];
    // 3. 根据主键，把所有的数据更新到新的表里面
    NSArray *oldNames = [TableTool tableSortedColumnNames:cls uid:uid];
    
    NSArray *newNames = [ModelTool allTableSortedIvarNames:cls];
    
    // 4.获取更名字典
    NSDictionary *newNameToOldNameDic = @{};
    if ([cls respondsToSelector:@selector(newNameToOldNameDic)]) {
        newNameToOldNameDic = [cls newNameToOldNameDic];
    }
    
    
    for (NSString *columnName in newNames) {
        NSString *oldName = columnName;
        // 找映射的旧的字段名称
        if ([newNameToOldNameDic[columnName] length] != 0) {
            oldName = newNameToOldNameDic[columnName];
        }
        
        // 如果老表包含新的列名 ，应该从老表更新到新的临时表格里面
        if ((![oldNames containsObject:columnName] && ![oldNames containsObject:oldName]) || [columnName isEqualToString:primaryKey]) {
            continue;
        }
        
        //
        
        // update 临时表 set 新字段名称 = （select 旧字段名称 from 旧表 where 临时表.主键 = 旧表.主键）
        // update %@ set age = (select age from xmgstu where xmgstu_temp.stuNum = xmgstu.stuName);
        NSString *updateSql = [NSString stringWithFormat:@"update %@ set %@ = (select %@ from %@ where %@.%@ = %@.%@);",temptableName,columnName,oldName,tableName,temptableName,primaryKey,tableName,primaryKey];
        
        [execSqls addObject:updateSql];
        
    }
    
    NSString *deleteOldTable = [NSString stringWithFormat:@"drop table if exists %@",tableName];
    [execSqls addObject:deleteOldTable];
    
    
    
    
    NSString *renameTableName = [NSString stringWithFormat:@"alter table %@ rename to %@",temptableName,tableName];
    [execSqls addObject:renameTableName];
    
  return  [SqliteTool dealSqlS:execSqls uid:uid];
    
    
}

+ (BOOL)saveOrUpdateModel:(id)model uid:(NSString *)uid
{
    // 如果用户在使用过程中，直接调用这个方法，去保存模型
    // 保存一个模型
    Class cls = [model class];
    // 1.判断表格是否存在，不存在就创建
    if (![TableTool isTableExists:cls uid:uid]) {
//        [self updateTable:cls uid:uid];
        [self createTable:cls uid:uid];
    }
    // 2.检测表格是否需要更新，需要就更新
    if ([self isTableRequiredUpdate:cls uid:uid]) {
       BOOL result = [self updateTable:cls uid:uid];
        if (!result) {
            NSLog(@"更新数据库表结构失败");
            return NO;
        }
    }
    // 3.判断记录是否存在，主键
    // 从表格里面，按照主键，进行查询该记录，如果能够查询到
    NSString *tableName = [ModelTool tableName:cls];
    if (![cls respondsToSelector:@selector(primaryKey)]) {
        NSLog(@"如果想要操作这个模型, 必须要实现+ (NSString *)primaryKey;这个方法, 来告诉我主键信息");
        return NO;
    }
    
    NSString *primaryKey = [cls primaryKey];
    id primaryValue = [model valueForKey:primaryKey];
    
    NSString *checkSql = [NSString stringWithFormat:@"select * from %@ where %@ = '%@'",tableName,primaryKey,primaryValue];
    NSArray *result = [SqliteTool querySql:checkSql uid:uid];
    
    // 获取字段名称数组
    NSArray *columnNames = [ModelTool classIvarNameTypeDic:cls].allKeys;
    
   // 获取值数组
    // model keyPath
    NSMutableArray *values = [NSMutableArray array];
    for (NSString *columnName in columnNames) {
        id value = [model valueForKey:columnName];
        
        // 处理模型里面的数组等情况
        if ([value isKindOfClass:[NSArray class]] || [value isKindOfClass:[NSDictionary class]]) {
            // 在这里,把字典或者数组，处理成为一个字符串，保存到数据库里面去
            
            // 字典 或者数组 转 data
            NSData *data = [NSJSONSerialization dataWithJSONObject:value options:NSJSONWritingPrettyPrinted error:nil];
            
            // data转text
            value = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        }
        
        
        [values addObject:value];
    }
    
    NSInteger count = columnNames.count;
    NSMutableArray *setValueArray = [NSMutableArray array];
    for (int i = 0; i < count; i++) {
        NSString *name = columnNames[i];
        id value = values[i];
        NSString *setStr = [NSString stringWithFormat:@"%@='%@'",name,value];
        [setValueArray addObject:setStr];
    }
    
    // 更新
    // 字段名称，字段值
    // update 表名 set 字段1=字段1值，字段2=字段2的值... where 主键 = ‘主键值’
    NSString *execSql = @"";
    if (result.count > 0) {
        execSql = [NSString stringWithFormat:@"update %@ set %@ where %@ = '%@'",tableName,[setValueArray componentsJoinedByString:@","],primaryKey,primaryValue];
    } else {
        // insert into 表名(字段1, 字段2, 字段3) values ('值1', '值2', '值3')
        // '   值1', '值2', '值3   '
        // 插入
        // text sz 'sz' 2 '2'
        
        execSql = [NSString stringWithFormat:@"insert into %@(%@) values('%@')", tableName, [columnNames componentsJoinedByString:@","], [values componentsJoinedByString:@"','"]];
    }
    
    return [SqliteTool deal:execSql uid:uid];
    
}


+ (BOOL)deleteModel:(id)model uid:(NSString *)uid
{
    Class cls = [model class];
    
    NSString *tableName = [ModelTool tableName:cls];
    
    if (![cls respondsToSelector:@selector(primaryKey)]) {
        //        NSLog(@"必须设置+ (NSString *)primaryKey;这个方法设置主键");
        return NO;
    }
  
    NSString *primaryKey = [cls primaryKey];
    id primaryValue = [model valueForKeyPath:primaryKey];
    NSString *deleteSql = [NSString stringWithFormat:@"delete from %@ where %@ = '%@'",tableName,primaryKey,primaryValue];
    
    return [SqliteTool deal:deleteSql uid:uid];
}


+ (BOOL)deleteModel:(Class)cls whereStr:(NSString *)whereStr uid:(NSString *)uid
{
   
    
    NSString *tableName = [ModelTool tableName:cls];
    
 
    
    NSString *deleteSql = [NSString stringWithFormat:@"delete from %@ ",tableName];
    if (whereStr.length > 0) {
        deleteSql = [deleteSql stringByAppendingFormat:@"where %@",whereStr];
    }
    return [SqliteTool deal:deleteSql uid:uid];
}


+ (BOOL)deleteModel:(Class)cls columnName:(NSString *)name relation:(ColumnNameToValueRelationType)relation value:(id)value uid:(NSString *)uid
{
    NSString *tableName = [ModelTool tableName:cls];
    

    
    NSString *deleteSql = [NSString stringWithFormat:@"delete from %@ where %@ %@ '%@'",tableName,name,self.ColumnNameToValueRelationTypeDic[@(relation)],value];
    //  假设不为空
    
    return [SqliteTool deal:deleteSql uid:uid];
}

+ (NSArray *)queryAllModels:(Class)cls uid:(NSString *)uid
{
    NSString *tableName = [ModelTool tableName:cls];
    // 1.sql
    NSString *sql = [NSString stringWithFormat:@"select * from %@",tableName];
    
    // 2.执行
    NSArray <NSDictionary *>*results = [SqliteTool querySql:sql uid:uid];
    
    // 3.处理结果集
    return [self parseResults:results withClass:cls];
}

+ (NSArray *)queryModel:(Class)cls columnName:(NSString *)name relation:(ColumnNameToValueRelationType)relation value:(id)value uid:(NSString *)uid
{
    NSString *tableName = [ModelTool tableName:cls];
    // 1.拼接sql
    NSString *sql = [NSString stringWithFormat:@"select * from %@ where %@ %@ '%@'",tableName,name,self.ColumnNameToValueRelationTypeDic[@(relation)],value];
    // 2.查询结果
    NSArray <NSDictionary *>*results = [SqliteTool querySql:sql uid:uid];
    
    // 3.处理结果集
    return [self parseResults:results withClass:cls];
}

+ (NSArray *)queryModels:(Class)cls WithSql:(NSString *)sql uid:(NSString *)uid
{
   
    // 2.查询结果
    NSArray <NSDictionary *>*results = [SqliteTool querySql:sql uid:uid];
    
    // 3.处理结果集
    return [self parseResults:results withClass:cls];
    
}

// 抽取结果集
+ (NSArray *)parseResults:(NSArray <NSDictionary *>*)results withClass:(Class)cls
{
    // 3.处理结果集
    NSMutableArray *models = [NSMutableArray array];
    
    // 属性名称 -> 类型 dic
    NSDictionary *nametypeDic = [ModelTool classIvarNameTypeDic:cls];
    for (NSDictionary *modelDic in results) {
        id model = [[cls alloc] init];
        [models addObject:model];
        
        
        [modelDic enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
            
            // 如果是字典或者数组
            
            NSString *type = nametypeDic[key];
            
            
            id resultValue = obj;
            if ([type isEqualToString:@"NSArray"] || [type isEqualToString:@"NSDictionary"]) {
                
                NSData *data = [obj dataUsingEncoding:NSUTF8StringEncoding];
                
                resultValue = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:nil];
                
            } else if ([type isEqualToString:@"NSMutableArray"] || [type isEqualToString:@"NSMutableDictionary"]) {
            
                NSData *data = [obj dataUsingEncoding:NSUTF8StringEncoding];
                
                resultValue = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableLeaves error:nil];

                
            }
            
            [model setValue:resultValue forKey:key];
        }];
        
        
    }
    return models;

}

+ (NSDictionary *)ColumnNameToValueRelationTypeDic
{
    return @{
             @(ColumnNameToValueRelationTypeMore):@">",
             @(ColumnNameToValueRelationTypeLess):@"<",
             @(ColumnNameToValueRelationTypeEqual):@"=",
             @(ColumnNameToValueRelationTypeMoreEqual):@">=",
             @(ColumnNameToValueRelationTypeLessEqual):@"<="
             };
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
