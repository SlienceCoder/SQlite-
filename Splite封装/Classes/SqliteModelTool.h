//
//  SqliteModelTool.h
//  Splite封装
//
//  Created by xpchina2003 on 2017/5/12.
//  Copyright © 2017年 xpchina2003. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ModelProtocol.h"

typedef NS_ENUM(NSUInteger, ColumnNameToValueRelationType){
    ColumnNameToValueRelationTypeMore,
    ColumnNameToValueRelationTypeLess,
    ColumnNameToValueRelationTypeEqual,
    ColumnNameToValueRelationTypeMoreEqual,
    ColumnNameToValueRelationTypeLessEqual,
} ;

@interface SqliteModelTool : NSObject

/**
 根据一个模型类, 创建数据库表
 
 @param cls 类名
 @param uid 用户唯一标识
 @return 是否创建成功
 */
+ (BOOL)createTable:(Class)cls uid:(NSString *)uid;



/**
 判断一个表格是否需要更新
 
 @param cls 类名
 @param uid 用户唯一标识
 @return 是否需要更新
 */
+ (BOOL)isTableRequiredUpdate:(Class)cls uid:(NSString *)uid;

/**
 更新表格
 
 @param cls 类名
 @param uid 用户唯一标识
 @return 是否更新成功
 */
+ (BOOL)updateTable:(Class)cls uid:(NSString *)uid;

+ (BOOL)saveOrUpdateModel:(id)model uid:(NSString *)uid;


+ (BOOL)deleteModel:(id)model uid:(NSString *)uid;

// 根据条件删除
+ (BOOL)deleteModel:(Class)cls whereStr:(NSString *)whereStr uid:(NSString *)uid;

// 具体
+ (BOOL)deleteModel:(Class)cls columnName:(NSString *)name relation:(ColumnNameToValueRelationType)relation value:(id)value uid:(NSString *)uid;

+ (BOOL)deletaWithSql:(NSString *)sql uid:(NSString *)uid;

//
// + (BOOL)deleteModel:(Class)cls columnNames:(NSArray *)names relations:(NSArray *)relations values:(NSArray *)values andOr:(NSArray *)andOrs uids:(NSArray *)uids;

+ (NSArray *)queryAllModels:(Class)cls uid:(NSString *)uid;

+ (NSArray *)queryModel:(Class)cls columnName:(NSString *)name relation:(ColumnNameToValueRelationType)relation value:(id)value uid:(NSString *)uid;

+ (NSArray *)queryModels:(Class)cls WithSql:(NSString *)sql uid:(NSString *)uid;


@end
