//
//  MPXSelectionCoreTests.m
//  MPXSelectionCoreTests
//
//  Created by Kolin Krewinkel on 8/24/15.
//  Copyright © 2015 Kolin Krewinkel. All rights reserved.
//

#import <XCTest/XCTest.h>

#import "MPXSelectionManager.h"
#import "MPXSelection.h"

@interface MPXSelectionManagerTests : XCTestCase

@property (nonatomic) MPXSelectionManager *selectionManager;

@end

@implementation MPXSelectionManagerTests

- (void)setUp {
    [super setUp];

    self.selectionManager = [[MPXSelectionManager alloc] init];
}

- (void)tearDown {
    self.selectionManager = nil;
    [super tearDown];
}

- (void)testSingleFinalizedSelection
{
    NSArray *originalSelections = @[[[MPXSelection alloc] initWithSelectionRange:NSMakeRange(50, 500)]];
    self.selectionManager.finalizedSelections = originalSelections;

    XCTAssertEqualObjects(self.selectionManager.visualSelections, originalSelections);
    XCTAssertEqualObjects(self.selectionManager.finalizedSelections, originalSelections);
}

- (void)testMultipleFinalizedSelections
{
    NSArray *originalSelections = @[[[MPXSelection alloc] initWithSelectionRange:NSMakeRange(0, 0)],
                                    [[MPXSelection alloc] initWithSelectionRange:NSMakeRange(10, 0)],
                                    [[MPXSelection alloc] initWithSelectionRange:NSMakeRange(10, 0)],
                                    [[MPXSelection alloc] initWithSelectionRange:NSMakeRange(50, 0)],
                                    [[MPXSelection alloc] initWithSelectionRange:NSMakeRange(50, 0)]];
    self.selectionManager.finalizedSelections = originalSelections;

    NSArray *expectedOutput = @[[[MPXSelection alloc] initWithSelectionRange:NSMakeRange(0, 0)],
                                [[MPXSelection alloc] initWithSelectionRange:NSMakeRange(10, 0)],
                                [[MPXSelection alloc] initWithSelectionRange:NSMakeRange(50, 0)]];
    XCTAssertEqualObjects(self.selectionManager.visualSelections, expectedOutput);
    XCTAssertEqualObjects(self.selectionManager.finalizedSelections, expectedOutput);
}

- (void)testTemporaryToFinalizedSelection
{
    NSArray *originalSelections = @[[[MPXSelection alloc] initWithSelectionRange:NSMakeRange(50, 500)]];
    [self.selectionManager setTemporarySelections:originalSelections];
    XCTAssertEqualObjects(self.selectionManager.visualSelections, originalSelections);
    XCTAssertNil(self.selectionManager.finalizedSelections);

    NSArray *finalSelections = @[[[MPXSelection alloc] initWithSelectionRange:NSMakeRange(30, 300)]];
    self.selectionManager.finalizedSelections = finalSelections;
    XCTAssertEqualObjects(self.selectionManager.finalizedSelections, finalSelections);
}

- (void)testZeroLengthIdenticalCoallescing
{
    MPXSelection *selection1 = [[MPXSelection alloc] initWithSelectionRange:NSMakeRange(10, 0)];
    MPXSelection *selection2 = [[MPXSelection alloc] initWithSelectionRange:NSMakeRange(10, 0)];

    self.selectionManager.finalizedSelections = @[selection1, selection2];
    XCTAssertEqualObjects(self.selectionManager.finalizedSelections, @[selection1]);
}

@end
