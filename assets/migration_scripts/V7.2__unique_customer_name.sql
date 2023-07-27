-- Unique the customer_name
ALTER TABLE ONLY public.customers
ADD CONSTRAINT customers_customer_name_key UNIQUE (customer_name);