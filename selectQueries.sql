-- 1.Написать запрос, считающий суммарное количество имеющихся на сайте новостей и обзоров.

select
(select count(*) from news)
+
(select count(*) from reviews) as SUM;

-- 2.Написать запрос, показывающий список категорий новостей и количество новостей в каждой категории.

select nc_name, count(n_id)
from news_categories
left join news on nc_id = n_category
group by nc_name;

-- 3.Написать запрос, показывающий список категорий обзоров и количество обзоров в каждой категории.

select rc_name, count(r_id)
from reviews_categories
left join reviews on rc_id = r_category
group by rc_name;

-- 4.Написать запрос, показывающий список категорий новостей, категорий обзоров и дату 
-- 		самой свежей публикации в каждой категории.

select nc_name as category_name, n.n_dt as last_date
from news_categories as nc
inner join news as n on n.n_category = nc.nc_id and n.n_dt = (select max(n2.n_dt) 
							      from news as n2
                                                              where n2.n_category = nc.nc_id)
union
select rc_name as category_name, r.r_dt as last_date
from reviews_categories as rc
inner join reviews as r on r.r_category = rc.rc_id and r.r_dt = (select max(r2.r_dt) 
								 from reviews as r2
                                                      		 where r2.r_category = rc.rc_id);                                                          

-- 5.Написать запрос, показывающий список страниц сайта верхнего уровня (у таких страниц нет родительской страницы)
--   и список баннеров для каждой такой страницы.

select p.p_name, b.b_id, b.b_url
from pages as p
inner join m2m_banners_pages as m on m.p_id = p.p_id and p.p_parent is null
inner join banners as b on b.b_id = m.b_id;

-- 6.Написать запрос, показывающий список страниц сайта, на которых есть баннеры.

select distinct p.p_name
from pages as p
inner join m2m_banners_pages as m on m.p_id = p.p_id;

-- 7.Написать запрос, показывающий список страниц сайта, на которых нет баннеров.

select p.p_name
from pages as p
left join m2m_banners_pages as m on m.p_id = p.p_id where m.p_id is null;

-- 8.Написать запрос, показывающий список баннеров, размещённых хотя бы на одной странице сайта.

select distinct b.b_id, b.b_url
from banners as b
inner join m2m_banners_pages as m on m.b_id = b.b_id;

-- 9.Написать запрос, показывающий список баннеров, не размещённых ни на одной странице сайта.

select b.b_id, b.b_url
from banners as b
left join m2m_banners_pages as m on m.b_id = b.b_id where m.b_id is null;

-- 10.Написать запрос, показывающий баннеры, для которых отношение кликов к показам >= 80% 
-- (при условии, что баннер был показан хотя бы один раз).

select b_id, b_url, (b_click/b_show) * 100 as rate
from banners
where b_show >= 1 and (b_click/b_show) * 100 >= 80;

-- 11.Написать запрос, показывающий список страниц сайта, на которых показаны баннеры 
-- с текстом (в поле `b_text` не NULL).

select distinct p.p_name
from pages as p
inner join m2m_banners_pages as m on m.p_id = p.p_id
inner join banners as b on b.b_id = m.b_id and b.b_text is not null;

-- 12.Написать запрос, показывающий список страниц сайта, на которых показаны баннеры 
-- с картинкой (в поле `b_pic` не NULL).

select distinct p.p_name
from pages as p
inner join m2m_banners_pages as m on m.p_id = p.p_id
inner join banners as b on b.b_id = m.b_id and b.b_pic is not null;

-- 13.Написать запрос, показывающий список публикаций (новостей и обзоров) за 2011-й год.

select n_header as header, n_dt as date
from news
where extract(year from n_dt) = 2011
union
select r_header, r_dt
from reviews
where extract(year from r_dt) = 2011;

-- 14.Написать запрос, показывающий список категорий публикаций (новостей и обзоров), 
-- 	в которых нет публикаций.

select nc_name as category
from news_categories as nc
left join news as n on n.n_category = nc.nc_id where n.n_category is null
union
select rc_name
from reviews_categories as rc
left join reviews as r on r.r_category = rc.rc_id where r.r_category is null;

-- 15.Написать запрос, показывающий список новостей из категории «Логистика» за 2012-й год.

select n_header, n_dt
from news as n
inner join news_categories as nc on nc.nc_id = n.n_category
				and nc.nc_name = 'Логистика'
				and extract(year from n.n_dt) = 2012;

-- 16.Написать запрос, показывающий список годов, за которые есть новости, а также 
--    количество новостей за каждый из годов.

select extract(year from n_dt) as year, count(*)
from news
group by year;

-- ? 17.Написать запрос, показывающий URL и id таких баннеров, 
--    где для одного и того же URL есть несколько баннеров.

select b_url, b_id 
from banners 
where b_url in (
    select b_url 
    from banners 
    group by b_url 
    having count(*) > 1
);

-- 18.Написать запрос, показывающий список непосредственных подстраниц 
-- 	  страницы «Юридическим лицам» со списком баннеров этих подстраниц.

select p.p_name, b.b_id, b.b_url
from pages as p2
inner join pages as p on p.p_parent = p2.p_id and p2.p_name = 'Юридическим лицам'
inner join m2m_banners_pages as m on m.p_id = p.p_id
inner join banners as b on b.b_id = m.b_id;

-- 19.Написать запрос, показывающий список всех баннеров с картинками (поле `b_pic` не NULL),
--    отсортированный по убыванию отношения кликов по баннеру к показам баннера

select b_id, b_url, (b_click/b_show) as rate
from banners
where b_pic is not null
order by rate desc;

-- 20.Написать запрос, показывающий самую старую публикацию на сайте
-- (не важно – новость это или обзор).

select n_header as header, n_dt as date 
from news
union
select r_header as header, r_dt as date  
from reviews
order by date asc
limit 1;

-- ? 21.Написать запрос, показывающий список баннеров, 
-- 	  URL которых встречается в таблице один раз.

select b_url, b_id 
from banners 
where b_url in (
    select b_url 
    from banners 
    group by b_url 
    having count(*) = 1
);

-- 22.Написать запрос, показывающий список страниц сайта в порядке убывания количества баннеров, 
-- расположенных на странице. Для случаев, когда на нескольких страницах расположено одинаковое 
-- количество баннеров, этот список страниц должен быть отсортирован по возрастанию имён страниц.

select p_name, count(*) as banners_count
from pages as p
inner join m2m_banners_pages as m
on p.p_id = m.p_id
group by p_name
order by banners_count desc, p_name asc;

-- 23.Написать запрос, показывающий самую «свежую» новость и самый «свежий» обзор.

select n_header as header, n_dt as date 
from news
where n_dt = (select max(n_dt) from news)
union
select r_header as header, r_dt as date  
from reviews
where r_dt = (select max(r_dt) from reviews);

-- ? 24.Написать запрос, показывающий баннеры, в тексте которых 
-- встречается часть URL, на который ссылается баннер.

select b_id, b_url, b_text
from banners
where locate(b_text, b_url) > 0;

-- 25.Написать запрос, показывающий страницу, 
-- на которой размещён баннер с самым высоким отношением кликов к показам.
select p.p_name
from pages as p
inner join m2m_banners_pages as m on m.p_id = p.p_id
inner join banners as b on b.b_id = m.b_id 
			and (b.b_click/b.b_show) = (select max(b2.b_click/b2.b_show) from banners as b2);

-- 26.Написать запрос, считающий среднее отношение кликов к показам по всем баннерам, 
-- которые были показаны хотя бы один раз.

select avg(b_click/b_show)
from banners
where b_show >= 1;

-- 27.Написать запрос, считающий среднее отношение кликов к показам по баннерам, 
-- у которых нет графической части (поле `b_pic` равно NULL).

select avg(b_click/b_show)
from banners
where b_pic is null;

-- 28.Написать запрос, показывающий количество баннеров, размещённых на страницах сайта 
-- верхнего уровня (у таких страниц нет родительских страниц).

select count(*)
from pages as p
inner join m2m_banners_pages as m on m.p_id = p.p_id and p.p_parent is null;

-- 29.Написать запрос, показывающий баннер(ы), 
-- который(ые) показаны на самом большом количестве страниц.

select banners.b_id, b_url, count(p_id) count
from banners
inner join m2m_banners_pages on banners.b_id = m2m_banners_pages.b_id
group by b_id, b_url
having count = (select max(count)
    		from (select banners.b_id, b_url, count(p_id) count
		      from banners
        	      inner join m2m_banners_pages ON banners.b_id = m2m_banners_pages.b_id
                      group by b_id, b_url
        	      order by count desc) 
        	t);
            
-- 30.Написать запрос, показывающий страницу(ы), 
-- на которой(ых) показано больше всего баннеров.

select *
from (select p.p_name, banners_count
      from pages as p
      inner join (select m2m_banners_pages.p_id, count(*) as banners_count
    		  from m2m_banners_pages
    		  group by m2m_banners_pages.p_id) as temp on temp.p_id = p.p_id
      order by banners_count desc, p_name asc) t2
having banners_count = (select max(banners_count)
    			from (select p.p_name, banners_count
			      from pages as p
			      inner join (select m2m_banners_pages.p_id, count(*) as banners_count
					  from m2m_banners_pages
					  group by m2m_banners_pages.p_id) as temp on temp.p_id = p.p_id
			      order by banners_count desc, p_name asc) 
		        t3);
