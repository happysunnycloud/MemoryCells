-- обновить ремайндер ячейки
update                 
	mc_cells
set
	remind_datetime = :remind_datetime,
	remind = :remind
where
	id = :id