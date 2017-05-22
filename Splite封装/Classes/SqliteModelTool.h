//
//  SqliteModelTool.h
//  Splite封装
//
//  Created by xpchina2003 on 2017/5/12.
//  Copyright © 2017年 xpchina2003. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ModelProtocol.h"
@interface SqliteModelTool : NSObject

// 动态建标
+ (BOOL)createTable:(Class)cls uid:(NSString *)uid;

+ (void)saveModel:(id)model;

// 表格是否需要和更新
+ (BOOL)isTableRequiredUpdate:(Class)cls uid:(NSString *)uid;
@end
