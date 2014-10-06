module Examples.Control.Each.Monomorphic where

  import Control.Each

  import Data.Maybe

  import Debug.Trace

  data Foo = Foo Number Number Boolean

  instance showFoo :: Show Foo where
    show (Foo m n b) =
      "Foo (" ++ show m ++ ") (" ++ show n ++ ") (" ++ show b ++ ")"

  instance eachFooNumber :: Each Foo Foo Number Number where
    each f (Foo m n b) = Foo <$> f m <*> f n <*> pure b

  instance eachFooBoolean :: Each Foo Foo Boolean Boolean where
    each f (Foo m n b) = Foo m n <$> f b

  main = do
    let foo = Foo 3 4 true
    print foo -- Foo (3) (4) (true)
    -- Inference doesn't happen properly so we have to annotate the types.
    print ((each ((+) 10 >>> Just) foo) :: Maybe Foo) -- Just (Foo (13) (14) (true))
    print ((each (\b -> if b then Just b else Nothing) foo) :: Maybe Foo) -- Just (Foo (3) (4) (true))
    print ((each (not >>> \b -> if b then Just b else Nothing) foo) :: Maybe Foo) -- Nothing
