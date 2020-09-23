select * from film 
where rental_rate > (select round(avg(rental_rate), 2) from film)

/*||||||||||||||||||||||||||*/

select film_id, title from film
where film.film_id in 
(select inventory.film_id from rental
inner join inventory 
on inventory.inventory_id = rental.inventory_id
where rental.return_date between '2005-05-29' and '2005-05-30')
order by title

/*||||||||||||||||||||||||||*/

select first_name, last_name
from customer as c
where exists
(select * from payment as p
where p.customer_id = c.customer_id and p.amount > 11)

/*||||||||||||||||||||||||||*/

select f1.title, f2.title, f2.length
from film as f1
inner join film as f2
on f1.film_id != f2.film_id
and f1.length = f2.length