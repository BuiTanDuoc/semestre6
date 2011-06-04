use SI2_TP1;

/* Ex4 - h)
 Implementar um mecanismo de alarme caso existam ingredientes fora da validade.
*/
if OBJECT_ID('OutOfValidity') IS NOT NULL
	drop function OutOfValidity;
go	

create function OutOfValidity()
returns @validityTemp table(
			ID_ING			int,
			ID_LOT			int,
			VALIDITY	datetime,
			QTY			decimal(10,3))
as
	begin
		declare @stock decimal(10,3), @validity datetime, @ingredientID_stock int, @currentDate datetime
		
		declare @ID_ingredient int, @numberOfUnits int
		
		set @currentDate = GetDate()
		set @numberOfUnits = 0
		
		
		--see all ingredients that had unit's
		--know number of units of this ingredient
		declare ingredients cursor
		for select ID, QTY_CURRENT from INGREDIENTS where QTY_CURRENT > 0
		open ingredients
		fetch next from ingredients into @ID_ingredient, @numberOfUnits
		while(@@FETCH_STATUS=0)
			begin
			--get cursor with lot that have stock
			declare stockcursor cursor
			for select LOT.INGREDIENTS_ID, VALIDITY, QTY
					from LOT 
					where (LOT.INGREDIENTS_ID = @ID_ingredient)
					order by LOT.VALIDITY
			open stockcursor
			fetch next from stockcursor into @ingredientID_stock, @validity, @stock	
			while(@@FETCH_STATUS=0)
				begin
				--verify if date isn't valid, if is true we save a tuple in temporary table
				--and break the cicle because we already verify that this ingredient isn't valid
				if @validity < @currentDate AND @numberOfUnits > 0
					begin
						insert into @validityTemp values(@ID_ingredient, @ingredientID_stock, @validity, @stock)
						BREAK
					end
				else -- subtract value of unit the number of stock this specify lot
						set @numberOfUnits = @numberOfUnits - @stock
				-- if @numberOfUnits is negative it means that already verify this ingredient
				if @numberOfUnits <= 0
				begin
					BREAK
				end
				fetch next from stockcursor into @ingredientID_stock, @validity, @stock
			end
			close stockcursor
			deallocate stockcursor	
		fetch next from ingredients into @ID_ingredient, @numberOfUnits
		end
		
		close ingredients
		deallocate ingredients
		
	return
	end
	
/*	
select * from LOT

select LOT.INGREDIENTS_ID, VALIDITY, STOCK
				from LOT 
				where (LOT.STOCK>0)
				order by LOT.VALIDITY



*/
