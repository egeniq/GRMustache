// The MIT License
// 
// Copyright (c) 2012 Gwendal Roué
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

#import "GRMustacheIdentifierExpression_private.h"
#import "GRMustacheContext_private.h"
#import "GRMustacheInvocation_private.h"

@interface GRMustacheIdentifierExpression()
@property (nonatomic, copy) NSString *identifier;

- (id)initWithIdentifier:(NSString *)identifier;
@end

@implementation GRMustacheIdentifierExpression
@synthesize debuggingToken=_debuggingToken;
@synthesize identifier=_identifier;

+ (id)expressionWithIdentifier:(NSString *)identifier
{
    return [[[self alloc] initWithIdentifier:identifier] autorelease];
}

- (id)initWithIdentifier:(NSString *)identifier
{
    self = [super init];
    if (self) {
        self.identifier = identifier;
    }
    return self;
}

- (void)dealloc
{
    [_debuggingToken release];
    [_identifier release];
    [super dealloc];
}

- (BOOL)isEqual:(id<GRMustacheExpression>)expression
{
    if (![expression isKindOfClass:[GRMustacheIdentifierExpression class]]) {
        return NO;
    }
    return [_identifier isEqual:((GRMustacheIdentifierExpression *)expression).identifier];
}


#pragma mark - GRMustacheExpression

- (id)valueForContext:(GRMustacheContext *)context filterContext:(GRMustacheContext *)filterContext delegatingTemplate:(GRMustacheTemplate *)delegatingTemplate delegates:(NSArray *)delegates invocation:(GRMustacheInvocation **)ioInvocation
{
    id value = [context valueForKey:_identifier];
    
    if (delegates.count > 0) {
        NSAssert(ioInvocation, @"WTF");
        *ioInvocation = [[[GRMustacheInvocation alloc] init] autorelease];
        (*ioInvocation).debuggingToken = _debuggingToken;
        (*ioInvocation).returnValue = value;
        (*ioInvocation).key = _identifier;
    }
    
    return value;
}

@end
