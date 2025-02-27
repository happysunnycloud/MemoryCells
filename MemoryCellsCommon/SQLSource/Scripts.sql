drop table mc_folders;
drop table mc_cells;

--------------

CREATE TABLE mc_folders (
    id           INTEGER PRIMARY KEY AUTOINCREMENT
                         NOT NULL,
    folder_id    INTEGER NOT NULL,
    cell_type_id INTEGER NOT NULL
                         DEFAULT (1),
    name         TEXT    NOT NULL,
    description  TEXT,
    content      TEXT,
    create_datetime text not null default (datetime('now', 'localtime')),
    update_datetime text not null default (datetime('now', 'localtime'))
);

insert into mc_folders(folder_id, name) values (1, 'Home'); -- id = 1

--------------

CREATE TABLE mc_cells (
    id              INTEGER PRIMARY KEY AUTOINCREMENT
                            NOT NULL,
    folder_id       INTEGER NOT NULL,
    cell_type_id    INTEGER NOT NULL
                            DEFAULT (2),
    name            TEXT    NOT NULL
                            DEFAULT ('*'),
    description     TEXT,
    content         TEXT,
    create_datetime TEXT    NOT NULL
                            DEFAULT (datetime('now', 'localtime') ),
    update_datetime TEXT    NOT NULL
                            DEFAULT (datetime('now', 'localtime') ),
    is_done         BOOLEAN DEFAULT false,
    remind_datetime TEXT    DEFAULT '1899-12-30 00:00:00',
    remind          BOOLEAN DEFAULT false
);

insert into mc_cells(folder_id, name, description, content) values (1, '*', 'Home: Домашняя', 'Home: Домашняя'); -- id = 1

--------------

CREATE TRIGGER update_datetime_trigger
        BEFORE UPDATE OF id,
                         folder_id,
                         cell_type_id,
                         name,
                         description,
                         content,
                         create_datetime,
                         is_done
            ON mc_cells
      FOR EACH ROW
BEGIN
    UPDATE mc_cells
       SET update_datetime = datetime('now', 'localtime') 
     WHERE id = old.id;
END;
