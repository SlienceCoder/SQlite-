//
//  TableTool.h
//  Splite封装
//
//  Created by xpchina2003 on 2017/5/22.
//  Copyright © 2017年 xpchina2003. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TableTool : NSObject

+ (NSArray *)tableSortedColumnNames:(Class)cls uid:(NSString *)uid;

+ (BOOL)isTableExists:(Class)cls uid:(NSString *)uid;

@end
