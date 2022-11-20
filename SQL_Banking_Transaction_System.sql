use [EN-Banking-Transactions]


/*===========================================================================================================================================================*/
--				Run All these table creations and insert statements before executing procedures
/*===========================================================================================================================================================*/


--CREATE TABLE dim_customer_data_001 (
--    Customer_ID int,
--    Customer_Name varchar(255),
--    Customer_Address varchar(255),
--    Customer_Gender varchar(255),
--    Customer_Age int,
--    Customer_Aadhar_Number bigint,
--    Customer_Mobile_Number bigint
--	);


--CREATE TABLE dim_transaction_data_001 (
--    Transaction_ID int,
--    Transaction_Mode varchar(255),
--    Transaction_Amount bigint,
--    Transaction_Date Date,
--    Sender_Account_Number bigint,
--	Receiver_Account_Number bigint
--	);


--CREATE TABLE dim_bank_details_001 (
--    Account_Number numeric(18,0),
--    Bank_Name varchar(55),
--    IFSC varchar(55),
--    Branch_Name varchar(55),
--    Branch_Number numeric(18,0),
--	Bank_Balance numeric(18,0)
--	);


--CREATE TABLE dim_user_logs_001 (
--    Customer_ID int,
--    Action_Operation varchar(255),
--    Transaction_Amount bigint,
--    Action_Date Datetime
--	);



--CREATE TABLE dim_bank_id_data_001 (
--    Bank_Name varchar(20),
--    Branch_Name varchar(255),
--    Branch_Number bigint
--	);


--insert into dim_bank_id_data_001 (Bank_Name	,Branch_Name, Branch_Number) values ('ICICI','Kolathur',563645)
--insert into dim_bank_id_data_001 (Bank_Name	,Branch_Name, Branch_Number) values ('ICICI','Royapuram',563505)
--insert into dim_bank_id_data_001 (Bank_Name	,Branch_Name, Branch_Number) values ('ICICI','T Nagar',563601)
--insert into dim_bank_id_data_001 (Bank_Name	,Branch_Name, Branch_Number) values ('ICICI','Anna Nagar',563612)
--insert into dim_bank_id_data_001 (Bank_Name	,Branch_Name, Branch_Number) values ('ICICI','Korattur',563555)
--insert into dim_bank_id_data_001 (Bank_Name	,Branch_Name, Branch_Number) values ('ICICI','Tambaram',563507)
--insert into dim_bank_id_data_001 (Bank_Name	,Branch_Name, Branch_Number) values ('ICICI','Thirumangalam',563562)
--insert into dim_bank_id_data_001 (Bank_Name	,Branch_Name, Branch_Number) values ('ICICI','Kaasimedu',563538)
--insert into dim_bank_id_data_001 (Bank_Name	,Branch_Name, Branch_Number) values ('ICICI','Central',563550)
--insert into dim_bank_id_data_001 (Bank_Name	,Branch_Name, Branch_Number) values ('ICICI','Porur',563511)
--insert into dim_bank_id_data_001 (Bank_Name	,Branch_Name, Branch_Number) values ('ICICI','Villivakkam',563600)




/*===========================================================================================================================================================*/
--					INSTRCTIONS TO BE FOLLOWED
/*===========================================================================================================================================================*/

/*=============================================*/
--	Run Procedures in below order
/*=============================================*/


/*	1) Run Insert_Customer_ procedure */
/*	2) Run Customer_Creation_ procedure procedure */
/*	3) Run Transaction_Execution procedure   */
/*	4) Run Transaction_Execution procedure   */

/*=============================================*/
--	Execute Procedures in below order
/*=============================================*/


/*	1)EXEC create_Customer_  (Run Multiple times with different data for account creation) */
/*	2) EXEC Transaction_Execution_ (Run Multiple times with different data for doing transactions)*/




/*===========================================================================================================================================================*/
--						Insert_Customer_ procedure
/*===========================================================================================================================================================*/

/*======================================================= START PROCEDURE =======================================================================================*/
GO
CREATE PROCEDURE Insert_Customer_
(
@Customer_Name varchar(50),
@Customer_Address varchar(250), 
@Customer_Gender varchar(6), 
@Customer_Age int,
@Customer_Aadhar_Number bigint,
@Customer_Mobile_Number bigint, 
@Account_Number numeric,
@Bank_Name varchar(50),
@Branch_Number numeric,
@Bank_Balance numeric
) AS

BEGIN
	
	IF (@Bank_Balance > 10000)

	BEGIN

		IF (len(@Customer_Aadhar_Number) = 12)

		BEGIN

			IF  (
				@Customer_Aadhar_Number not in  (select 
										 Customer_Aadhar_Number
										 from dim_customer_data_001)
				)
			and

				(
				@Customer_Mobile_Number not in  (select 
										 Customer_Mobile_Number
										 from dim_customer_data_001)
				)

			BEGIN
		
				IF (len(@Account_Number) = 12)

				BEGIN
	
					IF  (
						@Account_Number not in  (select 
												 Account_Number
												 from dim_bank_details_001)
						)

					BEGIN


						DECLARE @dim_Auto_Cust_id INT 
						SET @dim_Auto_Cust_id = (select MAX(Customer_ID) 
						from dim_customer_data_001)

						IF (@dim_Auto_Cust_id IS NULL)
						BEGIN
						SET @dim_Auto_Cust_id = 1
						END

						ELSE IF (@dim_Auto_Cust_id IS NOT NULL)
						BEGIN
						SET @dim_Auto_Cust_id =@dim_Auto_Cust_id+1
						END

						INSERT INTO dim_customer_data_001 (Customer_ID, Customer_Name, Customer_Address, Customer_Gender, Customer_Age,Customer_Aadhar_Number, Customer_Mobile_Number) 
						VALUES (@dim_Auto_Cust_id, @Customer_Name, @Customer_Address, @Customer_Gender, @Customer_Age, @Customer_Aadhar_Number, @Customer_Mobile_Number)

						DECLARE @dim_Cust_id INT
						SET @dim_Cust_id = (select MAX(Customer_ID) 
						from dim_customer_data_001)

						DECLARE @IFSC VARCHAR(20)
						SET @IFSC = CONCAT('ICIC',cast(RIGHT(@Branch_Number, 6) AS varchar))

					
						DECLARE @Branch_Name varchar(50) 
						SET @Branch_Name = (SELECT Branch_Name FROM dim_bank_id_data_001 where Branch_Number = @Branch_Number)


						INSERT INTO dim_bank_details_001		(Customer_ID, Account_Number, Bank_Name, IFSC, Branch_Name, Branch_Number, Bank_Balance) 
						VALUES (@dim_Cust_id, @Account_Number, @Bank_Name, @IFSC, @Branch_Name, @Branch_Number, @Bank_Balance)

						DECLARE @Action_Operation varchar(50) 
						SET @Action_Operation = 'Account - Created'

						INSERT INTO dim_user_logs_001			(Customer_ID, Action_Operation, Action_Date) 
						VALUES (@dim_Cust_id, @Action_Operation, CURRENT_TIMESTAMP)

					END

					ELSE
					BEGIN

					PRINT CONCAT((CONCAT(('{"Error" : "This Account_Number ['),CAST(@Account_Number AS VARCHAR))),'] already exists"}')
					END

				END
				ELSE
				BEGIN

				PRINT CONCAT((CONCAT(('{"Error" : "Length of Account_Number ['),CAST(@Account_Number AS VARCHAR))),'] Should be 12"}')
				END

			END

			ELSE
			BEGIN
			PRINT '{"Error" : "This Aadhar_Number [' + CAST(@Customer_Aadhar_Number AS VARCHAR) + ']' + ' or ' + 'Mobile Number [' +CAST(@Customer_Mobile_Number AS VARCHAR) + '] already exists"}'

			END

		END
		ELSE
		BEGIN

		PRINT CONCAT((CONCAT(('{"Error" : "Length of Aadhar_Number ['),CAST(@Account_Number AS VARCHAR))),'] Should be 12"}')
		END

	END

	ELSE
	BEGIN

	PRINT '"Error": "Account Creation Failed for ' + CAST(@Account_Number AS VARCHAR) + ' , Minimum deposit Rupees 10,000 required to create account" ' 
	END


END
/*======================================================= STOP PROCEDURE =======================================================================================*/


/*===========================================================================================================================================================*/
--						Customer_Creation_ procedure
/*===========================================================================================================================================================*/

/*======================================================= START PROCEDURE =======================================================================================*/
GO
CREATE PROCEDURE create_Customer_
(
@Customer_Name varchar(50),
@Customer_Address varchar(250), 
@Customer_Gender varchar(6), 
@Customer_Age int,
@Customer_Aadhar_Number bigint,
@Customer_Mobile_Number bigint, 
@Account_Number numeric,
@Bank_Name varchar(50),
@Branch_Number numeric,
@Bank_Balance numeric
) AS

BEGIN

	EXEC Insert_Customer_ 
	@Customer_Name = @Customer_Name, 
	@Customer_Address = @Customer_Address, 
	@Customer_Gender = @Customer_Gender, 
	@Customer_Age = @Customer_Age,
	@Customer_Aadhar_Number = @Customer_Aadhar_Number,
	@Customer_Mobile_Number = @Customer_Mobile_Number, 
	@Account_Number = @Account_Number, 
	@Bank_Name = @Bank_Name, 
	@Branch_Number = @Branch_Number, 
	@Bank_Balance = @Bank_Balance
END
/*======================================================= STOP PROCEDURE =======================================================================================*/

/*===========================================================================================================================================================*/
--							Transaction_Execution procedure
/*===========================================================================================================================================================*/

/*======================================================= START PROCEDURE =======================================================================================*/

GO
CREATE PROCEDURE Transaction_Execution_
(
@Transaction_Amount bigint,
@Transaction_Mode varchar(10),
@Sender_Account_Number bigint,
@Receiver_Account_Number bigint
) AS

BEGIN

	DECLARE @Receiver_Bank_Balance_ INT 
	SET @Receiver_Bank_Balance_ =	(
									SELECT Bank_Balance
									FROM dim_bank_details_001
									where Account_Number = 346725468651
									) 
	IF  (
		@Sender_Account_Number in  (select 
									Account_Number
									from dim_bank_details_001)
		)

	BEGIN
	
		IF  (
		@Receiver_Account_Number in  (select 
									Account_Number
									from dim_bank_details_001)
		)

		BEGIN

			DECLARE @Sender_Bank_Balance_Before_Transaction INT 
			SET @Sender_Bank_Balance_Before_Transaction =	(
								SELECT Bank_Balance
								FROM dim_bank_details_001
								where Account_Number = @Sender_Account_Number
								) 

		IF @Transaction_Amount <=
			(
			SELECT Bank_Balance
			FROM dim_bank_details_001
			where Account_Number = @Sender_Account_Number
			)
		Begin

			DECLARE @Sender_Bank_Balance INT 
			SET @Sender_Bank_Balance =	(
								SELECT Bank_Balance
								FROM dim_bank_details_001
								where Account_Number = @Sender_Account_Number
								) 


			UPDATE dim_bank_details_001
			SET Bank_Balance = @Sender_Bank_Balance - @Transaction_Amount
			WHERE Account_Number = @Sender_Account_Number;

			DECLARE @Receiver_Bank_Balance INT 
			SET @Receiver_Bank_Balance =	(
								SELECT Bank_Balance
								FROM dim_bank_details_001
								where Account_Number = @Receiver_Account_Number
								) 


			UPDATE dim_bank_details_001
			SET Bank_Balance = @Receiver_Bank_Balance + @Transaction_Amount
			WHERE Account_Number = @Receiver_Account_Number;

			DECLARE @Receiver_Bank_Balance_after_Transaction INT 
			SET @Receiver_Bank_Balance_after_Transaction =	(
											SELECT Bank_Balance
											FROM dim_bank_details_001
											where Account_Number = @Receiver_Account_Number
											) 

			IF (@Receiver_Bank_Balance_after_Transaction  >  @Receiver_Bank_Balance)

			BEGIN

				DECLARE @dim_Auto_Tansact_id INT 
				SET @dim_Auto_Tansact_id = (select MAX(Transaction_ID) 
				from dim_transaction_data_001)

				IF (@dim_Auto_Tansact_id IS NULL)
				BEGIN
				SET @dim_Auto_Tansact_id = 1
				END

				ELSE IF (@dim_Auto_Tansact_id IS NOT NULL)
				BEGIN
				SET @dim_Auto_Tansact_id =@dim_Auto_Tansact_id+1
				END


				INSERT INTO dim_transaction_data_001 (Transaction_ID, Transaction_Mode, Transaction_Amount, Transaction_Date, Sender_Account_Number, Receiver_Account_Number) 
				VALUES (@dim_Auto_Tansact_id, @Transaction_Mode, @Transaction_Amount, CURRENT_TIMESTAMP, @Sender_Account_Number, @Receiver_Account_Number)

				print('Transaction Completed')

			END

			ELSE
			BEGIN

			DECLARE @Sender_Bank_Balance_minus_Transaction_Amount INT 
			SET @Sender_Bank_Balance_minus_Transaction_Amount= @Sender_Bank_Balance - @Transaction_Amount



			UPDATE dim_bank_details_001
			SET Bank_Balance = @Receiver_Bank_Balance_
			WHERE Account_Number = @Receiver_Account_Number;


			UPDATE dim_bank_details_001
			SET Bank_Balance = @Sender_Bank_Balance_minus_Transaction_Amount + @Transaction_Amount
			WHERE Account_Number = @Sender_Account_Number;

			print(' ')
			print(concat('Transaction Failed, Amount Refunded to your Account ', cast(@Sender_Account_Number as varchar)))

			END

		END

		else

		Begin
			
			DECLARE @Sender_Current_Bank_Balance INT 
			SET @Sender_Current_Bank_Balance =	(
								SELECT Bank_Balance
								FROM dim_bank_details_001
								where Account_Number = @Sender_Account_Number
								) 

			PRINT '"Error": "Transaction Terminated due to insufficient fund, Available balance in your account [' + CAST(@Sender_Account_Number AS VARCHAR) + '] is '+ '[' +CAST(@Sender_Current_Bank_Balance AS VARCHAR) + ']'


		END


		END
		ELSE
		BEGIN
			PRINT CONCAT((CONCAT(('{"Error" : "This Receiver_Account_Number ['),CAST(@Receiver_Account_Number AS VARCHAR))),'] is invalid"}')
		END

	END
	ELSE
	BEGIN
		PRINT CONCAT((CONCAT(('{"Error" : "This Sender_Account_Number ['),CAST(@Sender_Account_Number AS VARCHAR))),'] is invalid"}')
	END

END

/*======================================================= STOP PROCEDURE =======================================================================================*/


EXEC create_Customer_
	@Customer_Name = 'Sathish Gupta', 
	@Customer_Address = 'Do No 5/54, 2nd Street, Kolathur, CH-82', 
	@Customer_Gender = 'Male', 
	@Customer_Age = 26,
	@Customer_Aadhar_Number = 367265185076,
	@Customer_Mobile_Number = 9080883289, 
	@Account_Number = 346725468651, 
	@Bank_Name = 'ICICI', 
	@Branch_Number = 563645, 
	@Bank_Balance = 15000


EXEC create_Customer_
	@Customer_Name = 'Rakesh Kumar', 
	@Customer_Address = 'Do No 7/52, 22nd Street, Kolathur, CH-52', 
	@Customer_Gender = 'Male', 
	@Customer_Age = 36,
	@Customer_Aadhar_Number = 346165105016,
	@Customer_Mobile_Number = 9080883288, 
	@Account_Number = 346705468659, 
	@Bank_Name = 'ICICI', 
	@Branch_Number = 563612, 
	@Bank_Balance = 100000


EXEC Transaction_Execution_
	@Transaction_Amount = 75000,
	@Transaction_Mode = 'NEFT',
	@Sender_Account_Number = 346705468659,
	@Receiver_Account_Number = 346725468651















DROP PROCEDURE Insert_Customer_
DROP PROCEDURE create_Customer_
DROP PROCEDURE Transaction_Execution_

select * from dim_customer_data_001
select * from dim_bank_details_001
select * from dim_transaction_data_001
select * from dim_user_logs_001

