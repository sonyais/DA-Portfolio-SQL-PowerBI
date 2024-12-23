--Решим задачу поиска n-го значения на языке SQL, применяя оконные функции
--Есть таблица userentry. В ней фиксируется вход пользователя на платформу, столбцы user_id (идентификатор пользователя), page_id (страница, на которую зашёл пользователь), entry_at (во сколько осуществился вход).
-- Нам необходимо найти 5-го пользователя по количеству входов (неважно, на какую страницу).
with a as (select usee_id, count(*) as cnt
  from userentry u
  group by user_id),
b as (select user_id, cnt, dense_rank() over (order by cnt desc) as rnk
  from a)
select *
from b
where rnk = 5
--Здесь после группировки количества заказов по пользователям я использовала оконную функцию dense_rank(), которая ранжировала пользователей по убываию количества заходов без разрывов.
