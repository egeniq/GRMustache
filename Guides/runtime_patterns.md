[up](../../../../GRMustache#documentation), [next](sample_code/indexes.md)

Patterns For Feeding GRMustache Templates
=========================================

You'll learn here a few practical techniques for feeding your templates. The loading of templates is covered in the [Templates Guide](templates.md). The [Runtime Guide](runtime.md) covers how GRMustache processes your data.

Summary
-------

**Rendering your raw model objects is fine.**

Objective-C categories, GRMustache filters and [rendering objects](rendering_objects.md) (not covered here but quite useful as well) are there to help you render complex graphs of model objects.

GRMustache ships with [sample code](../../../tree/master/Guides/sample_code) that covers common developer needs. Don't miss them, and run the sample projects.

**Ambitious templates may need ViewModel objects.**

When templates render data that can not be extracted from the model in a straightforward manner, ViewModel objects will act as a clean interface, keeping your application modular and testable.


Rendering raw application models
--------------------------------

If you are lucky, your templates can render your models directly. Given the following template:

    {{< page }}
    {{$ page_content }}
        <h1>{{firstName}} {{lastName}}</h1>
        <ul>
        {{# pets }}
            <li>{{name}}</li>
        {{/ pets }}
        </ul>
    {{/ page_content }}
    {{/ page }}

It's likely that your `User` class has the `firstName`, `lastName` and `pets` properties, and that the Pet class has its `name` property. The rendering is as simple as:

```objc
[self.template renderObject:user error:NULL];
```

(side note: this template uses a common `page` layout partial. Check the [Partials Guide](partials.md) for more information.)

On the edge of the trivial zone
-------------------------------

Now the template should render the age of each pet:

    ...
    {{# pets }}
        <li>{{name}}, {{age}} year(s)</li>
    {{/ pets }}
    ...

Of course, your Pet class has no `age` property.

Instead it has a `birthDate` property or type NSDate, or even maybe a `birthDateComponents` property of type NSDateComponents, which can't be messed up with any time zone.

How should we feed this `{{age}}` tag?

We'll see several options below. Each one has its advantages, and its drawbacks. The goal of this guide is to show that GRMustache supports many patterns. So let's start the journey.

Ad-Hoc Properties
-----------------

Quickly done, quite efficient, is the technique that adds an `age` property to the Pet class.

**Ad-Hoc Properties Benefits**: Done in five minutes, mostly spent in Xcode user interface.

**Ad-Hoc Properties Drawbacks**: The Pet class now has a property dedicated to a Mustache template it should know nothing about: the separation of concerns advocated by MVC has been trampled over.

If hell doesn't burn too much, here is how you could do it:

`Pet+GRMustache.h`

```objc
#import "Pet.h"

// Category on Pet dedicated to Mustache rendering.
@interface Pet(GRMustache)
@property (nonatomic, readonly) NSInteger age;
@end
```

`Pet+GRMustache.m`

```objc
#import "Pet+GRMustache.h"
@implementation Pet(GRMustache)
- (NSInteger)age
{
    return /* clever calculation based on self.birthDate */;
}
@end
```

The rendering code still reads:

```objc
[self.template renderObject:user error:NULL];
```

Filters
-------

If the dedicated property doesn't fit your coding standards, let us introduce GRMustache [filters](filters.md). Filters are a nice way to transform data. They do not cross the MVC barriers, and the Pet class can remain pristine.

Obviously, if the Pet class doesn't help, the template has to help itself: below is our template rewritten with filters.

    ...
    {{# pets }}
        <li>{{name}}, {{ age(birthDate) }} year(s)</li>
    {{/ pets }}
    ...

The rendering code now reads:

```objc
// Prepare template filters
id filters = @{
    @"age": [GRMustacheFilter filterWithBlock:^id(NSDate* date) {
        return /* clever calculation based on the date */;
    }]
};

// Render user with filters
[self.template renderObjectsFromArray:@[filters, user] error:NULL];
```

**Filter Benefits**: Done in five minutes. Conceptually clean.

**Filter Drawbacks**: The template is not compatible with other Mustache implementations, because filters are a GRMustache-specific addition. Help developers of other platforms: [spread the good news](https://github.com/defunkt/mustache/wiki/Other-Mustache-implementations)!


### Private and future-proof filters

You may want to "hide" the `age` filter in your template. This is the case, for example, when the template is shared between several objects, and that you don't want them to take care of feeding the template with filters.

This is how it can be done:

```objc
// Extend the base context of our template, so that the `age` filter is
// always available:
id filters = @{
    @"age": [GRMustacheFilter filterWithBlock:^id(NSDate* date) {
        return /* clever calculation based on the date */;
    }]
};
self.template.baseContext = [self.template.baseContext contextByAddingProtectedObject:filters];

// Render some users
[self.template renderObject:user1 error:NULL];
[self.template renderObject:user2 error:NULL];
```

The base context of a template provides keys that are always available for the template rendering. It contains all the ready for use tools of the [standard library](standard_library.md), for example, and now our `age` filter.

Here we have added the `age` filter as a *protected* object. This means that GRMustache will always resolve the `age` identifier to our filter. This makes our template future-proof: if the Pet class eventually gets an `age` property, the template will not suddenly resolve `age` as a number, which could not be used to compute the `age(birthDate)` expression.

Contexts are detailed in the [Rendering Objects](rendering_objects.md) and [Protected Contexts](protected_contexts) Guides.


ViewModel
---------

This technique is compatible with other Mustache implementations. It is also more verbose. And heartfully supported by GRMustache.

You set up *ViewModel* objects that fit your templates, and get rendered by GRMustache instead of the raw model objects.

The role of those ViewModel objects is to encapsulate the template interface, the set of Mustache tags that should be fed, and to translate raw model values into values that get rendered.

ViewModel objects can be defined by a set of regular classes, or a dedicated dictionary built by some specific method. Let's look at how it can be done with whole classes.

Everything starts from the `{{age}}` tag. This is the tag that can not be fed by model objects. So let's first build the `PetMustache` class, which provides data for the `{{age}}` and `{{name}}` pet tags:

`PetMustache.h`

```objc
@class Pet;

// The PetMustache class is dedicated at feeding the pet-related tags
// of a Mustache template with pet-related data.
@interface PetMustache : NSObject
@property (nonatomic, readonly) NSString *name;
@property (nonatomic, readonly) NSInteger age;
- (id)initWithPet:(Pet *)pet;
@end
```

`PetMustache.m`

```objc
#import "PetMustache.h"
#import "Pet.h"

@interface PetMustache()
@property (nonatomic) Pet *pet;
@end

@implementation PetMustache

- (id)initWithPet:(Pet *)pet
{
    self = [super init];
    if (self) {
        self.pet = pet;
    }
    return self;
}

- (NSString *)name
{
    return self.pet.name;
}

- (NSInteger)age
{
    return /* clever calculation based on self.pet.birthDate */;
}

@end
```

Our `Person` class does not give any PetMustache objects. That's unfortunate, but we need a `PersonMustache` class as well, for the `{{pets}}`, `{{firstName}}` and `{{lastName}}` person tags:

`PersonMustache.h`

```objc
@class Person;

// The PersonMustache class is dedicated at feeding the person-related tags
// of a Mustache template with person-related data.
@interface PersonMustache : NSObject
@property (nonatomic, readonly) NSString *firstName;
@property (nonatomic, readonly) NSString *lastName;
@property (nonatomic, readonly) NSArray *pets;    // array of PetMustache objects
- (id)initWithPerson:(Person *)person;
@end
```

`PersonMustache.m`

```objc
#import "PersonMustache.h"
#import "PetMustache.h"
#import "Person.h"

@interface PersonMustache()
@property (nonatomic) Person *person;
@end

@implementation PersonMustache

- (id)initWithPerson:(Person *)person
{
    self = [super init];
    if (self) {
        self.person = person;
    }
    return self;
}

- (NSString *)firstName
{
    return self.person.firstName;
}

- (NSString *)lastName
{
    return self.person.lastName;
}

- (NSArray *)pets
{
    NSMutableArray *pets = [NSMutableArray array];
    for (Pet *pet in self.person.pets) {
        [pets addObject:[[PetMustache alloc] initWithPet:pet]];
    }
    return pets;
}

@end
```

Rendering code:

```objc
PersonMustache *personMustache = [[PersonMustache alloc] initWithPerson:user];
[self.template renderObject:personMustache error:NULL];
```

Of course, it's hard to believe that the age of a pet can have you write so much boilerplate. Well, this guide is here to show you some techniques for rendering your data. Style is another topic, left to the reader's conscience.

**ViewModel Benefits**: Conceptually clean. Good base for testing the template without creating a full graph of person and pets.

**ViewModel Drawbacks**: Not done in five minutes. Quickly looks overdesigned, especially in a tutorial like this Guide.

[up](../../../../GRMustache#documentation), [next](sample_code/indexes.md)
