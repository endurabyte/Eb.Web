$distributionId = "EPIS3D7CTQEDQ"
$profile = "endurabyte"

write-host "Syncing with S3..."
pushd $PSScriptRoot
aws s3 sync . s3://endurabyte-website --exclude '*.ps1' --exclude '.git/*' --profile $profile

write-host "Invalidating Cloudfront caches..."
$createInvalidationResult = aws cloudfront create-invalidation --profile $profile --distribution-id $distributionId --paths "/*" | ConvertFrom-Json
$invalidationId = $createInvalidationResult.Invalidation.Id
write-host "Invalidation created with ID: $invalidationId"

# Monitor the invalidation status
$invalidationStatus = $createInvalidationResult.Invalidation.Status
while ($invalidationStatus -ne "Completed") {
    $getInvalidationResult = aws cloudfront get-invalidation --profile $profile --distribution-id $distributionId --id $invalidationId | ConvertFrom-Json
    $invalidationStatus = $getInvalidationResult.Invalidation.Status
    write-host "Invalidation status: $invalidationStatus"
    Start-Sleep -Seconds 2
}

write-host "Invalidation completed"
write-host "Deployment completed"
popd
