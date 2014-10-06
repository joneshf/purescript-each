module Examples.Control.Each.Record where

  import Control.Each

  import Data.Maybe

  import Debug.Trace

  newtype Foo = Foo
    { foo :: Number
    , bar :: Number
    , baz :: Boolean
    }

  instance showFoo :: Show Foo where
    show (Foo o) =
      "Foo {" ++
        "foo: " ++ show o.foo ++ ", " ++
        "bar: " ++ show o.bar ++ ", " ++
        "baz: " ++ show o.baz ++
      "}"

  instance eachFooNumber :: Each Foo Foo Number Number where
    each f (Foo o) = (\f b -> Foo o{foo = f, bar = b}) <$> f o.foo <*> f o.bar

  instance eachFooBoolean :: Each Foo Foo Boolean Boolean where
    each f (Foo o) = (\b -> Foo o{baz = b}) <$> f o.baz

  main = do
    let foo = Foo {foo: 3, bar: 4, baz: true}
    print foo -- Foo {foo: 3, bar: 4, baz: true}
    -- Inference doesn't happen properly so we have to annotate the types.
    print ((each ((+) 10 >>> Just) foo) :: Maybe Foo) -- Just (Foo {foo: 13, bar: 14, baz: true})
    print ((each (\b -> if b then Just b else Nothing) foo) :: Maybe Foo) -- Just (Foo {foo: 3, bar: 4, baz: true})
    print ((each (not >>> \b -> if b then Just b else Nothing) foo) :: Maybe Foo) -- Nothing
