# Module Documentation

## Module Control.Each

### Type Classes

    class Each s t a b where
      each :: forall f. (Applicative f) => (a -> f b) -> s -> f t


### Type Class Instances

    instance eachArray :: Each [a] [b] a b

    instance eachEither :: Each (Either c a) (Either c b) a b

    instance eachMaybe :: Each (Maybe a) (Maybe b) a b

    instance eachTuple :: Each (Tuple a a) (Tuple b b) a b



