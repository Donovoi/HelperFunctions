-- ADD area codes to numbers that don't have them 
DROP FUNCTION IF EXISTS FORMAT_PHONE_NUMBERS;

CREATE FUNCTION FORMAT_PHONE_NUMBERS (input varchar(255), state varchar(255))

RETURNS varchar(255)

DETERMINISTIC

BEGIN
  DECLARE len int;
  SET len = CHAR_LENGTH(input);

  -- First remove all spaces
  SET input = REPLACE(input, ' ', '');

  -- format phone numbers to specification
  IF len = 8
    AND (state LIKE '%VIC%'
    OR state LIKE '%TAS%') THEN
    SET input = CONCAT('03', input);
  ELSEIF len = 8
    AND (state LIKE '%NSW%'
    OR state LIKE '%ACT%') THEN
    SET input = CONCAT('02', input);
  ELSEIF len = 8
    AND state LIKE '%QLD%' THEN
    SET input = CONCAT('07', input);
  ELSEIF len = 8
    AND (state LIKE '%WA%'
    OR state LIKE '%SA%'
    OR state LIKE '%NT%') THEN
    SET input = CONCAT('08', input);
  END IF;

  IF input LIKE '0%' THEN
    SET input = CONCAT(LEFT(input, 2), " ", MID(input, 3, 4), " ", RIGHT(input, 4));
  END IF;

  IF input LIKE '13%' THEN
    SET input = CONCAT(LEFT(input, 4), " ", MID(input, 4, 3), " ", RIGHT(input, 3));
  END IF;

  RETURN input;
END;