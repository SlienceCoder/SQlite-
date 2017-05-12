//
//  ModelToolTest.m
//  Splite封装
//
//  Created by xpchina2003 on 2017/5/12.
//  Copyright © 2017年 xpchina2003. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "ModelTool.h"
#import "Student.h"
#import "SqliteModelTool.h"

@interface ModelToolTest : XCTestCase

@end

@implementation ModelToolTest

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testExample {
    
    
//   NSString *dic = [ModelTool columnNameAndTypesStr:[Student class]];
//   NSLog(@"%@",dic);
    
    
    
}

- (void)testPerformanceExample {
    // This is an example of a performance test case.
    [self measureBlock:^{
        // Put the code you want to measure the time of here.
    }];
}

@end
