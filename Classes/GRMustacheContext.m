// The MIT License
// 
// Copyright (c) 2010 Gwendal Roué
// 
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
// 
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
// 
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.

#import "GRMustache_private.h"
#import "GRMustacheContext_private.h"


@interface GRMustacheContext()
- (id)initWithObject:(id)object;
@end


@implementation GRMustacheContext
@synthesize objects;

+ (id)contextWithObject:(id)object {
	return [[[self alloc] initWithObject:object] autorelease];
}

- (id)initWithObject:(id)object {
	if (self = [self init]) {
		objects = [[NSMutableArray arrayWithCapacity:4] retain];
		[self pushObject:object];
	}
	return self;
}

- (void)pushObject:(id)object {
	switch ([GRMustache objectKind:object]) {
		case GRMustacheObjectKindFalseValue:
			[objects addObject:[NSNull null]];
			break;
		case GRMustacheObjectKindContext:
		case GRMustacheObjectKindLambda:
			[objects addObject:object];
			break;
		default:
			NSAssert(NO, @"object is not a NSDictionary, or does not conform to GRMustacheContext protocol, or is not a GRMustacheLambda.");
			break;
	}
}

- (void)pop {
	[objects removeLastObject];
}

- (id)valueForKey:(NSString *)key {
	id value;
	for (id object in [objects reverseObjectEnumerator]) {
		if (object == [NSNull null]) {
			continue;
		}
		value = [object valueForKey:key];
		if (value != nil) {
			return value;
		}
	}
	
	return nil;
}

- (void)dealloc {
	[objects release];
	[super dealloc];
}

@end
