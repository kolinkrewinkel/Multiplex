//
//     Generated by class-dump 3.5 (64 bit).
//
//     class-dump is Copyright (C) 1997-1998, 2000-2001, 2004-2013 by Steve Nygard.
//

#import "CDStructures.h"

@class DVTTestPerformanceMetricOutput, IDEEntityIdentifier, IDETest, IDETestResult, IDETestResultMessage, IDETestRunner, NSError, NSString, XCActivityRecord;

@protocol IDETestsObserver <NSObject>
- (void)didFinishTest:(IDETest *)arg1 withTestResult:(IDETestResult *)arg2 rawOutput:(NSString *)arg3;
- (void)didFailTest:(IDETest *)arg1 withTestResultMessage:(IDETestResultMessage *)arg2 rawOutput:(NSString *)arg3;
- (void)test:(IDETest *)arg1 didFinishActivity:(XCActivityRecord *)arg2;
- (void)test:(IDETest *)arg1 willStartActivity:(XCActivityRecord *)arg2;
- (void)test:(IDETest *)arg1 didMeasurePerformanceMetric:(DVTTestPerformanceMetricOutput *)arg2 rawOutput:(NSString *)arg3;
- (void)testDidOutput:(NSString *)arg1;
- (void)didStartTest:(IDETest *)arg1 withRawOutput:(NSString *)arg2;
- (void)testSuiteDidFinish:(long long)arg1 withFailures:(long long)arg2 unexpected:(long long)arg3 testDuration:(double)arg4 totalDuration:(double)arg5 rawOutput:(NSString *)arg6;
- (void)testSuite:(NSString *)arg1 willFinishAt:(NSString *)arg2 rawOutput:(NSString *)arg3;
- (void)testSuite:(NSString *)arg1 didStartAt:(NSString *)arg2 rawOutput:(NSString *)arg3;
- (void)testOperationGroupDidFinish;
- (void)testOperationWillFinishWithSuccess:(BOOL)arg1 withError:(NSError *)arg2;
- (void)testRunner:(IDETestRunner *)arg1 didLaunchTestSessionForScheme:(IDEEntityIdentifier *)arg2 withDisplayName:(NSString *)arg3;
@end

