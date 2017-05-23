//
//  ModelTool.m
//  Splite封装
//
//  Created by xpchina2003 on 2017/5/12.
//  Copyright © 2017年 xpchina2003. All rights reserved.
//

#import "ModelTool.h"
#import "ModelProtocol.h"
#import <objc/runtime.h>

@implementation ModelTool

+ (NSString *)tableName:(Class)cls
{
    return NSStringFromClass(cls);
}
+ (NSString *)tempTableName:(Class)cls
{
    return [NSStringFromClass(cls) stringByAppendingString:@"_tep"];
}


+ (NSDictionary *)classIvarNameTypeDic:(Class)cls
{
   // 获取成员变量和类型
    unsigned int outCount = 0;
   Ivar *varList =  class_copyIvarList(cls, &outCount);
    NSMutableDictionary *nameTypeDic = [NSMutableDictionary dictionary];
    
    NSArray *igonreArr = nil;
    
    if ([cls respondsToSelector:@selector(ignoreColumnNames)]) {
        igonreArr = [cls ignoreColumnNames];
    }

    
    for (int i = 0 ; i < outCount; i++) {
        
        Ivar ivar = varList[i];
        
        // 获取成员变量名称
        NSString *ivarName= [NSString stringWithUTF8String:ivar_getName(ivar)];
        
        if ([ivarName hasPrefix:@"_"]) {
            ivarName = [ivarName substringFromIndex:1];
        }
        
        if ([igonreArr containsObject:ivarName]) {
            continue;
        }
        
        
        // 获取成员变量类型
        NSString *type = [NSString stringWithUTF8String:ivar_getTypeEncoding(ivar)];
        
        type =  [type stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"@\""]];
        
        
        [nameTypeDic setValue:type forKey:ivarName];
    }
    
    return nameTypeDic;
    
}

+ (NSDictionary *)classIvarNameSqliteTypeDic:(Class)cls
{
    NSMutableDictionary *dic = [[self classIvarNameTypeDic:cls] mutableCopy];
    
    NSDictionary *typeDic = [self ocTypeToSqliteTypeDic];
    [dic enumerateKeysAndObjectsUsingBlock:^(NSString *key, NSString *obj, BOOL * _Nonnull stop) {

        dic[key] = typeDic[obj];
        NSLog(@"%@  %@   %@",key,dic[key],typeDic[key]);
    }];
    
    return dic;
 
}

+ (NSString *)columnNameAndTypesStr:(Class)cls
{
    NSDictionary *nameTypeDic = [self classIvarNameSqliteTypeDic:cls];
    
    
    NSMutableArray *result = [NSMutableArray array];
    [nameTypeDic enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
       
        [result addObject:[NSString stringWithFormat:@"%@ %@",key,obj]];
        
    }];
    
  return   [result componentsJoinedByString:@","];
}

+ (NSArray *)allTableSortedIvarNames:(Class)cls
{

    NSDictionary *dic = [self classIvarNameTypeDic:cls];
    NSArray *keys = dic.allKeys;
   keys = [keys sortedArrayUsingComparator:^NSComparisonResult(id  _Nonnull obj1, id  _Nonnull obj2) {
        return [obj1 compare:obj2];
    }];
    return keys;
}

#pragma mark --私有方法 映射数据库和 OC类型的方法
+ (NSDictionary *)ocTypeToSqliteTypeDic{
  return   @{
      @"d": @"real", // double
      @"f": @"real", // float
      
      @"i": @"integer",  // int
      @"q": @"integer", // long
      @"Q": @"integer", // long long
      @"B": @"integer", // bool
      
      @"NSData": @"blob",
      @"NSDictionary": @"text",
      @"NSMutableDictionary": @"text",
      @"NSArray": @"text",
      @"NSMutableArray": @"text",
      
      @"NSString": @"text"
      };

}
@end
