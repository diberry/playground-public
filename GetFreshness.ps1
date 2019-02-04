$azureContentDir = "/Users/diberry/repos/azure-docs-pr/articles/cognitive-services/"

# Freshness is 90, but subtract 10 because
# we want to catch them before they are overdue
$olderThan = 80

$files = get-childitem -recurse $azureContentDir -filter *.md -exclude media 

#Get today's date
$now = Get-Date

Write-Host $now

#Create a new array
$filesWithDates=@()

#Loop through the files
ForEach($file in $files) {

  #Find the date values
  $content = get-content $file.FullName 

  $author = $content | select-string -pattern "ms.author: "
  $author = $author.Line.ToString().Replace("ms.author: ","")

  $manager = $content | select-string -pattern "manager: "
  $manager = $manager.Line.ToString().Replace("manager: ","")
  
  $topic = $content | select-string -pattern "topic: "
  $topic = $topic.Line.ToString().Replace("topic: ","")
  
  $services = $content | select-string -pattern "services: "
  $services = $services.Line.ToString().Replace("services: ","")
  
  $date = $content | select-string -pattern "ms.date"
  $date = [datetime]$date.ToString().Replace("ms.date: ","")
  $date = Get-Date -Format d -Date $date



  #Get the difference
  $difference = New-TimeSpan -Start $date -End $now

  if($difference.Days -gt $olderThan) {
    #Create a new object and set the date and filename as properties
    $fileWithDate = new-object System.Object
    #$fileWithDate | add-member -MemberType NoteProperty -name LastPublished -Value $date
    # Figure out the 90 day stale date
    $plus90 = Get-Date (Get-Date $date).AddDays(90) -Format d

    #$fileWithDate | add-member -MemberType NoteProperty -name path -value $file.Path
    #$fileWithDate | add-member -MemberType NoteProperty -name path -value $file.
    $fileWithDate | add-member -MemberType NoteProperty -name 90Days -value $plus90
    $fileWithDate | add-member -MemberType NoteProperty -name Author -Value $author
    $fileWithDate | add-member -MemberType NoteProperty -name Manager -Value $manager
    $fileWithDate | add-member -MemberType NoteProperty -name Topic -Value $topic
    $fileWithDate | add-member -MemberType NoteProperty -name Services -Value $services
    $fileWithDate | add-member -MemberType NoteProperty -name FileName -Value $file.Name
    $fileWithDate | add-member -MemberType NoteProperty -name FullName -Value $file.FullName

    #Write-Host $fileWithDate

    #Add the object to the array
    $filesWithDates+=$fileWithDate
  }
}
#Sort by date, ascending
$filesWithDates | ConvertTo-Csv -NoTypeInformation | % {$_.Replace('"','')} | Out-File freshness.csv
#Export-Csv /Users/diberry/repos/freshness/freshness.csv