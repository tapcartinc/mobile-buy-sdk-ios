//
//  CHKCart.m
//  Checkout
//
//  Created by Shopify on 2014-09-15.
//  Copyright (c) 2014 Shopify Inc. All rights reserved.
//

#import "CHKCart.h"
#import "CHKLineItem.h"
#import "CHKProductVariant.h"

@implementation CHKCart {
	NSMutableArray *_lineItems;
	NSMutableDictionary *_variantToLineItem;
}

- (instancetype)init
{
	self = [super init];
	if (self) {
		_lineItems = [[NSMutableArray alloc] init];
		_variantToLineItem = [[NSMutableDictionary alloc] init];
	}
	return self;
}

- (NSArray *)lineItems
{
	return [NSArray arrayWithArray:_lineItems];
}

- (BOOL)isValid
{
	return [[self lineItems] count] > 0;
}

- (void)clearCart
{
	NSArray *lineItems = [self lineItems];
	for (CHKLineItem *lineItem in lineItems) {
		[self removeLineItemsObject:lineItem];
	}
}

#pragma mark - Simple Cart Editing

- (void)createLineItem:(CHKProductVariant *)variant
{
	CHKLineItem *lineItem = [[CHKLineItem alloc] initWithVariant:variant];
	if (variant.identifier) {
		_variantToLineItem[variant.identifier] = lineItem;
	}
	[_lineItems addObject:lineItem];
}

- (void)addVariant:(CHKProductVariant *)variant
{
	CHKLineItem *existingLineItem = [self lineItemForVariant:variant];
	if (existingLineItem) {
		existingLineItem.quantity = [existingLineItem.quantity decimalNumberByAdding:[NSDecimalNumber one]];
	}
	else {
		[self createLineItem:variant];
	}
}

- (void)removeVariant:(CHKProductVariant *)variant
{
	CHKLineItem *existingLineItem = [self lineItemForVariant:variant];
	if (existingLineItem) {
		existingLineItem.quantity = [existingLineItem.quantity decimalNumberBySubtracting:[NSDecimalNumber one]];
		if ([[existingLineItem quantity] isEqual:[NSDecimalNumber zero]]) {
			[_lineItems removeObject:existingLineItem];
			if (existingLineItem.variant.identifier) {
				[_variantToLineItem removeObjectForKey:existingLineItem.variant.identifier];
			}
		}
	}
}

#pragma mark - Direct Line Item Editing

- (void)addLineItemsObject:(CHKLineItem *)object
{
	CHKLineItem *existingLineItem = [self lineItemForVariant:object.variant];
	if (existingLineItem) {
		[_lineItems removeObject:existingLineItem];
	}
	[_lineItems addObject:object];
}

- (void)removeLineItemsObject:(CHKLineItem *)object
{
	[_lineItems removeObject:object];
}

#pragma mark - Helpers

- (CHKLineItem *)lineItemForVariant:(CHKProductVariant *)variant
{
	return variant.identifier ? _variantToLineItem[variant.identifier] : nil;
}

- (void)removeVariantFromCache:(CHKProductVariant *)variant
{
	if (variant.identifier) {
		[_variantToLineItem removeObjectForKey:variant.identifier];
	}
}

- (NSDictionary *)jsonDictionaryForCheckout
{
	NSMutableDictionary *cart = [[NSMutableDictionary alloc] init];
	NSArray *lineItems = [self lineItems];
	if ([lineItems count] > 0) {
		NSMutableArray *lineItemsJson = [[NSMutableArray alloc] init];
		for (CHKLineItem *lineItem in lineItems) {
			[lineItemsJson addObject:[lineItem jsonDictionaryForCheckout]];
		}
		cart[@"line_items"] = lineItemsJson;
	}
	return cart;
}

@end
