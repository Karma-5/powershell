get-adgroup -filter * | Where-Object {$_.name -like "*group-name*"}
