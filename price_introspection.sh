location="US East (N. Virginia)"
region="us-east-1"
instance_type="t3a.xlarge"

#Spot market price
aws ec2 describe-spot-price-history --start-time=$(date +%s) --product-descriptions="Linux/UNIX" --instance-types t3a.xlarge --region ${region}

#On demand & reserved market price
aws pricing get-products --service-code AmazonEC2 \
--filters "Type=TERM_MATCH,Field=instanceType,Value=${instance_type}" \
          "Type=TERM_MATCH,Field=location,Value=${location}" \
          "Type=TERM_MATCH,Field=tenancy,Value=Shared" \
          "Type=TERM_MATCH,Field=operatingSystem,Value=Linux" \
          "Type=TERM_MATCH,Field=currentGeneration,Value=Yes" \
          "Type=TERM_MATCH,Field=preInstalledSw,Value=NA" \
          "Type=TERM_MATCH,Field=licenseModel,Value=No License required" \
--region ${region} | jq -rc '.PriceList[]' | jq -r \
    '[  .product.attributes.instanceType,
        .product.attributes.memory,
        .product.attributes.vcpu,
        .product.attributes.dedicatedEbsThroughput,
        .product.attributes.clockSpeed,
        .product.attributes.instancesku?,
        .product.attributes.usagetype,
        .terms.OnDemand[].priceDimensions[].unit,
        .terms.OnDemand[].priceDimensions[].pricePerUnit.USD,
        .terms.OnDemand[].priceDimensions[].description] | @csv'

