-- обновить €чейку
--begin;
update
	mc_cells
set
	description = :description, 
	content = :content, 
	remind_datetime = :remind_datetime,
	remind = :remind
where
	id = :id
--commit;