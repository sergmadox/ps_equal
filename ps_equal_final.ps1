$files = (Get-ChildItem . *.csv)
$c1 = 0
foreach ($file in $files){
    
    $c1++
    Write-Progress -Id 0 -Activity 'Проверяем файлы:' -Status "Завершено $($c1) из $($files.count)" -CurrentOperation $file -PercentComplete (($c1/$files.Count) * 100)
    
    $cEthalon = Import-Csv .\Ethalon\etalonPO.csv -Encoding Default

    $cInstall = Import-Csv $file -Encoding Default -Delimiter ';'

    $regex = '(!?)*?'

    $new = @()
    
    $finish_result = @()

    for($i = 0; $i -lt $cEthalon.Length; $i++){
    
    Write-Progress -id 1 -Activity "Поиск и удаление эталонного ПО:" -status "Поиск $i" `
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