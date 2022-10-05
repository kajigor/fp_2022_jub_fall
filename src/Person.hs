{-# LANGUAGE InstanceSigs #-}
{-# LANGUAGE NamedFieldPuns #-}
module Person where

import MyEq (MyEq (..))
import ToString

-- Тип данных для человека
data Person = Person
  { firstName :: String         -- Имя, должно быть непустым
  , lastName :: String          -- Фамилия, должна быть непустой
  , formerLastNames :: [String] -- Предыдущие фамилии, если фамилия менялась
  , age :: Int                  -- Возраст, должен быть неотрицательным
  , idNumber :: (Int, Int)      -- Номер паспорта: состоит из серии и номера.
  }                             -- -- У детей (людей младше 14 лет) номера паспорта --- (0000, 000000)
  deriving (Show, Eq)

-- У разных людей разные номера паспортов
instance MyEq Person where
  (===) :: Person -> Person -> Bool
  (===) x y = idNumber x === idNumber y

-- Строка должна состоять из имени, фамилии и возраста.
-- Между именем и фамилией пробел, дальше запятая, пробел, и возраст.
instance ToString Person where
  toString :: Person -> String
  toString (Person {firstName, lastName, age}) = firstName ++ " " ++ lastName ++ ", " ++ show age 

-- Увеличить возраст на 1
ageUp :: Person -> Person
ageUp person = person {age = age person + 1}

-- Сменить фамилию.
-- Если новая фамилия совпадает с текущей, ничего не меняется
-- Старая фамилия запоминается в formerLastNames
updateLastName :: Person -> String -> Person
updateLastName person newLastName | lastName person /= newLastName = person{formerLastNames = lastName person : formerLastNames person, lastName = newLastName}
                                  | otherwise = person

-- Проверки на корректность (указаны в комментариях к типу данных)
validatePerson :: Person -> Bool
validatePerson (Person {firstName}) | firstName == [] = False
validatePerson (Person {lastName}) | lastName == [] = False
validatePerson (Person {age}) | age < 0 = False
validatePerson (Person {idNumber, age}) | age < 14 && (fst idNumber /= 0 || snd idNumber /= 0) = False
validatePerson _ = True



-- Проверить, что два человека -- тезки.
-- Тезки -- разные люди с одинаковыми именами и фамилиями
namesakes :: Person -> Person -> Bool
namesakes x y | x === y = False
namesakes x y | firstName x == firstName y && lastName x == lastName y = True
namesakes _ _ = False