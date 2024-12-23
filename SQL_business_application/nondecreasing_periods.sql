--Посмотрим на динамику некоторой величины (в этом примере - количество заходов на сайт), найдём монотонные неубывающие периоды.
-- Задача: найти дни, в которые 5 дней подряд количество пользователей (уникальных), заходящих на сайт, монотонно неубывало.
--Есть таблица userentry,содержащая информацию о пользователях и их заходах на платформу. Столбцы user_id (идентификатор пользователя), entry_at (время захода).
with a as (select date(entry_at) as dt, count(distinct user_id) as cnt
  from userentry u 
  group by date(entry_at)
  order by date(entry_at)),
b as (select dt, lag(cnt, 2) over(order by dt) as lg2, lag(cnt)  over(order by dt) as lg, cnt, lead(cnt) over(order by dt) as ld, lead(cnt, 2)  over(order by dt) as ld2
  from a
  order by dt)
select * from b
where lg2 <= lg and lg <= cnt and cnt <= ld and ld <= ld2

-- Таким образом, мы получим дни, в которые 2 дня до и 2 дня после количество уникальных посетителей сайта монотонно неубывало. В этом нам помогли оконные функции lag и lead, ищущие предыдущее и следующее значения соответственно.
-- В нашем случае порядок (кто следующий, кто предыдущий) определялся датой, расположенной по возрастанию.
