//
//  VGURLContent.m
//  VGContent
//
//  Created by Vlad Gorbenko on 05.07.15.
//  Copyright (c) 2015 Vlad Gorbenko. All rights reserved.
//

#import "VGURLContent.h"

#import <UIScrollView-InfiniteScroll/UIScrollView+InfiniteScroll.h>

@interface VGURLContent ()

@property (nonatomic, assign) UIScrollView *scrollView;

@end

@implementation VGURLContent

@synthesize isRefreshing = _isRefreshing;
@synthesize isAllLoaded = _isAllLoaded;
@synthesize isLoading = _isLoading;

#pragma mark - VGURLContent lifecycle

- (instancetype)initWithView:(UIView *)view {
    self = [super initWithView:view];
    if(self) {
        self.isAllLoaded = YES;
        self.scrollView = view;
        [self setupInfiniteScrollingWithScrollView:view];
    }
    return self;
}

#pragma mark - Setup methods

- (void)setupInfiniteScrollingWithScrollView:(UIScrollView *)scrollView {
    [scrollView addInfiniteScrollWithHandler:^(id scrollView) {
        if(!self.isAllLoaded) {
            [self loadMoreItems];
        }
    }];
}

#pragma mark - Accessors

- (NSInteger)offset {
    return _isRefreshing ? 0 : self.items.count;
}

- (BOOL)isRefreshing {
    return _isRefreshing;
}

#pragma mark - VGURLContent management

- (void)loadItems {
}

- (void)refresh {
    _isRefreshing = YES;
    [self notifyWillLoad];
    [self loadItems];
}

- (void)loadMoreItems {
    _isLoading = YES;
    [self notifyWillLoad];
    [self loadItems];
}

- (void)cancel {
}

#pragma mark - URL fetching management

- (void)fetchLoadedItems:(NSArray *)items error:(NSError *)error {
    if(error) {
        [self notifyDidFailWithError:error];
        return;
    }
    if (_isRefreshing) {
        [_items removeAllObjects];
    }
    [self insertItems:items atIndex:_items.count animated:YES];
    [self notifyDidLoadWithItems:items];
    _isRefreshing = NO;
    _isLoading = NO;
    [self.scrollView finishInfiniteScroll];
}

- (void)fetchLoadedItems:(NSArray *)items pageSize:(NSInteger)pageSize error:(NSError *)error {
    _isAllLoaded = items.count < pageSize;
    [self fetchLoadedItems:items error:error];
}

#pragma mark - Notifiers

- (void)notifyDidFailWithError:(NSError *)error {
    if ([self.dataDelegate respondsToSelector:@selector (content:didFailLoadingWithError:)]) {
        [self.dataDelegate content:self didFailLoadingWithError:error];
    }
}

- (void)notifyDidLoadWithItems:(NSArray *)items {
    if ([self.dataDelegate respondsToSelector:@selector (content:didFinishLoadingWithItems:)]) {
        [self.dataDelegate content:self didFinishLoadingWithItems:items];
    }
}

- (void)notifyWillLoad {
    if ([self.dataDelegate respondsToSelector:@selector (contentWillLoadItems:)]) {
        [self.dataDelegate contentWillLoadItems:self];
    }
}

@end