DELIMITER //

CREATE FUNCTION ProperCase(str VARCHAR(255))
RETURNS VARCHAR(255)
DETERMINISTIC
BEGIN
    DECLARE result VARCHAR(255) DEFAULT '';
    DECLARE word VARCHAR(255);

    -- Remove leading and trailing spaces
    SET str = TRIM(str);

    WHILE LOCATE(' ', str) > 0 DO
        SET word = SUBSTRING_INDEX(str, ' ', 1);

        SET result = CONCAT(
            result,
            UPPER(LEFT(word,1)),
            LOWER(SUBSTRING(word,2)),
            ' '
        );

        SET str = SUBSTRING(str, LOCATE(' ', str) + 1);
        SET str = TRIM(str);
    END WHILE;

    SET result = CONCAT(
        result,
        UPPER(LEFT(str,1)),
        LOWER(SUBSTRING(str,2))
    );

    RETURN result;
END //

DELIMITER ;