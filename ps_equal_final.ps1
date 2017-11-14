$files = dir | Where-Object {$_.Extension -like '*.csv'}

foreach ($file in $files){
    
    $cEthalon = Import-Csv .\Ethalon\etalonPO.csv -Encoding Default

    $cInstall = Import-Csv $file -Encoding Default -Delimiter ';'

    $regex = '(!?)*?'

    $new = @()
    
    $finish_result = @()

    for($i = 0; $i -lt $cEthalon.Length; $i++){
    
    Write-Progress -Activity "Searching and removing" -status "Searching $i" -CurrentOperation $i `
    -percentComplete ($i/$cEthalon.count*100)

    $result = $cInstall -match $regex + $cEthalon[$i].Names
        if ($result.Length -ge 0){
        
            $new += $result
         }
        else {
            $notmatch += $cEthalon[$i].Names
            }
        }

    $different = Compare-Object $cInstall $new -Property H1 -IncludeEqual
    
    foreach ($name in $different){
        switch($name.SideIndicator)
	        {
		        "<=" {$finish_result += $name;break}
	        }
        }

    $text = 'Complite_' + $file.ToString() + '.csv'
    
    $finish_result.H1 > $text
    
    }