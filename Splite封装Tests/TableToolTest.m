//
//  TableToolTest.m
//  Splite封装
//
//  Created by xpchina2003 on 2017/5/22.
//  Copyright © 2017年 xpchina2003. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "TableTool.h"
#import "SqliteModelTool.h"

@interface TableToolTest : XCTestCase

@end

@implementation TableToolTest

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testExample {

    Class cls = NSClassFromString(@"Student");
//    [TableTool tableSortedColumnNames:cls uid:nil];
//    BOOL result = [SqliteModelTool isTableRequiredUpdate:cls uid:nil];
   BOOL result = [SqliteModelTool updateTable:cls uid:nil];

}

- (void)testPerformanceExample {
    // This is an example of a performance test case.
    [self measureBlock:^{
        // Put the code you want to measure the time of here.
    }];
}

@end
