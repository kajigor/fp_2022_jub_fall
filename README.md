## Постановка задачи
### Minesweeper

Минимум:

* Веб (или другой пользовательский) интерфейс
* Поле фиксированного размера, фиксированное количество мин, случайная генерация поля
* Обработка ошибок
* Юнит-тесты

Дополнительные задачи:

* Выбор размера поля и количества мин
* Property-based тестирование

## Архитектура решения
Back-end реализован в файле src/Minesweeper.hs, наполнение поля поддерживается с помощью data FieldChars, ход игры с помощью data GameState.

Консольное приложение и необходимые для него функции реализованы непосредственно в app/Main.hs

Ограничение на пользовательские параметры поля: 4 <= rows <= 99, 4 <= cols <= 99, bombs <= (rows * cols) / 3. Это решение было принято из соображений того, что поле не может быть слишком маленьким или большим, и мин не может быть слишком много.

## Библиотеки
Из библиотек для реализации были использованы только Data.Set для поддержки открытых клеток, флагов и бомб. А также System.Random для генерации поля.

## Производительность
Так как задача реализации сапера решается только для маленьких размеров поля, производительность высокая.