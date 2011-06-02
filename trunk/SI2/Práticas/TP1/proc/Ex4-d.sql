use SI2_TP1;

/* Ex4 - d)
Apresentar o valor a pagar num evento gastron�mico considerando as respectivas redu��es de pre�o.
*/
if OBJECT_ID('EventCost') IS NOT NULL
	drop procedure EventCost;
go	
create function EventCost(@BookingID int)
as
	begin transaction
		--verify if there is a Booking with @BookingID and get number of customers
		declare @qty int, @MenuID int, @final_discount int, @price smallmoney
		set @qty = Booking.Qty from dbo.Booking where  ID = @BookingID
		set @MenuID = MENU_ID from EVENT where (BOOKING_ID=@BookingID)
		
		--verify where number of customers fits on discount table
		declare @discount int, @upper_limit int
		declare discount cursor
		for select CUSTOMER_QTY, DISCOUNT from EVENT_DISCOUNTS;
		open discount
		fetch next from discount into @upper_limit, @discount
		while(@@FETCH_STATUS=0)
			begin
			if @qty>@upper_limit
				set @final_discount=@discount
			fetch next from discount into @upper_limit, @discount
			end
		set @price = PRICE from MENU where (ID=@MenuID)
		return (@price - (@price * @final_discount / 100))
	commit