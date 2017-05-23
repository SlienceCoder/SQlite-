//
//  SqliteToolTest.m
//  Splite封装
//
//  Created by xpchina2003 on 2017/5/12.
//  Copyright © 2017年 xpchina2003. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "SqliteTool.h"
#import "SqliteModelTool.h"
#import "Student.h"

@interface SqliteToolTest : XCTestCase

@end

@implementation SqliteToolTest

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testExample {
    
//    NSString *sql = @"create table if not exists t_stu(id integer primary key autoincrement, name text not null, age integer,score real)";
//    
//    
//   BOOL result = [SqliteTool deal:sql uid:nil];
//    XCTAssertEqual(result, YES);
    Class cls = NSClassFromString(@"Student");
    BOOL res = [SqliteModelTool createTable:cls uid:nil];
    XCTAssertEqual(res, YES);
}

- (void)testQuery {
    
    NSString *sql = @"select * from t_stu";
    NSMutableArray *result = [SqliteTool querySql:sql uid:nil];
    NSLog(@"%@",result);
}
- (void)testPerformanceExample {
    // This is an example of a performance test case.
    [self measureBlock:^{
        // Put the code you want to measure the time of here.
    }];
}

- (void)testUpdateTable
{
//    BOOL update = [SqliteModelTool updateTable:[Student class] uid:nil];
//    
//    XCTAssertTrue(update);
    Student *stu = [[Student alloc] init];
    stu.stuNum = 1;
    stu.age2 = 1;
    stu.name = @"科比";
    stu.score = 1;
    
    [SqliteModelTool saveOrUpdateModel:stu uid:nil];
//    [SqliteModelTool deleteModel:stu uid:nil];
}
- (void)test{
    
    [SqliteModelTool deleteModel:[Student class] whereStr:@"score <= 100" uid:nil];
    
    
}
- (void)test2{
    
    [SqliteModelTool deleteModel:[Student class] columnName:@"name" relation:ColumnNameToValueRelationTypeEqual value:@"王二小2" uid:nil];
    
    
}

@end
