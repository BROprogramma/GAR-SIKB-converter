<?xml version="1.0" encoding="utf-8"?>
<!-- XSLT for conversion of SIKB0101 to BRO GAR  
        SIKB0101 version: v14.2.0 
        IMMetingen version: v14.2.0 
        BRO GAR version: versie 0.9.9; release 20191114 -->

<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:sikb="http://www.sikb.nl/imsikb0101" 
    xmlns:gar="http://www.broservices.nl/xsd/isgar/1.0" xmlns:brocom="http://www.broservices.nl/xsd/brocommon/3.0"
    xmlns:gml="http://www.opengis.net/gml/3.2" xmlns:imm="http://www.sikb.nl/immetingen" 
    xmlns:garcom="http://www.broservices.nl/xsd/garcommon/1.0" xmlns:sam="http://www.opengis.net/sampling/2.0"
    xmlns:xlink="http://www.w3.org/1999/xlink" xmlns:spec="http://www.opengis.net/samplingSpecimen/2.0" 
    xmlns:xsi="http://www.w3.org/2001/XMLSchema" xsi:schemaLocation="http://www.sikb.nl/imsikb0101 imsikb0101_v14.2.0.xsd">
    
    <!-- extra namespace declarations, don't know if I need them yet 
        xmlns:fn="http://www.w3.org/2005/xpath-functions" xmlns:xdt="http://www.w3.org/2005/xpath-datatypes" 
    xmlns:imsikb0101="http://www.sikb.nl/imsikb0101" xmlns:immetingen="http://www.sikb.nl/immetingen" 
    xmlns:gco="http://www.isotc211.org/2005/gco" xmlns:gmd="http://www.isotc211.org/2005/gmd" 
    xmlns:gsr="http://www.isotc211.org/2005/gsr" xmlns:gss="http://www.isotc211.org/2005/gss" 
    xmlns:gts="http://www.isotc211.org/2005/gts" xmlns:gml="http://www.opengis.net/gml/3.2"
    xmlns:om="http://www.opengis.net/om/2.0" xmlns:sam="http://www.opengis.net/sampling/2.0"
    xmlns:sams="http://www.opengis.net/samplingSpatial/2.0" xmlns:spec="http://www.opengis.net/samplingSpecimen/2.0" 
    xmlns:xlink="http://www.w3.org/1999/xlink" xmlns:sikb="http://xslcontrole.sikb" 
    -->
    
    <!-- Issues
    - Rapportagegrens is op korte termijn niet te mappen. Dit betekent dat SIKB bestanden die getransformeerd worden naar GAR niet valide zijn. We moeten hiervoor een workaround 
   bedenken en implementeren in deze stylesheet 
    -  Afgesproken dat BRO nog wijzigingsverzoek indient voor het toevoegen van de inhoud van BRO bemonsteringsprocedure aan SIKB Bemonsteringsmethode.
    -  IM Metingen kent wel organisaties maar alleen namen terwijl de BRO KvKnummers opslaat
    - 'belucht' bij  SIKB = 'filter belucht' in de BRO. Zie issue: https://github.com/BROprogramma/GAR/issues/145.
    -  Specifiek BRO gerelateerde zaken zoals bronhouder, dataleverancier, kwaliteitsregime zijn bij IM Metingen niet bekend. Dergelijke gegevens zitten meestal in het bericht, 
    niet in het brondocument. Bronhouder: IMMetingen neemt bij organisaties een legalidentitynr op, nl het RSIN. Kvknr kan worden toegevoegd door of defintie van dit veld op 
    te rekken of een veld toe te voegen. Bij laboratorium als veld. Er is een organisatatie codelijst voor laboratoria (bij aquo-lex is dat wellicht beschikbaar incl kvk). 
    NIEUW
    - Geen mapping voor grondwatermonitoringnet.
   -->
    
    <xsl:output method="xml" indent="yes"/>
    
    <xsl:template match="sikb:FeatureCollectionIMSIKB0101">
        <gar:registrationRequest>
            <brocom:requestReference>[todo-mapping?]</brocom:requestReference>
            <!-- [to mapping. IMMetingen neemt bij organisaties een legalidentitynr op, nl het RSIN. Kvknr kan worden toegevoegd door of defintie van dit veld op 
    te rekken of een veld toe te voegen. Met het imskib0101:sender veld moet dus nog iets gebeuren. -->
            <brocom:deliveryAccountableParty><xsl:value-of select="sikb:metaData/sikb:sender"/></brocom:deliveryAccountableParty>
            <!-- assumption is that quality regime is always IMBRO (we are converting current data, not old data from some archive -->
            <brocom:qualityRegime>IMBRO</brocom:qualityRegime>
            <gar:sourceDocument>
                <xsl:apply-templates select="sikb:featureMember/sikb:Sample"/>
            </gar:sourceDocument>
        </gar:registrationRequest>
    </xsl:template>
            
    <xsl:template match="sikb:Sample">
        <gar:GAR>
            <xsl:apply-templates select="@gml:id"/>
            <gar:objectIdAccountableParty><xsl:value-of select="imm:identification/imm:NEN3610ID/imm:lokaalID"/></gar:objectIdAccountableParty>
            <gar:qualityControlMethod codeSpace="urn:bro:gar:QualityControlMethod">[todo: not in sikb sample file]<xsl:value-of select="sikb:correctnessJudgmentMethod"/></gar:qualityControlMethod>
            <!-- 1 or more repetitions: -->
            <gar:groundwaterMonitoringNet>[todo no mapping yet]</gar:groundwaterMonitoringNet>
            <monitoringPoint>
                <!-- finding the filter -->
                <xsl:for-each select="sam:relatedSamplingFeature/sam:SamplingFeatureComplex/sam:relatedSamplingFeature">
                    <xsl:apply-templates select="//sikb:Filter[@gml:id=substring-after(current()/@xlink:href, '#')]"/>
                </xsl:for-each>
            </monitoringPoint>
            <fieldResearch>
                <garcom:samplingDateTime><xsl:value-of select="imm:startTime"/></garcom:samplingDateTime>
                <!-- Optional: -->
                <garcom:samplingOperator>
                    <brocom:chamberOfCommerceNumber>[todo samplingOperator mapping, value of <xsl:value-of select="spec:processingDetails/imm:FieldSamplePreparationStep/spec:processOperator/local-name()"/>?]</brocom:chamberOfCommerceNumber>
                </garcom:samplingOperator>
                <garcom:samplingStandard codeSpace="urn:bro:gar:SamplingStandard">[todo not in sample file]</garcom:samplingStandard>
                <garcom:samplingDevice>
                    <garcom:pumpType codeSpace="urn:bro:gar:PumpType">[todo not in sample file]</garcom:pumpType>
                </garcom:samplingDevice>
                <!-- hier gebleven. -->
                <garcom:fieldObservation>
                    <!-- Optional -->
                    <garcom:primaryColour codeSpace="urn:bro:gar:Colour">wit</garcom:primaryColour>
                    <!-- Optional -->
                    <garcom:secondaryColour codeSpace="urn:bro:gar:Colour">grijs</garcom:secondaryColour>
                    <!-- Optional -->
                    <garcom:colourStrength codeSpace="urn:bro:gar:ColourStrength">licht</garcom:colourStrength>
                    <garcom:abnormalityInCooling>ja</garcom:abnormalityInCooling>
                    <garcom:abnormalityInDevice>nee</garcom:abnormalityInDevice>
                    <garcom:pollutedByEngine>onbekend</garcom:pollutedByEngine>
                    <garcom:filterAerated>ja</garcom:filterAerated>
                    <garcom:groundWaterLevelDroppedTooMuch>nee</garcom:groundWaterLevelDroppedTooMuch>
                    <garcom:abnormalFilter>onbekend</garcom:abnormalFilter>
                    <garcom:sampleAerated>ja</garcom:sampleAerated>
                    <garcom:hoseReused>nee</garcom:hoseReused>
                    <garcom:temperatureDifficultToMeasure>onbekend</garcom:temperatureDifficultToMeasure>
                </garcom:fieldObservation>
                <!-- 0 or more repetitions: -->
                <garcom:fieldMeasurement>
                    <garcom:parameter>1496</garcom:parameter>
                    <garcom:fieldMeasurementValue uom="mg/l">5.123</garcom:fieldMeasurementValue>
                    <garcom:qualityControlStatus codeSpace="urn:bro:gar:QualityControlStatus">goedgekeurd</garcom:qualityControlStatus>
                </garcom:fieldMeasurement>
                <garcom:fieldMeasurement>
                    <garcom:parameter>6024</garcom:parameter>
                    <garcom:fieldMeasurementValue uom="10^-3">3</garcom:fieldMeasurementValue>
                    <garcom:qualityControlStatus codeSpace="urn:bro:gar:QualityControlStatus">afgekeurd</garcom:qualityControlStatus>
                </garcom:fieldMeasurement>
                <garcom:fieldMeasurement>
                    <garcom:parameter>3548</garcom:parameter>
                    <garcom:fieldMeasurementValue uom="uS/cm">15.123</garcom:fieldMeasurementValue>
                    <garcom:qualityControlStatus codeSpace="urn:bro:gar:QualityControlStatus">onbekend</garcom:qualityControlStatus>
                </garcom:fieldMeasurement>
            </fieldResearch>
        </gar:GAR>
    </xsl:template>
    
    <xsl:template match="sikb:Filter">
        <garcom:GroundwaterMonitoringTube>
            <xsl:apply-templates select="@gml:id"/>
            <garcom:broId>[todo get BRO GMW ID based on??]</garcom:broId>
            <garcom:tubeNumber>[todo get BRO GMW tube number based on??]</garcom:tubeNumber>
        </garcom:GroundwaterMonitoringTube>
    </xsl:template>
    
    <xsl:template match="@gml:id">
        <xsl:copy-of select="."/>        
    </xsl:template>
</xsl:stylesheet>