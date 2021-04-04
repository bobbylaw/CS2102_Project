/* === 2. Each course package allows a customer to register free-of-charge for a fixed number of course sessions which can be redeemed for any course offering. === */
CREATE OR REPLACE FUNCTION REDEMPTION_LEFT()
RETURNS TRIGGER AS $$
DECLARE
num_redemption INTEGER;
BEGIN
    num_redemption := (
        SELECT num_redemption
        FROM (Buys NATURAL JOIN Redeems) AS BR
        WHERE NEW.card_number = BR.card_number 
        AND NEW.package_id = BR.package_id 
        AND NEW.purchase_date = BR.purchase_date
        LIMIT 1;                     
        );
    IF (num_redemption > 0) THEN 
        UPDATE Buys
        SET num_of_redemption = num_of_redemption - 1
        WHERE card_number = NEW.card_number 
        AND package_id = NEW.package_id 
        AND purchase_date = NEW.purchase_date; 
        RETURN NEW;
    ELSE 
        RAISE EXCEPTION 'There is no free redemption of this package!';
        RETURN NULL;
    END IF;
END
$$ LANGUAGE plpgsql;

CREATE TRIGGER REDEEM_LEFT_TRIGGER
BEFORE INSERT ON Redeems
FOR EACH ROW EXECUTE FUNCTION REDEMPTION_LEFT();

/* === 3. A customer’s course package is classified as either active if there is at least one unused session in the package, 
partially active if all the sessions in the package have been redeemed but there is at least one redeemed session that could be refunded if it is cancelled, 
or inactive otherwise. 
Each customer can have at most one active or partially active package. === */
CREATE OR REPLACE FUNCTION ACTIVE_PKG()
RETURNS TRIGGER AS $$
BEGIN
    IF EXISTS (
        SELECT 1 
        FROM (Buys NATURAL JOIN Owns_credit_cards) AS BO
        WHERE BO.cust_id = NEW.cust_id 
        AND BO.num_of_redemption > 0
    ) THEN 
        RAISE EXCEPTION 'You can only have at most one active packet!';
        RETURN NULL;
    ELSEIF EXISTS (
        SELECT 1 
        FROM (Buys NATURAL JOIN Redeems NATURAL JOIN Owns_credit_cards NATURAL JOIN Sessions) AS BROS
        WHERE BROS.cust_id = NEW.cust_id
        AND REDEMPTION_DATE -  BROS.session_date >= 7
    ) THEN
        RAISE EXCEPTION 'You can only have at most one partially active packet!';
        RETURN NULL;
    ELSE 
        RETURN NEW;
    END IF;
END
$$ LANGUAGE plpgsql;

CREATE TRIGGER ACTIVE_PKG_TRIGGER
BEFORE INSERT ON Buys
FOR EACH ROW EXECUTE FUNCTION ACTIVE_PKG();

/* === 5. Each room can be used to conduct at most one course session at any time. === */
CREATE OR REPLACE FUNCTION ROOM_AVAIL()
RETURNS TRIGGER AS $$
BEGIN
    IF EXISTS (
        SELECT rid 
        FROM Sessions
        WHERE rid = NEW.rid
        AND( 
        (NEW.start_time < start_time AND NEW.end_time > start_time AND NEW.end_time <= end_time) OR
        (NEW.start_time >= start_time AND NEW.start_time < end_time AND NEW.end_time > end_time) OR
        (NEW.start_time >= start_time AND NEW.start_time <= end_time AND NEW.end_time >= start_time AND NEW.end_time <= end_time) OR
        (NEW.start_time < start_time AND NEW.start_time < end_time AND NEW.end_time > start_time AND NEW.end_time > end_time)
        )) THEN
        RAISE EXCEPTION 'The room is occupied!';
        RETURN NULL;
    ELSE 
        RETURN NEW;
    END IF; 
END
$$ LANGUAGE plpgsql;

CREATE TRIGGER ROOM_AVAIL_TRIGGER
BEFORE INSERT OR UPDATE ON Sessions
FOR EACH ROW EXECUTE FUNCTION ROOM_AVAIL();
