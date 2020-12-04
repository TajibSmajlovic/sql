select distinct title ,first_name, last_name from film_actor
inner join actor 
on film_actor.actor_id = actor.actor_id 
inner join film
on film_actor.film_id = film.film_id 
where first_name = 'Nick'
