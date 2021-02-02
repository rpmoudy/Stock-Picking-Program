# Stock-Picking-Program
James O'Shaughnessy Method for undervalued Stocks

This stock picking program is based on a modified version of James O'Shaughnessy strategy for finding undervalued companies that are publicly traded. 

List of Softwares needed to run: MATLAB, Excel, Python 3.6.1

The program works by using a stock screener (Finviz) to find a list of companies traded on the NYSE that are small to large cap companies. After getting the list, the MATLAB program interatively passes a ticker from the list into a python script where the script queries Yahoos database. The database returns a JSON packet of information that's used to calculate the following financial ratios: P/E, P/S, P/B, P/FCF, EV/EBITDA, Dividend & Shareholder Yeild, and the 200 day moving average. 

After all the information is gathered, the MATLAB program uses a built-in "ranking" function to rank each individual financial ratio of the stocks in the list. Once complete, two text files are created. One is called "All Stocks - (dd/mm/yyyy)" and the other is just "(dd/mm/yyyy)". The "All Stocks"  text file is a list of all the companies financial ratios (Usually 3000+ Stocks). The other text file is a list of only the top ranked stocks (Overall score: 490+). In order to make the data more digestable, open the "Stock Picks.xlsm" excel workbook. On the front sheet will be a button called "Click Me". A file browser will open to select one of the two text files. After the file is selected, the excel macro will input the stock picks and their financial information, along with rank, into a pivot table. 

PREREQUISITIES FOR RUNNING THE PROGRAM:
1) Have the MATLAB file and python script in same directory. 
2) Need Administrative Privledges

TRY THE PROGRAM YOUR SELF BY:
1) Open the MATLAB Program "Shaughnessy_Stock_Picking_Method_v2.m" and click "Run"
	-Beaware that depending on current internet speeds and traffic the program can take anywhere from 2		to 5 hours to complete. The program can be minimized while it is running. 
1a) Or skip the above step for convience and continue below.
2) Open "Stock Picks" excel workbook and click the button "Click".
3) Select one of the two text files provided already. ("All Stocks - dd/mm/yyyy") or ("dd/mm/yyyy")
