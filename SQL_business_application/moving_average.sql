--В той же таблице userentry (пользователь user_id, дата захода entry_at) посчитаем скользящее среднее количества посетителей платформы за три дня.
with a as (select to_char(entry_at, 'MM-DD') as dt, count (distinct user_id) as cnt
  from userentry
  group by dt),
b as (select dt, cnt, avg(cnt) over (order by dt rows between current row and 2 following) as avg2
  from a)
select dt, cnt, avg2
from b
--Здесь, вместо того, чтобы пользоваться lead и lag, удобнее воспользоваться функцией вычисления среднего как оконной, задав правила обработки строк на текущую и две следующих (получив, таким образом, скользящее окно из трёх строчек)
