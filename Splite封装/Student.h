//
//  Student.h
//  Splite封装
//
//  Created by xpchina2003 on 2017/5/12.
//  Copyright © 2017年 xpchina2003. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ModelProtocol.h"

@interface Student : NSObject <ModelProtocol>
{
    int b;
}
@property (nonatomic, assign) int stuNum;
@property (nonatomic, copy) NSString *name;
@property (nonatomic, assign) int age2;
@property (nonatomic, assign) float score;
@property (nonatomic, assign) float score2;
@property (nonatomic, assign) float score3;
@end
