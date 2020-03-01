-- Function to capitalize first letter of each word for street names
DROP FUNCTION IF EXISTS CAP_FIRST;
CREATE FUNCTION CAP_FIRST (input varchar(255))

RETURNS varchar(255)

DETERMINISTIC

BEGIN
  DECLARE len int;
  DECLARE i int;

  SET len = CHAR_LENGTH(input);
  SET input = LOWER(input);
  SET i = 0;

  WHILE (i < len) DO
    IF (MID(input, i, 1) = ' '
      OR i = 0) THEN
      IF (i < len) THEN
        SET input = CONCAT(
        LEFT(input, i),
        UPPER(MID(input, i + 1, 1)),
        RIGHT(input, len - i - 1)
        );
      END IF;
    END IF;
    SET i = i + 1;
  END WHILE;

  RETURN input;
END;



-- Format address's
DROP FUNCTION IF EXISTS FORMAT_ADDRESS;

CREATE FUNCTION FORMAT_ADDRESS (input varchar(255))

RETURNS varchar(255)

DETERMINISTIC

BEGIN

  -- fix if two spaces behind comma
  IF input LIKE '%  ,%' THEN
    SET input = REPLACE(input, '  ,', ',');
  END IF;

  -- fix if one space behind comma
  IF input LIKE '% ,%' THEN
    SET input = REPLACE(input, ' ,', ',');
  END IF;

  -- shorten street names
  IF input LIKE '%Alley%' THEN
    SET input = REPLACE(input, 'Alley', 'Ally');
  ELSEIF input LIKE '%Approach%' THEN
    SET input = REPLACE(input, 'Approach', 'App');
  ELSEIF input LIKE '%Arcade%' THEN
    SET input = REPLACE(input, 'Arcade', 'Arc');
  ELSEIF input LIKE '%Avenue%' THEN
    SET input = REPLACE(input, 'Avenue', 'Ave');
  ELSEIF input LIKE '%Boardwalk%' THEN
    SET input = REPLACE(input, 'Boardwalk', 'Bwlk');
  ELSEIF input LIKE '%Boulevard%' THEN
    SET input = REPLACE(input, 'Boulevard', 'Bvd');
  ELSEIF input LIKE '%Break%' THEN
    SET input = REPLACE(input, 'Break', 'Brk');
  ELSEIF input LIKE '%Bypass%' THEN
    SET input = REPLACE(input, 'Bypass', 'Bypa');
  ELSEIF input LIKE '%Chase%' THEN
    SET input = REPLACE(input, 'Chase', 'Ch');
  ELSEIF input LIKE '%Circuit%' THEN
    SET input = REPLACE(input, 'Circuit', 'Cct');
  ELSEIF input LIKE '%Close%' THEN
    SET input = REPLACE(input, 'Close', 'Cl');
  ELSEIF input LIKE '%Concourse%' THEN
    SET input = REPLACE(input, 'Concourse', 'Con');
  ELSEIF input LIKE '%Court%' THEN
    SET input = REPLACE(input, 'Court', 'Ct');
  ELSEIF input LIKE '%Crescent%' THEN
    SET input = REPLACE(input, 'Crescent', 'Cres');
  ELSEIF input LIKE '%Crest%' THEN
    SET input = REPLACE(input, 'Crest', 'Crst');
  ELSEIF input LIKE '%Drive%' THEN
    SET input = REPLACE(input, 'Drive', 'Dr');
  ELSEIF input LIKE '%Entrance%' THEN
    SET input = REPLACE(input, 'Entrance', 'Ent');
  ELSEIF input LIKE '%Esplanade%' THEN
    SET input = REPLACE(input, 'Esplanade', 'Esp');
  ELSEIF input LIKE '%Expressway%' THEN
    SET input = REPLACE(input, 'Expressway', 'Exp');
  ELSEIF input LIKE '%Firetrail%' THEN
    SET input = REPLACE(input, 'Firetrail', 'Ftrl');
  ELSEIF input LIKE '%Freeway%' THEN
    SET input = REPLACE(input, 'Freeway', 'Fwy');
  ELSEIF input LIKE '%Glade%' THEN
    SET input = REPLACE(input, 'Glade', 'Glde');
  ELSEIF input LIKE '%Grange%' THEN
    SET input = REPLACE(input, 'Grange', 'Gra');
  ELSEIF input LIKE '%Grove%' THEN
    SET input = REPLACE(input, 'Grove', 'Gr');
  ELSEIF input LIKE '%Highway%' THEN
    SET input = REPLACE(input, 'Highway', 'Hwy');
  ELSEIF input LIKE '%Motorway%' THEN
    SET input = REPLACE(input, 'Motorway', 'Mwy');
  ELSEIF input LIKE '%Parade%' THEN
    SET input = REPLACE(input, 'Parade', 'Pde');
  ELSEIF input LIKE '%Parkway%' THEN
    SET input = REPLACE(input, 'Parkway', 'Pwy');
  ELSEIF input LIKE '%Passage%' THEN
    SET input = REPLACE(input, 'Passage', 'Psge');
  ELSEIF input LIKE '%Place%' THEN
    SET input = REPLACE(input, 'Place', 'Pl');
  ELSEIF input LIKE '%Plaza%' THEN
    SET input = REPLACE(input, 'Plaza', 'Plza');
  ELSEIF input LIKE '%Promenade%' THEN
    SET input = REPLACE(input, 'Promenade', 'Prom');
  ELSEIF input LIKE '%Quays%' THEN
    SET input = REPLACE(input, 'Quays', 'Qys');
  ELSEIF input LIKE '%Retreat%' THEN
    SET input = REPLACE(input, 'Retreat', 'Rtt');
  ELSEIF input LIKE '%Ridge%' THEN
    SET input = REPLACE(input, 'Ridge', 'Rdge');
  ELSEIF input LIKE '%Road%' THEN
    SET input = REPLACE(input, 'Road', 'Rd');
  ELSEIF input LIKE '%Square%' THEN
    SET input = REPLACE(input, 'Square', 'Sq');
  ELSEIF input LIKE '%Steps%' THEN
    SET input = REPLACE(input, 'Steps', 'Stps');
  ELSEIF input LIKE '%Street%' THEN
    SET input = REPLACE(input, 'Street', 'St');
  ELSEIF input LIKE '%Subway%' THEN
    SET input = REPLACE(input, 'Subway', 'Sbwy');
  ELSEIF input LIKE '%Terrace%' THEN
    SET input = REPLACE(input, 'Terrace', 'Tce');
  ELSEIF input LIKE '%Track%' THEN
    SET input = REPLACE(input, 'Track', 'Trk');
  ELSEIF input LIKE '%Trail%' THEN
    SET input = REPLACE(input, 'Trail', 'Trl');
  ELSEIF input LIKE '%Vista%' THEN
    SET input = REPLACE(input, 'Vista', 'Vsta');
  END IF;

  RETURN input;
END;


-- Format NT Postcodes
DROP FUNCTION IF EXISTS FORMAT_NT_POSTCODES;

CREATE FUNCTION FORMAT_NT_POSTCODES (input varchar(255))

RETURNS varchar(255)

DETERMINISTIC

BEGIN
  DECLARE len int;
  SET len = CHAR_LENGTH(input);

  IF len = 3 THEN
    SET input = CONCAT('0', input);
  END IF;

  RETURN input;
END;


-- Format PO BOXES
DROP FUNCTION IF EXISTS FORMAT_PO_BOXES;

CREATE FUNCTION FORMAT_PO_BOXES (input varchar(255))

RETURNS varchar(255)

DETERMINISTIC

BEGIN

  IF input LIKE 'PO Box % %' THEN
    SET input = REGEXP_REPLACE(input, '[:space:]', ', ',1,3);
  END IF;

    IF input LIKE 'Locked Bag % %' THEN
    SET input = REGEXP_REPLACE(input, '[:space:]', ', ',1,3);
  END IF;

      IF input LIKE 'Private Mail Bag % %' THEN
    SET input = REGEXP_REPLACE(input, '[:space:]', ', ',1,4);
  END IF;

    IF input LIKE 'Private Bag % %' THEN
    SET input = REGEXP_REPLACE(input, '[:space:]', ', ',1,3);
  END IF;

      IF input LIKE 'GPO Box % %' THEN
    SET input = REGEXP_REPLACE(input, '[:space:]', ', ',1,3);
  END IF;

  RETURN input;
END;
