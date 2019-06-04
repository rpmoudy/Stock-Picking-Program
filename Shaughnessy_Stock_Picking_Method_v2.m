%%% <---- Write informaton to text file when done.
browserHide = 'False';

%%% <---- For grabbing tickers
options = weboptions('Timeout',Inf);
str = webread('http://finviz.com/screener.ashx?v=111&f=cap_smallover',options);

expression = {'(?-i)\w*c&t=';...
              '(?i)\W*\''><br>'};
[match, nomatch] = regexp(str,expression,'match','split');

j = 1;

ticker{j} = nomatch{1,1}{1,1};

for i = 2:2:40 
   
    [token, remain] = strtok(nomatch{1,1}{1,i},'\W*\''><br>');
    
    ticker{j} = token;
    j = j + 1;

end 

[numStocks, nonumStocks] = regexp(str,'</b>([0-9].*) #1</td>','tokens','match');

numStocks = str2double(numStocks{1,1});

TotalPages = fix(numStocks(1)/20);

p = 1;

%%Grabbing all tickers off each page in for loop
for k = 2:TotalPages-1 %%% Changed to 49 because of 'W' tickers. Use TotalPages when switching back.
p = 20 + p;    
URL = sprintf('http://finviz.com/screener.ashx?v=111&f=cap_smallover&r=%d',p);
str = webread(URL,options);

expression = {'(?-i)\w*c&t=';...
              '(?i)\W*\''><br>'};
[match, nomatch] = regexp(str,expression,'match','split');

    for i = 2:2:40 
        ticker{j} = {str};
        [token, remain] = strtok(nomatch{1,1}{1,i},'\W*\''><br>');
        [token2, remain2] = strtok(nomatch{1,1}{1,i},'\w*\''><br>');

        if strcmp(token,token2)
            ticker{j} = token;
            j = j + 1;
        end

    end 
    
    pause(randi([1,5]));
end
%%%%<---- Ticker End

[remainder,numStocks] = size(ticker);

%%%%<----- Grabbing P/E, P/S, P/B, Stock Price, Dividend&Yield, Market Cap, P/FCF,  off webpage. W
for z = 1:numStocks-1
    StupidHyphen = ''; % Hyphens in tickers cause problems.
    
    [nohyphen,hyphen] = size(ticker{z});
    
    company = ticker{z};
    
    error404 = 0;
    
    for h = 1:hyphen
        if(strcmp(company(h),'-'))
            StupidHyphen = 'abort';
        end
    end
    
    if (strcmp(ticker{z},'PLAY') || strcmp(ticker{z},'CHR') || strcmp(ticker{z},'EZP') || strcmp(ticker{z},'SNC') || strcmp(ticker{z},'CD') || strcmp(ticker{z},'PN') || strcmp(ticker{z},'&n') || strcmp(ticker{z},'MP') || strcmp(ticker{z},'BS') || strcmp(ticker{z},'OOF') || strcmp(ticker{z},'YNN') || strcmp(ticker{z},'JW-A') || strcmp(ticker{z},'AKO-A') || strcmp(ticker{z},'AKO-B'))
       disp(sprintf('Another Stock Removed! Ticker: %s', ticker{z}));
       
    elseif(strcmp(StupidHyphen,'abort'))
       disp('Another Hyphenated Stock')
       error404 = 1;
    else
    
    %Run Python Script for extracting Json Data to Text file. RPM 5/22/2017
    
    commandStr = sprintf('python stats.py %s',ticker{z});
    [status, commandOut] = system(commandStr);

    fID = fopen('data.txt');
    str = fscanf(fID,'%s');
    
    str(str==' ')=''; 
    
    %Stock Price
    
    [match, nomatch] = regexp(str,'"currentPrice":{"raw":([0-9_\.]+),"','tokens','match');  
    
    if (isempty(match))
        Stock_Price{1,z} = 0;
    else
        Stock_Price{1,z} = str2double(match{1,1}{1,1});
    end
    
    % Price to Earnings Ratio

    [match, nomatch] = regexp(str,'"trailingPE":{"raw":([0-9_\-_\.]+),','tokens','match');
    
    if isempty(match) 
        PE{1,z} = 0;
    else
        PE{1,z} = str2double(match{1,1}{1,1});
    end
    
    %Price to Book 
    
    [match, nomatch] = regexp(str,'"priceToBook":{"raw":([0-9_\-_\.]+),','tokens','match');
    
    if isempty(match) 
        PB{1,z} = 0;
    else
        PB{1,z} = str2double(match{1,1}{1,1});
    end
    
    %Market Cap
    
    [match, nomatch] = regexp(str,'"marketCap":{"raw":([0-9_\-_\.]+),','tokens','match');
    
    if isempty(match) 
        Market_Cap{1,z} = 0;
    else
        Market_Cap{1,z} = str2double(match{1,1}{1,1});
    end
    
     %Free Cash Flow
     
    [match, nomatch] = regexp(str,'"freeCashflow":{"raw":([0-9_\-_\.]+),','tokens','match');
    
    if isempty(match) 
        FCF{1,z} = 0;
    else
        FCF{1,z} = str2double(match{1,1}{1,1});
    end
    
    %Price to Free Cash FLow
    
    if FCF{1,z} == 0
       PFCF{1,z} = 0;
    else
       PFCF{1,z} = Market_Cap{1,z}/FCF{1,z};
    end
        
    %Price to Sales
    
    [match, nomatch] = regexp(str,'"priceToSalesTrailing12Months":{"raw":([0-9_\-_\.]+),','tokens','match');
    
    if isempty(match) 
        PS{1,z} = 0;
    else
        PS{1,z} = str2double(match{1,1}{1,1});
    end

    %Stock Repurchased 
    
    [match, nomatch] = regexp(str,'"salePurchaseOfStock":{"raw":([0-9_\-_\.]+),','tokens','match');
    
    if isempty(match) 
        Shareholder{1,z} = 0;
    else
        Shareholder{1,z} = str2double(match{1,1}{1,1})*(-1);
    end
    
    ShareholderYield{1,z} = Shareholder{1,z}/Market_Cap{1,z};
    
    %Dividend and Yield
    
    [match, nomatch] = regexp(str,'"dividendYield":{"raw":([0-9_\-_\.]+),','tokens','match');
    
    if isempty(match)
        Dividend{1,z} = 0;
    else 
        Dividend{1,z} = str2double(match{1,1}{1,1})*100;
    end 
    
    DividendAndYield{1,z} = ShareholderYield{1,z} + Dividend{1,z};
        
    %Enterprise Value to EBITDA - (Buyout Cost)
    
    [match, nomatch] = regexp(str,'"enterpriseToEbitda":{"raw":([0-9_\-_\.]+),','tokens','match');
    
    if isempty(match)
        EVEBITDA{1,z} = 0;
    else 
        EVEBITDA{1,z} = str2double(match{1,1}{1,1});
    end 

    end

    try
        fclose(fID);
    catch
        % Errors out if no file is open. 
    end
    
    %Six Month Price movement from Finviz. RPM 5/24/2017
    
    URL = sprintf('http://finviz.com/quote.ashx?t=%s',ticker{1,z}); %% ---> '%s' is for strings. '%d' is for numbers.
    options = weboptions('Timeout',Inf);
    
    try
        str = webread(URL,options);
    catch
        pause(randi([10,15]));
        disp(sprintf('Finviz: %s', ticker{z}))
        str = webread(URL,options);
    end
    
    str(str==' ')=''; 
    
    [match, nomatch] = regexp(str,'>SMA200</td><tdwidth="8%"class="snapshot-td2"align="left"><b>([0-9_\._\-]+)%<','tokens','match');
            
    if isempty(match)
        [match, nomatch] = regexp(str,'>SMA200</td><tdwidth="8%"class="snapshot-td2"align="left"><b><spanstyle="color:#([a-zA-z0-9]+);">([0-9_\._\-]+)%</span>','tokens','match');
        if isempty(match)
            Momentum{1,z} = 0;
        else
            Momentum{1,z} = str2double(match{1,1}{1,2})/100;
        end
    else 
        Momentum{1,z} = str2double(match{1,1}{1,1})/100;
    end
    
end

%Organize Information to store into a text file. RPM 5/15/2017

for i = 1:z-1
    if (isempty(Stock_Price{1,i}))
        Stock_Price{1,i} = 1000000;
    elseif (isnan(Stock_Price{1,i}))
        Stock_Price{1,i} = 1000000;
    elseif (Stock_Price{1,i} <= 0)
        Stock_Price{1,i} = 1000000;
    else
        
    end
    
end

Stock_Price = cell2mat(Stock_Price);

for i = 1:z-1
    if (isempty(Momentum{1,i}))
        Momentum{1,i} = 0;
    elseif (isnan(Momentum{1,i}))
        Momentum{1,i} = 0;
    else
        
    end
    
end

Momentum = cell2mat(Momentum);

for i = 1:z-1
    if (isempty(PS{1,i}))
        PS{1,i} = 1000000;
    elseif (isnan(PS{1,i}))
        PS{1,i} = 1000000;
    elseif (PS{1,i} <= 0)
        PS{1,i} = 1000000;
    else
        
    end
    
end

PS = cell2mat(PS);

psrank = ((-1*tiedrank(PS)/length(PS))+1)*100;

for i = 1:z-1
    if (isempty(PE{1,i}))
        PE{1,i} = 1000000;
    elseif (isnan(PE{1,i}))
        PE{1,i} = 1000000;
    elseif (PE{1,i} <= 0)
        PE{1,i} = 1000000;
    else
        
    end
end

PE = cell2mat(PE);

perank = ((-1*tiedrank(PE)/length(PE))+1)*100;

for i = 1:z-1
    if (isempty(PFCF{1,i}))
        PFCF{1,i} = 1000000;
    elseif (isnan(PFCF{1,i}))
        PFCF{1,i} = 1000000;
    elseif (PFCF{1,i} <= 0)
        PFCF{1,i} = 1000000;
    else
        
    end
end

PFCF = cell2mat(PFCF);

pfcfrank = ((-1*tiedrank(PFCF)/length(PFCF))+1)*100;

for i = 1:z-1
    if (isempty(PB{1,i}))
        PB{1,i} = 1000000;
    elseif (isnan(PB{1,i}))
        PB{1,i} = 1000000;
    elseif (PB{1,i} <= 0)
        PB{1,i} = 1000000;
    else
        
    end
end

PB = cell2mat(PB);

pbrank = ((-1*tiedrank(PB)/length(PB))+1)*100;

for i = 1:z-1
    if (isempty(EVEBITDA{1,i}))
        EVEBITDA{1,i} = 1000000;
    elseif (isnan(EVEBITDA{1,i}))
        EVEBITDA{1,i} = 1000000;
    elseif (EVEBITDA{1,i} <= 0)
        EVEBITDA{1,i} = 1000000;
    else
        
    end
end

EVEBITDA = cell2mat(EVEBITDA);

evebitdarank = ((-1*tiedrank(EVEBITDA)/length(EVEBITDA))+1)*100;

for i = 1:z-1
    if (isempty(DividendAndYield{1,i}))
        DividendAndYield{1,i} = 0.00000001;
    elseif (isnan(DividendAndYield{1,i}))
        DividendAndYield{1,i} = 0.00000001;
    elseif (DividendAndYield{1,i} <= 0)
        DividendAndYield{1,i} = 0.00000001;
    else
        
    end
end

DividendAndYield = cell2mat(DividendAndYield);

%High Values are better so get rid of the inverse way of ranking.
%5/25/2017
divyieldrank = ((tiedrank(DividendAndYield)/length(DividendAndYield)))*100; 

for i = 1:z
    rank(i) = perank(i) + psrank(i) + pbrank(i) + pfcfrank(i) + evebitdarank(i) + divyieldrank(i);
end

x = 1;

for i = 1:z
    if (rank(i) > 490)
        TopRank(x) = i;
        x = x+1;
    end
end

TopRank = sort(TopRank);

p = 1;
 
textFile = date;

fID = fopen(sprintf('%s.txt',textFile),'wt');

for i = 1:numel(TopRank) %Top Picks 
    fwrite(fID,sprintf('Ticker: %s\n - Stock Price: %.2f %', ticker{TopRank(i)},Stock_Price(1,TopRank(i))));
    fwrite(fID,sprintf('P/E: %.4f P/E Rank: %.4f\n', PE(TopRank(i)), perank(TopRank(i))));
    fwrite(fID,sprintf('P/S: %.4f P/S Rank: %.4f\n', PS(TopRank(i)),psrank(TopRank(i))));
    fwrite(fID,sprintf('P/B: %.4f P/B Rank: %.4f\n', PB(TopRank(i)), pbrank(TopRank(i))));
    fwrite(fID,sprintf('P/FCF: %.4f P/FCF Rank: %.4f\n', PFCF(TopRank(i)), pfcfrank(TopRank(i))));
    fwrite(fID,sprintf('EVEBITDA: %.4f EVEBITDA Rank: %.4f\n', EVEBITDA(TopRank(i)), evebitdarank(TopRank(i))));
    fwrite(fID,sprintf('DividendAndYield: %.4f DividendAndYield Rank: %.4f\n', DividendAndYield(TopRank(i)), divyieldrank(TopRank(i))));
    fwrite(fID,sprintf('Overall Rank: %.4f%\n', rank(TopRank(i))));
    fwrite(fID,sprintf('Six Month Price Movement: %.2f %%\n', Momentum(TopRank(i))));
    fwrite(fID,sprintf('\n'));
end

fclose(fID);

textFile = date;

fID = fopen(sprintf('All Stocks - %s.txt',textFile),'wt');

for i = 1:z-1 %All Stocks and their Information
    fwrite(fID,sprintf('Ticker: %s\n - Stock Price: %.2f %', ticker{i},Stock_Price(1,i)));
    fwrite(fID,sprintf('P/E: %.4f P/E Rank: %.4f\n', PE(i), perank(i)));
    fwrite(fID,sprintf('P/S: %.4f P/S Rank: %.4f\n', PS(i),psrank(i)));
    fwrite(fID,sprintf('P/B: %.4f P/B Rank: %.4f\n', PB(i), pbrank(i)));
    fwrite(fID,sprintf('P/FCF: %.4f P/FCF Rank: %.4f\n', PFCF(i), pfcfrank(i)));
    fwrite(fID,sprintf('EVEBITDA: %.4f EVEBITDA Rank: %.4f\n', EVEBITDA(i), evebitdarank(i)));
    fwrite(fID,sprintf('DividendAndYield: %.4f DividendAndYield Rank: %.4f\n', DividendAndYield(i), divyieldrank(i)));
    fwrite(fID,sprintf('Overall Rank: %.4f%\n', rank(i)));
    fwrite(fID,sprintf('Six Month Price Movement: %.2f %%\n', Momentum(i)));
    fwrite(fID,sprintf('\n'));
end

fclose(fID);

