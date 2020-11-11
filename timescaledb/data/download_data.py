
#script for downloading the data for this project 
#just run it in the commandline like this:
#linux user$: python download_data.py

def download_data(year):
    
    import csv
    import requests    
    
    url = "https://s3.amazonaws.com/nyc-tlc/trip+data/yellow_tripdata_" + str(year) + "-"
    
    for x in range(1, 13):
        try:
            
            #download file
            link = url + str(x).zfill(2) + ".csv"
            print("Requesting URL:")
            print(link)            
            response = requests.get(link)      
            
            #writing file
            filename = 'out_' + year + "_" + str(x).zfill(2) + '.csv'
            print("Writing File...")
            print('out_' + year + "_" + str(x).zfill(2) + '.csv', sep="")
            
            with open(filename, 'w') as f:
                writer = csv.writer(f)
                for line in response.iter_lines():
                    writer.writerow(line.decode('utf-8').split(','))        
             
        except:
            
            print("Link not found. Not downloaded the following link.")
            print(url, str(x).zfill(2), ".csv", sep="")     

#calling the function
download_data(2020)






    


    
    