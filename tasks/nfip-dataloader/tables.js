const tables = {
    nfip_claims: {
        name: 'nfip_claims',
        schema: 'open_fema_data',
        columns: [
            'baseFloodElevation', 'basementEnclosureCrawlspaceType', 'policyCount', 'communityRatingSystemDiscount',
            'elevationCertificateIndicator', 'elevationDifference', 'locationOfContents', 'numberOfFloorsInTheInsuredBuilding', 'obstructionType', 'occupancyType', 'amountPaidOnIncreasedCostOfComplianceClaim',
            'totalBuildingInsuranceCoverage', 'totalContentsInsuranceCoverage', 'yearofLoss', 'yearOfLoss',

            'latitude', 'longitude', 'lowestAdjacentGrade', 'lowestFloorElevation', 'amountPaidOnBuildingClaim', 'amountPaidOnContentsClaim',

            'asOfDate', 'dateOfLoss', 'originalConstructionDate', 'originalNBDate',

            'agricultureStructureIndicator', 'elevatedBuildingIndicator', 'houseWorship', 'nonProfitIndicator',
            'postFIRMConstructionIndicator', 'smallBusinessIndicatorBuilding', 'primaryResidence',

            'reportedCity', 'condominiumIndicator', 'countyCode', 'censusTract', 'floodZone', 'rateMethod', 'state', 'reportedZipCode', 'id'
        ],
        numericColumns: [
            'baseFloodElevation', 'basementEnclosureCrawlspaceType', 'policyCount', 'communityRatingSystemDiscount',
            'elevationCertificateIndicator', 'elevationDifference', 'locationOfContents', 'numberOfFloorsInTheInsuredBuilding', 'obstructionType', 'occupancyType', 'amountPaidOnIncreasedCostOfComplianceClaim',
            'totalBuildingInsuranceCoverage', 'totalContentsInsuranceCoverage', 'yearofLoss', 'yearOfLoss',
        ],
        floatColumns: [
            'latitude', 'longitude', 'lowestAdjacentGrade', 'lowestFloorElevation', 'amountPaidOnBuildingClaim', 'amountPaidOnContentsClaim',
        ],
        dateColumns: [
            'asOfDate', 'dateOfLoss', 'originalConstructionDate', 'originalNBDate',
        ],
        booleanColumns: [
            'agricultureStructureIndicator', 'elevatedBuildingIndicator', 'houseWorship', 'nonProfitIndicator',
            'postFIRMConstructionIndicator', 'smallBusinessIndicatorBuilding', 'primaryResidence'
        ]
    }
}

tables.nfip_claims.columns = tables.nfip_claims.columns.map(col => ({
    name: col.replace(/[A-Z]/g, letter => `_${letter.toLowerCase()}`),
    dataType: tables.nfip_claims.numericColumns.includes(col) ? 'double precision' :
        tables.nfip_claims.floatColumns.includes(col) ? 'double precision' :
            tables.nfip_claims.dateColumns.includes(col) ? 'timestamp with time zone' :
                tables.nfip_claims.booleanColumns.includes(col) ? 'boolean' : 'character varying'
}))

module.exports = {
    tables
}