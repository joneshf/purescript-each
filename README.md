# Purescript-each

#### Installation

Install with bower.

```
bower i purescript-each
```

#### Motiviation

The reason for this library is two-fold.

1. Trick people into learning about lenses in a way that is less heady.
1. Provide a way to traverse monomorphic data types.

The idea is that if you have some data types like:

```haskell
data Foo   = Foo Number Number Number
data Bar a = Bar a      a      a
```

You should be able to implement most (if not all) of the type classes in the `Functor` hierarchy for `Bar`, because it is polymorphic.
However, you cannot actually implement any of the type classes in the `Functor` hierarchy for `Foo`, because it is monomorphic.

This means you do not have an easy way to `traverse` all of the fields of `Foo` like you can for `Bar`.
You end up having to write special cased functions and whatnot.
This seems to miss the point of reuse.

So, we steal the idea of a `Traversal` from lens, and push it up to the type class level with our `Each` class.

What is `Traversal`?
It's a type synonym:

```haskell
Traversal s t a b = forall f. (Applicative f) => (a -> f b) -> s -> f t
```

That's all that's going on.
If you look at the type signature of `traverse`, it looks very similar.

```haskell
class (Functor m, Foldable m) <= Traversable m where
  traverse :: forall f a b. (Applicative f) => (a -> f b) -> m a -> f (m b)
```

In fact, if you instantiate the type variables properly, `s ~ m a` and `t ~ m b`,
you see that we get the same type signature.
We've just stated that `Traversal` is a more general type than `traverse`, as the data type needn't be polymorphic.

What does this mean in practice?
It means that you can `traverse` monomorphic and polymorphic data types with the same api.
In other words, you can get code reuse for free!

#### Usage

N.B. This sprung out from lens, so the full power is shown when used in conjunction with lens.

`Each` is a typeclass with one member: `each`, so it needs to be implemented.

Let's look at the type class:

```haskell
class Each s t a b where
  each :: forall f. (Applicative f) => (a -> f b) -> s -> f t
```

Looking at each type variable:

* `s` is the data type we're starting with
* `t` is the data type we want to end up with
* `a` is the type of `s` we want to focus on
* `b` is the type of `t` we end up focusing on

Meaning, in our `Foo` example, we would be starting and ending with the same data type (`Foo`), and focusing on the same type (`Number`). We can just follow the types for the implementation.

```haskell
instance eachFoo :: Each Foo Foo Number Number where
  each f (Foo x y z) = Foo <$> f x <*> f y <*> f z
```

So, using some functions from lens, we could use this in the follow ways:

```haskell
Foo 1 2 3 # each .~ 0         -- Foo 0  0  0
Foo 1 2 3 # each *~ 10        -- Foo 10 20 30
Foo 1 2 3 # over each negate  -- Foo -1 -2 -3
```

The use of lens is **not** necessary, it just provides an implicit wrapping/unwrapping of `Identity` so that you don't have to worry about manging the `Applicative` instance.

Of course, there are instances for the more common data types in this library.
In particular: `[]`, `Either`, `Maybe`, and `Tuple`.

There are more examples in the `examples` directory.
