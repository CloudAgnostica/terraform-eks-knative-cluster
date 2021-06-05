#On-demand pricing: regional
#Spot pricing: zonal

location="US East (N. Virginia)"
region=$(terraform output -raw region)
instance_type="t3a.xlarge"

echo "Spot price on cheapest zone"
aws ec2 describe-spot-price-history --start-time=$(date +%s) --product-descriptions="Linux/UNIX" --instance-types ${instance_type} --region ${region} \
  | jq '.SpotPriceHistory|=sort_by(.SpotPrice)' \
  | jq '.SpotPriceHistory[] | .AvailabilityZone + " $" + .SpotPrice' \
  | python -c "import sys; print(input())"


echo "On demand & reserved market price"
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

#TODO filter out reserved market prices
#|  python -c "import sys; input_lines = sys.stdin.readlines(); for item in input_lines: if ""On Demand Linux"" in item: print(item)"
#| select( .terms.OnDemand[].priceDimensions[].description | contains("On Demand Linux"))

# Cost savings from spot to on-demand

spot_price=$(aws ec2 describe-spot-price-history --start-time=$(date +%s) --product-descriptions="Linux/UNIX" --instance-types ${instance_type} --region ${region} \
  | jq '.SpotPriceHistory|=sort_by(.SpotPrice)' \
  | jq '.SpotPriceHistory[] | .SpotPrice' \
  | python -c "import sys; print(input())")