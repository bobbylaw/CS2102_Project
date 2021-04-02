-- add_customer
CREATE OR REPLACE PROCEDURE add_customer(IN input_cust_name TEXT, IN input_address TEXT, IN input_phone TEXT, IN input_email TEXT, IN input_card_number TEXT, IN input_expiry_date DATE, IN input_CVV INTEGER)
AS $$
DECLARE
    customer_id INTEGER;
BEGIN

    INSERT INTO Customers(name, address, phone, email)
        VALUES (input_cust_name, input_address, input_phone, input_email);

    SELECT c.cust_id into customer_id
        FROM Customers as c
        WHERE input_cust_name = c.name
            AND input_address = c.address
            AND input_phone = c.phone
            AND input_email = c.email;

    INSERT INTO Owns_credit_cards(card_number, cust_id, CVV, from_date, expiry_date)
        VALUES(input_card_number, customer_id, input_CVV, NOW(), input_expiry_date);

END
$$ LANGUAGE plpgsql;

-- update_credit_card
CREATE OR REPLACE PROCEDURE update_credit_card(IN input_cust_name TEXT, IN input_address TEXT, IN input_phone TEXT, IN input_email TEXT, IN input_card_number TEXT, IN input_expiry_date DATE, IN input_CVV INTEGER)
AS $$
DECLARE
    customer_id INTEGER;
BEGIN

    SELECT c.cust_id into customer_id
        FROM Customers as c
        WHERE input_cust_name = c.name
            AND input_address = c.address
            AND input_phone = c.phone
            AND input_email = c.email;
    
    UPDATE Owns_credit_cards
        SET card_number = input_card_number,
            CVV = input_CVV,
            expiry_date = input_expiry_date
    WHERE customer_id = cust_id;

END
$$ LANGUAGE plpgsql;