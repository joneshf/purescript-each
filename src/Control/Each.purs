module Control.Each where

  import Data.Array (snoc)
  import Data.Either (Either(..))
  import Data.Maybe (Maybe(..))
  import Data.Tuple (Tuple(..))

  -- |  This is a generalization of `Data.Traversable.Traversable`
  --    where the "container" can be monomorphic.
  --    This allows you to "traverse" things like Arrays and also Records
  --    (Assuming you "newtype" them in order to get around the typeclass).
  --    This comes from lens.
  class Each s t a b where
    -- each :: Traversal s t a b
    each :: forall f. (Applicative f) => (a -> f b) -> s -> f t

  -- This is exactly the `Data.Traversable.Traversable` instance.
  instance eachArray :: Each [a] [b] a b where
    -- We want to use a tail recursive version here so we don't blow the stack.
    each f = go (pure []) f
      where
        go :: forall f a b. (Applicative f) => f [b] -> (a -> f b) -> [a] -> f [b]
        go xs _ []     = xs
        go xs f (y:ys) = go (snoc <$> xs <*> f y) f ys

  -- This is exactly the `Data.Traversable.Traversable` instance.
  instance eachEither :: Each (Either c a) (Either c b) a b where
    each f (Right x) = Right <$> f x
    each _ (Left  x) = pure $ Left x

  -- This is exactly the `Data.Traversable.Traversable` instance.
  instance eachMaybe :: Each (Maybe a) (Maybe b) a b where
    each f (Just x) = Just <$> f x
    each _ Nothing  = pure Nothing

  -- This is basically the `Data.Bifunctor.Bifunctor` instance specialized to
  -- `Data.Tuple.Tuple`s with the same type on both sides.
  -- Meaning that one function applies to both the first and second fields.
  instance eachTuple :: Each (Tuple a a) (Tuple b b) a b where
    each f (Tuple a b) = Tuple <$> f a <*> f b
