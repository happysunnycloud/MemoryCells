-- апдейт атрибутов €чейки
update
	mc_cells
set
	is_done = :is_done 
where
	id = :id
