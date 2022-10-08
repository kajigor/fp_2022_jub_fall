module Person where

import qualified Data.Set as Set
import Data.Maybe
data Tree t = Node2 t (Tree t) (Tree t) | Node1 t (Tree t) | Terminal t deriving (Show, Eq)

data Document = Passport (Int, Int) | BirthCert (String, Int) deriving (Show, Eq, Ord)

-- Тип данных для человека
data Person = Person
  { firstName :: String         -- Имя, должно быть непустым
  , lastName :: String          -- Фамилия, должна быть непустой
  , formerLastNames :: [String] -- Предыдущие фамилии, если фамилия менялась
  , age :: Int                  -- Возраст, должен быть неотрицательным
  , idNumber :: Maybe Document  -- Какое-то удостоверение личности
  , parents :: (Maybe Person, Maybe Person)       -- Родители данного человека. Выбрать подходящий контейнер.
  }
  deriving (Show, Eq, Ord)

-- Создание ребенка данных родителей
createChild :: (Maybe Person, Maybe Person) -> Person
createChild ((Just p1), (Just p2)) = Person {firstName = firstName p1, lastName = lastName p1, formerLastNames = [], age = 0, idNumber = Just (BirthCert ("IIIP", 0)), parents = (Just p1, Just p2)}
createChild (Nothing, (Just p2)) = Person {firstName = firstName p2, lastName = lastName p2, formerLastNames = [], age = 0, idNumber = Just (BirthCert ("IIIP", 0)), parents = (Nothing, Just p2)}
createChild ((Just p1), Nothing) = Person {firstName = firstName p1, lastName = lastName p1, formerLastNames = [], age = 0, idNumber = Just (BirthCert ("IIIP", 0)), parents = (Just p1, Nothing)}
createChild (Nothing, Nothing) = Person {firstName = "orphan", lastName = "orphan", formerLastNames = [], age = 0, idNumber = Just (BirthCert ("IIIP", 0)), parents = (Nothing, Nothing)}

-- Самый далекий предок данного человека.
-- Если на одном уровне иерархии больше одного предка -- вывести самого старшего из них.
-- Если на одном уровне иерархии больше одного предка одного максимального возраста -- вывести любого из них
cast :: Maybe Person -> Person
cast (Just person) = person

greatestAncestor :: Person -> Person
greatestAncestor person | (not $ isNothing $ fst $ parents person) && (not $ isNothing $ snd $ parents person)  = (greatestAncestor $ cast $ fst $ parents person) `f` (greatestAncestor $ cast $ snd $ parents person)
                        | (not $ isNothing $ fst $ parents person) = (greatestAncestor $ cast $ fst $ parents person)
                        | (not $ isNothing $ snd $ parents person) = (greatestAncestor $ cast $ snd $ parents person)
                        | otherwise = person
  where
    f p1 p2 | (age p1) >= (age p2) = p1 | otherwise = p2 


-- Предки на одном уровне иерархии.
ancestors :: Int -> Person -> Set.Set Person
ancestors 0 person = Set.singleton person
ancestors level person | (not $ isNothing $ fst $ parents person) && (not $ isNothing $ snd $ parents person) = Set.union (ancestors (level - 1) (cast $ fst $ parents person)) (ancestors (level - 1) (cast $ snd $ parents person))
                       | (not $ isNothing $ fst $ parents person) = ancestors (level - 1) (cast $ fst $ parents person)
                       | (not $ isNothing $ snd $ parents person) = ancestors (level - 1) (cast $ snd $ parents person)
                       | otherwise = Set.empty

-- Возвращает семейное древо данного человека, описывающее его потомков.
descendants :: Person -> Tree Person
descendants person | (not $ isNothing $ fst $ parents person) && (not $ isNothing $ snd $ parents person) = Node2 person (descendants $ cast $ fst $ parents person) (descendants $ cast $ snd $ parents person)
                   | (not $ isNothing $ fst $ parents person) = Node1 person (descendants $ cast $ fst $ parents person)
                   | (not $ isNothing $ snd $ parents person) = Node1 person (descendants $ cast $ snd $ parents person)
                   | otherwise = Terminal person