//
//  CATActionViewController.m
//  Catalyst
//
//  Created by Kolin Krewinkel on 11/23/14.
//  Copyright (c) 2014 Kolin Krewinkel. All rights reserved.
//

#import "CATActionViewController.h"

@interface CATActionViewController ()

@property (nonatomic) NSTextField *searchField;
@property (nonatomic) NSTableView *tableView;
@property (nonatomic) NSScrollView *scrollView;

@end

@implementation CATActionViewController

- (void)loadView
{
    self.view = ({
        NSView *view = [[NSView alloc] initWithFrame:CGRectMake(0.f, 0.f, 240.f, 320.f)];
        view.wantsLayer = YES;
        view;
    });

    self.scrollView = ({
        NSScrollView *scrollView = [[NSScrollView alloc] initWithFrame:CGRectMake(2.f, 2.f, self.view.frame.size.width - (2.f + 2.f), self.view.frame.size.height - (20.f + 4.f + 2.f))];
        scrollView.drawsBackground = NO;
        scrollView;
    });

    self.searchField = ({
        NSTextField *searchField = [[NSTextField alloc] initWithFrame:CGRectMake(4.f, self.view.frame.size.height - (20.f + 4.f), self.view.frame.size.width - 8.f, 20.f)];
        searchField.drawsBackground = NO;
        searchField.bezeled = NO;
        searchField.focusRingType = NSFocusRingTypeNone;
        searchField;
    });
    [self.view addSubview:self.searchField];
}

- (void)viewWillTransitionToSize:(NSSize)newSize
{
    [super viewWillTransitionToSize:newSize];

    self.searchField.frame = CGRectMake(5.f, 5.f, newSize.width - 10.f, 20.f);
}

@end
