$HAR = Get-Content -Raw $HarFile | Out-String | ConvertFrom-Json

# Start Locust script
Write-Output "from locust import HttpUser, TaskSet, task, tag, between"
Write-Output "from locust.contrib.fasthttp import FastHttpUser"

Write-Output "class UserBehavior(FastHttpUser):"
Write-Output "    wait_time = between(1, 5)"

# Get HAR pages

$HAR.log.pages | % {
    $page = $_

    Write-Output "    @task"
    Write-Output ("    def task_" + $page.id + "(self):")

    $HAR.log.entries | % {
        $task = $_
        $req = $task.request
        
        if ( $true # @TODO add filters...
        ) {
            # If request belongs to page, add to @Task
            if( $task.pageref -eq $page.id ){
            
                $h = ""
                # Concatenate headers from HAR request
                $req.headers | % {
    
                    $h += ( '"' + $_.name + '": "' + $_.value.replace('"', '\"') + '", ' )

                }
                
                # Add request to @Task
                Write-Output ("        h = {" + $h + "}").replace(", }", "}")
                Write-Output ("        self.client."+$req.method.ToLower()+"(`""+$req.url+"`", headers=h)"  )
            }
        }
    }
}
$HAR = $null
